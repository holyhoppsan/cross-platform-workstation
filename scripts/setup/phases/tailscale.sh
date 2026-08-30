#!/usr/bin/env bash
set -u

repo_root=${1:?repo root required}
install_missing=${2:-false}
enable_mosh_host=${3:-false}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"

platform=$(setup_detect_platform)
case "$platform" in
  macos)
    if [ -d /Applications/Tailscale.app ]; then
      info 'Tailscale app already detected'
    elif [ "$install_missing" = true ]; then
      macos_install_cask tailscale
      [ -d /Applications/Tailscale.app ] || die 'Tailscale cask completed but /Applications/Tailscale.app was not found.'
    else
      die 'Tailscale is missing. Rerun with ./setup.sh --phase tailscale --install-missing after Homebrew is available.'
    fi
    if [ "$enable_mosh_host" = true ]; then
      if has_command mosh-server; then
        info 'Mosh server already available'
      elif [ "$install_missing" = true ]; then
        macos_install_formulae mosh
      else
        die 'Mosh is missing. Rerun with ./setup.sh --phase tailscale --enable-mosh-host --install-missing.'
      fi
    else
      info 'Mosh host preparation not requested; use --enable-mosh-host when this Mac should accept ShadowTerm Mosh connections'
    fi
    ;;
  windows)
    die 'Tailscale setup for the Windows MSYS2 SSH/Mosh host uses normal PowerShell; run ./setup.ps1 -Phase tailscale.'
    ;;
  *)
    die 'Tailscale setup is currently implemented for Windows and macOS only.'
    ;;
esac
