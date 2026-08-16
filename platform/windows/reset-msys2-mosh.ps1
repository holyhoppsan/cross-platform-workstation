[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

if ((Get-WorkstationPlatform) -ne 'windows') { throw 'This reset script only supports Windows.' }
if ($Apply -and -not (Test-WindowsProcessElevated)) { throw 'Run this reset script from an elevated PowerShell when using -Apply.' }

foreach ($ruleName in @('cross-platform-workstation-msys2-sshd-lan', 'cross-platform-workstation-mosh-lan')) {
    if ($Apply) {
        Write-SetupInfo "remove firewall rule $ruleName if present"
        Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    } else { Write-SetupInfo "would remove firewall rule $ruleName if present" }
}

if ($Apply) {
    Write-SetupInfo 'stop and unregister the msys2_sshd service if present'
    & sc.exe stop msys2_sshd | Out-Null
    & sc.exe delete msys2_sshd | Out-Null
} else { Write-SetupInfo 'would stop and unregister the msys2_sshd service if present' }

Write-SetupInfo 'host keys, SSH configuration backups, and the authorized key are preserved for deliberate inspection.'
if (-not $Apply) { Write-Host "`nDry run only. Re-run with -Apply to remove the service and LAN firewall rules." }
