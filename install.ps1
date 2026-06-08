# Install the Windows WezTerm config.
#
# Copies wezterm_windows.lua -> %USERPROFILE%\.wezterm.lua. Any existing config
# is backed up first. Re-run this after pulling repo updates to refresh the copy.
#
# Usage (in PowerShell, from the repo directory):
#   ./install.ps1

$ErrorActionPreference = 'Stop'

$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $repoDir 'wezterm_windows.lua'
$dest = Join-Path $env:USERPROFILE '.wezterm.lua'

if (-not (Test-Path $src)) {
	Write-Error "$src not found"
	exit 1
}

if (Test-Path $dest) {
	$backup = "$dest.backup." + (Get-Date -Format 'yyyyMMddHHmmss')
	Move-Item -Path $dest -Destination $backup
	Write-Host "Backed up existing config to $backup"
}

Copy-Item -Path $src -Destination $dest
Write-Host "Copied $src -> $dest"
Write-Host "Reload WezTerm (Leader+r) or open a new window to apply."
