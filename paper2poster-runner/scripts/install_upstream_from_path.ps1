param(
  [Parameter(Mandatory = $true)]
  [string]$SourcePath,
  [switch]$Force
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$repoDir = Join-Path $root "Paper2Poster"
$sourceResolved = (Resolve-Path $SourcePath).Path

$requiredPaths = @(
  "README.md",
  "requirements.txt",
  "Dockerfile",
  "PosterAgent"
)

foreach ($relativePath in $requiredPaths) {
  $candidate = Join-Path $sourceResolved $relativePath
  if (-not (Test-Path $candidate)) {
    throw "Source path is missing required upstream item: $relativePath"
  }
}

if (Test-Path $repoDir) {
  if (-not $Force) {
    throw "Target upstream directory already exists at $repoDir. Use -Force to replace it."
  }

  Remove-Item -Path $repoDir -Recurse -Force
}

Write-Host "Copying upstream from $sourceResolved to $repoDir"
Copy-Item -Path $sourceResolved -Destination $repoDir -Recurse

Write-Host "Installed upstream Paper2Poster to $repoDir"

