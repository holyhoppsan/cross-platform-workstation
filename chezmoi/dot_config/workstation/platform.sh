#!/usr/bin/env bash

# Detection accepts an optional uname value to make behavior testable.
workstation_detect_platform() {
  local kernel=${1:-}
  if [ -z "$kernel" ]; then
    kernel=$(uname -s 2>/dev/null || printf 'unknown')
  fi

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

WORKSTATION_OS=${WORKSTATION_OS:-$(workstation_detect_platform)}
export WORKSTATION_OS

workstation_git_bash_path() {
  [ "$WORKSTATION_OS" = windows ] || return 1
  if [ -n "${BASH:-}" ] && [ -x "$BASH" ]; then
    cygpath -w "$BASH" 2>/dev/null || printf '%s\n' "$BASH"
    return 0
  fi
  command -v bash 2>/dev/null || return 1
}

