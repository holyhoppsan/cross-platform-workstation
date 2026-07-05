#!/usr/bin/env bash

info() { printf '[setup] %s\n' "$*"; }
die() { printf '[setup] error: %s\n' "$*" >&2; exit 2; }

setup_usage() {
  cat <<'EOF'
usage: setup.sh [--phase foundation|shell|all] [--dry-run] [--install-missing]

Only Phase 0 and Phase 1 are implemented in this deliverable.
EOF
}

setup_detect_platform() {
  local kernel
  kernel=$(uname -s 2>/dev/null || printf unknown)
  case "$kernel" in
    MINGW*|MSYS*|CYGWIN*) printf '%s\n' windows ;;
    Darwin) printf '%s\n' macos ;;
    Linux)
      if [ -r /etc/os-release ] && grep -Eq '^(ID|ID_LIKE)=.*ubuntu' /etc/os-release; then
        printf '%s\n' ubuntu
      else
        printf '%s\n' linux
      fi
      ;;
    *) printf '%s\n' unknown ;;
  esac
}

require_file() {
  [ -r "$1" ] || die "missing required file: $1"
}

require_dir() {
  [ -d "$1" ] || die "missing required directory: $1"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

windows_command_exists() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  fi
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "if (Get-Command '$1' -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }" >/dev/null 2>&1
    return $?
  fi
  return 1
}

setup_apply_chezmoi() {
  local repo_root=${1:?repo root required}
  local source_dir="$repo_root/chezmoi"
  require_command chezmoi
  require_dir "$source_dir"
  info "initializing chezmoi source: $source_dir"
  chezmoi init --source "$source_dir"
  info 'applying chezmoi dotfiles'
  chezmoi --source "$source_dir" apply
}

setup_validate_interactive_shell() {
  local repo_root=${1:?repo root required}
  info 'validating configured interactive Bash shell'
  (
    cd "$repo_root" || exit 1
    bash -i -c '
      set -e
      export WORKSTATION_REPO_ROOT="$PWD"
      platform-info
      doctor --phase shell
      native_path=$(winpath "$PWD")
      test -n "$native_path"
      unix_path=$(unixpath "$native_path")
      test -n "$unix_path"
      project >/tmp/workstation-project-stub.out 2>&1 && exit 1 || test "$?" -eq 64
      agent >/tmp/workstation-agent-stub.out 2>&1 && exit 1 || test "$?" -eq 64
    '
  )
}
