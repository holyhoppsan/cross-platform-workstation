[CmdletBinding()]
param(
    [ValidateSet('foundation', 'shell', 'wezterm', 'quake', 'neovim', 'yazi', 'vowen', 'all')]
    [string]$Phase = 'shell',
    [switch]$DryRun,
    [switch]$SkipInstall,
    [switch]$SkipApply,
    [switch]$InstallVowen,
    [ValidateSet('pi', 'codex')][string]$Agent
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

if ($Platform -eq 'windows' -and -not $DryRun -and (Test-WindowsProcessElevated)) {
    throw 'Do not run setup.ps1 from an elevated/Admin PowerShell. Setup configures the current user profile and winget user-scope packages. Open a normal user PowerShell and rerun setup.'
}

Test-FoundationPhase -RepoRoot $RepoRoot

if ($Agent) {
    if ($Platform -ne 'windows') { throw 'Agent installation through setup.ps1 is supported on Windows only.' }
    if ($SkipInstall) { Write-SetupInfo "skipping $Agent install/verify by request" } else { Ensure-WindowsAgent -Agent $Agent -DryRun:$DryRun }
    exit 0
}

if ($Phase -eq 'vowen') {
    if ($Platform -ne 'windows') {
        throw 'Vowen installation through setup.ps1 is supported on Windows only. On macOS, run ./setup.sh --phase vowen [--install-missing].'
    }
    Ensure-WindowsVowen -Install:$InstallVowen -DryRun:$DryRun
    Invoke-WindowsVowenValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    if ($DryRun) {
        Write-Host 'Dry run complete; no changes were made.'
    } else {
        Write-Host "Phase '$Phase' setup completed. Complete the Vowen installer and permissions manually, then rerun doctor --phase vowen."
    }
    exit 0
}

if ($Phase -in @('shell', 'wezterm', 'quake', 'neovim', 'yazi', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Test-ShellPhase -RepoRoot $RepoRoot -Platform $Platform
        } else {
            Ensure-WindowsPhaseOneTools -DryRun:$DryRun
            Ensure-WindowsHerdr -DryRun:$DryRun
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

if ($Phase -in @('wezterm', 'quake', 'neovim', 'yazi', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Write-SetupInfo 'skipping WezTerm install/verify by request'
        } else {
            Ensure-WindowsWezTerm -DryRun:$DryRun
        }

        if ($SkipApply) {
            Write-SetupInfo 'skipping WezTerm config apply by request'
        } elseif ($Phase -in @('wezterm', 'quake')) {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }

        Invoke-WindowsWezTermValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    } else {
        if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
            throw 'WezTerm is required for Phase 2. Install it with your platform package manager, then rerun setup.'
        }
        if (-not $SkipApply -and $Phase -in @('wezterm', 'quake')) {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }
    }
}

if ($Phase -in @('neovim', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Write-SetupInfo 'skipping Neovim install/verify by request'
        } else {
            Ensure-WindowsNeovim -DryRun:$DryRun
        }

        if ($SkipApply) {
            Write-SetupInfo 'skipping Neovim config apply by request'
        } elseif ($Phase -eq 'neovim') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }

        Invoke-WindowsNeovimValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    } else {
        if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
            throw 'Neovim is required for Phase 4. Install it with your platform package manager, then rerun setup.'
        }
        if (-not $SkipApply -and $Phase -eq 'neovim') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }
    }
}

if ($Phase -in @('yazi', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Write-SetupInfo 'skipping Yazi install/verify by request'
        } else {
            Ensure-WindowsYazi -DryRun:$DryRun
        }

        if ($SkipApply) {
            Write-SetupInfo 'skipping Yazi config apply by request'
        } elseif ($Phase -eq 'yazi') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }

        Invoke-WindowsYaziValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    } else {
        if (-not (Get-Command yazi -ErrorAction SilentlyContinue)) {
            throw 'Yazi is required for Phase 5. Install it with your platform package manager, then rerun setup.'
        }
        if (-not $SkipApply -and $Phase -eq 'yazi') {
            Invoke-ChezmoiApply -RepoRoot $RepoRoot -DryRun:$DryRun
        }
    }
}

if ($Phase -in @('quake', 'all')) {
    if ($Platform -eq 'windows') {
        if ($SkipInstall) {
            Write-SetupInfo 'skipping AutoHotkey install/verify by request'
        } else {
            Ensure-WindowsAutoHotkey -DryRun:$DryRun
        }

        Register-WindowsQuakeStartup -RepoRoot $RepoRoot -DryRun:$DryRun
        Invoke-WindowsQuakeValidation -RepoRoot $RepoRoot -DryRun:$DryRun
    } else {
        throw 'Quake setup is currently implemented only for Windows. macOS and Ubuntu adapters are documented stubs.'
    }
}

if ($Phase -eq 'foundation') {
    if ($Platform -eq 'windows') {
        $bash = Get-WindowsMsys2BashPath
        if ($bash) {
            if ($DryRun) {
                Write-SetupInfo 'would run scripts/doctor --phase foundation through MSYS2 UCRT64 Bash'
            } else {
                Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase foundation'
            }
        } else {
            Write-SetupInfo 'MSYS2 UCRT64 Bash not found; foundation file checks passed but Bash doctor validation was skipped.'
        }
    }
}

Write-Host ''
if ($DryRun) {
    Write-Host 'Dry run complete; no changes were made.'
} else {
    Write-Host "Phase '$Phase' setup completed."
}
