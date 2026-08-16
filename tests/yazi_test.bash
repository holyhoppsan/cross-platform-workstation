#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

yazi_config=$(cat "$repo_root/chezmoi/dot_config/yazi/yazi.toml")
yazi_keymap=$(cat "$repo_root/chezmoi/dot_config/yazi/keymap.toml")
yazi_theme=$(cat "$repo_root/chezmoi/dot_config/yazi/theme.toml")
functions_config=$(cat "$repo_root/chezmoi/dot_config/workstation/functions.sh")
doctor=$(cat "$repo_root/chezmoi/dot_config/workstation/doctor")
wezterm_config=$(cat "$repo_root/chezmoi/dot_config/wezterm/wezterm.lua")
yazi_doc=$(cat "$repo_root/docs/yazi.md")
setup_ps1=$(cat "$repo_root/setup.ps1")
common_ps1=$(cat "$repo_root/scripts/setup/common.ps1")
reset_windows=$(cat "$repo_root/scripts/setup/reset-windows.ps1")
agents_config=$(cat "$repo_root/config/agents.example.toml")

assert_contains "$yazi_config" '[manager]' 'Yazi config has manager section'
assert_contains "$yazi_config" 'sort_by = "natural"' 'Yazi config uses natural sorting'
assert_contains "$yazi_config" '[preview]' 'Yazi config has preview section'
assert_contains "$yazi_keymap" 'prepend_keymap' 'Yazi keymap exists'
assert_contains "$yazi_theme" '[manager]' 'Yazi theme has manager section'
assert_contains "$functions_config" 'y()' 'Yazi helper is implemented'
assert_contains "$functions_config" '--cwd-file="$tmp"' 'Yazi helper supports cwd-file directory handoff'
assert_contains "$doctor" 'check_yazi' 'doctor implements Yazi checks'
assert_contains "$doctor" 'workstation_find_yazi' 'doctor uses shared Yazi command resolver'
assert_contains "$doctor" 'Yazi agent status' 'doctor records Yazi non-agent status'
assert_contains "$doctor" 'not an AI agent' 'doctor states Yazi is not an AI agent'
assert_contains "$doctor" 'optional_command ffmpeg' 'doctor checks optional preview dependency ffmpeg'
assert_contains "$doctor" 'find_command 7z 7zz' 'doctor checks optional archive preview dependency'
assert_contains "$wezterm_config" "spawn_interactive_bash_command('y')" 'WezTerm opens Yazi new pane through interactive Bash'
assert_contains "$wezterm_config" "SendString 'y" 'WezTerm opens Yazi in current pane'
assert_contains "$setup_ps1" "'yazi'" 'setup.ps1 accepts yazi phase'
assert_contains "$setup_ps1" 'Ensure-WindowsYazi' 'setup.ps1 verifies Windows Yazi'
assert_contains "$setup_ps1" 'Invoke-WindowsYaziValidation' 'setup.ps1 validates Yazi phase'
assert_contains "$common_ps1" 'sxyazi.yazi' 'Windows setup helper knows Yazi package'
assert_contains "$reset_windows" ".config/yazi" 'reset-windows removes Yazi config for Phase 5'
assert_contains "$reset_windows" 'sxyazi.yazi' 'reset-windows can uninstall setup-managed Yazi package'
assert_contains "$yazi_doc" 'Yazi is not an AI agent' 'Yazi docs preserve non-agent boundary'
assert_contains "$yazi_doc" 'Ctrl+A' 'Yazi docs mention WezTerm bindings'
assert_not_contains "$agents_config" '[agents.yazi]' 'Yazi is absent from agent config'

finish_tests
