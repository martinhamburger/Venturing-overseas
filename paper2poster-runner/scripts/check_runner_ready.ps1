param(
  [string]$PaperFolder = "my_paper"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$repoDir = Join-Path $root "Paper2Poster"
$envFile = Join-Path $root ".env"
$paperDir = Join-Path $root "Paper2Poster-data\$PaperFolder"
$paperPdf = Join-Path $paperDir "paper.pdf"
$posterYaml = Join-Path $paperDir "poster.yaml"
$versionsDir = Join-Path $root "versions\$PaperFolder"

$requiredUpstream = @(
  "README.md",
  "requirements.txt",
  "Dockerfile",
  "PosterAgent"
)

function Get-DotEnvValue {
  param(
    [string]$EnvPath,
    [string]$Key
  )

  if (-not (Test-Path $EnvPath)) {
    return $null
  }

  $line = Get-Content -Path $EnvPath |
    Where-Object { $_ -match "^\s*$Key=" } |
    Select-Object -First 1

  if (-not $line) {
    return $null
  }

  return $line.Split("=", 2)[1].Trim()
}

$dockerAvailable = [bool](Get-Command docker -ErrorAction SilentlyContinue)
$envExists = Test-Path $envFile
$openAiKey = if ($envExists) { Get-DotEnvValue -EnvPath $envFile -Key "OPENAI_API_KEY" } else { $null }
$openAiKeyReady = -not [string]::IsNullOrWhiteSpace($openAiKey) -and $openAiKey -ne "your_openai_api_key"
$upstreamReady = $true
foreach ($item in $requiredUpstream) {
  if (-not (Test-Path (Join-Path $repoDir $item))) {
    $upstreamReady = $false
    break
  }
}

$versionCount = 0
if (Test-Path $versionsDir) {
  $versionCount = @(Get-ChildItem -Path $versionsDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^v\d{3}$' }).Count
}

$rows = @(
  [pscustomobject]@{ item = "docker_on_path"; required = $true; status = $dockerAvailable; detail = if ($dockerAvailable) { "docker command is available." } else { "Install Docker Desktop or add docker to PATH." } },
  [pscustomobject]@{ item = "upstream_repo"; required = $true; status = $upstreamReady; detail = if ($upstreamReady) { "Paper2Poster source is present." } else { "Run ./scripts/bootstrap_upstream.ps1 or install_upstream_from_path.ps1." } },
  [pscustomobject]@{ item = "env_file"; required = $true; status = $envExists; detail = if ($envExists) { ".env exists." } else { "Copy .env.example to .env and fill OPENAI_API_KEY." } },
  [pscustomobject]@{ item = "openai_api_key"; required = $true; status = $openAiKeyReady; detail = if ($openAiKeyReady) { "OPENAI_API_KEY looks configured." } else { "Set a real OPENAI_API_KEY value in .env." } },
  [pscustomobject]@{ item = "paper_pdf"; required = $true; status = (Test-Path $paperPdf); detail = if (Test-Path $paperPdf) { "Input paper found." } else { "Place paper.pdf under Paper2Poster-data/$PaperFolder/." } },
  [pscustomobject]@{ item = "poster_yaml"; required = $false; status = (Test-Path $posterYaml); detail = if (Test-Path $posterYaml) { "Per-paper poster.yaml exists." } else { "Optional. Add poster.yaml if you want per-paper style overrides." } },
  [pscustomobject]@{ item = "version_history"; required = $false; status = $true; detail = "$versionCount recorded version(s) under versions/$PaperFolder/." }
)

$rows | Format-Table -AutoSize

$blocking = @($rows | Where-Object { $_.required -and -not $_.status })
if ($blocking.Count -gt 0) {
  Write-Host ""
  Write-Host "Runner is not ready yet. Blocking items:" -ForegroundColor Yellow
  $blocking | ForEach-Object { Write-Host "- $($_.item): $($_.detail)" }
  exit 1
}

Write-Host ""
Write-Host "Runner is ready for the next Docker attempt." -ForegroundColor Green
