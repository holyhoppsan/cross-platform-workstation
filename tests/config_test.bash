#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

workstation_config=$(cat "$repo_root/config/workstation.example.toml")
assert_contains "$workstation_config" 'foundation = true' 'foundation feature enabled'
assert_contains "$workstation_config" 'bash = true' 'bash feature enabled'
assert_contains "$workstation_config" 'wezterm = true' 'WezTerm feature enabled'
assert_contains "$workstation_config" 'neovim = true' 'Neovim feature enabled'
assert_contains "$workstation_config" 'yazi = true' 'Yazi feature enabled'
assert_contains "$workstation_config" 'install_wsl = false' 'WSL disabled'
assert_contains "$workstation_config" 'shell = "msys2-ucrt64"' 'Windows shell is MSYS2 UCRT64'

agents_config=$(cat "$repo_root/config/agents.example.toml")
assert_contains "$agents_config" '[agents.opencode]' 'OpenCode placeholder exists'
assert_contains "$agents_config" '[agents.goose]' 'Goose placeholder exists'
assert_not_contains "$agents_config" '[agents.yazi]' 'Yazi is not an agent'
assert_not_contains "$agents_config" '[agents.yasi]' 'Yasi typo is not an agent'

models=$(cat "$repo_root/config/models.example.toml")
for profile in local-fast local-coder cloud-fast cloud-reasoning review; do
  assert_contains "$models" "[profiles.$profile]" "defines $profile model profile"
done
assert_contains "$models" 'api_key_env' 'models use environment variable placeholders'
finish_tests
