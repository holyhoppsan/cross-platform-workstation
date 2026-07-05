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

default_output=$("$repo_root/setup.sh" --dry-run)
assert_contains "$default_output" 'phase: shell' 'setup.sh defaults to current implemented phase'

install_output=$("$repo_root/setup.sh" --phase shell --install-missing --dry-run)
assert_contains "$install_output" 'install_missing: true' 'setup.sh parses install-missing'

powershell_setup=$(cat "$repo_root/setup.ps1")
assert_contains "$powershell_setup" "[string]\$Phase = 'shell'" 'setup.ps1 defaults to shell phase'
assert_contains "$powershell_setup" 'Ensure-WindowsPhaseOneTools' 'setup.ps1 installs or verifies Windows Phase 1 tools'
assert_contains "$powershell_setup" 'Invoke-ChezmoiApply' 'setup.ps1 applies chezmoi'
assert_contains "$powershell_setup" 'Invoke-WindowsShellValidation' 'setup.ps1 validates configured Git Bash'

common_ps1=$(cat "$repo_root/scripts/setup/common.ps1")
assert_contains "$common_ps1" "PackageId 'Git.Git'" 'Windows bootstrap knows Git package'
assert_contains "$common_ps1" "PackageId 'twpayne.chezmoi'" 'Windows bootstrap knows chezmoi package'
assert_contains "$common_ps1" 'Do not install WSL' 'placeholder'

common_sh=$(cat "$repo_root/scripts/setup/common.sh")
assert_contains "$common_sh" 'setup_apply_chezmoi' 'setup.sh has chezmoi apply helper'
assert_contains "$common_sh" 'setup_validate_interactive_shell' 'setup.sh has interactive shell validation helper'

detect_output=$("$repo_root/scripts/setup/detect-platform.sh")
case "$detect_output" in
  windows|macos|ubuntu|linux|unknown) assert_eq "$detect_output" "$detect_output" 'detect-platform emits known token' ;;
  *) assert_eq 'known-platform-token' "$detect_output" 'detect-platform emits known token' ;;
esac

finish_tests
