#!/usr/bin/env bash
# Configure MSYS2's OpenSSH server for the LAN-only ShadowTerm/Mosh proof of concept.
# Run through setup-msys2-mosh.ps1; do not run this script directly from an
# unelevated shell.
set -euo pipefail

service_name='msys2_sshd'
service_description='MSYS2 sshd (cross-platform-workstation)'
sshd_port='22'
target_user=''
authorized_key=''

usage() {
  printf '%s\n' 'usage: configure-msys2-sshd.sh --target-user USER --authorized-key FILE [--sshd-port PORT]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target-user) target_user=${2:?missing target user}; shift 2 ;;
    --authorized-key) authorized_key=${2:?missing authorized-key path}; shift 2 ;;
    --sshd-port) sshd_port=${2:?missing SSH port}; shift 2 ;;
    *) usage >&2; exit 64 ;;
  esac
done

[ -n "$target_user" ] && [ -n "$authorized_key" ] || { usage >&2; exit 64; }
case "$sshd_port" in
  *[!0-9]*|'') printf '%s\n' 'SSH port must be numeric.' >&2; exit 64 ;;
esac

for command in cygrunsrv ssh-keygen sshd mosh-server net getent; do
  command -v "$command" >/dev/null || { printf 'Missing required command: %s\n' "$command" >&2; exit 1; }
done

editrights=/ucrt64/bin/editrights
[ -x "$editrights" ] || { printf '%s\n' 'Missing UCRT64 editrights. Install mingw-w64-ucrt-x86_64-editrights.' >&2; exit 1; }
[ -f "$authorized_key" ] || { printf 'Authorized-key file was not found: %s\n' "$authorized_key" >&2; exit 1; }

key_line=$(head -n 1 "$authorized_key" | tr -d '\r')
case "$key_line" in
  ssh-ed25519\ *|ecdsa-sha2-*\ *|sk-ssh-ed25519@openssh.com\ *|sk-ecdsa-sha2-nistp256@openssh.com\ *|ssh-rsa\ *) ;;
  *) printf '%s\n' 'Authorized-key file does not start with a supported OpenSSH public-key type.' >&2; exit 1 ;;
esac

# This is the privilege-separation account hard-coded by OpenSSH.  It is not
# an interactive login account.  This follows MSYS2's published setup recipe.
if ! net user sshd >/dev/null 2>&1; then
  net user sshd //add //fullname:'Privilege separation user for sshd' //homedir:"$(cygpath -w /var/empty)" //active:no
fi

mkdir -p /var/empty
chmod 755 /var/empty
ssh-keygen -A

# MSYS2's dynamic account lookup should use Windows profile homes. This makes
# the key location deterministic for the Windows account passed by the wrapper.
nsswitch=/etc/nsswitch.conf
if [ -f "$nsswitch" ]; then
  cp -n "$nsswitch" "$nsswitch.cross-platform-workstation.bak" || true
  if grep -q '^[[:space:]]*db_home:' "$nsswitch"; then
    sed -i -E 's|^[[:space:]]*db_home:.*$|db_home: windows|' "$nsswitch"
  else
    printf '\ndb_home: windows\n' >> "$nsswitch"
  fi
fi

home_directory=$(getent passwd "$target_user" | awk -F: 'NR == 1 { print $6 }')
[ -n "$home_directory" ] || { printf 'Could not resolve an MSYS2 home directory for Windows user %s.\n' "$target_user" >&2; exit 1; }

ssh_directory="$home_directory/.ssh"
authorized_keys="$ssh_directory/authorized_keys"
mkdir -p "$ssh_directory"
chmod 700 "$ssh_directory"
touch "$authorized_keys"
grep -Fqx "$key_line" "$authorized_keys" || printf '%s\n' "$key_line" >> "$authorized_keys"
chmod 600 "$authorized_keys"

# Current MSYS2 packages keep the server configuration below /etc/ssh rather
# than the older /etc/sshd_config path used by the published wiki script.
sshd_config=/etc/ssh/sshd_config
cp -n "$sshd_config" "$sshd_config.cross-platform-workstation.bak" || true
temporary_config=$(mktemp)
awk '/^# BEGIN cross-platform-workstation mosh/,/^# END cross-platform-workstation mosh/ { next } { print }' "$sshd_config" > "$temporary_config"
cat >> "$temporary_config" <<EOF

# BEGIN cross-platform-workstation mosh
# Managed by platform/windows/configure-msys2-sshd.sh.
Port $sshd_port
SetEnv MSYSTEM=UCRT64
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin no
AuthorizedKeysFile .ssh/authorized_keys
# END cross-platform-workstation mosh
EOF
mv "$temporary_config" "$sshd_config"

sshd -t
cygrunsrv -R "$service_name" >/dev/null 2>&1 || true
cygrunsrv -I "$service_name" -d "$service_description" -p /usr/bin/sshd.exe -a '-D -e' -y tcpip
net start "$service_name" >/dev/null 2>&1 || net start "$service_name"

printf 'MSYS2 sshd is running as %s on TCP %s.\n' "$service_name" "$sshd_port"
printf 'Authorized key installed for %s at %s.\n' "$target_user" "$authorized_keys"
