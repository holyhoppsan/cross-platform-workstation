#!/usr/bin/env bash

has() { command -v "$1" >/dev/null 2>&1; }

workstation_load_env() {
  if [ -n "${WORKSTATION_REPO_ROOT:-}" ]; then
    return 0
  fi

  local env_file="${XDG_CONFIG_HOME:-$HOME/.config}/workstation/env.sh"
  if [ -r "$env_file" ]; then
    # shellcheck source=env.sh
    . "$env_file"
  fi
}

winpath() {
  [ "$#" -eq 1 ] || { printf 'usage: winpath PATH\n' >&2; return 2; }
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
  [ "$#" -eq 1 ] || { printf 'usage: unixpath PATH\n' >&2; return 2; }
  if [ "${WORKSTATION_OS:-}" != windows ]; then
    printf '%s\n' "$1"
  elif command -v cygpath >/dev/null 2>&1; then
    cygpath -au -- "$1"
  else
    printf 'unixpath: cygpath is required in Git Bash\n' >&2
    return 1
  fi
}

platform-info() {
  printf 'os=%s\n' "${WORKSTATION_OS:-unknown}"
  printf 'kernel=%s\n' "$(uname -s 2>/dev/null || printf unknown)"
  printf 'machine=%s\n' "$(uname -m 2>/dev/null || printf unknown)"
  printf 'shell=%s\n' "${SHELL:-${COMSPEC:-unknown}}"
  if [ "${WORKSTATION_OS:-}" = windows ]; then
    if workstation_git_bash_path >/dev/null 2>&1; then
      printf 'git_bash=%s\n' "$(workstation_git_bash_path)"
    else
      printf 'git_bash=not-found\n'
    fi
  fi
}

workstation-root() {
  workstation_load_env

  if [ -n "${WORKSTATION_REPO_ROOT:-}" ] && [ -r "$WORKSTATION_REPO_ROOT/PLAN.md" ]; then
    printf '%s\n' "$WORKSTATION_REPO_ROOT"
    return 0
  fi

  local dir
  dir=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf 'workstation-root: not inside a Git worktree\n' >&2
    return 1
  }
  printf '%s\n' "$dir"
}

doctor() {
  workstation_load_env

  if command -v workstation-doctor >/dev/null 2>&1; then
    workstation-doctor "$@"
  elif [ -n "${WORKSTATION_REPO_ROOT:-}" ] && [ -x "$WORKSTATION_REPO_ROOT/scripts/doctor" ]; then
    "$WORKSTATION_REPO_ROOT/scripts/doctor" "$@"
  else
    printf 'doctor: workstation-doctor is not installed; run scripts/doctor from the repository\n' >&2
    return 127
  fi
}

project() { printf 'project: stubbed until Phase 7\n' >&2; return 64; }
y() { printf 'y: Yazi helper is stubbed until Phase 5\n' >&2; return 64; }
nv() { printf 'nv: Neovim helper is stubbed until Phase 4\n' >&2; return 64; }
rider() { printf 'rider: Rider helper is stubbed until Phase 6\n' >&2; return 64; }
wt-create() { printf 'wt-create: worktree helpers are stubbed until Phase 7\n' >&2; return 64; }
wt-list() { printf 'wt-list: worktree helpers are stubbed until Phase 7\n' >&2; return 64; }
wt-remove() { printf 'wt-remove: worktree helpers are stubbed until Phase 7\n' >&2; return 64; }
wt-open() { printf 'wt-open: worktree helpers are stubbed until Phase 7\n' >&2; return 64; }
agent() { printf 'agent: AI agent launcher is stubbed until Phase 8\n' >&2; return 64; }
agent-notify() { printf 'agent-notify: notification helper is stubbed until Phase 9\n' >&2; return 64; }

croot() {
  local root
  root=$(workstation-root) || return
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

workstation_check_unix_commands() {
  local missing=0
  local tool
  for tool in ls cd pwd cat grep git curl tar unzip mkdir rm cp mv; do
    case "$tool" in
      cd) : ;;
      *) command -v "$tool" >/dev/null 2>&1 || { printf '%s\n' "$tool"; missing=$((missing + 1)); } ;;
    esac
  done
  return "$missing"
}
