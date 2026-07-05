# cross-platform-workstation

Phased workstation setup for Windows 11, macOS, and Ubuntu GNOME.

The current deliverable implements Phase 0 and Phase 1 only:

- repository foundation
- persistent implementation tracker
- setup entrypoints
- shared Bash configuration
- platform detection
- Git Bash detection on Windows
- Unix-style command availability checks
- phase-aware doctor command
- initial portable tests

Later phases for WezTerm, Quake mode, Neovim, Yazi, Rider, worktrees, agents, model tooling, and hardening are documented in [PLAN.md](PLAN.md), but they are not implemented yet except as placeholders.

Windows remains native. Git for Windows Bash is the shell target. WSL is not installed or required. Git for Windows is a prerequisite for cloning and running this repository; setup verifies it but does not install it.

## Start Here

`PLAN.md` is the canonical implementation tracker and requirements record. Read it before changing behavior.

Useful docs:

- [PLAN.md](PLAN.md)
- [architecture](docs/architecture.md)
- [implementation plan narrative](docs/implementation-plan.md)
- [provisioning](docs/provisioning.md)
- [shell workflow](docs/shell.md)

## Phase 0 and Phase 1 Setup

Windows, from PowerShell:

```powershell
./setup.ps1 -Phase foundation -DryRun
./setup.ps1 -Phase shell -DryRun
./setup.ps1 -Phase shell
```

On Windows, install Git for Windows first, clone this repository, then run `setup.ps1 -Phase shell`. Setup verifies Git and Git Bash, installs or verifies chezmoi and Phase 1 CLI tools with `winget`, backs up known Phase 1 shell targets, applies chezmoi, then validates the configured Git Bash shell automatically. It never installs WSL or Git.

Windows, from Git Bash:

```bash
./setup --phase foundation --dry-run
./setup --phase shell --dry-run
./setup --phase shell --install-missing
```

macOS / Ubuntu:

```bash
./setup.sh --phase foundation --dry-run
./setup.sh --phase shell --dry-run
```

Dry-run mode reports what would happen. Non-dry-run mode verifies prerequisites and prints the next manual steps; it does not install package managers, does not install WSL, and does not overwrite user configuration.

## Validate

Run portable tests from Git Bash, macOS Bash, or Ubuntu Bash:

```bash
./tests/run.bash
```

Run the phase-aware doctor:

```bash
./scripts/doctor --phase foundation
./scripts/doctor --phase shell
```

After setup completes, these helpers should be available in a fresh Git Bash session:

```bash
platform-info
workstation-root
doctor --phase shell
winpath "$PWD"      # Windows Git Bash only; passthrough elsewhere
unixpath 'C:\work'  # Windows Git Bash only; passthrough elsewhere
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
