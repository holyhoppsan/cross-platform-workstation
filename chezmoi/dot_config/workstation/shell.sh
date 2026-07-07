#!/usr/bin/env bash

# Conservative interactive safety: no aliases alter rm/cp/mv behavior.
set -o notify
shopt -s checkwinsize histappend
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000

path_prepend() {
  [ "$#" -eq 1 ] || return 2
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
  export PATH
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/workstation/env.sh" ]; then
  # shellcheck source=env.sh
  . "${XDG_CONFIG_HOME:-$HOME/.config}/workstation/env.sh"
fi

if [ "${WORKSTATION_OS:-}" = windows ] && command -v cygpath >/dev/null 2>&1 && [ -n "${LOCALAPPDATA:-}" ]; then
  path_prepend "$(cygpath -u "$LOCALAPPDATA")/Microsoft/WinGet/Links"
fi

if [ "${WORKSTATION_OS:-}" = windows ] && command -v cygpath >/dev/null 2>&1 && [ -n "${ProgramFiles:-}" ]; then
  path_prepend "$(cygpath -u "$ProgramFiles")/WezTerm"
  path_prepend "$(cygpath -u "$ProgramFiles")/Neovim/bin"
fi

if [ "${WORKSTATION_OS:-}" = windows ]; then
  path_prepend '/c/Program Files/WezTerm'
  path_prepend '/c/Program Files/Neovim/bin'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate -20'

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border}"
fi

if command -v rg >/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-}"
fi
