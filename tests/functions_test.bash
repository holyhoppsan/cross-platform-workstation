#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"
# shellcheck source=../chezmoi/dot_config/workstation/platform.sh
. "$repo_root/chezmoi/dot_config/workstation/platform.sh"
# shellcheck source=../chezmoi/dot_config/workstation/functions.sh
. "$repo_root/chezmoi/dot_config/workstation/functions.sh"

WORKSTATION_OS=macos
assert_eq '/tmp/a path' "$(winpath '/tmp/a path')" 'POSIX winpath preserves spaces'
assert_eq '/tmp/a path' "$(unixpath '/tmp/a path')" 'POSIX unixpath preserves spaces'

WORKSTATION_OS=windows
cygpath() {
  case "$1" in
    -aw) printf 'C:\\work path\\file.txt\n' ;;
    -au) printf '/c/work path/file.txt\n' ;;
    *) return 2 ;;
  esac
}
assert_eq 'C:\work path\file.txt' "$(winpath '/c/work path/file.txt')" 'Windows conversion preserves one argument'
assert_eq '/c/work path/file.txt' "$(unixpath 'C:\work path\file.txt')" 'Unix conversion preserves one argument'

project >/tmp/project-stub.out 2>&1
assert_eq 64 "$?" 'project helper is an explicit stub'
agent >/tmp/agent-stub.out 2>&1
assert_eq 64 "$?" 'agent helper is an explicit stub'

shell_config=$(cat "$repo_root/chezmoi/dot_config/workstation/shell.sh")
assert_contains "$shell_config" 'Microsoft/WinGet/Links' 'Windows shell adds winget links directory'
assert_contains "$shell_config" 'workstation/env.sh' 'shell loads machine-local workstation env'

functions_config=$(cat "$repo_root/chezmoi/dot_config/workstation/functions.sh")
assert_contains "$functions_config" 'workstation_load_env' 'functions can load machine-local workstation env'

doctor_config=$(cat "$repo_root/chezmoi/dot_config/workstation/doctor")
assert_contains "$doctor_config" 'workstation_load_env' 'doctor can load machine-local workstation env'

WORKSTATION_REPO_ROOT="$repo_root"
assert_eq "$repo_root" "$(workstation-root)" 'workstation-root uses configured repository root'
finish_tests
