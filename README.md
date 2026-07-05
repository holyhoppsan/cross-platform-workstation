# workstation

Cross-platform terminal workstation configuration for Windows 11, macOS, and Ubuntu GNOME. It uses WezTerm, Bash, chezmoi, native platform hotkey adapters, and Git worktrees. Windows remains fully native: Git for Windows Bash is used and WSL is neither installed nor required.

## Current status

Phase 1 is a working configuration slice: shared Bash startup, platform detection, WezTerm leader bindings, chezmoi data, Quake adapter interface stubs, and diagnostics. The global dropdown adapters are intentionally non-functional stubs pending platform-specific implementation and manual validation.

## Try the current slice

Prerequisites: Git, Bash, chezmoi, and WezTerm. From a clone of this repository:

```bash
chezmoi init --source "$PWD/chezmoi"
chezmoi diff
chezmoi apply
workstation-doctor
```

On Windows, run these commands in Git Bash. The configuration detects Git Bash and exports helpers for native path conversion:

```bash
winpath "$PWD"       # C:\... form for native Windows programs
unixpath 'C:\work'   # /c/work form for Bash tools
```

## Core keys

Press `Ctrl+A`, release it, then press the second key: `|` or `-` splits; `h/j/k/l` navigates; `H/J/K/L` resizes; `c` creates a tab; `x` closes a pane; `z` zooms; `w` picks a workspace; `r` renames it; `p` creates a workspace from a project directory; `q` switches to the dedicated Quake workspace; `u` selects the next agent pane needing attention; `1..9` selects tabs; `[` enters copy mode; `a` sends literal `Ctrl+A`.

`Ctrl+`` is reserved for the operating-system Quake adapter and is not captured by WezTerm.

## Repository map

- `chezmoi/`: deployed shell and WezTerm configuration
- `scripts/`: repository-local diagnostics and, in later phases, workflow commands
- `platform/`: native dropdown and bootstrap adapters
- `config/`: non-secret configuration examples
- `templates/`: agent task contracts
- `tests/`: portable Bash tests
- `docs/`: architecture, implementation phases, and operating notes

`PLAN.md` is the canonical implementation tracker and requirements record for the repository. See [PLAN.md](PLAN.md), [architecture](docs/architecture.md), [implementation plan](docs/implementation-plan.md), and [installation notes](docs/installation.md).
