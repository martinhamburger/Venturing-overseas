param(
  [string]$RepoPath = ""
)

$ErrorActionPreference = "Stop"

if (-not $RepoPath) {
  $root = Split-Path -Parent $PSScriptRoot
  $RepoPath = Join-Path $root "Paper2Poster"
}

$requiredPaths = @(
  "README.md",
  "requirements.txt",
  "Dockerfile",
  "PosterAgent"
)

$results = foreach ($relativePath in $requiredPaths) {
  $fullPath = Join-Path $RepoPath $relativePath
  [pscustomobject]@{
    path = $relativePath
    exists = (Test-Path $fullPath)
  }
}

$missing = $results | Where-Object { -not $_.exists }

Write-Host "Checking upstream at $RepoPath"
$results | Format-Table -AutoSize

if ($missing) {
  Write-Host ""
  Write-Host "Upstream is incomplete."
  exit 1
}

Write-Host ""
Write-Host "Upstream looks usable."

