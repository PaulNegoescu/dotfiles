#Requires -Version 5.1

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$DotfilesDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ExtensionFile = Join-Path $DotfilesDir 'vscode\extensions\windows.txt'

if (-not $DryRun -and -not (Get-Command code.cmd -ErrorAction SilentlyContinue)) {
  throw 'The VS Code command-line launcher is unavailable. Restart the terminal after installing VS Code, then retry.'
}

$Extensions = Get-Content $ExtensionFile |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ -and -not $_.StartsWith('#') }

# One CLI call for every extension, instead of a Node startup per extension.
$arguments = @($Extensions | ForEach-Object { '--install-extension', $_ }) + '--force'

if ($DryRun) {
  Write-Host "[dry-run] code $($arguments -join ' ')"
  return
}

# VS Code's bundled Node prints a url.parse() DEP0169 warning on every run.
$previousNodeOptions = $env:NODE_OPTIONS
$env:NODE_OPTIONS = '--no-deprecation'
try {
  & code.cmd @arguments
  if ($LASTEXITCODE -ne 0) {
    throw 'VS Code could not install one or more extensions; see the output above.'
  }
}
finally {
  $env:NODE_OPTIONS = $previousNodeOptions
}
