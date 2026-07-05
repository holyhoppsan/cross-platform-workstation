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

On Windows, `setup.ps1` is the primary clean-machine bootstrap entrypoint. `setup.sh` is useful after Git Bash exists, but it cannot install Git Bash before Bash exists.

## Phase 0

Phase 0 verifies repository structure and required foundation files. It does not install tools or write to user configuration.

Expected behavior:

- detect platform
- verify repository files
- verify `git`
- run `scripts/doctor --phase foundation`
- print next manual steps

## Phase 1

Phase 1 provisions and verifies the common shell workflow for the selected platform. On Windows it installs required Phase 1 tools, applies chezmoi-managed dotfiles, and validates the configured Git Bash shell.

Expected behavior:

- detect platform
- verify Bash
- require Git Bash when running on Windows
- install or verify Git for Windows and Git Bash on Windows
- install or verify `chezmoi` on Windows
- install or verify Phase 1 CLI tools on Windows: `ripgrep`, `fd`, `jq`, and `fzf`
- apply chezmoi dotfiles
- verify common Unix-style commands
- report optional commands such as `rg`, `fd`, `jq`, and `fzf`
- run `scripts/doctor --phase shell`
- launch Git Bash non-interactively to validate configured shell helpers

Windows validation after setup:

```powershell
./scripts/setup/verify.ps1 -Phase shell
```

## Dry Run

Dry-run mode prints the selected phase, detected platform, and intended checks without changing files.

## Install Policy

Setup must not:

- install WSL
- silently install Homebrew
- use curl-to-shell installation
- commit credentials or write secrets

Setup may apply this repository's chezmoi-managed dotfiles for the selected phase. It should still keep behavior idempotent and avoid touching unrelated user configuration.

When later phases require tools, setup should prefer verification first and document explicit installation steps.
