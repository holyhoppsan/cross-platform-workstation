#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

wezterm_config=$(cat "$repo_root/chezmoi/dot_config/wezterm/wezterm.lua")
helper_block=$(sed -n '/local function spawn_bash_command/,/^end/p' "$repo_root/chezmoi/dot_config/wezterm/wezterm.lua")
wezterm_doc=$(cat "$repo_root/docs/wezterm.md")
doctor=$(cat "$repo_root/chezmoi/dot_config/workstation/doctor")

assert_not_contains "$wezterm_config" 'intentionally not implemented' 'WezTerm placeholder failure removed'
assert_contains "$wezterm_config" "foreground = '#cccccc'" 'WezTerm mirrors Windows Terminal default foreground'
assert_contains "$wezterm_config" "background = '#0c0c0c'" 'WezTerm mirrors Windows Terminal default background'
assert_contains "$wezterm_config" "'#c50f1f'" 'WezTerm includes Windows Terminal default red'
assert_contains "$wezterm_config" "'#3b78ff'" 'WezTerm includes Windows Terminal bright blue'
assert_not_contains "$wezterm_config" 'Solarized' 'WezTerm no longer uses hard-to-read Solarized scheme'
assert_contains "$wezterm_config" "config.leader = { key = 'a', mods = 'CTRL'" 'WezTerm uses Ctrl+A leader'
assert_contains "$wezterm_config" 'SplitHorizontal' 'WezTerm has horizontal split binding'
assert_contains "$wezterm_config" "key = '|', mods = 'CTRL|SHIFT'" 'WezTerm has one-stroke tmux-symbol horizontal split binding'
assert_contains "$wezterm_config" "key = 'mapped:|', mods = 'CTRL|SHIFT'" 'WezTerm has mapped one-stroke horizontal split binding'
assert_contains "$wezterm_config" "key = '-', mods = 'CTRL'" 'WezTerm has one-stroke tmux-symbol vertical split binding'
assert_contains "$wezterm_config" "key = 'mapped:-', mods = 'CTRL'" 'WezTerm has mapped one-stroke vertical split binding'
assert_contains "$wezterm_config" "key = '_', mods = 'CTRL|SHIFT'" 'WezTerm has shifted-minus vertical split fallback'
assert_contains "$wezterm_config" "key = '_', mods = 'LEADER|SHIFT'" 'WezTerm has leader shifted-minus vertical split fallback'
assert_contains "$wezterm_config" "key = '\\\\', mods = 'LEADER|SHIFT'" 'WezTerm has Windows shifted backslash split binding'
assert_contains "$wezterm_config" 'SplitVertical' 'WezTerm has vertical split binding'
assert_contains "$wezterm_config" 'ActivatePaneDirection' 'WezTerm has pane movement bindings'
assert_contains "$wezterm_config" 'AdjustPaneSize' 'WezTerm has pane resize bindings'
assert_contains "$wezterm_config" "SwitchToWorkspace { name = 'quake'" 'WezTerm has quake workspace placeholder'
assert_not_contains "$wezterm_config" "SpawnCommandInNewPane" 'WezTerm does not use invalid pane spawn action'
assert_contains "$wezterm_config" "SplitPane" 'WezTerm can spawn helper panes'
assert_not_contains "$helper_block" "domain =" 'SplitPane helper does not use invalid domain field'
assert_contains "$wezterm_config" 'workstation-next-agent' 'WezTerm has agent attention placeholder event'
assert_contains "$wezterm_config" "PasteFrom 'Clipboard'" 'WezTerm has explicit clipboard paste binding'
assert_contains "$wezterm_config" "CopyTo 'Clipboard'" 'WezTerm has explicit clipboard copy binding'
assert_contains "$wezterm_config" 'mouse_bindings' 'WezTerm has explicit mouse bindings'
assert_contains "$wezterm_config" "button = 'Right'" 'WezTerm right click is bound'
assert_contains "$wezterm_doc" 'Ctrl+A' 'WezTerm docs record leader key'
assert_contains "$wezterm_doc" 'Right click' 'WezTerm docs describe right-click paste'
assert_contains "$wezterm_doc" 'macOS and Ubuntu behavior must remain marked unvalidated' 'WezTerm docs mark unvalidated platforms'
assert_contains "$doctor" 'check_wezterm' 'doctor implements WezTerm checks'
assert_contains "$doctor" 'show-keys --lua' 'doctor validates WezTerm config loading'

finish_tests
