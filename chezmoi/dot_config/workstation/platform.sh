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

workstation_is_msys2_ucrt64() {
  case "$(uname -s 2>/dev/null || printf unknown):${MSYSTEM:-}" in
    MSYS*:UCRT64|MINGW*:UCRT64) return 0 ;;
    *) return 1 ;;
  esac
}

workstation_windows_bash_path() {
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

workstation_add_homebrew_path() {
  [ "${WORKSTATION_OS:-$(workstation_detect_platform)}" = macos ] || return 0

  local brew_path brew_prefix
  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$brew_path" ] || continue
    brew_prefix=$("$brew_path" --prefix 2>/dev/null) || continue

    case ":$PATH:" in
      *":$brew_prefix/bin:"*) ;;
      *) PATH="$brew_prefix/bin:$PATH" ;;
    esac
    case ":$PATH:" in
      *":$brew_prefix/sbin:"*) ;;
      *) PATH="$brew_prefix/sbin:$PATH" ;;
    esac
    export PATH
    return 0
  done
}

WORKSTATION_OS=${WORKSTATION_OS:-$(workstation_detect_platform)}
export WORKSTATION_OS
