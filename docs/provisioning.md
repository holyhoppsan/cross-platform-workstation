# Provisioning

Provisioning is phase-based and conservative.

Supported entrypoints:

```bash
./setup --phase foundation
./setup.sh --phase shell
./setup.sh --phase shell --install-missing
```

```powershell
./setup.ps1 -Phase foundation
./setup.ps1 -Phase shell
```

On Windows, install Git for Windows first, clone this repository, then use `setup.ps1` as the primary bootstrap entrypoint. `setup.sh` is useful after Git Bash exists, but it cannot bootstrap a machine before Bash exists.

## Phase 0

Phase 0 verifies repository structure and required foundation files. It does not install tools or write to user configuration.

Expected behavior:

- detect platform
- verify repository files
- verify `git`
- run `scripts/doctor --phase foundation`
- print next manual steps

## Phase 1

Phase 1 provisions and verifies the common shell workflow for the selected platform. On Windows it assumes Git for Windows is already present, installs required setup-managed Phase 1 tools, applies chezmoi-managed dotfiles, and validates the configured Git Bash shell.

Expected behavior:

- detect platform
- verify Bash
- require Git and Git Bash when running on Windows
- verify Git for Windows and Git Bash on Windows
- install or verify `chezmoi` on Windows
- install or verify Phase 1 CLI tools on Windows: `ripgrep`, `fd`, `jq`, and `fzf`
- back up known Phase 1 managed dotfiles to `~/.workstation-setup-backup/<timestamp>`
- apply chezmoi dotfiles with `--force` so setup does not block on interactive overwrite prompts
- verify common Unix-style commands
- report optional commands such as `rg`, `fd`, `jq`, and `fzf`
- run `scripts/doctor --phase shell`
- launch Git Bash non-interactively to validate configured shell helpers

Windows validation after setup:

```powershell
./scripts/setup/verify.ps1 -Phase shell
```

Windows reset dry run:

```powershell
./scripts/setup/reset-windows.ps1 -Phase shell
```

To actually reset Phase 1 config, use `-Apply`. To uninstall setup-managed Phase 1 packages too, add `-RemovePackages`. Git is never removed by this script.

## Dry Run

Dry-run mode prints the selected phase, detected platform, and intended checks without changing files.

## Install Policy

Setup must not:

- install WSL
- install Git
- silently install Homebrew
- use curl-to-shell installation
- commit credentials or write secrets

Setup may apply this repository's chezmoi-managed dotfiles for the selected phase. It should still keep behavior idempotent and avoid touching unrelated user configuration.

For Phase 1, setup backs up the known managed targets before forcing chezmoi apply:

- `~/.bashrc`
- `~/.bash_profile`
- `~/.config/workstation`
- `~/.local/bin/workstation-doctor`

When later phases require tools, setup should prefer verification first and document explicit installation steps.
