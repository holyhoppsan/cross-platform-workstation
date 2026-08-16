# macOS Agent Validation Runbook

This runbook prepares a MacBook Pro for Phase 6 validation. It is intentionally conservative: a coding agent may inspect, test, and apply this repository's managed configuration, but it must stop for the user to install or approve prerequisites and to perform GUI checks.

## Boundaries

- Use native macOS. Do not use MSYS2, WSL, Windows paths, SSH/Mosh, ShadowTerm, or Tailscale for this phase.
- Do not install Homebrew automatically or use curl-to-shell installation.
- Do not run `./setup.sh` without the user's approval after the dry run. It applies managed dotfiles with `chezmoi --force`, after backing up the targets it manages.
- Do not claim GUI behavior is validated from command output alone.

## 1. Agent preflight

Run these read-only checks from Terminal and retain their output in the validation report:

```bash
sw_vers
uname -m
git --version
bash --version | head -n 1
xcode-select -p
brew --version
```

Stop and report instead of continuing if either condition applies:

- `xcode-select -p` fails: ask the user to install or select the Xcode Command Line Tools.
- `brew --version` fails: ask the user whether they want to install Homebrew themselves. Do not invoke the Homebrew installer.

Homebrew documents its supported prefix as `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel Macs; use `brew --prefix` rather than assuming either path.

## 2. Clone and non-destructive repository checks

Clone the repository into a normal user-writable directory, then run:

```bash
git clone <repository-url> ~/src/cross-platform-workstation
cd ~/src/cross-platform-workstation
./setup.sh --phase yazi --dry-run
./tests/run.bash
./scripts/doctor --phase yazi
```

The dry run only reports intent. The test suite and doctor may report missing managed configuration before it is applied; record that result rather than treating it as a platform failure.

## 3. User-approved setup, dependency installation, and managed configuration

Ask the user for explicit approval before this step. When Homebrew is already available, this command installs or verifies the missing macOS dependencies through Homebrew: `git`, Bash, chezmoi, ripgrep, fd, jq, fzf, WezTerm, Neovim, and Yazi. It never installs Homebrew. It then backs up the managed targets under `~/.workstation-setup-backup/<timestamp>` before applying this repository's chezmoi source.

```bash
./setup.sh --phase yazi --install-missing
```

Then start a fresh Bash session and collect this evidence:

```bash
platform-info
doctor --phase shell
doctor --phase wezterm
doctor --phase neovim
doctor --phase yazi
command -v y nvim yazi wezterm
```

`unzip` is supplied by macOS. Optional Yazi preview dependencies are out of scope for the initial validation.

## 4. User-performed GUI validation

The user, not the agent, confirms the following in a newly opened WezTerm window:

1. The shell is Bash and the expected Homebrew or system Bash is selected.
2. Clipboard copy/paste works, including ordinary `Ctrl+V` text paste if that is the desired local workflow.
3. Pane creation, movement, resize, tabs, and workspace picker work with the documented bindings.
4. `nvim` starts and the `Ctrl+A` terminal leader does not conflict with Neovim controls.
5. `y` starts Yazi and returns to the selected directory when quitting.
6. `Ctrl+A`, `e` opens Yazi in a new pane and `Ctrl+A`, `E` opens it in the current pane.

Quake mode is not part of Phase 6 validation because the macOS adapter remains unimplemented.

## 5. Report and stop conditions

Record the macOS version, CPU architecture, Homebrew prefix, package versions, command/test/doctor output, and every manual result in `PLAN.md`.

Stop and request user direction if Homebrew or Xcode tools are missing, package installation fails, setup proposes an unexpected overwrite target, `chezmoi` reports a conflict, or any command requires elevated privileges. Do not work around these conditions with an alternate package manager or a curl-to-shell installer.

## References

- [Homebrew installation requirements](https://docs.brew.sh/Installation)
- [WezTerm macOS installation](https://wezterm.org/install/macos.html)
- [Neovim installation](https://neovim.io/doc/install/)
- [Yazi installation](https://yazi-rs.github.io/docs/next/installation/)
- [chezmoi quick start](https://www.chezmoi.io/quick-start/)
