[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$InstallMissing,
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

$RequiredMsys2Packages = @(
    'openssh',
    'mosh',
    'cygrunsrv',
    'mingw-w64-ucrt-x86_64-editrights'
)
$RequiredMsys2Commands = @(
    '/usr/bin/cygrunsrv',
    '/usr/bin/ssh-keygen',
    '/usr/bin/sshd',
    '/usr/bin/mosh-server',
    'getent',
    'net',
    '/ucrt64/bin/editrights'
)

function Test-AuthorizedPublicKey {
    param([Parameter(Mandatory)][string]$Path)

    $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Authorized-key path is not a file: $resolvedPath"
    }
    $keyLine = Get-Content -LiteralPath $resolvedPath -TotalCount 1 -ErrorAction Stop
    if ([string]::IsNullOrWhiteSpace($keyLine)) {
        throw "Authorized-key file is empty: $resolvedPath"
    }
    $keyPattern = '^(ssh-ed25519|ecdsa-sha2-[^\s]+|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com|ssh-rsa)\s+([A-Za-z0-9+/]+={0,2})(?:\s+.*)?$'
    if ($keyLine -notmatch $keyPattern) {
        throw 'Authorized-key file must contain a supported single-line OpenSSH public key (Ed25519 is preferred).'
    }
    try {
        $decodedKey = [Convert]::FromBase64String($Matches[2])
    } catch {
        throw 'Authorized-key file contains invalid base64 key data.'
    }
    if ($decodedKey.Length -eq 0) { throw 'Authorized-key file contains empty key data.' }
    return $resolvedPath
}

function Get-Msys2MoshPrerequisites {
    param([Parameter(Mandatory)][string]$BashPath)

    $packageChecks = ($RequiredMsys2Packages | ForEach-Object {
        "pacman -Q '$($_)' >/dev/null 2>&1 || printf 'MISSING_PACKAGE:%s\\n' '$($_)'"
    }) -join "`n"
    $commandChecks = ($RequiredMsys2Commands | ForEach-Object {
        if ($_ -like '/*') {
            "[ -x '$($_)' ] || printf 'MISSING_COMMAND:%s\\n' '$($_)'"
        } else {
            "command -v '$($_)' >/dev/null 2>&1 || printf 'MISSING_COMMAND:%s\\n' '$($_)'"
        }
    }) -join "`n"
    $checkScript = "set -u`n$packageChecks`n$commandChecks"
    $previousMsystem = $Env:MSYSTEM
    try {
        $Env:MSYSTEM = 'UCRT64'
        $output = @(& $BashPath --login -c $checkScript 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "MSYS2 prerequisite preflight failed with exit code $LASTEXITCODE.`n$($output -join "`n")"
        }
    } finally {
        $Env:MSYSTEM = $previousMsystem
    }

    return [pscustomobject]@{
        MissingPackages = @($output | Where-Object { "$_" -like 'MISSING_PACKAGE:*' } | ForEach-Object { "$_".Substring(16) })
        MissingCommands = @($output | Where-Object { "$_" -like 'MISSING_COMMAND:*' } | ForEach-Object { "$_".Substring(16) })
    }
}

function Write-Msys2MoshPrerequisiteReport {
    param([Parameter(Mandatory)]$Result)

    if ($Result.MissingPackages.Count -gt 0) {
        Write-SetupWarn "missing MSYS2 packages: $($Result.MissingPackages -join ', ')"
    }
    if ($Result.MissingCommands.Count -gt 0) {
        Write-SetupWarn "missing required commands: $($Result.MissingCommands -join ', ')"
    }
    if ($Result.MissingPackages.Count -eq 0 -and $Result.MissingCommands.Count -eq 0) {
        Write-SetupInfo 'MSYS2 SSH/Mosh prerequisite preflight passed'
    }
}

if ((Get-WorkstationPlatform) -ne 'windows') { throw 'This installer only supports Windows.' }
if ([string]::IsNullOrWhiteSpace($TargetUser)) { throw '-TargetUser must not be empty.' }
if ($Apply -and [string]::IsNullOrWhiteSpace($AuthorizedKeyPath)) { throw 'For key-only SSH, -AuthorizedKeyPath is required with -Apply.' }
$emptyRemoteAddresses = @($AllowedRemoteAddress | Where-Object { [string]::IsNullOrWhiteSpace($_) })
if ($AllowedRemoteAddress.Count -eq 0 -or $emptyRemoteAddresses.Count -gt 0) { throw '-AllowedRemoteAddress must contain at least one non-empty LAN scope.' }
if ($AllowedRemoteAddress -contains 'Any') { throw 'This LAN proof must not use Any. Use LocalSubnet or explicit LAN addresses.' }

$bash = Join-Path $MsysRoot 'usr\bin\bash.exe'
$installer = Join-Path $RepoRoot 'platform\windows\configure-msys2-sshd.sh'
# Validate key path and format before package installation or any service/firewall mutation.
$keyPath = if ($AuthorizedKeyPath) { Test-AuthorizedPublicKey -Path $AuthorizedKeyPath } else { $null }
foreach ($path in @($bash, $installer)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required path was not found: $path" }
}

Write-SetupInfo "MSYS2 root: $MsysRoot"
Write-SetupInfo "target Windows user: $TargetUser"
Write-SetupInfo "SSH TCP port: $SshPort"
Write-SetupInfo "Mosh UDP port: $MoshPort"
Write-SetupInfo "allowed remote addresses: $($AllowedRemoteAddress -join ', ')"

$prerequisites = Get-Msys2MoshPrerequisites -BashPath $bash
Write-Msys2MoshPrerequisiteReport -Result $prerequisites

if (-not $Apply) {
    if ($InstallMissing -and $prerequisites.MissingPackages.Count -gt 0) {
        Ensure-Msys2Ucrt64Packages -Packages $prerequisites.MissingPackages -DryRun
    } elseif ($InstallMissing) {
        Write-SetupInfo 'no missing MSYS2 packages would be installed'
    }
    if ($prerequisites.MissingCommands.Count -gt 0 -and $prerequisites.MissingPackages.Count -eq 0) {
        Write-SetupWarn 'required commands are missing even though all prerequisite packages are installed; repair the affected MSYS2 packages before applying.'
    }
    Write-Host "`nPreflight only. No packages, services, authorized keys, or firewall rules were changed."
    if (-not $InstallMissing -and $prerequisites.MissingPackages.Count -gt 0) {
        Write-SetupInfo 'rerun with -InstallMissing to preview package installation, or with -Apply -InstallMissing and a public key to install and configure.'
    }
    exit 0
}

if (-not (Test-WindowsProcessElevated)) { throw 'Run this installer from an elevated PowerShell when using -Apply; it installs MSYS2 packages and creates a Windows service and firewall rules.' }
$hasMissingPrerequisites = $prerequisites.MissingPackages.Count -gt 0 -or $prerequisites.MissingCommands.Count -gt 0
if ($hasMissingPrerequisites -and -not $InstallMissing) {
    throw 'MSYS2 SSH/Mosh prerequisites are missing. No service or firewall changes were made. Rerun with -Apply -InstallMissing and the same key parameters.'
}
if ($InstallMissing -and $prerequisites.MissingPackages.Count -gt 0) {
    Ensure-Msys2Ucrt64Packages -Packages $prerequisites.MissingPackages
}

# Revalidate immediately before the first service mutation. This also catches
# installed packages whose expected commands are absent or unusable.
$prerequisites = Get-Msys2MoshPrerequisites -BashPath $bash
Write-Msys2MoshPrerequisiteReport -Result $prerequisites
if ($prerequisites.MissingPackages.Count -gt 0 -or $prerequisites.MissingCommands.Count -gt 0) {
    throw 'MSYS2 SSH/Mosh prerequisites are still incomplete after installation. No service or firewall changes were made; repair the reported packages and rerun.'
}

Write-SetupInfo 'installing and starting the MSYS2 sshd service with key-only authentication'
$previousMsystem = $Env:MSYSTEM
try {
    $env:MSYSTEM = 'UCRT64'
    # A login shell loads MSYS2's system profile, which supplies the UCRT64
    # PATH required by mosh-server and editrights.
    & $bash --login $installer --target-user $TargetUser --authorized-key $keyPath --sshd-port $SshPort
    if ($LASTEXITCODE -ne 0) { throw "MSYS2 sshd installer failed with exit code $LASTEXITCODE." }
} finally {
    $Env:MSYSTEM = $previousMsystem
}

if ($EnableLanFirewall) {
    foreach ($rule in @(
        @{ Name = 'cross-platform-workstation-msys2-sshd-lan'; DisplayName = 'Cross-platform workstation MSYS2 SSH (LAN)'; Protocol = 'TCP'; Port = $SshPort },
        @{ Name = 'cross-platform-workstation-mosh-lan'; DisplayName = 'Cross-platform workstation Mosh (LAN)'; Protocol = 'UDP'; Port = $MoshPort }
    )) {
        Write-SetupInfo "creating or updating firewall rule $($rule.Name)"
        Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
        New-NetFirewallRule -Name $rule.Name -DisplayName $rule.DisplayName -Direction Inbound -Action Allow -Protocol $rule.Protocol -LocalPort $rule.Port -RemoteAddress $AllowedRemoteAddress -Profile Private | Out-Null
    }
} else {
    Write-SetupInfo 'firewall rules are unchanged; after a local SSH test, rerun with -Apply -EnableLanFirewall for the LAN-only phone test.'
}
