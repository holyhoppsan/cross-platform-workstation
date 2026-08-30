# Tailscale remote access

Phase 9 extends the already validated Windows-native MSYS2 SSH/Mosh service
to the private Tailscale network. It does not use Tailscale SSH, WSL, router
port forwarding, an auth key, or a public address.

## Install a client without configuring it

On macOS, the phase installs the Tailscale app but does not launch its
onboarding flow, create a VPN configuration, or join a tailnet:

```bash
./setup.sh --phase tailscale --install-missing
```

This is useful for machines where you only want the client present for later.
When you do want that Mac to join a tailnet, open Tailscale from Applications
and complete its normal macOS approval and sign-in flow. It is safe to leave
the app installed and signed out.

## Prepare a Mac as a ShadowTerm Mosh host

On a Mac that should accept connections from ShadowTerm, install or verify
Mosh as an explicit extension of Phase 9:

```bash
./setup.sh --phase tailscale --enable-mosh-host --install-missing
```

This installs the Homebrew `mosh` formula, but does **not** enable SSH/Remote
Login, add an SSH key, alter the macOS firewall, sign in to Tailscale, or
configure an MCP client/server.

Complete these manual security steps on that Mac:

1. System Settings → General → Sharing → enable **Remote Login**, and allow
   only the intended macOS user.
2. In ShadowTerm, create an Ed25519 identity. Use its **Full setup** command
   on the Mac to append the public key to `~/.ssh/authorized_keys`; never copy
   the private key out of the phone or into this repository.
3. Add a ShadowTerm host with the Mac username and LAN address. Enable Mosh,
   keep SSH port `22` and Mosh port `60001`, and set **Mosh Server Path** to
   `/opt/homebrew/bin/mosh-server` on Apple Silicon or
   `/usr/local/bin/mosh-server` on Intel Homebrew.
4. Test that LAN entry before optionally signing the Mac and phone into the
   same tailnet. For off-LAN use, create a separate host entry using the
   Mac's Tailscale IP or MagicDNS name; do not port-forward the router.

If the macOS application firewall is configured to block all incoming
connections, explicitly allow Remote Login and `mosh-server`. Tailnet policy,
not a broad macOS firewall rule, should restrict off-LAN access to your phone.

## Install the Windows host client

From a normal (non-Administrator) PowerShell on **LFG Laptop Herdr**:

```powershell
./setup.ps1 -Phase tailscale
```

The setup command installs or verifies the official Tailscale Windows client
through WinGet, applies the updated doctor command, and reports whether this
machine has a Tailscale IPv4 address. It deliberately does not invoke
`tailscale up` or sign in on your behalf. Use the Tailscale Windows app to log
in to the intended tailnet.

Install Tailscale on the iPhone from the App Store, log in to the same
tailnet, and confirm both devices appear in the Tailscale admin console. Keep
the tailnet policy restricted to your devices before opening the host firewall.

## Add the Tailscale-only firewall rules

After both clients are connected, find the iPhone's Tailscale IPv4 address in
the Tailscale app or admin console. It will be in `100.64.0.0/10`. Use its
exact address with `/32` unless you intentionally need a narrower shared
Tailscale subnet.

Open **PowerShell as Administrator** on LFG Laptop Herdr and first review the
dry run:

```powershell
.\platform\windows\setup-tailscale-mosh.ps1 -AllowedRemoteAddress '100.x.y.z/32'
```

Then apply exactly those two rules:

```powershell
.\platform\windows\setup-tailscale-mosh.ps1 -Apply -AllowedRemoteAddress '100.x.y.z/32'
```

The rules allow only the supplied Tailscale source address to reach TCP 22 and
UDP 60001. They do not modify the existing LAN rules, open a router port, or
allow `Any`/`LocalSubnet`.

## ShadowTerm test

Create a separate ShadowTerm host entry using the LFG Laptop Herdr Tailscale
IPv4 address or its MagicDNS name. Keep the existing username, SSH key, SSH
port `22`, Mosh enabled, and Mosh port `60001`. Test with the phone off the
home Wi-Fi. Then switch between Wi-Fi and cellular to confirm the existing
Mosh session resumes.

Check local status from an MSYS2 UCRT64 shell:

```bash
doctor --phase tailscale
```

On macOS use:

```bash
~/.local/bin/workstation-doctor --phase tailscale
```

## Roll back the Tailscale firewall rules

This preserves Tailscale itself, its login state, the MSYS2 service, keys, and
the separate LAN-only rules:

```powershell
.\platform\windows\reset-tailscale-mosh.ps1
.\platform\windows\reset-tailscale-mosh.ps1 -Apply
```
