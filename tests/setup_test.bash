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

neovim_output=$("$repo_root/setup.sh" --phase neovim --dry-run)
assert_contains "$neovim_output" 'phase: neovim' 'setup.sh parses neovim phase'

yazi_output=$("$repo_root/setup.sh" --phase yazi --dry-run)
assert_contains "$yazi_output" 'phase: yazi' 'setup.sh parses yazi phase'

default_output=$("$repo_root/setup.sh" --dry-run)
assert_contains "$default_output" 'phase: shell' 'setup.sh defaults to current implemented phase'

install_output=$("$repo_root/setup.sh" --phase shell --install-missing --dry-run)
assert_contains "$install_output" 'install_missing: true' 'setup.sh parses install-missing'

powershell_setup=$(cat "$repo_root/setup.ps1")
verify_ps1=$(cat "$repo_root/scripts/setup/verify.ps1")
assert_contains "$powershell_setup" "[string]\$Phase = 'shell'" 'setup.ps1 defaults to shell phase'
assert_contains "$powershell_setup" "'wezterm'" 'setup.ps1 accepts wezterm phase'
assert_contains "$powershell_setup" "'quake'" 'setup.ps1 accepts quake phase'
assert_contains "$powershell_setup" "'neovim'" 'setup.ps1 accepts neovim phase'
assert_contains "$powershell_setup" "'yazi'" 'setup.ps1 accepts yazi phase'
assert_contains "$powershell_setup" 'Ensure-WindowsPhaseOneTools' 'setup.ps1 verifies Windows Phase 1 prerequisites'
assert_contains "$powershell_setup" 'Ensure-WindowsWezTerm' 'setup.ps1 verifies Windows WezTerm'
assert_contains "$powershell_setup" 'Ensure-WindowsAutoHotkey' 'setup.ps1 verifies Windows AutoHotkey for Quake phase'
assert_contains "$powershell_setup" 'Ensure-WindowsNeovim' 'setup.ps1 verifies Windows Neovim'
assert_contains "$powershell_setup" 'Ensure-WindowsYazi' 'setup.ps1 verifies Windows Yazi'
assert_contains "$powershell_setup" 'Register-WindowsQuakeStartup' 'setup.ps1 registers Windows Quake startup shortcut'
assert_contains "$powershell_setup" 'Do not run setup.ps1 from an elevated/Admin PowerShell' 'setup.ps1 blocks elevated non-dry Windows setup'
assert_contains "$powershell_setup" 'Invoke-ChezmoiApply' 'setup.ps1 applies chezmoi'
assert_contains "$powershell_setup" 'Invoke-WindowsShellValidation' 'setup.ps1 validates configured MSYS2 Bash'
assert_contains "$powershell_setup" 'Invoke-WindowsWezTermValidation' 'setup.ps1 validates WezTerm phase'
assert_contains "$powershell_setup" 'Invoke-WindowsQuakeValidation' 'setup.ps1 validates Quake phase'
assert_contains "$powershell_setup" 'Invoke-WindowsNeovimValidation' 'setup.ps1 validates Neovim phase'
assert_contains "$powershell_setup" 'Invoke-WindowsYaziValidation' 'setup.ps1 validates Yazi phase'
assert_contains "$verify_ps1" "'yazi'" 'verify.ps1 accepts yazi phase'
assert_contains "$verify_ps1" 'Invoke-WindowsYaziValidation' 'verify.ps1 validates Yazi phase'

reset_windows=$(cat "$repo_root/scripts/setup/reset-windows.ps1")
assert_contains "$reset_windows" '[switch]$Apply' 'reset-windows requires explicit apply switch'
assert_contains "$reset_windows" '[switch]$RemovePackages' 'reset-windows makes package removal explicit'
assert_contains "$reset_windows" "'wezterm'" 'reset-windows accepts wezterm phase'
assert_contains "$reset_windows" "'quake'" 'reset-windows accepts quake phase'
assert_contains "$reset_windows" "'neovim'" 'reset-windows accepts neovim phase'
assert_contains "$reset_windows" "'yazi'" 'reset-windows accepts yazi phase'
assert_contains "$reset_windows" ".config/wezterm" 'reset-windows removes WezTerm config for Phase 2'
assert_contains "$reset_windows" ".config/nvim" 'reset-windows removes Neovim config for Phase 4'
assert_contains "$reset_windows" ".config/yazi" 'reset-windows removes Yazi config for Phase 5'
assert_contains "$reset_windows" 'Stop-SetupManagedProcess' 'reset-windows stops setup-managed processes before package removal'
assert_contains "$reset_windows" 'wezterm-gui' 'reset-windows stops WezTerm GUI before uninstall'
assert_contains "$reset_windows" 'wezterm-mux-server' 'reset-windows stops WezTerm mux server before uninstall'
assert_contains "$reset_windows" 'Test-WindowsProcessElevated' 'reset-windows detects elevated PowerShell'
assert_contains "$reset_windows" 'Do not run reset-windows.ps1 with -Apply -RemovePackages from an elevated/Admin PowerShell' 'reset-windows blocks elevated package removal before file cleanup'
assert_contains "$reset_windows" 'winget package $Id' 'reset-windows package uninstall function remains parameterized'
assert_contains "$reset_windows" 'is not installed; skipping uninstall' 'reset-windows tolerates already-removed packages'
assert_contains "$reset_windows" 'package was not listed by winget' 'reset-windows handles winget list misses when command exists'
assert_contains "$reset_windows" 'could not be uninstalled by winget package ID after list miss; continuing' 'reset-windows continues after ambiguous winget uninstall miss'
assert_contains "$reset_windows" "Command 'yazi.exe'" 'reset-windows maps Yazi package to command detection'
assert_contains "$reset_windows" "wez.wezterm" 'reset-windows can uninstall setup-managed WezTerm package'
assert_contains "$reset_windows" "AutoHotkey.AutoHotkey" 'reset-windows can uninstall setup-managed AutoHotkey package'
assert_contains "$reset_windows" "Neovim.Neovim" 'reset-windows can uninstall setup-managed Neovim package'
assert_contains "$reset_windows" "sxyazi.yazi" 'reset-windows can uninstall setup-managed Yazi package'
assert_contains "$reset_windows" 'Get-WindowsQuakeStartupShortcutPath' 'reset-windows removes Windows Quake startup shortcut'
assert_not_contains "$reset_windows" 'RemoveGit' 'reset-windows has no Git removal switch'
assert_not_contains "$reset_windows" "Git.Git" 'reset-windows never uninstalls Git'

common_ps1=$(cat "$repo_root/scripts/setup/common.ps1")
assert_not_contains "$common_ps1" "PackageId 'Git.Git'" 'setup.ps1 never installs Git'
assert_contains "$common_ps1" 'Test-WindowsProcessElevated' 'Windows setup helpers can detect elevated PowerShell'
assert_contains "$common_ps1" 'Get-WindowsMsys2BashPath' 'Windows setup locates MSYS2 Bash'
assert_contains "$common_ps1" 'Ensure-Msys2Ucrt64Packages' 'Windows setup verifies MSYS2 CLI packages'
assert_contains "$common_ps1" 'Invoke-Msys2Bash' 'Windows setup validates through MSYS2 Bash'
assert_contains "$common_ps1" "PackageId 'twpayne.chezmoi'" 'Windows bootstrap knows chezmoi package'
assert_contains "$common_ps1" 'Do not install WSL' 'Windows bootstrap documents WSL exclusion'
assert_contains "$common_ps1" 'Backup-ChezmoiManagedTargets' 'setup.ps1 backs up managed dotfiles before chezmoi apply'
assert_contains "$common_ps1" 'apply --force' 'setup.ps1 forces chezmoi apply after backup'
assert_contains "$common_ps1" ".config/wezterm" 'setup.ps1 backs up WezTerm config before chezmoi apply'
assert_contains "$common_ps1" ".config/nvim" 'setup.ps1 backs up Neovim config before chezmoi apply'
assert_contains "$common_ps1" "PackageId 'wez.wezterm'" 'Windows bootstrap knows WezTerm package'
assert_contains "$common_ps1" "PackageId 'AutoHotkey.AutoHotkey'" 'Windows bootstrap knows AutoHotkey package'
assert_contains "$common_ps1" "PackageId 'Neovim.Neovim'" 'Windows bootstrap knows Neovim package'
assert_contains "$common_ps1" "PackageId 'sxyazi.yazi'" 'Windows bootstrap knows Yazi package'
assert_contains "$common_ps1" "WezTerm" 'Windows bootstrap searches standard WezTerm install path'
assert_contains "$common_ps1" "Neovim\\bin" 'Windows bootstrap searches standard Neovim install path'
assert_contains "$common_ps1" "Yazi" 'Windows bootstrap searches standard Yazi install path'
assert_contains "$common_ps1" "AutoHotkey\\v2" 'Windows bootstrap searches standard AutoHotkey v2 install path'
assert_contains "$common_ps1" 'Write-WorkstationEnv' 'setup.ps1 writes machine-local repo root env'
assert_contains "$common_ps1" 'Get-WindowsQuakeStartupShortcutPath' 'Windows bootstrap resolves Quake startup shortcut path'
assert_contains "$common_ps1" 'cross-platform-workstation-quake.lnk' 'Windows bootstrap names Quake startup shortcut'
assert_contains "$common_ps1" 'Register-WindowsQuakeStartup' 'Windows bootstrap can register Quake startup shortcut'
assert_contains "$common_ps1" 'WScript.Shell' 'Windows bootstrap creates startup shortcut with WScript shell'

msys2_mosh_setup=$(cat "$repo_root/platform/windows/setup-msys2-mosh.ps1")
msys2_mosh_reset=$(cat "$repo_root/platform/windows/reset-msys2-mosh.ps1")
msys2_sshd_setup=$(cat "$repo_root/platform/windows/configure-msys2-sshd.sh")
assert_contains "$msys2_mosh_setup" '[switch]$Apply' 'MSYS2 Mosh installer requires explicit apply switch'
assert_contains "$msys2_mosh_setup" '[switch]$EnableLanFirewall' 'MSYS2 Mosh installer makes firewall changes explicit'
assert_contains "$msys2_mosh_setup" "@('LocalSubnet')" 'MSYS2 Mosh installer defaults firewall scope to local subnet'
assert_contains "$msys2_mosh_setup" 'Test-WindowsProcessElevated' 'MSYS2 Mosh installer requires elevation for writes'
assert_contains "$msys2_mosh_setup" 'AuthorizedKeyPath is required' 'MSYS2 Mosh installer requires a public key'
assert_contains "$msys2_mosh_reset" 'cross-platform-workstation-mosh-lan' 'MSYS2 Mosh reset removes the UDP rule'
assert_contains "$msys2_mosh_reset" 'sc.exe delete msys2_sshd' 'MSYS2 Mosh reset unregisters the service'
assert_contains "$msys2_sshd_setup" 'SetEnv MSYSTEM=UCRT64' 'MSYS2 SSH service starts remote sessions in UCRT64'
assert_contains "$msys2_sshd_setup" 'PasswordAuthentication no' 'MSYS2 SSH service disables password authentication'
assert_contains "$msys2_sshd_setup" 'sshd_config=/etc/ssh/sshd_config' 'MSYS2 SSH setup uses the current packaged configuration path'
assert_contains "$msys2_sshd_setup" "cygrunsrv -I \"\$service_name\"" 'MSYS2 SSH setup registers a cygrunsrv service'

common_sh=$(cat "$repo_root/scripts/setup/common.sh")
assert_contains "$common_sh" 'setup_apply_chezmoi' 'setup.sh has chezmoi apply helper'
assert_contains "$common_sh" 'setup_backup_chezmoi_targets' 'setup.sh backs up managed dotfiles before chezmoi apply'
assert_contains "$common_sh" 'apply --force' 'setup.sh forces chezmoi apply after backup'
assert_contains "$common_sh" ".config/wezterm" 'setup.sh backs up WezTerm config before chezmoi apply'
assert_contains "$common_sh" ".config/nvim" 'setup.sh backs up Neovim config before chezmoi apply'
assert_contains "$common_sh" ".config/yazi" 'setup.sh backs up Yazi config before chezmoi apply'
assert_contains "$common_sh" 'WORKSTATION_REPO_ROOT' 'setup.sh writes machine-local repo root env'
assert_contains "$common_sh" 'setup_validate_interactive_shell' 'setup.sh has interactive shell validation helper'

wezterm_phase=$(cat "$repo_root/scripts/setup/phases/wezterm.sh")
assert_contains "$wezterm_phase" 'wez.wezterm' 'setup.sh WezTerm phase knows Windows package'

neovim_phase=$(cat "$repo_root/scripts/setup/phases/neovim.sh")
assert_contains "$neovim_phase" 'Neovim.Neovim' 'setup.sh Neovim phase knows Windows package'

yazi_phase=$(cat "$repo_root/scripts/setup/phases/yazi.sh")
assert_contains "$yazi_phase" 'sxyazi.yazi' 'setup.sh Yazi phase knows Windows package'

detect_output=$("$repo_root/scripts/setup/detect-platform.sh")
case "$detect_output" in
  windows|macos|ubuntu|linux|unknown) assert_eq "$detect_output" "$detect_output" 'detect-platform emits known token' ;;
  *) assert_eq 'known-platform-token' "$detect_output" 'detect-platform emits known token' ;;
esac

finish_tests
