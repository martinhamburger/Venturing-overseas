param(
  [string]$PaperFolder = "my_paper",
  [string]$TextModel = "4o",
  [string]$VisionModel = "4o",
  [int]$PosterWidthInches = 48,
  [int]$PosterHeightInches = 36,
  [string]$ConferenceVenue = "",
  [switch]$NoBlankDetection,
  [switch]$SkipBuild,
  [string]$VersionLabel = ""
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "versioning.ps1")

function Get-DotEnvValue {
  param(
    [string]$EnvPath,
    [string]$Key
  )

  $line = Get-Content -Path $EnvPath |
    Where-Object { $_ -match "^\s*$Key=" } |
    Select-Object -First 1

  if (-not $line) {
    return $null
  }

  return $line.Split("=", 2)[1].Trim()
}

function New-DockerStagingPaths {
  param(
    [string]$PaperFolder,
    [string]$VersionId
  )

  $stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) "paper2poster-runner"
  $runRoot = Join-Path $stagingRoot "$PaperFolder-$VersionId"
  $dataRoot = Join-Path $runRoot "Paper2Poster-data"
  $paperRoot = Join-Path $dataRoot $PaperFolder
  $outputsRoot = Join-Path $runRoot "outputs"

  New-Item -ItemType Directory -Path $paperRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $outputsRoot -Force | Out-Null

  return [pscustomobject]@{
    Root = $runRoot
    DataRoot = $dataRoot
    PaperRoot = $paperRoot
    OutputsRoot = $outputsRoot
  }
}

$root = Split-Path -Parent $PSScriptRoot
$repoDir = Join-Path $root "Paper2Poster"
$dataDir = (Resolve-Path (Join-Path $root "Paper2Poster-data")).Path
$outputsDir = Join-Path $root "outputs"
$envFile = Join-Path $root ".env"
$paperDir = Join-Path $dataDir $PaperFolder
$paperPdf = Join-Path $paperDir "paper.pdf"
$dockerConfigDir = Join-Path $root ".docker-config"
$context = New-VersionContext `
  -RunnerRoot $root `
  -PaperFolder $PaperFolder `
  -Engine "docker" `
  -TextModel $TextModel `
  -VisionModel $VisionModel `
  -PosterWidthInches $PosterWidthInches `
  -PosterHeightInches $PosterHeightInches `
  -ConferenceVenue $ConferenceVenue `
  -NoBlankDetection $NoBlankDetection.IsPresent `
  -VersionLabel $VersionLabel

Save-VersionSnapshots -Context $context
Write-VersionManifest -Context $context -Status "running" -Stage "preflight"
Write-VersionNotes -Context $context -Status "running" -Stage "preflight"

$pushedLocation = $false
$staging = $null
$runSucceeded = $false

try {
  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed or not on PATH. Install Docker Desktop first, then rerun this script."
  }

  if (-not (Test-Path (Join-Path $repoDir "README.md"))) {
    throw "Upstream Paper2Poster is missing. Run ./scripts/bootstrap_upstream.ps1 first."
  }

  if (-not (Test-Path $envFile)) {
    throw ".env not found at $envFile. Copy .env.example to .env and add OPENAI_API_KEY."
  }

  if (-not (Test-Path $paperPdf)) {
    throw "Input paper not found at $paperPdf"
  }

  if (-not (Test-Path $dockerConfigDir)) {
    New-Item -ItemType Directory -Path $dockerConfigDir -Force | Out-Null
  }
  $env:DOCKER_CONFIG = $dockerConfigDir

  $openaiKey = Get-DotEnvValue -EnvPath $envFile -Key "OPENAI_API_KEY"
  if (-not $openaiKey) {
    throw "OPENAI_API_KEY not found in .env"
  }

  $googleKey = Get-DotEnvValue -EnvPath $envFile -Key "GOOGLE_SEARCH_API_KEY"
  $googleEngineId = Get-DotEnvValue -EnvPath $envFile -Key "GOOGLE_SEARCH_ENGINE_ID"

  if (-not (Test-Path $outputsDir)) {
    New-Item -ItemType Directory -Path $outputsDir -Force | Out-Null
  }

  $staging = New-DockerStagingPaths -PaperFolder $PaperFolder -VersionId $context.VersionId
  Copy-Item -Path (Join-Path $paperDir "*") -Destination $staging.PaperRoot -Recurse -Force

  $volumeData = "$($staging.DataRoot):/Paper2Poster-data"
  $volumeOutputs = "$($staging.OutputsRoot):/app/$($context.ModelTag)_generated_posters"

  Push-Location $repoDir
  $pushedLocation = $true
  if (-not $SkipBuild) {
    Write-Host "Building Docker image..."
    & docker build -t paper2poster . *>&1 | Tee-Object -FilePath $context.LogPath -Append
    if ($LASTEXITCODE -ne 0) {
      throw "docker build failed."
    }
  }

  $dockerArgs = @(
    "run",
    "--rm",
    "-e", "OPENAI_API_KEY=$openaiKey"
  )

  if ($googleKey) {
    $dockerArgs += @("-e", "GOOGLE_SEARCH_API_KEY=$googleKey")
  }

  if ($googleEngineId) {
    $dockerArgs += @("-e", "GOOGLE_SEARCH_ENGINE_ID=$googleEngineId")
  }

  $dockerArgs += @(
    "-v", $volumeData,
    "-v", $volumeOutputs,
    "paper2poster",
    "python", "-m", "PosterAgent.new_pipeline",
    "--poster_path=/Paper2Poster-data/$PaperFolder/paper.pdf",
    "--model_name_t=$TextModel",
    "--model_name_v=$VisionModel",
    "--poster_width_inches=$PosterWidthInches",
    "--poster_height_inches=$PosterHeightInches"
  )

  if ($NoBlankDetection) {
    $dockerArgs += "--no_blank_detection"
  }

  if ($ConferenceVenue) {
    $dockerArgs += "--conference_venue=$ConferenceVenue"
  }

  Write-VersionCommand -Context $context -CommandText ("docker " + ($dockerArgs -join " "))
  Write-VersionManifest -Context $context -Status "running" -Stage "generation"
  Write-VersionNotes -Context $context -Status "running" -Stage "generation"

  Write-Host "Running Docker generation for paper folder '$PaperFolder'..."
  & docker @dockerArgs *>&1 | Tee-Object -FilePath $context.LogPath -Append
  if ($LASTEXITCODE -ne 0) {
    throw "docker run failed."
  }

  $stagedOutputItems = Get-ChildItem -Path $staging.OutputsRoot -Force -ErrorAction SilentlyContinue
  if ($stagedOutputItems) {
    Copy-Item -Path (Join-Path $staging.OutputsRoot "*") -Destination $outputsDir -Recurse -Force
  }

  $copyScript = Join-Path $PSScriptRoot "copy_final.ps1"
  $finalPptx = $null
  if (Test-Path $copyScript) {
    $finalPptx = (& $copyScript -PaperFolder $PaperFolder -ModelTag $context.ModelTag -SearchRoot $staging.OutputsRoot -VersionId $context.VersionId -VersionDir $context.VersionDir | Select-Object -Last 1)
  }

  $versionOutputPptx = Join-Path $context.OutputDir "poster.pptx"
  Write-VersionManifest -Context $context -Status "succeeded" -Stage "completed" -VersionOutputPptx $versionOutputPptx -FinalOutputPptx $finalPptx
  Write-VersionNotes -Context $context -Status "succeeded" -Stage "completed" -VersionOutputPptx $versionOutputPptx -FinalOutputPptx $finalPptx
  $runSucceeded = $true
}
catch {
  $message = $_.Exception.Message
  Write-VersionManifest -Context $context -Status "failed" -Stage "error" -ErrorMessage $message
  Write-VersionNotes -Context $context -Status "failed" -Stage "error" -ErrorMessage $message
  throw
}
finally {
  if ($pushedLocation) {
    Pop-Location
  }

  if ($staging -and $runSucceeded -and (Test-Path $staging.Root)) {
    Remove-Item -Path $staging.Root -Recurse -Force
  }
}

Write-Host "Version recorded at $($context.VersionDir)"
Write-Host "Expected output folder: $outputsDir\Paper2Poster-data\$PaperFolder"
