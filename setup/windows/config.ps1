#Requires -Version 5.1

[CmdletBinding()]
param(
  [switch]$Yes,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$DotfilesDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Confirm-Replacement {
  param([Parameter(Mandatory)][string]$Path)
  if ($Yes) { return $true }
  return (Read-Host "$Path already exists. Back it up and replace it? [y/N]") -match '^(y|yes)$'
}

function Copy-ManagedFile {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Destination
  )

  $parent = Split-Path -Parent $Destination
  if ($DryRun) {
    Write-Host "[dry-run] copy $Source -> $Destination (backing up a different existing file)"
    return
  }

  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if (Test-Path $Destination) {
    $sourceHash = (Get-FileHash -Path $Source -Algorithm SHA256).Hash
    $destinationHash = (Get-FileHash -Path $Destination -Algorithm SHA256).Hash
    if ($sourceHash -eq $destinationHash) {
      Write-Host "Already current: $Destination"
      return
    }

    if (-not (Confirm-Replacement $Destination)) {
      Write-Host "Skipped: $Destination" -ForegroundColor Yellow
      return
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backup = "$Destination.backup.$timestamp"
    Move-Item -Path $Destination -Destination $backup
    Write-Host "Backed up $Destination to $backup"
  }

  Copy-Item -Path $Source -Destination $Destination
  Write-Host "Configured $Destination" -ForegroundColor Green
}

$CodeUserDirectory = Join-Path $env:APPDATA 'Code\User'
Copy-ManagedFile `
  -Source (Join-Path $DotfilesDir 'windows\wezterm\wezterm.lua') `
  -Destination (Join-Path $HOME '.wezterm.lua')
Copy-ManagedFile `
  -Source (Join-Path $DotfilesDir 'vscode\User\settings.json') `
  -Destination (Join-Path $CodeUserDirectory 'settings.json')
Copy-ManagedFile `
  -Source (Join-Path $DotfilesDir 'vscode\User\keybindings.json') `
  -Destination (Join-Path $CodeUserDirectory 'keybindings.json')
Copy-ManagedFile `
  -Source (Join-Path $DotfilesDir 'vscode\windows\tasks.json') `
  -Destination (Join-Path $CodeUserDirectory 'tasks.json')

$SourceSnippets = Join-Path $DotfilesDir 'vscode\User\snippets'
if (Test-Path $SourceSnippets) {
  $DestinationSnippets = Join-Path $CodeUserDirectory 'snippets'
  if ($DryRun) {
    Write-Host "[dry-run] copy snippets from $SourceSnippets -> $DestinationSnippets"
  }
  else {
    New-Item -ItemType Directory -Path $DestinationSnippets -Force | Out-Null
    Copy-Item -Path (Join-Path $SourceSnippets '*') -Destination $DestinationSnippets -Recurse -Force
    Write-Host "Configured $DestinationSnippets" -ForegroundColor Green
  }
}
