# Provisioning

Provisioning is phase-based and conservative.

Supported entrypoints:

```bash
./setup --phase foundation
./setup.sh --phase shell
./setup.sh --phase shell --install-missing
./setup.sh --phase wezterm --install-missing
```

```powershell
./setup.ps1 -Phase foundation
./setup.ps1 -Phase shell
./setup.ps1 -Phase wezterm
```

On Windows, install MSYS2 at `C:\msys64`, use its UCRT64 environment, and use `setup.ps1` as the primary bootstrap entrypoint. Git for Windows may be used to clone the repository, but `setup.sh` is run from MSYS2 UCRT64 Bash.

## Phase 0

Phase 0 verifies repository structure and required foundation files. It does not install tools or write to user configuration.

Expected behavior:

- detect platform
- verify repository files
- verify `git`
- run `scripts/doctor --phase foundation`
- print next manual steps

## Phase 1

Phase 1 provisions and verifies the common shell workflow for the selected platform. On Windows it requires MSYS2 UCRT64, verifies required MSYS2 CLI packages, applies chezmoi-managed dotfiles, and validates the configured UCRT64 shell. On macOS, when Homebrew is already installed and `--install-missing` is supplied, it installs the supported Homebrew formulae.

Expected behavior:

- detect platform
- verify Bash
- require MSYS2 UCRT64 Bash when running on Windows
- verify Git is available for repository use and MSYS2 packages provide the interactive CLI tools
- install or verify `chezmoi` on Windows
- install or verify Phase 1 MSYS2 CLI tools on Windows: `git`, `ripgrep`, `fd`, `jq`, `fzf`, and `unzip`
- install or verify Herdr: use `brew install herdr` on macOS; on Windows, only if absent, use Herdr's documented preview installer. This is a user-approved exception to the repository's normal no-remote-script execution rule because Herdr has no supported Winget package. Do not reuse this exception for any other dependency.
- install or verify `just`: Homebrew's `just` formula on macOS and MSYS2's `mingw-w64-ucrt-x86_64-just` package on Windows. This installs only the executable; no `justfile` is created.
- back up known Phase 1 managed dotfiles to `~/.workstation-setup-backup/<timestamp>`
- apply chezmoi dotfiles with `--force` so setup does not block on interactive overwrite prompts
- verify common Unix-style commands
- report optional commands such as `rg`, `fd`, `jq`, and `fzf`
- run `scripts/doctor --phase shell`
- launch MSYS2 UCRT64 Bash non-interactively to validate configured shell helpers

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

## Phase 2

Phase 2 provisions and verifies the WezTerm baseline.

Expected behavior:

- verify Phase 1 prerequisites
- install or verify WezTerm on Windows with winget package `wez.wezterm`
- apply chezmoi dotfiles
- verify `wezterm` or `wezterm.exe`
- verify `wezterm.lua` is present and no longer contains the intentional placeholder failure
- run `doctor --phase wezterm`

On macOS and Ubuntu, setup currently verifies that WezTerm is installed; automatic package installation is deferred until platform validation.

## Phase 6 macOS readiness

Use [the macOS agent validation runbook](macos-agent-validation.md) when preparing the MacBook Pro. Once Homebrew is already installed and the user approves it, `./setup.sh --phase yazi --install-missing` installs or verifies the phase dependencies through Homebrew, then applies the managed configuration. Setup deliberately does not install Homebrew or use curl-to-shell.
