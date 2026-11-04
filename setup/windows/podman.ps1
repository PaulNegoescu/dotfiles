#Requires -Version 5.1

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'

$machineName = 'podman-machine-default'
if ($DryRun) {
  Write-Host "[dry-run] podman machine init $machineName (if missing)"
  Write-Host "[dry-run] podman machine start $machineName"
  Write-Host '[dry-run] podman info'
  return
}

if (-not (Get-Command podman.exe -ErrorAction SilentlyContinue)) {
  throw 'Podman is unavailable. Install the core Windows applications, restart the terminal, and retry.'
}

$machines = @(& podman.exe machine list --format json | ConvertFrom-Json)
$machine = $machines | Where-Object Name -eq $machineName

if (-not $machine) {
  & podman.exe machine init $machineName
  if ($LASTEXITCODE -ne 0) { throw 'Podman machine initialization failed.' }
}

& podman.exe machine start $machineName
if ($LASTEXITCODE -ne 0) {
  $refreshed = @(& podman.exe machine list --format json | ConvertFrom-Json) |
    Where-Object Name -eq $machineName
  if (-not $refreshed.Running) { throw 'Podman machine startup failed.' }
}

& podman.exe info | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Podman is installed but the engine is unavailable.' }

Write-Host 'Podman is running. The WSL setup connects its Podman client to this same engine.' -ForegroundColor Green
Write-Host 'Docker-compatible docker and docker compose commands are provided inside WSL.'
