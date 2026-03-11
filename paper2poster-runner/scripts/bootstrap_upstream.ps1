param(
  [switch]$Force,
  [ValidateSet("Auto", "Native", "Docker", "Api")]
  [string]$Method = "Auto",
  [int]$TimeoutSeconds = 1800,
  [int]$Retries = 5,
  [int]$RetryDelaySeconds = 5
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$repoDir = Join-Path $root "Paper2Poster"
$tempDir = Join-Path $root "Paper2Poster-main"
$tempZip = Join-Path $root "Paper2Poster-main.zip"
$downloadUrl = "https://codeload.github.com/Paper2Poster/Paper2Poster/zip/refs/heads/main"
$treeApiUrl = "https://api.github.com/repos/Paper2Poster/Paper2Poster/git/trees/main?recursive=1"
$blobApiBaseUrl = "https://api.github.com/repos/Paper2Poster/Paper2Poster/git/blobs"
$rawBaseUrl = "https://raw.githubusercontent.com/Paper2Poster/Paper2Poster/main"
$dockerConfigDir = Join-Path $root ".docker-config"
$apiIncludeDirs = @("PosterAgent", "utils", "camel", "config", "docling")

if (-not (Test-Path $dockerConfigDir)) {
  New-Item -ItemType Directory -Path $dockerConfigDir -Force | Out-Null
}

$env:DOCKER_CONFIG = $dockerConfigDir

function Test-ZipArchive {
  param(
    [string]$ZipPath
  )

  if (-not (Test-Path $ZipPath)) {
    return $false
  }

  try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    $zip.Dispose()
    return $true
  }
  catch {
    return $false
  }
}

function Remove-TempArtifacts {
  if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
  }

  if (Test-Path $tempZip) {
    Remove-Item -Path $tempZip -Force
  }
}

function Get-EncodedRawUrl {
  param(
    [string]$RelativePath
  )

  $segments = $RelativePath -split '/'
  $encodedPath = ($segments | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
  return "$rawBaseUrl/$encodedPath"
}

function Invoke-CurlProcess {
  param(
    [string[]]$Arguments,
    [string]$FailureContext
  )

  $process = Start-Process -FilePath 'curl.exe' -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
  if ($process.ExitCode -ne 0) {
    throw "curl failed for $FailureContext (exit code $($process.ExitCode))"
  }
}

function Download-FileWithCurl {
  param(
    [string]$SourceUrl,
    [string]$DestinationPath
  )

  $destinationDir = Split-Path -Parent $DestinationPath
  if ($destinationDir -and -not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
  }

  $arguments = @(
    '--silent',
    '--show-error',
    '--fail',
    '--location',
    '--retry', "$Retries",
    '--retry-all-errors',
    '--retry-delay', "$RetryDelaySeconds",
    '--connect-timeout', '30',
    '--max-time', "$TimeoutSeconds",
    $SourceUrl,
    '--output', $DestinationPath
  )

  Invoke-CurlProcess -Arguments $arguments -FailureContext $SourceUrl
}

function Invoke-CurlJson {
  param(
    [string]$SourceUrl,
    [string]$FailureContext,
    [hashtable]$Headers = @{}
  )

  for ($attempt = 1; $attempt -le ($Retries + 1); $attempt++) {
    try {
      return Invoke-RestMethod -Uri $SourceUrl -Headers $Headers -TimeoutSec $TimeoutSeconds
    }
    catch {
      if ($attempt -gt $Retries) {
        throw "Request failed for $FailureContext after $Retries retries: $($_.Exception.Message)"
      }

      Start-Sleep -Seconds ($RetryDelaySeconds * $attempt)
    }
  }
}

function Download-FileViaGitHubBlobApi {
  param(
    [string]$BlobSha,
    [string]$DestinationPath
  )

  if (-not $BlobSha) {
    throw "Blob SHA is missing."
  }

  $destinationDir = Split-Path -Parent $DestinationPath
  if ($destinationDir -and -not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
  }

  $blobUrl = "$blobApiBaseUrl/$BlobSha"
  $blob = Invoke-CurlJson `
    -SourceUrl $blobUrl `
    -FailureContext $blobUrl `
    -Headers @{
      Accept = 'application/vnd.github+json'
      'X-GitHub-Api-Version' = '2022-11-28'
    }

  if ($blob.encoding -ne 'base64') {
    throw "Unsupported blob encoding '$($blob.encoding)'."
  }

  $blobContent = ($blob.content -replace '\s', '')
  $bytes = [System.Convert]::FromBase64String($blobContent)
  [System.IO.File]::WriteAllBytes($DestinationPath, $bytes)
}

function Download-Native {
  if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
    Write-Host "Downloading upstream Paper2Poster zip with native curl..."
    $arguments = @(
      '--silent',
      '--show-error',
      '--fail',
      '--location',
      '--continue-at', '-',
      '--retry', "$Retries",
      '--retry-all-errors',
      '--retry-delay', "$RetryDelaySeconds",
      '--connect-timeout', '30',
      '--max-time', "$TimeoutSeconds",
      $downloadUrl,
      '--output', $tempZip
    )

    Invoke-CurlProcess -Arguments $arguments -FailureContext $downloadUrl
    return
  }

  Write-Host "Downloading upstream Paper2Poster zip with Invoke-WebRequest..."
  Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -TimeoutSec $TimeoutSeconds
}

function Download-WithDocker {
  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not available on PATH for Docker-based upstream download."
  }

  $containerName = "paper2poster-bootstrap-temp"

  cmd /c "docker rm -f $containerName >nul 2>nul"
  Write-Host "Downloading upstream Paper2Poster zip with Docker..."
  & docker create --name $containerName curlimages/curl:8.12.1 `
    --fail `
    --location `
    --continue-at - `
    --retry $Retries `
    --retry-all-errors `
    --retry-delay $RetryDelaySeconds `
    --connect-timeout 30 `
    --max-time $TimeoutSeconds `
    $downloadUrl `
    -o /tmp/Paper2Poster-main.zip *> $null

  if ($LASTEXITCODE -ne 0) {
    cmd /c "docker rm -f $containerName >nul 2>nul"
    throw "Docker-based upstream container creation failed."
  }

  & docker start -a $containerName
  if ($LASTEXITCODE -ne 0) {
    cmd /c "docker rm -f $containerName >nul 2>nul"
    throw "Docker-based upstream download failed."
  }

  & docker cp "${containerName}:/tmp/Paper2Poster-main.zip" $tempZip
  if ($LASTEXITCODE -ne 0) {
    cmd /c "docker rm -f $containerName >nul 2>nul"
    throw "Docker downloaded the archive but docker cp failed."
  }

  cmd /c "docker rm -f $containerName >nul 2>nul"
}

function Download-WithGitHubApi {
  Write-Host "Downloading upstream Paper2Poster source via GitHub API..."

  if (-not (Test-Path $repoDir)) {
    New-Item -ItemType Directory -Path $repoDir -Force | Out-Null
  }

  $tree = Invoke-CurlJson `
    -SourceUrl $treeApiUrl `
    -FailureContext $treeApiUrl `
    -Headers @{
      Accept = 'application/vnd.github+json'
      'X-GitHub-Api-Version' = '2022-11-28'
    }
  $files = @(
    $tree.tree | Where-Object {
      $_.type -eq 'blob' -and
      $_.path -notmatch '(^|/)__pycache__(/|$)' -and
      $_.path -notmatch '\.pyc$' -and
      (
        $_.path -notmatch '/' -or
        ($apiIncludeDirs -contains (($_.path -split '/')[0]))
      )
    }
  )

  if ($files.Count -eq 0) {
    throw "GitHub API returned no files for the filtered upstream subset."
  }

  $processed = 0
  $downloaded = 0
  $skipped = 0

  foreach ($file in $files) {
    $destinationPath = Join-Path $repoDir $file.path

    if (Test-Path $destinationPath) {
      $processed++
      $skipped++
      if (($processed % 25) -eq 0 -or $processed -eq $files.Count) {
        Write-Host "Processed $processed / $($files.Count) files (downloaded $downloaded, skipped $skipped)..."
      }
      continue
    }

    $sourceUrl = Get-EncodedRawUrl -RelativePath $file.path

    try {
      Download-FileWithCurl -SourceUrl $sourceUrl -DestinationPath $destinationPath
    }
    catch {
      $rawErrorMessage = $_.Exception.Message
      Write-Warning "Raw download failed for '$($file.path)'. Retrying via GitHub blob API..."

      try {
        Download-FileViaGitHubBlobApi -BlobSha $file.sha -DestinationPath $destinationPath
      }
      catch {
        throw "Failed while downloading '$($file.path)': raw download error: $rawErrorMessage; blob API error: $($_.Exception.Message)"
      }
    }

    $processed++
    $downloaded++

    if (($processed % 25) -eq 0 -or $processed -eq $files.Count) {
      Write-Host "Processed $processed / $($files.Count) files (downloaded $downloaded, skipped $skipped)..."
    }
  }

  New-Item -ItemType Directory -Path (Join-Path $repoDir 'logo_store\institutes') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $repoDir 'logo_store\conferences') -Force | Out-Null
}

$repoAlreadyExists = Test-Path (Join-Path $repoDir 'README.md')
if ($repoAlreadyExists -and -not $Force -and $Method -ne 'Api') {
  Write-Host "Paper2Poster already exists at $repoDir"
  exit 0
}

if ((Test-Path $repoDir) -and ($Force -or $Method -ne 'Api')) {
  Remove-Item -Path $repoDir -Recurse -Force
}

Remove-TempArtifacts

try {
  switch ($Method) {
    "Native" {
      Download-Native
    }
    "Docker" {
      Download-WithDocker
    }
    "Api" {
      Download-WithGitHubApi
    }
    default {
      try {
        Download-Native
      }
      catch {
        Write-Warning "Native download failed. Falling back to GitHub API bootstrap."
        Remove-TempArtifacts
        Download-WithGitHubApi
      }
    }
  }
}
catch {
  Remove-TempArtifacts
  if ((Test-Path $repoDir) -and -not (Test-Path (Join-Path $repoDir 'README.md'))) {
    Remove-Item -Path $repoDir -Recurse -Force
  }
  throw
}

if ($Method -eq 'Api') {
  Write-Host "Upstream Paper2Poster subset is ready at $repoDir"
  exit 0
}

if ($Method -eq 'Auto' -and (Test-Path (Join-Path $repoDir 'README.md'))) {
  Write-Host "Upstream Paper2Poster subset is ready at $repoDir"
  exit 0
}

if (-not (Test-ZipArchive -ZipPath $tempZip)) {
  Remove-TempArtifacts
  throw "Downloaded upstream zip is missing or invalid."
}

Write-Host "Extracting archive..."
Expand-Archive -Path $tempZip -DestinationPath $root -Force

if (-not (Test-Path $tempDir)) {
  Remove-TempArtifacts
  throw "Archive extracted but the expected Paper2Poster-main directory was not found."
}

Rename-Item -Path $tempDir -NewName "Paper2Poster"
Remove-Item -Path $tempZip -Force

Write-Host "Upstream Paper2Poster is ready at $repoDir"
