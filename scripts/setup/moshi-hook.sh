#!/usr/bin/env bash
set -u

repo_root=${1:?repo root required}
install_missing=${2:-false}
# shellcheck source=common.sh
. "$repo_root/scripts/setup/common.sh"

if [ "$(setup_detect_platform)" != macos ]; then
  die 'Moshi hook setup is currently implemented only for macOS; Windows MSYS2 support is intentionally deferred.'
fi

if has_command moshi-hook; then
  info 'Moshi hook already available'
  moshi-hook version
  exit 0
fi

if [ "$install_missing" != true ]; then
  die 'Moshi hook is missing. Rerun with ./setup.sh --moshi-hook --install-missing after Homebrew is available.'
fi

require_command brew
info 'adding the documented Moshi Homebrew tap'
brew tap rjyo/moshi || die 'Homebrew failed while adding the Moshi tap.'
macos_install_formulae moshi-hook
has_command moshi-hook || die 'Moshi hook installation completed but moshi-hook was not found on PATH.'
moshi-hook version
info 'Moshi hook is installed only; pairing, service activation, and agent-hook installation remain manual.'
