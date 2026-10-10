# MSYS2 Mosh LAN proof of concept

This is the Windows-native, WSL-independent path for connecting ShadowTerm on the same LAN. It does not install, configure, require, or use WSL; an independently managed WSL2 installation may coexist on the machine:

```text
ShadowTerm on phone -- SSH/TCP 22 --> MSYS2 msys2_sshd -- starts --> mosh-server UDP 60001
```

Herdr owns persistent sessions after connection. tmux is not part of this proof.

## Preconditions

MSYS2 must be installed at `C:\msys64`; this repository then owns the MSYS2
SSH/Mosh packages and service configuration. The required packages are
`openssh`, `mosh`, `cygrunsrv`, and
`mingw-w64-ucrt-x86_64-editrights`. The installer uses the repository's shared
MSYS2 UCRT64 package helper and never uses Windows OpenSSH, WSL SSH,
`pacman -Sy`, or an implicit full MSYS2 upgrade.

In ShadowTerm, create or export an OpenSSH public key and save only the public key in a local file, for example `C:\Users\Daniel Hall\Downloads\shadowterm_ed25519.pub`. Never add private keys to this repository.

## Install and test locally

You can run a non-mutating preflight from PowerShell without a key or elevation:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -TargetUser $env:USERNAME
```

This reports all missing packages and commands together. To preview only the
packages that setup would install, still without changing anything:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -TargetUser $env:USERNAME -InstallMissing
```

For apply, open **PowerShell as Administrator**. The public-key path and format
are validated before any package, service, authorized-key, or firewall change.
Run the complete setup with:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -Apply -InstallMissing -TargetUser $env:USERNAME -AuthorizedKeyPath 'C:\path\to\client_ed25519.pub'
```

`-Apply` without `-InstallMissing` is also supported when every prerequisite is
already present. If any prerequisite is missing it stops before service or
firewall mutation and tells you to rerun with `-InstallMissing`. After any
installation, setup revalidates the four packages and these commands before it
creates or restarts `msys2_sshd`:

`/usr/bin/cygrunsrv`, `/usr/bin/ssh-keygen`, `/usr/bin/sshd`,
`/usr/bin/mosh-server`, `getent`, `net`, and `/ucrt64/bin/editrights`.

The service configuration disables password and keyboard-interactive SSH,
idempotently installs the supplied public key for the target Windows user, and
starts only the repository-owned `msys2_sshd` service. Confirm it with
`Get-Service msys2_sshd`.

Test the server on the laptop before opening the LAN firewall. Use an SSH client and the same private key represented by the public key above:

```powershell
ssh -p 22 "${env:USERNAME}@localhost"
```

The remote shell must resolve `mosh-server`:

```powershell
ssh -p 22 "${env:USERNAME}@localhost" 'command -v mosh-server'
```

## Enable LAN-only access

After both local SSH tests pass, create firewall rules restricted to the Windows **Private** profile and `LocalSubnet`:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -Apply -InstallMissing -EnableLanFirewall -TargetUser $env:USERNAME -AuthorizedKeyPath 'C:\path\to\client_ed25519.pub'
```

Find the laptop's LAN IPv4 address with `ipconfig`. In ShadowTerm, use that address, your Windows username, SSH port `22`, enable Mosh, leave **Mosh Server Path** blank, and use Mosh port `60001`. The phone must be on the same LAN and Windows must classify that network as Private.

Do not port-forward TCP 22 or UDP 60001. Tailscale/VPN reachability is a separate later decision.

## Roll back

This removes only the service and the two firewall rules; host keys, SSH configuration backups, and the authorized key remain for review:

```powershell
.\platform\windows\reset-msys2-mosh.ps1
.\platform\windows\reset-msys2-mosh.ps1 -Apply
```
