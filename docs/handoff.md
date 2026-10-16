# Handoff guide for the next coding agent

This repository is ready to continue under Pi, Claude Code, Codex, or another
independent coding agent. The repository itself does not depend on which agent
opens it.

## Start here

From the repository root:

```bash
git status --short
git log -6 --oneline
```

Read these files before changing anything:

1. `AGENTS.md` for durable constraints.
2. `PLAN.md` for the phase tracker and current next actions.
3. `docs/architecture.md` for ownership and platform boundaries.
4. `docs/agents.md` for agent installation and credential boundaries.

Do not infer unfinished work from chat history. Update `PLAN.md` in the same
change when requirements or validation status changes. Do not commit or push
unless the user explicitly requests it.

## Current baseline

The repository owns the interactive workstation layer: MSYS2 UCRT64, WezTerm,
Neovim, Yazi, shell configuration, dotfiles, and terminal behavior. Windows is
native and WSL-independent. WSL2 may exist, but `workstation-infra` owns WSL2,
Docker, Horde infrastructure, build toolchains, infrastructure logs/storage,
firewall rules, scheduled tasks, and updater state. Keep the two repositories'
checkouts and generated state separate.

Implemented and validated enough to use:

- Windows and macOS shell, WezTerm, Neovim, and Yazi baseline.
- Windows and macOS Quake behavior, with macOS multi-monitor placement still
  pending.
- Windows MSYS2 `msys2_sshd` plus LAN Mosh/ShadowTerm access and temporary LAN
  interruption recovery; Tailscale off-LAN validation remains pending.
- `just`, Starship, Herdr, Pi, and Codex installation on Windows/macOS.
- Claude Code installation/version check on Windows. macOS and Ubuntu Claude
  validation remain pending.
- Pi MCP support through `pi-mcp-adapter`; MCP endpoints, credentials, and
  server selection remain per-machine and untracked.

## Agent commands

Windows PowerShell:

```powershell
.\setup.ps1 -Agent pi
.\setup.ps1 -Agent codex
.\setup.ps1 -Agent claude
```

macOS:

```bash
./setup.sh --agent pi --install-missing
./setup.sh --agent codex --install-missing
./setup.sh --agent claude --install-missing
```

Claude Code uses `@anthropic-ai/claude-code`. Its installer explicitly runs
the package's official `install.cjs` step because the repository installs npm
packages with lifecycle scripts disabled by default. Complete authentication
inside each agent's own documented flow; never add credentials to Git.

## Validation before new work

Run the portable suite from MSYS2 UCRT64 Bash, macOS Bash, or Ubuntu Bash:

```bash
./tests/run.bash
```

On Windows, use `C:\msys64\usr\bin\bash.exe` explicitly if a generic
`bash` command resolves to another environment. Run the relevant doctor phase
after setup, and label any platform-specific behavior as pending until it has
been tested on that platform.

The immediate unfinished work is tracked in `PLAN.md`: Ubuntu validation,
remaining GUI checks, Tailscale off-LAN access, `just` recipe design, Rider and
worktree workflows, the unified `agent` launcher, model tooling, and optional
notifications.
