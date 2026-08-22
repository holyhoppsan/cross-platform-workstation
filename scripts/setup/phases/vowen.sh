#!/usr/bin/env bash
set -u

repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"

platform=$(setup_detect_platform)

case "$platform" in
  macos)
    if [ -d /Applications/Vowen.app ] || [ -d "$HOME/Applications/Vowen.app" ]; then
      info 'Vowen already detected'
    elif [ "$install_missing" = true ]; then
      info 'opening the official Vowen macOS download page; DMG download, security review, installation, and permissions remain manual'
      open 'https://vowen.ai/mac/download/'
    else
      info 'Vowen is optional and was not detected. Rerun with ./setup.sh --phase vowen --install-missing to open the official download page.'
    fi
    ;;
  windows)
    vowen_path=''
    for candidate in \
      "$HOME/AppData/Local/Programs/Vowen/Vowen.exe" \
      "$HOME/AppData/Local/Vowen/Vowen.exe" \
      '/c/Program Files/Vowen/Vowen.exe'; do
      if [ -r "$candidate" ]; then
        vowen_path=$candidate
        break
      fi
    done
    if [ -n "$vowen_path" ]; then
      info "Vowen already detected: $vowen_path"
    elif [ "$install_missing" = true ]; then
      info 'opening the official Vowen Windows download page; download, security review, installation, and permissions remain manual'
      powershell.exe -NoProfile -Command "Start-Process 'https://vowen.ai/windows/download/'"
    else
      info 'Vowen is optional. From PowerShell, use ./setup.ps1 -Phase vowen -InstallVowen to open the official download page.'
    fi
    ;;
  *)
    die 'Vowen setup currently supports only Windows and macOS. See docs/vowen.md for manual guidance.'
    ;;
esac
