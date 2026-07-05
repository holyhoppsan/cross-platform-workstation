[CmdletBinding()]
param(
    [ValidateSet('shell')]
    [string]$Phase = 'shell',
    [switch]$Apply,
    [switch]$RemovePackages,
    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

function Invoke-ResetAction {
    param(
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][scriptblock]$Action
    )

    if ($Apply) {
        Write-SetupInfo $Description
        & $Action
    } else {
        Write-SetupInfo "would $Description"
    }
}

function Backup-ThenRemove {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$BackupRoot
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    if ($NoBackup) {
        Remove-Item -LiteralPath $Path -Recurse -Force
        return
    }

    $resolved = Resolve-Path -LiteralPath $Path
    $relativeName = ($resolved.Path -replace '^[A-Za-z]:\\', '') -replace '[\\/:*?"<>| ]+', '_'
    $target = Join-Path $BackupRoot $relativeName
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    Move-Item -LiteralPath $resolved.Path -Destination $target -Force
}

function Uninstall-WingetPackage {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Name
    )

    Invoke-ResetAction "uninstall $Name with winget package $Id" {
        $winget = Get-WingetCommand
        if (-not $winget) {
            throw "winget is required to uninstall $Name automatically, but winget was not found."
        }

        & $winget uninstall --id $Id --exact --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "winget failed to uninstall $Name ($Id)."
        }
    }
}

if ((Get-WorkstationPlatform) -ne 'windows') {
    throw 'reset-windows.ps1 only supports Windows.'
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $HOME ".workstation-reset-backup\$timestamp"

Write-SetupInfo "phase: $Phase"
Write-SetupInfo "apply: $($Apply.IsPresent)"
Write-SetupInfo "remove_packages: $($RemovePackages.IsPresent)"
Write-SetupInfo "backup_root: $backupRoot"

$targets = @(
    (Join-Path $HOME '.bashrc'),
    (Join-Path $HOME '.bash_profile'),
    (Join-Path $HOME '.config/workstation'),
    (Join-Path $HOME '.local/bin/workstation-doctor'),
    (Join-Path $HOME '.local/share/chezmoi')
)

foreach ($target in $targets) {
    if (Test-Path -LiteralPath $target) {
        Invoke-ResetAction "remove or back up $target" {
            Backup-ThenRemove -Path $target -BackupRoot $backupRoot
        }
    } else {
        Write-SetupInfo "not present: $target"
    }
}

if ($RemovePackages) {
    Uninstall-WingetPackage -Id 'twpayne.chezmoi' -Name 'chezmoi'
    Uninstall-WingetPackage -Id 'BurntSushi.ripgrep.MSVC' -Name 'ripgrep'
    Uninstall-WingetPackage -Id 'sharkdp.fd' -Name 'fd'
    Uninstall-WingetPackage -Id 'jqlang.jq' -Name 'jq'
    Uninstall-WingetPackage -Id 'junegunn.fzf' -Name 'fzf'
}

if (-not $Apply) {
    Write-Host ''
    Write-Host 'Dry run only. Re-run with -Apply to perform the reset.'
    Write-Host 'Use -RemovePackages to uninstall setup-managed Phase 1 packages. Git is never removed by this script.'
} else {
    Write-Host ''
    Write-Host 'Reset completed.'
    if (-not $NoBackup) {
        Write-Host "Backups, if any, were moved to: $backupRoot"
    }
}
