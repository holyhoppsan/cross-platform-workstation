# MSYS2 Mosh LAN proof of concept

This is the Windows-native, WSL-free path for connecting ShadowTerm on the same LAN:

```text
ShadowTerm on phone -- SSH/TCP 22 --> MSYS2 msys2_sshd -- starts --> mosh-server UDP 60001
```

Herdr owns persistent sessions after connection. tmux is not part of this proof.

## Preconditions

MSYS2 must be installed at `C:\msys64` and opened as **UCRT64**. The user has already installed and verified `openssh`, `mosh`, `cygrunsrv`, and `mingw-w64-ucrt-x86_64-editrights`.

In ShadowTerm, create or export an OpenSSH public key and save only the public key in a local file, for example `C:\Users\Daniel Hall\Downloads\shadowterm_ed25519.pub`. Never add private keys to this repository.

## Install and test locally

Open **PowerShell as Administrator** and run a dry run first:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -AuthorizedKeyPath 'C:\path\to\shadowterm_ed25519.pub'
```

Then apply the service setup. This disables password and keyboard-interactive SSH authentication, installs the supplied public key for the current Windows user, and starts `msys2_sshd`:

```powershell
.\platform\windows\setup-msys2-mosh.ps1 -Apply -AuthorizedKeyPath 'C:\path\to\shadowterm_ed25519.pub'
Get-Service msys2_sshd
```

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
.\platform\windows\setup-msys2-mosh.ps1 -Apply -EnableLanFirewall -AuthorizedKeyPath 'C:\path\to\shadowterm_ed25519.pub'
```

Find the laptop's LAN IPv4 address with `ipconfig`. In ShadowTerm, use that address, your Windows username, SSH port `22`, enable Mosh, leave **Mosh Server Path** blank, and use Mosh port `60001`. The phone must be on the same LAN and Windows must classify that network as Private.

Do not port-forward TCP 22 or UDP 60001. Tailscale/VPN reachability is a separate later decision.

## Roll back

This removes only the service and the two firewall rules; host keys, SSH configuration backups, and the authorized key remain for review:

```powershell
.\platform\windows\reset-msys2-mosh.ps1
.\platform\windows\reset-msys2-mosh.ps1 -Apply
```
