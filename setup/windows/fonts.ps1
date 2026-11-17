#Requires -Version 5.1

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$DownloadUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip'
$FontDirectory = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

if ($DryRun) {
  Write-Host "[dry-run] download $DownloadUrl"
  Write-Host "[dry-run] install MesloLGS Nerd Font Mono into $FontDirectory"
  return
}

$TemporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-fonts-$([guid]::NewGuid())"
$Archive = Join-Path $TemporaryDirectory 'Meslo.zip'
$Expanded = Join-Path $TemporaryDirectory 'Meslo'

try {
  New-Item -ItemType Directory -Path $TemporaryDirectory -Force | Out-Null
  New-Item -ItemType Directory -Path $FontDirectory -Force | Out-Null
  Invoke-WebRequest -Uri $DownloadUrl -OutFile $Archive
  Expand-Archive -Path $Archive -DestinationPath $Expanded

  $Fonts = Get-ChildItem -Path $Expanded -Filter 'MesloLGSNerdFontMono-*.ttf'
  if (-not $Fonts) {
    throw 'The Nerd Fonts archive did not contain MesloLGS Nerd Font Mono.'
  }

  foreach ($font in $Fonts) {
    $destination = Join-Path $FontDirectory $font.Name
    $current = (Test-Path $destination) -and
      (Get-FileHash $destination).Hash -eq (Get-FileHash $font.FullName).Hash

    if ($current) {
      Write-Host "Already installed $($font.Name)"
    }
    else {
      # Windows locks fonts it has loaded; a newer release can only replace them after sign-out.
      try {
        Copy-Item -Path $font.FullName -Destination $destination -Force
      }
      catch [System.IO.IOException] {
        Write-Warning "$($font.Name) is in use. Sign out and rerun this step to update it."
        continue
      }
      Write-Host "Installed $($font.Name)"
    }

    New-ItemProperty `
      -Path 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' `
      -Name "$($font.BaseName) (TrueType)" `
      -Value $destination `
      -PropertyType String `
      -Force | Out-Null
  }
}
finally {
  Remove-Item -Path $TemporaryDirectory -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'MesloLGS Nerd Font Mono installed. Restart open terminals before testing it.' -ForegroundColor Green
Write-Host 'MonoLisa is licensed separately and must be installed manually if you want it as the first-choice font.'
