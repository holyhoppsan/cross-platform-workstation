#!/usr/bin/env bash
set -u

repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"

platform=$(setup_detect_platform)

if ! has_command yazi && ! has_command yazi.exe; then
  if [ "$platform" = windows ]; then
    if [ "$install_missing" = true ]; then
      if windows_command_exists winget; then
        info 'Yazi not found; installing with winget package sxyazi.yazi'
        powershell.exe -NoProfile -Command "winget install --id sxyazi.yazi --exact --accept-package-agreements --accept-source-agreements" || die 'winget failed to install Yazi'
      else
        die 'Yazi is missing and winget was not found. Install Yazi manually, then rerun setup.'
      fi
    else
      die 'Yazi is missing. Rerun with ./setup.sh --phase yazi --install-missing, or install with: winget install --id sxyazi.yazi --exact'
    fi
  elif [ "$platform" = macos ] && [ "$install_missing" = true ]; then
    macos_install_formulae yazi
  elif [ "$platform" = macos ]; then
    die 'Yazi is missing. Rerun with ./setup.sh --phase yazi --install-missing after Homebrew is available.'
  else
    die 'Yazi is missing. Install it with your platform package manager, then rerun setup.'
  fi
fi

require_file "$repo_root/chezmoi/dot_config/yazi/yazi.toml"
require_file "$repo_root/chezmoi/dot_config/yazi/keymap.toml"
require_file "$repo_root/chezmoi/dot_config/yazi/theme.toml"
info 'yazi phase checks passed'
