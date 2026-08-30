[CmdletBinding()]
param(
    [switch]$Apply,
    [ValidateRange(1, 65535)][int]$SshPort = 22,
    [ValidateRange(1, 65535)][int]$MoshPort = 60001,
    [Parameter(Mandatory)][string[]]$AllowedRemoteAddress
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

function Test-TailscaleAddress {
    param([Parameter(Mandatory)][string]$Address)

    $parts = $Address -split '/', 2
    $ip = [System.Net.IPAddress]::Any
    if (-not [System.Net.IPAddress]::TryParse($parts[0], [ref]$ip) -or $ip.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
        return $false
    }
    if ($parts.Count -eq 2 -and (($parts[1] -notmatch '^\d+$') -or [int]$parts[1] -lt 10 -or [int]$parts[1] -gt 32)) {
        return $false
    }

    $bytes = $ip.GetAddressBytes()
    return $bytes[0] -eq 100 -and $bytes[1] -ge 64 -and $bytes[1] -le 127
}

if ((Get-WorkstationPlatform) -ne 'windows') { throw 'This installer only supports the Windows MSYS2 SSH/Mosh host.' }
if ($Apply -and -not (Test-WindowsProcessElevated)) { throw 'Run this script from an elevated PowerShell only when using -Apply; it creates Windows firewall rules.' }
if ($AllowedRemoteAddress -contains 'Any' -or $AllowedRemoteAddress -contains 'LocalSubnet') { throw 'Use the iPhone Tailscale IPv4 address (normally /32), never Any or LocalSubnet.' }
foreach ($address in $AllowedRemoteAddress) {
    if (-not (Test-TailscaleAddress -Address $address)) {
        throw "'$address' is not a Tailscale CGNAT IPv4 address or allowed CIDR. Use an address in 100.64.0.0/10, normally the phone address with /32."
    }
}

if (-not (Test-CommandAvailable -Name 'tailscale.exe')) { throw 'Tailscale is not installed. Run ./setup.ps1 -Phase tailscale from a normal PowerShell first.' }

Write-SetupInfo "SSH TCP port: $SshPort"
Write-SetupInfo "Mosh UDP port: $MoshPort"
Write-SetupInfo "allowed Tailscale remote addresses: $($AllowedRemoteAddress -join ', ')"

foreach ($rule in @(
    @{ Name = 'cross-platform-workstation-msys2-sshd-tailscale'; DisplayName = 'Cross-platform workstation MSYS2 SSH (Tailscale)'; Protocol = 'TCP'; Port = $SshPort },
    @{ Name = 'cross-platform-workstation-mosh-tailscale'; DisplayName = 'Cross-platform workstation Mosh (Tailscale)'; Protocol = 'UDP'; Port = $MoshPort }
)) {
    if ($Apply) {
        Write-SetupInfo "create or update firewall rule $($rule.Name)"
        Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
        New-NetFirewallRule -Name $rule.Name -DisplayName $rule.DisplayName -Direction Inbound -Action Allow -Protocol $rule.Protocol -LocalPort $rule.Port -RemoteAddress $AllowedRemoteAddress -Profile Any | Out-Null
    } else {
        Write-SetupInfo "would create or update firewall rule $($rule.Name)"
    }
}

if (-not $Apply) {
    Write-Host "`nDry run only. After Tailscale login and tailnet-policy review, rerun from elevated PowerShell with -Apply and the iPhone's Tailscale IPv4 address."
}
