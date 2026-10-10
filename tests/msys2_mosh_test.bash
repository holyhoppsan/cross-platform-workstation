#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

setup_file="$repo_root/platform/windows/setup-msys2-mosh.ps1"
service_file="$repo_root/platform/windows/configure-msys2-sshd.sh"
setup_source=$(cat "$setup_file")
service_source=$(cat "$service_file")

package_list=$(sed -n "/^\$RequiredMsys2Packages = @(/,/^)/p" "$setup_file" |
  sed -n "s/^[[:space:]]*'\([^']*\)',\{0,1\}$/\1/p" |
  paste -sd, -)
assert_eq 'openssh,mosh,cygrunsrv,mingw-w64-ucrt-x86_64-editrights' "$package_list" 'MSYS2 Mosh preflight has the exact prerequisite package list'

assert_contains "$setup_source" '[switch]$InstallMissing' 'MSYS2 Mosh setup has an explicit InstallMissing switch'
assert_contains "$setup_source" 'Preflight only. No packages, services, authorized keys, or firewall rules were changed.' 'MSYS2 Mosh dry run is explicitly non-mutating'
assert_contains "$setup_source" 'missing MSYS2 packages:' 'MSYS2 Mosh preflight aggregates missing packages'
assert_contains "$setup_source" 'missing required commands:' 'MSYS2 Mosh preflight aggregates missing commands'
assert_contains "$setup_source" 'MSYS2 SSH/Mosh prerequisites are missing. No service or firewall changes were made.' 'MSYS2 Mosh apply refuses missing prerequisites without InstallMissing'
assert_contains "$setup_source" 'Ensure-Msys2Ucrt64Packages -Packages $prerequisites.MissingPackages' 'MSYS2 Mosh install path reuses the shared package helper'
assert_not_contains "$setup_source" 'pacman -Sy' 'MSYS2 Mosh setup never refreshes package databases alone'
assert_not_contains "$setup_source" 'pacman -Syu' 'MSYS2 Mosh setup never silently performs a full upgrade'

first_preflight_line=$(grep -n '\$prerequisites = Get-Msys2MoshPrerequisites' "$setup_file" | head -n 1 | cut -d: -f1)
install_line=$(grep -n 'Ensure-Msys2Ucrt64Packages -Packages \$prerequisites.MissingPackages$' "$setup_file" | head -n 1 | cut -d: -f1)
second_preflight_line=$(grep -n '\$prerequisites = Get-Msys2MoshPrerequisites' "$setup_file" | tail -n 1 | cut -d: -f1)
service_line=$(grep -n "installing and starting the MSYS2 sshd service" "$setup_file" | cut -d: -f1)
if [ "$first_preflight_line" -lt "$install_line" ] && [ "$install_line" -lt "$second_preflight_line" ] && [ "$second_preflight_line" -lt "$service_line" ]; then
  assert_eq revalidated revalidated 'MSYS2 Mosh setup revalidates after installation and before service creation'
else
  assert_eq 'preflight-install-revalidate-service' 'incorrect-order' 'MSYS2 Mosh setup revalidates after installation and before service creation'
fi

assert_contains "$setup_source" "'/usr/bin/cygrunsrv'" 'MSYS2 Mosh preflight checks cygrunsrv at its required path'
assert_contains "$setup_source" "'/usr/bin/ssh-keygen'" 'MSYS2 Mosh preflight checks ssh-keygen at its required path'
assert_contains "$setup_source" "'/usr/bin/sshd'" 'MSYS2 Mosh preflight checks sshd at its required path'
assert_contains "$setup_source" "'/usr/bin/mosh-server'" 'MSYS2 Mosh preflight checks mosh-server at its required path'
assert_contains "$setup_source" "'getent'" 'MSYS2 Mosh preflight checks getent'
assert_contains "$setup_source" "'net'" 'MSYS2 Mosh preflight checks net'
assert_contains "$setup_source" "'/ucrt64/bin/editrights'" 'MSYS2 Mosh preflight checks UCRT64 editrights at its required path'

key_validation_line=$(grep -n 'Test-AuthorizedPublicKey -Path' "$setup_file" | cut -d: -f1)
first_package_action_line=$(grep -n 'Ensure-Msys2Ucrt64Packages -Packages' "$setup_file" | head -n 1 | cut -d: -f1)
if [ "$key_validation_line" -lt "$first_package_action_line" ]; then
  assert_eq validated validated 'MSYS2 Mosh validates key input before package or service changes'
else
  assert_eq 'key-before-writes' 'incorrect-order' 'MSYS2 Mosh validates key input before package or service changes'
fi

assert_contains "$service_source" 'PubkeyAuthentication yes' 'MSYS2 SSH continues to enable public-key authentication'
assert_contains "$service_source" 'PasswordAuthentication no' 'MSYS2 SSH continues to disable password authentication'
assert_contains "$service_source" 'KbdInteractiveAuthentication no' 'MSYS2 SSH continues to disable keyboard-interactive authentication'
assert_contains "$setup_source" '-Profile Private' 'MSYS2 Mosh firewall remains Private-profile scoped'
assert_contains "$setup_source" "@('LocalSubnet')" 'MSYS2 Mosh firewall remains LocalSubnet scoped by default'
assert_contains "$setup_source" "-contains 'Any'" 'MSYS2 Mosh setup continues to reject public Any scope'
assert_contains "$service_source" 'grep -Fqx "$key_line" "$authorized_keys" ||' 'MSYS2 SSH authorized-key installation remains idempotent'
assert_contains "$service_source" 'cygrunsrv -R "$service_name"' 'MSYS2 SSH service replacement remains rerunnable'

finish_tests
