#!/usr/bin/env bash

has() { command -v "$1" >/dev/null 2>&1; }

winpath() {
  if [ "${WORKSTATION_OS:-}" != windows ]; then
    printf '%s\n' "$1"
  elif command -v cygpath >/dev/null 2>&1; then
    cygpath -aw -- "$1"
  else
    printf 'winpath: cygpath is required in Git Bash\n' >&2
    return 1
  fi
}

unixpath() {
  if [ "${WORKSTATION_OS:-}" != windows ]; then
    printf '%s\n' "$1"
  elif command -v cygpath >/dev/null 2>&1; then
    cygpath -au -- "$1"
  else
    printf 'unixpath: cygpath is required in Git Bash\n' >&2
    return 1
  fi
}

croot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf 'croot: not inside a Git worktree\n' >&2
    return 1
  }
  cd "$root" || return
}

mkcd() {
  [ "$#" -eq 1 ] || { printf 'usage: mkcd DIRECTORY\n' >&2; return 2; }
  mkdir -p -- "$1" && cd "$1"
}

gfind() {
  if has rg; then rg --files "$@"; else git ls-files "$@"; fi
}

fdx() {
  if has fd; then fd "$@"; elif has fdfind; then fdfind "$@"; else find . "$@"; fi
}

jqf() { jq -C "$@" | less -R; }
uvr() { uv run "$@"; }
nrun() { npm run "$@"; }
cmake-configure() { cmake -S "${1:-.}" -B "${2:-build}" -G Ninja; }
cmake-build() { cmake --build "${1:-build}" -- "${@:2}"; }

