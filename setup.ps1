#Requires -Version 5.1

[CmdletBinding()]
param(
  [switch]$Yes,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$DotfilesDir = $PSScriptRoot

function Write-Heading {
  param([Parameter(Mandatory)][string]$Text)
  Write-Host "`n==> $Text`n" -ForegroundColor Cyan
}

function Confirm-Step {
  param([Parameter(Mandatory)][string]$Prompt)

  if ($Yes) {
    Write-Host "$Prompt [yes]"
    return $true
  }

  $answer = Read-Host "$Prompt [y/N]"
  return $answer -match '^(y|yes)$'
}

function Invoke-Step {
  param(
    [Parameter(Mandatory)][string]$Prompt,
    [Parameter(Mandatory)][string]$Heading,
    [Parameter(Mandatory)][scriptblock]$Action
  )

  if (Confirm-Step $Prompt) {
    Write-Heading $Heading
    & $Action
  }
  else {
    Write-Host "Skipped: $Heading" -ForegroundColor Yellow
  }
}

if ($env:OS -ne 'Windows_NT') {
  throw 'This setup wizard only supports Windows. Use ./setup.sh on macOS or ./setup/wsl/setup.sh inside WSL.'
}

Write-Host ''
Write-Host "Welcome to Paul's Windows dotfiles" -ForegroundColor Yellow
Write-Host ''
Write-Host 'Every machine-changing step is optional and defaults to No.'
if ($DryRun) {
  Write-Host 'Dry-run mode is active; commands will be displayed without being executed.' -ForegroundColor Yellow
}

Invoke-Step -Prompt 'Install or update core Windows applications with WinGet?' `
  -Heading 'Install core Windows applications' `
  -Action { & "$DotfilesDir/setup/windows/packages.ps1" -Profile Core -DryRun:$DryRun }

Invoke-Step -Prompt 'Install or update your optional Windows applications with WinGet?' `
  -Heading 'Install optional Windows applications' `
  -Action { & "$DotfilesDir/setup/windows/packages.ps1" -Profile Apps -DryRun:$DryRun }

Invoke-Step -Prompt 'Install MesloLGS Nerd Font Mono for terminals and icons?' `
  -Heading 'Install MesloLGS Nerd Font Mono' `
  -Action { & "$DotfilesDir/setup/windows/fonts.ps1" -DryRun:$DryRun }

Invoke-Step -Prompt 'Install WSL 2 and Ubuntu 26.04 LTS?' `
  -Heading 'Install WSL and Ubuntu' `
  -Action { & "$DotfilesDir/setup/windows/wsl.ps1" -DryRun:$DryRun }

Invoke-Step -Prompt 'Copy WezTerm and VS Code settings into your Windows profile?' `
  -Heading 'Configure Windows applications' `
  -Action { & "$DotfilesDir/setup/windows/config.ps1" -Yes:$Yes -DryRun:$DryRun }

Invoke-Step -Prompt 'Install the native VS Code extensions used by this setup?' `
  -Heading 'Install Windows VS Code extensions' `
  -Action { & "$DotfilesDir/setup/windows/vscode.ps1" -DryRun:$DryRun }

Invoke-Step -Prompt 'Initialize Podman Desktop and its default machine?' `
  -Heading 'Configure Podman' `
  -Action { & "$DotfilesDir/setup/windows/podman.ps1" -DryRun:$DryRun }

if (Confirm-Step 'Run the Linux setup wizard inside Ubuntu now?') {
  Write-Heading 'Run the WSL setup wizard'
  if ($DryRun) {
    Write-Host "[dry-run] wsl.exe -d Ubuntu-26.04 --cd $DotfilesDir -- bash setup/wsl/setup.sh"
  }
  else {
    & wsl.exe -d Ubuntu-26.04 --cd $DotfilesDir -- bash setup/wsl/setup.sh
  }
}
else {
  Write-Host 'Skipped: Run the WSL setup wizard' -ForegroundColor Yellow
}

Write-Host "`nWindows setup wizard finished." -ForegroundColor Green
Write-Host 'Restart Windows if WSL requested it, then rerun this wizard to continue.'
