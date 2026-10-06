#Requires -Version 5.1

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$DotfilesDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ExtensionFile = Join-Path $DotfilesDir 'vscode\extensions\windows.txt'

if (-not $DryRun -and -not (Get-Command code.cmd -ErrorAction SilentlyContinue)) {
  throw 'The VS Code command-line launcher is unavailable. Restart the terminal after installing VS Code, then retry.'
}

foreach ($extension in (Get-Content $ExtensionFile)) {
  $extension = $extension.Trim()
  if (-not $extension -or $extension.StartsWith('#')) { continue }

  if ($DryRun) {
    Write-Host "[dry-run] code --install-extension $extension --force"
  }
  else {
    & code.cmd --install-extension $extension --force
    if ($LASTEXITCODE -ne 0) {
      throw "VS Code could not install $extension."
    }
  }
}
