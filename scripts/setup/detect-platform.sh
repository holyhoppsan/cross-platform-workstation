#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
# shellcheck source=common.sh
. "$repo_root/scripts/setup/common.sh"
setup_detect_platform

