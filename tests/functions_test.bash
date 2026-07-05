#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"
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
finish_tests

