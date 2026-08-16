#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

runbook=$(cat "$repo_root/docs/macos-agent-validation.md")
plan=$(cat "$repo_root/PLAN.md")

assert_contains "$runbook" 'Do not install Homebrew automatically' 'macOS runbook blocks automatic Homebrew installation'
assert_contains "$runbook" 'xcode-select -p' 'macOS runbook checks Xcode Command Line Tools'
assert_contains "$runbook" 'brew install bash chezmoi neovim yazi ripgrep fd jq fzf' 'macOS runbook defines user-approved CLI prerequisites'
assert_contains "$runbook" 'brew install --cask wezterm' 'macOS runbook defines WezTerm installation'
assert_contains "$runbook" './setup.sh --phase yazi --dry-run' 'macOS runbook includes setup dry run'
assert_contains "$runbook" './tests/run.bash' 'macOS runbook includes repository tests'
assert_contains "$runbook" 'User-performed GUI validation' 'macOS runbook keeps GUI validation manual'
assert_contains "$runbook" 'Do not work around these conditions with an alternate package manager or a curl-to-shell installer' 'macOS runbook has explicit stop condition'
assert_contains "$plan" 'docs/macos-agent-validation.md' 'Phase 6 plan links the agent validation runbook'

finish_tests
