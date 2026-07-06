#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

foundation_output=$("$repo_root/setup.sh" --phase foundation --dry-run)
assert_contains "$foundation_output" 'phase: foundation' 'setup.sh parses foundation phase'
assert_contains "$foundation_output" 'dry_run: true' 'setup.sh parses dry-run'

shell_output=$("$repo_root/setup.sh" --phase shell --dry-run)
assert_contains "$shell_output" 'phase: shell' 'setup.sh parses shell phase'
assert_contains "$shell_output" 'install_missing: false' 'setup.sh reports install-missing default'

wezterm_output=$("$repo_root/setup.sh" --phase wezterm --dry-run)
assert_contains "$wezterm_output" 'phase: wezterm' 'setup.sh parses wezterm phase'

quake_output=$("$repo_root/setup.sh" --phase quake --dry-run)
assert_contains "$quake_output" 'phase: quake' 'setup.sh parses quake phase'

default_output=$("$repo_root/setup.sh" --dry-run)
assert_contains "$default_output" 'phase: shell' 'setup.sh defaults to current implemented phase'

install_output=$("$repo_root/setup.sh" --phase shell --install-missing --dry-run)
assert_contains "$install_output" 'install_missing: true' 'setup.sh parses install-missing'

powershell_setup=$(cat "$repo_root/setup.ps1")
assert_contains "$powershell_setup" "[string]\$Phase = 'shell'" 'setup.ps1 defaults to shell phase'
assert_contains "$powershell_setup" "'wezterm'" 'setup.ps1 accepts wezterm phase'
assert_contains "$powershell_setup" "'quake'" 'setup.ps1 accepts quake phase'
assert_contains "$powershell_setup" 'Ensure-WindowsPhaseOneTools' 'setup.ps1 verifies Windows Phase 1 prerequisites'
assert_contains "$powershell_setup" 'Ensure-WindowsWezTerm' 'setup.ps1 verifies Windows WezTerm'
assert_contains "$powershell_setup" 'Ensure-WindowsAutoHotkey' 'setup.ps1 verifies Windows AutoHotkey for Quake phase'
assert_contains "$powershell_setup" 'Register-WindowsQuakeStartup' 'setup.ps1 registers Windows Quake startup shortcut'
assert_contains "$powershell_setup" 'Invoke-ChezmoiApply' 'setup.ps1 applies chezmoi'
assert_contains "$powershell_setup" 'Invoke-WindowsShellValidation' 'setup.ps1 validates configured Git Bash'
assert_contains "$powershell_setup" 'Invoke-WindowsWezTermValidation' 'setup.ps1 validates WezTerm phase'
assert_contains "$powershell_setup" 'Invoke-WindowsQuakeValidation' 'setup.ps1 validates Quake phase'

reset_windows=$(cat "$repo_root/scripts/setup/reset-windows.ps1")
assert_contains "$reset_windows" '[switch]$Apply' 'reset-windows requires explicit apply switch'
assert_contains "$reset_windows" '[switch]$RemovePackages' 'reset-windows makes package removal explicit'
assert_contains "$reset_windows" "'wezterm'" 'reset-windows accepts wezterm phase'
assert_contains "$reset_windows" "'quake'" 'reset-windows accepts quake phase'
assert_contains "$reset_windows" ".config/wezterm" 'reset-windows removes WezTerm config for Phase 2'
assert_contains "$reset_windows" 'winget package $Id' 'reset-windows package uninstall function remains parameterized'
assert_contains "$reset_windows" "wez.wezterm" 'reset-windows can uninstall setup-managed WezTerm package'
assert_contains "$reset_windows" "AutoHotkey.AutoHotkey" 'reset-windows can uninstall setup-managed AutoHotkey package'
assert_contains "$reset_windows" 'Get-WindowsQuakeStartupShortcutPath' 'reset-windows removes Windows Quake startup shortcut'
assert_not_contains "$reset_windows" 'RemoveGit' 'reset-windows has no Git removal switch'
assert_not_contains "$reset_windows" "Git.Git" 'reset-windows never uninstalls Git'

common_ps1=$(cat "$repo_root/scripts/setup/common.ps1")
assert_not_contains "$common_ps1" "PackageId 'Git.Git'" 'setup.ps1 never installs Git'
assert_contains "$common_ps1" "PackageId 'twpayne.chezmoi'" 'Windows bootstrap knows chezmoi package'
assert_contains "$common_ps1" 'Do not install WSL or Git' 'Windows bootstrap documents Git as prerequisite'
assert_contains "$common_ps1" 'Backup-ChezmoiManagedTargets' 'setup.ps1 backs up managed dotfiles before chezmoi apply'
assert_contains "$common_ps1" 'apply --force' 'setup.ps1 forces chezmoi apply after backup'
assert_contains "$common_ps1" ".config/wezterm" 'setup.ps1 backs up WezTerm config before chezmoi apply'
assert_contains "$common_ps1" "PackageId 'wez.wezterm'" 'Windows bootstrap knows WezTerm package'
assert_contains "$common_ps1" "PackageId 'AutoHotkey.AutoHotkey'" 'Windows bootstrap knows AutoHotkey package'
assert_contains "$common_ps1" "AutoHotkey\\v2" 'Windows bootstrap searches standard AutoHotkey v2 install path'
assert_contains "$common_ps1" 'Write-WorkstationEnv' 'setup.ps1 writes machine-local repo root env'
assert_contains "$common_ps1" 'Get-WindowsQuakeStartupShortcutPath' 'Windows bootstrap resolves Quake startup shortcut path'
assert_contains "$common_ps1" 'cross-platform-workstation-quake.lnk' 'Windows bootstrap names Quake startup shortcut'
assert_contains "$common_ps1" 'Register-WindowsQuakeStartup' 'Windows bootstrap can register Quake startup shortcut'
assert_contains "$common_ps1" 'WScript.Shell' 'Windows bootstrap creates startup shortcut with WScript shell'

common_sh=$(cat "$repo_root/scripts/setup/common.sh")
assert_contains "$common_sh" 'setup_apply_chezmoi' 'setup.sh has chezmoi apply helper'
assert_contains "$common_sh" 'setup_backup_chezmoi_targets' 'setup.sh backs up managed dotfiles before chezmoi apply'
assert_contains "$common_sh" 'apply --force' 'setup.sh forces chezmoi apply after backup'
assert_contains "$common_sh" ".config/wezterm" 'setup.sh backs up WezTerm config before chezmoi apply'
assert_contains "$common_sh" 'WORKSTATION_REPO_ROOT' 'setup.sh writes machine-local repo root env'
assert_contains "$common_sh" 'setup_validate_interactive_shell' 'setup.sh has interactive shell validation helper'

wezterm_phase=$(cat "$repo_root/scripts/setup/phases/wezterm.sh")
assert_contains "$wezterm_phase" 'wez.wezterm' 'setup.sh WezTerm phase knows Windows package'

detect_output=$("$repo_root/scripts/setup/detect-platform.sh")
case "$detect_output" in
  windows|macos|ubuntu|linux|unknown) assert_eq "$detect_output" "$detect_output" 'detect-platform emits known token' ;;
  *) assert_eq 'known-platform-token' "$detect_output" 'detect-platform emits known token' ;;
esac

finish_tests
