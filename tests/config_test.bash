#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

workstation_config=$(cat "$repo_root/config/workstation.example.toml")
assert_contains "$workstation_config" 'foundation = true' 'foundation feature enabled'
assert_contains "$workstation_config" 'bash = true' 'bash feature enabled'
assert_contains "$workstation_config" 'wezterm = true' 'WezTerm feature enabled'
assert_contains "$workstation_config" 'install_wsl = false' 'WSL disabled'
assert_contains "$workstation_config" 'shell = "git-bash"' 'Windows shell is Git Bash'

agents_config=$(cat "$repo_root/config/agents.example.toml")
assert_contains "$agents_config" '[agents.opencode]' 'OpenCode placeholder exists'
assert_contains "$agents_config" '[agents.goose]' 'Goose placeholder exists'

models=$(cat "$repo_root/config/models.example.toml")
for profile in local-fast local-coder cloud-fast cloud-reasoning review; do
  assert_contains "$models" "[profiles.$profile]" "defines $profile model profile"
done
assert_contains "$models" 'api_key_env' 'models use environment variable placeholders'
finish_tests
