function Get-TrackedFileInfo {
  param(
    [string]$Path
  )

  $info = [ordered]@{
    path = $Path
    exists = $false
    sha256 = $null
    size_bytes = $null
  }

  if (Test-Path $Path -PathType Leaf) {
    $item = Get-Item -Path $Path
    $info.exists = $true
    $info.sha256 = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    $info.size_bytes = $item.Length
  }

  return [pscustomobject]$info
}

function Get-NextVersionId {
  param(
    [string]$PaperVersionsDir
  )

  $max = 0

  if (Test-Path $PaperVersionsDir) {
    $dirs = Get-ChildItem -Path $PaperVersionsDir -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $dirs) {
      if ($dir.Name -match '^v(\d{3})$') {
        $num = [int]$Matches[1]
        if ($num -gt $max) {
          $max = $num
        }
      }
    }
  }

  return ("v{0:D3}" -f ($max + 1))
}

function New-VersionContext {
  param(
    [string]$RunnerRoot,
    [string]$PaperFolder,
    [string]$Engine,
    [string]$TextModel,
    [string]$VisionModel,
    [int]$PosterWidthInches,
    [int]$PosterHeightInches,
    [string]$ConferenceVenue = "",
    [bool]$NoBlankDetection = $false,
    [string]$VersionLabel = ""
  )

  $versionsRoot = Join-Path $RunnerRoot "versions"
  $paperVersionsDir = Join-Path $versionsRoot $PaperFolder

  if (-not (Test-Path $paperVersionsDir)) {
    New-Item -ItemType Directory -Path $paperVersionsDir -Force | Out-Null
  }

  $versionId = Get-NextVersionId -PaperVersionsDir $paperVersionsDir
  $versionDir = Join-Path $paperVersionsDir $versionId
  $outputDir = Join-Path $versionDir "output"
  $artifactsDir = Join-Path $versionDir "artifacts"

  New-Item -ItemType Directory -Path $versionDir -Force | Out-Null
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
  New-Item -ItemType Directory -Path $artifactsDir -Force | Out-Null

  $paperDir = Join-Path $RunnerRoot "Paper2Poster-data\$PaperFolder"
  $paperPdf = Join-Path $paperDir "paper.pdf"
  $posterYaml = Join-Path $paperDir "poster.yaml"
  $startedAt = Get-Date -Format o
  $commandPath = Join-Path $versionDir "command.txt"
  $notesPath = Join-Path $versionDir "notes.md"
  $manifestPath = Join-Path $versionDir "manifest.json"
  $logPath = Join-Path $artifactsDir "run.log"

  Set-Content -Path $commandPath -Value "Pending command assembly." -Encoding UTF8
  Set-Content -Path $logPath -Value "" -Encoding UTF8

  return [pscustomobject]@{
    RunnerRoot = $RunnerRoot
    PaperFolder = $PaperFolder
    PaperDir = $paperDir
    PaperPdf = $paperPdf
    PosterYaml = $posterYaml
    Engine = $Engine
    TextModel = $TextModel
    VisionModel = $VisionModel
    ModelTag = "${TextModel}_${VisionModel}"
    PosterWidthInches = $PosterWidthInches
    PosterHeightInches = $PosterHeightInches
    ConferenceVenue = $ConferenceVenue
    NoBlankDetection = $NoBlankDetection
    VersionId = $versionId
    VersionLabel = $VersionLabel
    VersionDir = $versionDir
    OutputDir = $outputDir
    ArtifactsDir = $artifactsDir
    ManifestPath = $manifestPath
    NotesPath = $notesPath
    CommandPath = $commandPath
    LogPath = $logPath
    StartedAt = $startedAt
  }
}

function Save-VersionSnapshots {
  param(
    [pscustomobject]$Context
  )

  if (Test-Path $Context.PosterYaml -PathType Leaf) {
    Copy-Item -Path $Context.PosterYaml -Destination (Join-Path $Context.VersionDir "poster.yaml.snapshot") -Force
  }
}

function Write-VersionCommand {
  param(
    [pscustomobject]$Context,
    [string]$CommandText
  )

  Set-Content -Path $Context.CommandPath -Value $CommandText -Encoding UTF8
}

function Write-VersionManifest {
  param(
    [pscustomobject]$Context,
    [string]$Status,
    [string]$Stage = "",
    [string]$ErrorMessage = "",
    [string]$VersionOutputPptx = "",
    [string]$FinalOutputPptx = ""
  )

  $versionOutputInfo = $null
  $finalOutputInfo = $null

  if ($VersionOutputPptx) {
    $versionOutputInfo = Get-TrackedFileInfo -Path $VersionOutputPptx
  }

  if ($FinalOutputPptx) {
    $finalOutputInfo = Get-TrackedFileInfo -Path $FinalOutputPptx
  }

  $manifest = [ordered]@{
    version_id = $Context.VersionId
    version_label = $Context.VersionLabel
    paper_folder = $Context.PaperFolder
    engine = $Context.Engine
    text_model = $Context.TextModel
    vision_model = $Context.VisionModel
    model_tag = $Context.ModelTag
    poster_width_inches = $Context.PosterWidthInches
    poster_height_inches = $Context.PosterHeightInches
    conference_venue = $Context.ConferenceVenue
    no_blank_detection = $Context.NoBlankDetection
    status = $Status
    stage = $Stage
    started_at = $Context.StartedAt
    updated_at = (Get-Date -Format o)
    input = [ordered]@{
      paper_pdf = (Get-TrackedFileInfo -Path $Context.PaperPdf)
      poster_yaml = (Get-TrackedFileInfo -Path $Context.PosterYaml)
    }
    files = [ordered]@{
      manifest = $Context.ManifestPath
      notes = $Context.NotesPath
      command = $Context.CommandPath
      run_log = $Context.LogPath
      version_output_pptx = $versionOutputInfo
      final_output_pptx = $finalOutputInfo
    }
    error_message = $ErrorMessage
  }

  $manifest | ConvertTo-Json -Depth 8 | Set-Content -Path $Context.ManifestPath -Encoding UTF8
}

function Write-VersionNotes {
  param(
    [pscustomobject]$Context,
    [string]$Status,
    [string]$Stage = "",
    [string]$ErrorMessage = "",
    [string]$VersionOutputPptx = "",
    [string]$FinalOutputPptx = ""
  )

  $label = if ($Context.VersionLabel) { $Context.VersionLabel } else { "auto" }
  $lines = @(
    "# $($Context.VersionId)"
    ""
    "- status: $Status"
    "- stage: $Stage"
    "- label: $label"
    "- paper_folder: $($Context.PaperFolder)"
    "- engine: $($Context.Engine)"
    "- text_model: $($Context.TextModel)"
    "- vision_model: $($Context.VisionModel)"
    "- started_at: $($Context.StartedAt)"
    "- updated_at: $(Get-Date -Format o)"
    "- paper_pdf: $($Context.PaperPdf)"
    "- poster_yaml: $($Context.PosterYaml)"
    "- command_file: $($Context.CommandPath)"
    "- run_log: $($Context.LogPath)"
  )

  if ($VersionOutputPptx) {
    $lines += "- version_output_pptx: $VersionOutputPptx"
  }

  if ($FinalOutputPptx) {
    $lines += "- final_output_pptx: $FinalOutputPptx"
  }

  if ($ErrorMessage) {
    $lines += "- error: $ErrorMessage"
  }

  Set-Content -Path $Context.NotesPath -Value $lines -Encoding UTF8
}
