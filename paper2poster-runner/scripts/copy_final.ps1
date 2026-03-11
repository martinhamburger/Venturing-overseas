param(
  [string]$PaperFolder = "my_paper",
  [string]$ModelTag = "4o_4o",
  [string]$SearchRoot = "",
  [string]$VersionId = "",
  [string]$VersionDir = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
if (-not $SearchRoot) {
  $SearchRoot = Join-Path $root "outputs"
}

$candidatePaths = @(
  (Join-Path $SearchRoot "Paper2Poster-data\$PaperFolder\poster.pptx"),
  (Join-Path $SearchRoot "$PaperFolder\poster.pptx")
)

$source = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $source) {
  $found = Get-ChildItem -Path $SearchRoot -Recurse -Filter "poster.pptx" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match [regex]::Escape($PaperFolder) } |
    Select-Object -First 1

  if ($found) {
    $source = $found.FullName
  }
}

if (-not $source) {
  throw "poster.pptx not found under $SearchRoot for paper folder '$PaperFolder'."
}

$finalDir = Join-Path $root "outputs\final"
if (-not (Test-Path $finalDir)) {
  New-Item -ItemType Directory -Path $finalDir -Force | Out-Null
}

$versionedName =
  if ($VersionId) {
    "$PaperFolder-$VersionId-$ModelTag.pptx"
  }
  else {
    "$PaperFolder-$ModelTag.pptx"
  }

$destination = Join-Path $finalDir $versionedName
$latestDestination = Join-Path $finalDir "$PaperFolder-latest.pptx"

Copy-Item -Path $source -Destination $destination -Force
Copy-Item -Path $source -Destination $latestDestination -Force

if ($VersionDir) {
  $versionOutputDir = Join-Path $VersionDir "output"
  if (-not (Test-Path $versionOutputDir)) {
    New-Item -ItemType Directory -Path $versionOutputDir -Force | Out-Null
  }

  $versionOutput = Join-Path $versionOutputDir "poster.pptx"
  Copy-Item -Path $source -Destination $versionOutput -Force
}

Write-Host "Copied versioned PPTX to $destination"
Write-Host "Updated latest PPTX at $latestDestination"
Write-Output $destination
