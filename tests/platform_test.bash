#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"
# shellcheck source=../chezmoi/dot_config/workstation/platform.sh
. "$repo_root/chezmoi/dot_config/workstation/platform.sh"

assert_eq windows "$(workstation_detect_platform MINGW64_NT-10.0)" 'detects Git Bash'
assert_eq windows "$(workstation_detect_platform MSYS_NT-10.0)" 'detects MSYS'
assert_eq macos "$(workstation_detect_platform Darwin)" 'detects macOS'
assert_eq unknown "$(workstation_detect_platform Plan9)" 'handles unknown kernels'
finish_tests

