#Requires -Version 5.1

[CmdletBinding()]
param(
  [ValidateSet('Core', 'Apps')]
  [string]$Profile = 'Core',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$CorePackages = @(
  @{ Id = 'Microsoft.PowerShell'; Source = 'winget' },
  @{ Id = 'Git.Git'; Source = 'winget' },
  @{ Id = 'Microsoft.VisualStudioCode'; Source = 'winget' },
  @{ Id = 'wez.wezterm'; Source = 'winget' },
  @{ Id = '7zip.7zip'; Source = 'winget' },
  @{ Id = 'Klocman.BulkCrapUninstaller'; Source = 'winget' },
  @{ Id = 'Podman.CLI'; Source = 'winget' },
  @{ Id = 'RedHat.Podman-Desktop'; Source = 'winget' },
  @{ Id = '9PFXXSHC64H3'; Source = 'msstore' }
)

$AppPackages = @(
  @{ Id = 'calibre.calibre'; Source = 'winget' },
  @{ Id = 'Dell.DisplayManager'; Source = 'winget' },
  @{ Id = 'Foxit.FoxitReader'; Source = 'winget' },
  @{ Id = 'ImputNet.Helium'; Source = 'winget' },
  @{ Id = 'Legcord.Legcord'; Source = 'winget' },
  @{ Id = 'Obsidian.Obsidian'; Source = 'winget' },
  @{ Id = 'Proton.ProtonDrive'; Source = 'winget' },
  @{ Id = 'Proton.ProtonMail'; Source = 'winget' },
  @{ Id = 'Proton.ProtonPass'; Source = 'winget' },
  @{ Id = 'OpenWhisperSystems.Signal'; Source = 'winget' },
  @{ Id = 'Spotify.Spotify'; Source = 'winget' },
  @{ Id = 'Stremio.Stremio'; Source = 'winget' },
  @{ Id = 'TeamViewer.TeamViewer'; Source = 'winget' },
  @{ Id = 'VideoLAN.VLC'; Source = 'winget' },
  @{ Id = 'Zoom.Zoom'; Source = 'winget' },
  @{ Id = '9NKSQGP7F2NH'; Source = 'msstore' }
)

if (-not $DryRun -and -not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
  throw 'WinGet is unavailable. Install or update App Installer from Microsoft Store, then rerun this step.'
}

$Packages = if ($Profile -eq 'Core') { $CorePackages } else { $AppPackages }
$Failures = [System.Collections.Generic.List[string]]::new()

# WinGet reports an already-current package as an error rather than a no-op.
$SuccessCodes = @(
  0,
  -1978335189, # 0x8A15002B APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE
  -1978335135  # 0x8A150061 APPINSTALLER_CLI_ERROR_PACKAGE_ALREADY_INSTALLED
)

foreach ($package in $Packages) {
  $arguments = @(
    'install',
    '--id', $package.Id,
    '--exact',
    '--source', $package.Source,
    '--accept-package-agreements',
    '--accept-source-agreements',
    '--silent'
  )

  if ($DryRun) {
    Write-Host "[dry-run] winget $($arguments -join ' ')"
    continue
  }

  Write-Host "Installing or updating $($package.Id)..." -ForegroundColor Cyan
  & winget.exe @arguments
  if ($LASTEXITCODE -notin $SuccessCodes) {
    $Failures.Add($package.Id)
    Write-Warning "WinGet could not install $($package.Id). Continuing with the remaining packages."
  }
}

if ($Failures.Count -gt 0) {
  throw "WinGet failed for: $($Failures -join ', ')"
}
