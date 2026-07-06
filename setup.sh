#!/usr/bin/env bash
set -u

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/setup/common.sh
. "$repo_root/scripts/setup/common.sh"

phase=shell
dry_run=false
install_missing=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --phase)
      [ "$#" -ge 2 ] || die '--phase requires a value'
      phase=$2
      shift 2
      ;;
    --phase=*)
      phase=${1#--phase=}
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --install-missing)
      install_missing=true
      shift
      ;;
    -h|--help)
      setup_usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

case "$phase" in
  foundation|shell|wezterm|quake|all) ;;
  *) die "phase is not implemented in this deliverable: $phase" ;;
esac

platform=$(setup_detect_platform)
info "repository: $repo_root"
info "platform: $platform"
info "phase: $phase"
info "dry_run: $dry_run"
info "install_missing: $install_missing"

if [ "$dry_run" = true ]; then
  info 'dry run only; no changes made'
  exit 0
fi

case "$phase" in
  foundation)
    "$repo_root/scripts/setup/phases/foundation.sh" "$repo_root"
    "$repo_root/scripts/doctor" --phase foundation
    ;;
  shell)
    "$repo_root/scripts/setup/phases/foundation.sh" "$repo_root"
    "$repo_root/scripts/setup/phases/shell.sh" "$repo_root" "$install_missing"
    setup_apply_chezmoi "$repo_root"
    "$repo_root/scripts/doctor" --phase shell
    setup_validate_interactive_shell "$repo_root"
    ;;
  wezterm)
    "$repo_root/scripts/setup/phases/foundation.sh" "$repo_root"
    "$repo_root/scripts/setup/phases/shell.sh" "$repo_root" "$install_missing"
    "$repo_root/scripts/setup/phases/wezterm.sh" "$repo_root" "$install_missing"
    setup_apply_chezmoi "$repo_root"
    "$repo_root/scripts/doctor" --phase wezterm
    setup_validate_interactive_shell "$repo_root"
    ;;
  quake)
    "$repo_root/scripts/setup/phases/foundation.sh" "$repo_root"
    "$repo_root/scripts/setup/phases/shell.sh" "$repo_root" "$install_missing"
    "$repo_root/scripts/setup/phases/wezterm.sh" "$repo_root" "$install_missing"
    if [ "$platform" = windows ]; then
      info 'Windows Quake setup is implemented in setup.ps1; run ./setup.ps1 -Phase quake from PowerShell.'
    else
      die 'Quake setup is currently implemented only for Windows; macOS and Ubuntu adapters are documented stubs.'
    fi
    ;;
  all)
    "$repo_root/scripts/setup/phases/foundation.sh" "$repo_root"
    "$repo_root/scripts/setup/phases/shell.sh" "$repo_root" "$install_missing"
    "$repo_root/scripts/setup/phases/wezterm.sh" "$repo_root" "$install_missing"
    setup_apply_chezmoi "$repo_root"
    "$repo_root/scripts/doctor" --phase wezterm
    setup_validate_interactive_shell "$repo_root"
    ;;
esac

cat <<'EOF'

Setup completed. Open a fresh Git Bash session and run:
  doctor --phase wezterm
EOF
