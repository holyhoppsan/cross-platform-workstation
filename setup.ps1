[CmdletBinding()]
param(
    [ValidateSet('foundation', 'shell', 'wezterm', 'all')]
    [string]$Phase = 'shell',
    [switch]$DryRun,
    [switch]$SkipInstall,
    [switch]$SkipApply
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

$Platform = Get-WorkstationPlatform
Write-SetupInfo "repository: $RepoRoot"
Write-SetupInfo "platform: $Platform"
Write-SetupInfo "phase: $Phase"
Write-SetupInfo "dry_run: $($DryRun.IsPresent)"
Write-SetupInfo "skip_install: $($SkipInstall.IsPresent)"
Write-SetupInfo "skip_apply: $($SkipApply.IsPresent)"

Test-FoundationPhase -RepoRoot $RepoRoot

if ($Phase -in @('shell', 'wezterm', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Test-ShellPhase -RepoRoot $RepoRoot -Platform $Platform
        } else {
            Ensure-WindowsPhaseOneTools -DryRun:$DryRun
        }

        if ($Phase -in @('shell', 'all')) {
            if ($SkipApply) {
                Write-SetupInfo 'skipping chezmoi apply by request'
            } else {
                Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
            }

            Invoke-WindowsShellValidation -RepoRoot $RepoRoot -DryRun:$DryRun
        }
    } else {
        Test-ShellPhase -RepoRoot $RepoRoot -Platform $Platform
        if ($Phase -in @('shell', 'all')) {
            if (-not $SkipApply) {
                Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
            }
        }
    }
}

if ($Phase -in @('wezterm', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Write-SetupInfo 'skipping WezTerm install/verify by request'
        } else {
            Ensure-WindowsWezTerm -DryRun:$DryRun
        }

        if ($SkipApply) {
            Write-SetupInfo 'skipping WezTerm config apply by request'
        } elseif ($Phase -eq 'wezterm') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }

        Invoke-WindowsWezTermValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    } else {
        if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
            throw 'WezTerm is required for Phase 2. Install it with your platform package manager, then rerun setup.'
        }
        if (-not $SkipApply -and $Phase -eq 'wezterm') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }
    }
}

if ($Phase -eq 'foundation') {
    if ($Platform -eq 'windows') {
        $bash = Get-WindowsGitBashPath
        if ($bash) {
            if ($DryRun) {
                Write-SetupInfo 'would run scripts/doctor --phase foundation through Git Bash'
            } else {
                Invoke-GitBash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase foundation'
            }
        } else {
            Write-SetupInfo 'Git Bash not found; foundation file checks passed but Bash doctor validation was skipped.'
        }
    }
}

Write-Host ''
if ($DryRun) {
    Write-Host 'Dry run complete; no changes were made.'
} else {
    Write-Host "Phase '$Phase' setup completed."
}
