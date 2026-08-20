# Agent integration status

Agent launchers and model profile translation are scheduled for Phase 11. OpenCode, Pi, Claude Code, and Codex remain independent integrations. A profile name expresses intent; it does not imply that every tool supports that model or endpoint.

Pi and Codex can already be installed independently; selecting one never installs, configures, or authenticates the other. Node.js/npm is installed only when the selected agent needs it and `--install-missing` is supplied.

The Pi setup path also installs the global Pi extension `npm:@narumitw/pi-usage` through Pi itself (`pi install npm:@narumitw/pi-usage`). It is not installed by the Codex path. Pi records global extensions in its own user configuration, and the extension uses Pi's existing authentication store; this repository neither reads nor stores those credentials. As with any third-party Pi extension, review it before use because extensions execute code with the permissions of your user account.

Windows PowerShell:

```powershell
./setup.ps1 -Agent pi
./setup.ps1 -Agent codex
```

macOS:

```bash
./setup.sh --agent pi --install-missing
./setup.sh --agent codex --install-missing
```

After installation, authenticate each tool through its own documented interactive flow. No credentials are stored by this repository.

Credentials must live in environment variables, agent-native configuration, or an OS credential store/password manager. They must not be added to this repository.
