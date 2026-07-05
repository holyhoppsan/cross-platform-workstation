#!/usr/bin/env bash
set -u
repo_root=${1:?repo root required}
# shellcheck source=../common.sh
. "$repo_root/scripts/setup/common.sh"

require_command git
for path in \
  README.md \
  PLAN.md \
  AGENTS.md \
  docs/architecture.md \
  docs/implementation-plan.md \
  docs/provisioning.md \
  docs/shell.md \
  config/workstation.example.toml \
  config/agents.example.toml \
  config/models.example.toml \
  scripts/doctor \
  chezmoi/dot_bashrc \
  chezmoi/dot_bash_profile
do
  require_file "$repo_root/$path"
done

info 'foundation phase checks passed'

