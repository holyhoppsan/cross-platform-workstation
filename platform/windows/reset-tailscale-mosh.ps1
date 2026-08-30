[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

if ((Get-WorkstationPlatform) -ne 'windows') { throw 'This reset script only supports Windows.' }
if ($Apply -and -not (Test-WindowsProcessElevated)) { throw 'Run this reset script from an elevated PowerShell when using -Apply.' }

foreach ($ruleName in @('cross-platform-workstation-msys2-sshd-tailscale', 'cross-platform-workstation-mosh-tailscale')) {
    if ($Apply) {
        Write-SetupInfo "remove firewall rule $ruleName if present"
        Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    } else {
        Write-SetupInfo "would remove firewall rule $ruleName if present"
    }
}

Write-SetupInfo 'Tailscale, its login state, MSYS2 sshd, Mosh, LAN firewall rules, and authorized keys are preserved.'
if (-not $Apply) { Write-Host "`nDry run only. Re-run with -Apply to remove only the Tailscale-scoped firewall rules." }
