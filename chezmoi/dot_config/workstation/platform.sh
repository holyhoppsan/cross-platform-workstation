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

workstation_prepend_path_entry() {
  local entry path_entry filtered_path previous_ifs
  entry=$1
  filtered_path=''
  previous_ifs=$IFS
  IFS=:

  for path_entry in $PATH; do
    [ "$path_entry" = "$entry" ] && continue
    if [ -n "$filtered_path" ]; then
      filtered_path="$filtered_path:$path_entry"
    else
      filtered_path=$path_entry
    fi
  done

  IFS=$previous_ifs
  PATH=$entry
  [ -n "$filtered_path" ] && PATH="$PATH:$filtered_path"
}

workstation_add_homebrew_path() {
  [ "${WORKSTATION_OS:-$(workstation_detect_platform)}" = macos ] || return 0

  local brew_path brew_prefix
  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$brew_path" ] || continue
    brew_prefix=$("$brew_path" --prefix 2>/dev/null) || continue

    workstation_prepend_path_entry "$brew_prefix/bin"
    workstation_prepend_path_entry "$brew_prefix/sbin"
    export PATH
    return 0
  done
}

WORKSTATION_OS=${WORKSTATION_OS:-$(workstation_detect_platform)}
export WORKSTATION_OS
