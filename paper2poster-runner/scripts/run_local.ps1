param(
  [string]$PaperFolder = "my_paper",
  [string]$TextModel = "4o",
  [string]$VisionModel = "4o",
  [int]$PosterWidthInches = 48,
  [int]$PosterHeightInches = 36,
  [string]$ConferenceVenue = "",
  [switch]$NoBlankDetection,
  [string]$VersionLabel = ""
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "versioning.ps1")

function Import-DotEnv {
  param([string]$EnvPath)

  foreach ($line in Get-Content -Path $EnvPath) {
    if (-not $line -or $line.Trim().StartsWith("#") -or $line -notmatch "=") {
      continue
    }

    $parts = $line.Split("=", 2)
    $name = $parts[0].Trim()
    $value = $parts[1].Trim()
    Set-Item -Path "Env:$name" -Value $value
  }
}

$root = Split-Path -Parent $PSScriptRoot
$repoDir = Join-Path $root "Paper2Poster"
$dataDir = (Resolve-Path (Join-Path $root "Paper2Poster-data")).Path
$outputsDir = Join-Path $root "outputs"
$envFile = Join-Path $root ".env"
$paperPdf = Join-Path $dataDir "$PaperFolder\paper.pdf"
$context = New-VersionContext `
  -RunnerRoot $root `
  -PaperFolder $PaperFolder `
  -Engine "local" `
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

try {
  if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "python is not available on PATH."
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

  if (-not (Get-Command soffice -ErrorAction SilentlyContinue)) {
    Write-Warning "soffice is not on PATH. Local export may fail until LibreOffice is installed."
  }

  if (-not (Get-Command pdftoppm -ErrorAction SilentlyContinue)) {
    Write-Warning "pdftoppm is not on PATH. Install poppler if local rendering fails."
  }

  Import-DotEnv -EnvPath $envFile
  if (-not $env:OPENAI_API_KEY) {
    throw "OPENAI_API_KEY not found in .env"
  }

  if (-not (Test-Path $outputsDir)) {
    New-Item -ItemType Directory -Path $outputsDir -Force | Out-Null
  }

  $env:PYTHONPATH = "$repoDir;$env:PYTHONPATH"

  Push-Location $repoDir
  $pushedLocation = $true
  $pythonArgs = @(
    "-m", "PosterAgent.new_pipeline",
    "--poster_path=$paperPdf",
    "--model_name_t=$TextModel",
    "--model_name_v=$VisionModel",
    "--poster_width_inches=$PosterWidthInches",
    "--poster_height_inches=$PosterHeightInches"
  )

  if ($NoBlankDetection) {
    $pythonArgs += "--no_blank_detection"
  }

  if ($ConferenceVenue) {
    $pythonArgs += "--conference_venue=$ConferenceVenue"
  }

  Write-VersionCommand -Context $context -CommandText ("python " + ($pythonArgs -join " "))
  Write-VersionManifest -Context $context -Status "running" -Stage "generation"
  Write-VersionNotes -Context $context -Status "running" -Stage "generation"

  Write-Host "Running local generation for paper folder '$PaperFolder'..."
  & python @pythonArgs *>&1 | Tee-Object -FilePath $context.LogPath -Append
  if ($LASTEXITCODE -ne 0) {
    throw "Local Paper2Poster generation failed."
  }

  $repoOutputDir = Join-Path $repoDir "$($context.ModelTag)_generated_posters\Paper2Poster-data\$PaperFolder"
  $wrapperOutputDir = Join-Path $outputsDir "Paper2Poster-data\$PaperFolder"

  if (Test-Path $repoOutputDir) {
    if (-not (Test-Path $wrapperOutputDir)) {
      New-Item -ItemType Directory -Path $wrapperOutputDir -Force | Out-Null
    }

    Copy-Item -Path (Join-Path $repoOutputDir "*") -Destination $wrapperOutputDir -Recurse -Force
  }

  $copyScript = Join-Path $PSScriptRoot "copy_final.ps1"
  $finalPptx = $null
  if (Test-Path $copyScript) {
    $finalPptx = (& $copyScript -PaperFolder $PaperFolder -ModelTag $context.ModelTag -VersionId $context.VersionId -VersionDir $context.VersionDir | Select-Object -Last 1)
  }

  $versionOutputPptx = Join-Path $context.OutputDir "poster.pptx"
  Write-VersionManifest -Context $context -Status "succeeded" -Stage "completed" -VersionOutputPptx $versionOutputPptx -FinalOutputPptx $finalPptx
  Write-VersionNotes -Context $context -Status "succeeded" -Stage "completed" -VersionOutputPptx $versionOutputPptx -FinalOutputPptx $finalPptx
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
}

Write-Host "Version recorded at $($context.VersionDir)"
Write-Host "Expected output folder: $outputsDir\Paper2Poster-data\$PaperFolder"
