#!/usr/bin/env bash
set -u
repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"
# shellcheck source=../../chezmoi/dot_config/workstation/platform.sh
. "$repo_root/chezmoi/dot_config/workstation/platform.sh"

if ! has_command nvim && ! has_command nvim.exe; then
  if [ "$WORKSTATION_OS" = windows ] && [ "$install_missing" = true ]; then
    if windows_command_exists winget; then
      info 'Neovim not found; installing with winget package Neovim.Neovim'
      powershell.exe -NoProfile -Command "winget install --id Neovim.Neovim --exact --accept-package-agreements --accept-source-agreements" || die 'winget failed to install Neovim'
    else
      die 'Neovim is missing and winget was not found. Install Neovim manually, then rerun setup.'
    fi
  else
    die 'Neovim is missing. Install it with your platform package manager, then rerun setup.'
  fi
fi

require_file "$repo_root/chezmoi/dot_config/nvim/init.lua"
require_dir "$repo_root/chezmoi/dot_config/nvim/lua/workstation"
info 'neovim phase checks passed'
