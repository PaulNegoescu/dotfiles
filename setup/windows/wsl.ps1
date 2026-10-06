#Requires -Version 5.1

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$Distribution = 'Ubuntu-26.04'

if ($DryRun) {
  Write-Host '[dry-run] wsl.exe --update'
  Write-Host '[dry-run] wsl.exe --set-default-version 2'
  Write-Host "[dry-run] wsl.exe --install --distribution $Distribution --no-launch"
  Write-Host "[dry-run] wsl.exe --set-default $Distribution"
  return
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  throw 'wsl.exe is unavailable on this Windows installation.'
}

& wsl.exe --update
if ($LASTEXITCODE -ne 0) {
  Write-Warning 'WSL could not update itself. Continuing with the installed version.'
}

& wsl.exe --set-default-version 2
if ($LASTEXITCODE -ne 0) {
  throw 'WSL could not make version 2 the default.'
}

$installed = @(& wsl.exe --list --quiet 2>$null) -replace "`0", ''
if ($installed -contains $Distribution) {
  Write-Host "$Distribution is already installed."
  & wsl.exe --set-default $Distribution
  return
}

$available = @(& wsl.exe --list --online 2>$null) -replace "`0", ''
if (-not ($available -match [regex]::Escape($Distribution))) {
  throw "$Distribution is not listed by WSL on this machine. Run 'wsl --list --online' and install the current Ubuntu LTS explicitly."
}

& wsl.exe --install --distribution $Distribution --no-launch
if ($LASTEXITCODE -ne 0) {
  throw 'WSL installation failed.'
}

& wsl.exe --set-default $Distribution
if ($LASTEXITCODE -ne 0) {
  Write-Warning "The distribution was installed, but WSL could not make $Distribution the default yet."
}

Write-Host "$Distribution was requested successfully." -ForegroundColor Green
Write-Host 'Windows may require a restart. After restarting, launch Ubuntu once to create your Linux user, then rerun setup.ps1.'
