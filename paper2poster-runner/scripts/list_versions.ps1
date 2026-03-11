param(
  [string]$PaperFolder = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$versionsRoot = Join-Path $root "versions"

if (-not (Test-Path $versionsRoot)) {
  Write-Host "No versions directory exists yet."
  exit 0
}

$paperDirs =
  if ($PaperFolder) {
    @(Get-Item -Path (Join-Path $versionsRoot $PaperFolder) -ErrorAction SilentlyContinue)
  }
  else {
    Get-ChildItem -Path $versionsRoot -Directory -ErrorAction SilentlyContinue
  }

$rows = @()
foreach ($paperDir in $paperDirs) {
  if (-not $paperDir) {
    continue
  }

  $versionDirs = Get-ChildItem -Path $paperDir.FullName -Directory -ErrorAction SilentlyContinue |
    Sort-Object Name

  foreach ($versionDir in $versionDirs) {
    $manifestPath = Join-Path $versionDir.FullName "manifest.json"
    if (-not (Test-Path $manifestPath)) {
      continue
    }

    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $rows += [pscustomobject]@{
      paper_folder = $manifest.paper_folder
      version_id = $manifest.version_id
      status = $manifest.status
      engine = $manifest.engine
      model_tag = $manifest.model_tag
      updated_at = $manifest.updated_at
      notes = (Join-Path $versionDir.FullName "notes.md")
    }
  }
}

if (-not $rows) {
  Write-Host "No version manifests found yet."
  exit 0
}

$rows | Format-Table -AutoSize

