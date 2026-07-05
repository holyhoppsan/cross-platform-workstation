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

Windows remains native. Git for Windows Bash is the shell target. WSL is not installed or required.

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

On Windows, `setup.ps1 -Phase shell` is the clean-machine bootstrap path. It installs or verifies Git for Windows, Git Bash, chezmoi, and Phase 1 CLI tools with `winget`, applies chezmoi, then validates the configured Git Bash shell automatically. It never installs WSL.

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
