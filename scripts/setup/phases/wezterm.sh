#!/usr/bin/env bash
set -u
repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"
# shellcheck source=../../chezmoi/dot_config/workstation/platform.sh
. "$repo_root/chezmoi/dot_config/workstation/platform.sh"

if ! has_command wezterm && ! has_command wezterm.exe; then
  if [ "$WORKSTATION_OS" = windows ] && [ "$install_missing" = true ]; then
    if windows_command_exists winget; then
      info 'WezTerm not found; installing with winget package wez.wezterm'
      powershell.exe -NoProfile -Command "winget install --id wez.wezterm --exact --accept-package-agreements --accept-source-agreements" || die 'winget failed to install WezTerm'
    else
      die 'WezTerm is missing and winget was not found. Install WezTerm manually, then rerun setup.'
    fi
  else
    die 'WezTerm is missing. Install it with your platform package manager, then rerun setup.'
  fi
fi

require_file "$repo_root/chezmoi/dot_config/wezterm/wezterm.lua"
info 'wezterm phase checks passed'
