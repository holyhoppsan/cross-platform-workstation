#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
phase=${1:-foundation}
"$repo_root/scripts/doctor" --phase "$phase"

