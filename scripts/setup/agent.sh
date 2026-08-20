#!/usr/bin/env bash
set -eu
repo_root=${1:?repo root required}
agent=${2:?agent required}
install_missing=${3:-false}
. "$repo_root/scripts/setup/common.sh"
platform=$(setup_detect_platform)
case "$agent" in
  pi) package='@earendil-works/pi-coding-agent'; command_name='pi' ;;
  codex) package='@openai/codex'; command_name='codex' ;;
esac
if ! has_command node || ! has_command npm; then
  [ "$install_missing" = true ] || die "Node.js/npm is required for $agent. Rerun with --install-missing."
  [ "$platform" = macos ] || die 'Agent installation through setup.sh is supported on macOS only; use setup.ps1 on Windows.'
  macos_install_formulae node
fi
if ! has_command "$command_name"; then
  [ "$install_missing" = true ] || die "$agent is missing. Rerun with --agent $agent --install-missing."
  info "installing $agent with npm package $package"
  npm install -g --ignore-scripts "$package"
fi
"$command_name" --version
