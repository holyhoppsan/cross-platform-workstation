#!/usr/bin/env bash
set -u
repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"
# shellcheck source=../../chezmoi/dot_config/workstation/platform.sh
. "$repo_root/chezmoi/dot_config/workstation/platform.sh"

require_command bash
require_command git

if [ "$WORKSTATION_OS" = windows ]; then
  workstation_is_git_bash || die 'Phase 1 shell setup must be run from Git for Windows Bash on Windows'
  workstation_git_bash_path >/dev/null 2>&1 || die 'Git Bash path could not be detected'
fi

if ! has_command chezmoi; then
  if [ "$WORKSTATION_OS" = windows ]; then
    if [ "$install_missing" = true ]; then
      if windows_command_exists winget; then
        info 'chezmoi not found; installing with winget package twpayne.chezmoi'
        powershell.exe -NoProfile -Command "winget install --id twpayne.chezmoi --exact --accept-package-agreements --accept-source-agreements" || die 'winget failed to install chezmoi'
      else
        die 'chezmoi is missing and winget was not found. Install chezmoi manually, then rerun setup.'
      fi
    else
      die 'chezmoi is missing. Rerun with ./setup.sh --phase shell --install-missing, or install with: winget install --id twpayne.chezmoi --exact'
    fi
  else
    die 'chezmoi is missing. Install it with your platform package manager, then rerun setup.'
  fi
fi

info 'shell phase checks passed'
