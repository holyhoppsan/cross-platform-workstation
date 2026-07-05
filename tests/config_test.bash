#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

wezterm_config=$(cat "$repo_root/chezmoi/dot_config/wezterm/wezterm.lua")
assert_contains "$wezterm_config" "key = 'a', mods = 'CTRL'" 'defines Ctrl+A leader'
assert_contains "$wezterm_config" "flags = 'FUZZY|WORKSPACES'" 'defines workspace picker'
assert_contains "$wezterm_config" "window:active_workspace()" 'shows active workspace'
assert_contains "$wezterm_config" "name = 'quake'" 'defines dedicated Quake workspace action'
assert_contains "$wezterm_config" "workstation-next-agent" 'defines agent attention traversal'
assert_contains "$wezterm_config" "SwitchToWorkspace" 'defines project workspace creation'

models=$(cat "$repo_root/config/models.example.toml")
for profile in local-fast local-coder cloud-fast cloud-reasoning review; do
  assert_contains "$models" "[profiles.$profile]" "defines $profile profile"
done
finish_tests
