[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$EnableLanFirewall,
    [string]$MsysRoot = 'C:\msys64',
    [ValidateRange(1, 65535)][int]$SshPort = 22,
    [ValidateRange(1, 65535)][int]$MoshPort = 60001,
    [string]$TargetUser = $env:USERNAME,
    [string]$AuthorizedKeyPath,
    [string[]]$AllowedRemoteAddress = @('LocalSubnet')
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

function Invoke-SetupAction {
    param([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][scriptblock]$Action)
    if ($Apply) { Write-SetupInfo $Description; & $Action } else { Write-SetupInfo "would $Description" }
}

if ((Get-WorkstationPlatform) -ne 'windows') { throw 'This installer only supports Windows.' }
if ($Apply -and -not (Test-WindowsProcessElevated)) { throw 'Run this installer from an elevated PowerShell when using -Apply; it creates a Windows service and firewall rules.' }
if ($Apply -and [string]::IsNullOrWhiteSpace($AuthorizedKeyPath)) { throw 'For key-only SSH, -AuthorizedKeyPath is required with -Apply.' }
if ($AllowedRemoteAddress -contains 'Any') { throw 'This LAN proof must not use Any. Use LocalSubnet or explicit LAN addresses.' }

$bash = Join-Path $MsysRoot 'usr\bin\bash.exe'
$installer = Join-Path $RepoRoot 'platform\windows\configure-msys2-sshd.sh'
$keyPath = if ($AuthorizedKeyPath) { (Resolve-Path -LiteralPath $AuthorizedKeyPath -ErrorAction Stop).Path } else { $null }
foreach ($path in @($bash, $installer)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required path was not found: $path" }
}

Write-SetupInfo "MSYS2 root: $MsysRoot"
Write-SetupInfo "target Windows user: $TargetUser"
Write-SetupInfo "SSH TCP port: $SshPort"
Write-SetupInfo "Mosh UDP port: $MoshPort"
Write-SetupInfo "allowed remote addresses: $($AllowedRemoteAddress -join ', ')"

Invoke-SetupAction 'install and start the MSYS2 sshd service with key-only authentication' {
    $env:MSYSTEM = 'UCRT64'
    # A login shell loads MSYS2's system profile, which supplies the UCRT64
    # PATH required by mosh-server and editrights.
    & $bash --login $installer --target-user $TargetUser --authorized-key $keyPath --sshd-port $SshPort
    if ($LASTEXITCODE -ne 0) { throw "MSYS2 sshd installer failed with exit code $LASTEXITCODE." }
}

if ($EnableLanFirewall) {
    foreach ($rule in @(
        @{ Name = 'cross-platform-workstation-msys2-sshd-lan'; DisplayName = 'Cross-platform workstation MSYS2 SSH (LAN)'; Protocol = 'TCP'; Port = $SshPort },
        @{ Name = 'cross-platform-workstation-mosh-lan'; DisplayName = 'Cross-platform workstation Mosh (LAN)'; Protocol = 'UDP'; Port = $MoshPort }
    )) {
        Invoke-SetupAction "create or update firewall rule $($rule.Name)" {
            Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
            New-NetFirewallRule -Name $rule.Name -DisplayName $rule.DisplayName -Direction Inbound -Action Allow -Protocol $rule.Protocol -LocalPort $rule.Port -RemoteAddress $AllowedRemoteAddress -Profile Private | Out-Null
        }
    }
} else {
    Write-SetupInfo 'firewall rules are unchanged; after a local SSH test, rerun with -Apply -EnableLanFirewall for the LAN-only phone test.'
}

if (-not $Apply) { Write-Host "`nDry run only. Supply -Apply and the path to ShadowTerm's public key to make changes." }
