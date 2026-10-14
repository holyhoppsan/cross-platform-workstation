# Agent integration status

Agent launchers and model profile translation are scheduled for Phase 12. OpenCode, Pi, Claude Code, and Codex remain independent integrations. A profile name expresses intent; it does not imply that every tool supports that model or endpoint.

Pi, Codex, and Claude Code can be installed independently; selecting one never installs, configures, or authenticates the others. Node.js/npm is installed only when the selected agent needs it and `--install-missing` is supplied.

Claude Code is installed from Anthropic's official npm package
`@anthropic-ai/claude-code`; setup does not authenticate it or create Claude
configuration. Complete its own login flow after installation.

The Pi setup path installs the global Pi extensions `npm:@narumitw/pi-usage`, `npm:pi-mcp-adapter`, and `npm:pi-markdown-preview` through Pi itself, then removes the superseded `npm:@pandi-coding-agent/mdview` package if it was installed by an earlier setup run. They are not installed by the Codex path. Markdown preview provides `/preview` commands for Pi responses and local files, inline WezTerm rendering, browser preview, and optional PDF export. It requires Pandoc (installed by Pi setup: Homebrew on macOS, WinGet on Windows) plus an installed Chromium-based browser. PDF export additionally requires a LaTeX engine, which remains optional and is not installed by this repository. Pi records global extensions in its own user configuration, and the extensions use Pi's existing authentication store; this repository neither reads nor stores those credentials. As with any third-party Pi extension, review it before use because extensions execute code with the permissions of your user account.

Pi does not include MCP support in its core. The adapter adds it and exposes `/mcp` in an interactive Pi session. Setup installs only the adapter; it never creates, imports, or commits MCP server definitions. On each computer, use `/mcp setup` to inspect available host configurations and explicitly select compatible servers to import. Do not copy Codex Desktop's internal runtime servers. OAuth-backed servers require their own Pi login; existing Codex credentials are not copied.

Windows PowerShell:

```powershell
./setup.ps1 -Agent pi
./setup.ps1 -Agent codex
./setup.ps1 -Agent claude
```

macOS:

```bash
./setup.sh --agent pi --install-missing
./setup.sh --agent codex --install-missing
./setup.sh --agent claude --install-missing
```

After installation, authenticate each tool through its own documented interactive flow. No credentials are stored by this repository.

Credentials must live in environment variables, agent-native configuration, or an OS credential store/password manager. They must not be added to this repository.
