# cross-platform-workstation

Phased workstation setup for Windows 11, macOS, and Ubuntu GNOME.

The current deliverable implements Phases 0 through 2, the Windows slice of Phase 3, Phase 4, and Phase 5:

- repository foundation
- persistent implementation tracker
- setup entrypoints
- shared Bash configuration
- platform detection
- MSYS2 UCRT64 detection on Windows
- Unix-style command availability checks
- phase-aware doctor command
- WezTerm baseline with tmux-style bindings
- Windows Quake-mode adapter using AutoHotkey v2
- Neovim baseline
- Yazi baseline terminal file manager
- initial portable tests

Later phases for macOS/Ubuntu Quake mode, Rider, worktrees, agents, model tooling, and hardening are documented in [PLAN.md](PLAN.md), but they are not implemented yet except as placeholders. Yazi is implemented only as a terminal file manager, not as an AI agent.

Windows remains native and WSL-independent. MSYS2 UCRT64 Bash is the shell target, and Windows-native paths and tools are the default. This repository does not install, configure, require, or use WSL. WSL2 may nevertheless be installed on the same machine and managed by a separate infrastructure control plane; its presence alone is not an error. Git for Windows may be used to clone the repository, but it is not the configured interactive shell.

## Repository Ownership Boundary

`cross-platform-workstation` owns the interactive workstation experience: MSYS2 UCRT64, WezTerm, editors and interactive tools, shell configuration, user dotfiles, and terminal behavior.

The separate `workstation-infra` repository owns WSL2 and Docker; Horde Server, MongoDB, and Redis; the native Horde Agent/UBA worker; build toolchains; infrastructure storage and logs; and infrastructure firewall rules, scheduled tasks, and updater state.

The repositories keep separate checkouts, generated state, logs, firewall rule names, scheduled tasks, and package ownership. Neither repository may silently install, remove, or reconfigure resources owned by the other. In particular, `install_wsl` remains `false` here, while tests and doctor must tolerate WSL2 being present.

## Start Here

`PLAN.md` is the canonical implementation tracker and requirements record. Read it before changing behavior.

Useful docs:

- [PLAN.md](PLAN.md)
- [architecture](docs/architecture.md)
- [implementation plan narrative](docs/implementation-plan.md)
- [provisioning](docs/provisioning.md)
- [shell workflow](docs/shell.md)
- [WezTerm](docs/wezterm.md)
- [Neovim](docs/neovim.md)
- [Yazi](docs/yazi.md)
- [Vowen desktop dictation](docs/vowen.md)
- [macOS agent validation](docs/macos-agent-validation.md)

## Phase 0 and Phase 1 Setup

Windows, from PowerShell:

```powershell
./setup.ps1 -Phase foundation -DryRun
./setup.ps1 -Phase shell -DryRun
./setup.ps1 -Phase shell
./setup.ps1 -Phase wezterm
./setup.ps1 -Phase quake
./setup.ps1 -Phase neovim
./setup.ps1 -Phase yazi
./setup.ps1 -Phase vowen
```

On Windows, install MSYS2 at `C:\msys64`, open the UCRT64 environment, and install its `git`, `jq`, `mingw-w64-ucrt-x86_64-ripgrep`, `mingw-w64-ucrt-x86_64-fd`, and `mingw-w64-ucrt-x86_64-fzf` packages. Git for Windows may be used to clone this repository. `setup.ps1 -Phase shell` verifies MSYS2 UCRT64, installs or verifies chezmoi, backs up known Phase 1 shell targets, applies chezmoi, then validates the configured UCRT64 shell automatically. It never installs WSL or Git for Windows.

Windows, from MSYS2 UCRT64 Bash:

```bash
./setup --phase foundation --dry-run
./setup --phase shell --dry-run
./setup --phase shell --install-missing
./setup --phase wezterm --install-missing
./setup.sh --phase quake --dry-run
./setup.sh --phase neovim --install-missing
./setup.sh --phase yazi --install-missing
./setup.sh --phase vowen
```

macOS / Ubuntu:

```bash
./setup.sh --phase foundation --dry-run
./setup.sh --phase shell --dry-run
./setup.sh --phase wezterm --dry-run
./setup.sh --phase neovim --dry-run
./setup.sh --phase yazi --dry-run
```

Dry-run mode reports what would happen. Non-dry-run mode verifies prerequisites and prints the next manual steps; it does not install package managers, does not install WSL, and does not overwrite user configuration.

## Validate

Run portable tests from MSYS2 UCRT64 Bash, macOS Bash, or Ubuntu Bash:

```bash
./tests/run.bash
```

Run the phase-aware doctor:

```bash
./scripts/doctor --phase foundation
./scripts/doctor --phase shell
./scripts/doctor --phase wezterm
./scripts/doctor --phase quake
./scripts/doctor --phase neovim
./scripts/doctor --phase yazi
./scripts/doctor --phase vowen
```

After setup completes, these helpers should be available in a fresh MSYS2 UCRT64 session:

```bash
platform-info
workstation-root
doctor --phase shell
winpath "$PWD"      # Windows MSYS2 only; passthrough elsewhere
unixpath 'C:\work'  # Windows MSYS2 only; passthrough elsewhere
```

Automated post-setup validation:

```powershell
./scripts/setup/verify.ps1 -Phase shell
```

Dry-run a Windows reset for Phase 1:

```powershell
./scripts/setup/reset-windows.ps1 -Phase shell
```

To actually remove setup-managed Phase 1 configuration, add `-Apply`. To also remove setup-managed Phase 1 packages, add `-RemovePackages`. Git is never removed by the reset script.

## Repository Map

- `PLAN.md`: canonical tracker and source of truth
- `chezmoi/`: shared dotfile source
- `scripts/`: doctor, setup support, and later workflow commands
- `config/`: non-secret `.example` configuration
- `platform/`: operating-system-specific placeholders and future adapters
- `agents/`: future agent adapter placeholders
- `tools/`: future tool integration placeholders
- `docs/`: architecture and operating notes
- `tests/`: initial portable tests
