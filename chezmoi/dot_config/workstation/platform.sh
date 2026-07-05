#!/usr/bin/env bash

workstation_detect_platform() {
  local kernel="${1:-}"
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

workstation_is_git_bash() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    MINGW*|MSYS*) return 0 ;;
    *) return 1 ;;
  esac
}

workstation_git_bash_path() {
  if [ "${WORKSTATION_OS:-$(workstation_detect_platform)}" != windows ]; then
    return 1
  fi

  if [ -n "${BASH:-}" ] && [ -x "$BASH" ]; then
    if command -v cygpath >/dev/null 2>&1; then
      cygpath -w -- "$BASH"
    else
      printf '%s\n' "$BASH"
    fi
    return 0
  fi

  command -v bash 2>/dev/null || return 1
}

workstation_session_type() {
  printf '%s\n' "${XDG_SESSION_TYPE:-unknown}"
}

WORKSTATION_OS=${WORKSTATION_OS:-$(workstation_detect_platform)}
export WORKSTATION_OS
