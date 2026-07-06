# Cross-Platform Workstation Plan

This file is the canonical implementation tracker and requirements record for this repository.

`docs/implementation-plan.md` may contain narrative explanation and architecture rationale, but this file contains the actionable phase-by-phase requirements, checklist, validation state, and current next actions. Future implementation sessions must update this file after changes.

## Project Overview

Repository: cross-platform-workstation

Goal: Build a phased, version-controlled workstation setup for Windows 11, macOS, and Ubuntu GNOME, using Git Bash/Bash, WezTerm, Neovim, Yazi, Rider, and AI coding agents while keeping Windows native and WSL-free.

This repository should eventually allow the user to:

1. Clone the repo on a fresh Windows, macOS, or Ubuntu machine.
2. Run a setup command for the current phase.
3. Install or verify required tools for that phase.
4. Apply dotfiles.
5. Configure WezTerm.
6. Configure Bash.
7. Configure Neovim.
8. Configure Yazi.
9. Configure the platform-specific Quake-mode toggle.
10. Configure supported AI agents.
11. Configure local model/tooling examples without committing secrets.
12. Run a doctor command to verify the current phase.
13. Work in a consistent CLI workflow across all supported platforms.

## Non-Negotiable Constraints

* [ ] Do not require WSL.
* [ ] Windows development must remain native.
* [ ] Windows shell workflow uses Git Bash.
* [ ] Windows setup assumes Git for Windows is already installed because Git is required to clone this repository.
* [ ] Common CLI workflow should use Unix-style commands across platforms.
* [ ] Avoid requiring Windows-specific shell habits such as `dir`.
* [ ] Prefer `ls`, `cd`, `pwd`, `cat`, `less`, `grep`, `rg`, `fd`, `jq`, `git`, `curl`, `tar`, `unzip`, `mkdir`, `rm`, `cp`, and `mv` across all platforms.
* [ ] WezTerm is the terminal and workspace layer.
* [ ] WezTerm uses tmux-style keybindings.
* [ ] tmux is deferred for now.
* [ ] Neovim is the terminal editor.
* [ ] Yazi is the terminal file manager, not an AI agent.
* [ ] Rider is the IDE for Unreal projects.
* [ ] Unreal integration is minimal for now: launch Rider with `.uproject` or project folder.
* [ ] Platform-specific behavior must be isolated.
* [ ] Setup scripts must be idempotent.
* [ ] Secrets must never be committed.
* [ ] Each implementation phase must be independently testable.
* [ ] Do not claim untested platform behavior is verified.

## Supported Platforms

* [ ] Windows 11
* [ ] macOS
* [ ] Ubuntu Desktop with GNOME, Wayland assumed by default

## Unsupported or Deferred

* [ ] WSL as a required dependency
* [ ] tmux as an active dependency
* [ ] full Unreal build automation
* [ ] Visual Studio automation
* [ ] arbitrary Linux desktops beyond Ubuntu GNOME
* [ ] perfect Quake-mode behavior on every possible Linux compositor
* [ ] committing API keys or private credentials

## Core Stack

* WezTerm as the terminal emulator, pane, tab, workspace, and Quake-window layer
* Git Bash on Windows
* Bash on macOS and Ubuntu
* chezmoi for dotfile management
* Git for version control
* Neovim as the primary terminal editor
* Yazi as the terminal file manager
* JetBrains Rider as the IDE for Unreal projects
* OpenCode, Pi, Claude Code, Codex, and Goose as supported AI/coding-agent tools
* Local and cloud models where the selected agent supports them
* Git worktrees for parallel-agent isolation
* tmux intentionally deferred

## Terminology

* Goose means the open-source AI agent from Block / block-goose.
* Yazi means the Rust terminal file manager from https://yazi-rs.github.io/.
* Yazi is not an AI agent.
* Do not create an agent adapter for Yazi.
* Do not create anything named Yasi.

## High-Level Architecture

Use WezTerm as the universal terminal and pane/workspace layer.

Use Git Bash on Windows to provide a Unix-like command-line workflow without WSL.

Use Bash as the common shell layer on all platforms.

Use platform-specific desktop adapters only for the global Quake-mode shortcut and focused-monitor window placement.

Use chezmoi to apply dotfiles.

Use a modular setup/provisioning system so the workstation can be installed or updated safely in phases.

Use a common project launcher and agent launcher so the workflow is consistent even when the underlying tools differ.

Use Git worktrees to isolate parallel write-capable agents.

Use Neovim for terminal editing.

Use Yazi for terminal file navigation.

Use Rider for Unreal project editing.

Use OpenCode, Pi, Claude Code, Codex, and Goose as agent tools, but do not assume every tool supports every model or every mode.

## Repository Goals

* Preserve workstation configuration in version control.
* Keep shared behavior in `chezmoi/`.
* Keep platform automation isolated in `platform/`.
* Keep setup incremental, idempotent, and testable.
* Keep Windows native and WSL-free.
* Make each phase independently understandable and resumable.
* Keep unchecked, stubbed, blocked, and manually validated work visible.

## Setup/Provisioning Model

The setup/provisioning system must bootstrap the workstation incrementally.

It must be idempotent and safe to re-run.

It should:

1. Detect the operating system.
2. Detect architecture.
3. Detect shell environment.
4. Install or verify required tools for the selected phase.
5. Install or verify optional tools based on config.
6. Apply chezmoi dotfiles.
7. Install WezTerm config.
8. Install Bash config.
9. Install Neovim config.
10. Install Yazi config.
11. Install the platform-specific Quake-mode adapter.
12. Configure startup/launch integration for the Quake adapter.
13. Install or verify supported coding agents.
14. Install or verify model tooling where requested.
15. Configure local example files from `.example` templates.
16. Run the doctor command for the selected phase at the end.
17. Print next manual steps clearly.

Base required tools:

* Git
* Bash
* WezTerm
* chezmoi
* Neovim
* Yazi
* ripgrep
* fd
* fzf
* jq
* curl
* unzip
* tar

Platform-specific required tools:

Windows:

* Git for Windows, assumed preinstalled before running repository setup
* AutoHotkey v2
* winget, when available
* PowerShell 7, optional but preferred
* No WSL
* Do not install WSL

macOS:

* Homebrew, if already available
* Hammerspoon
* Homebrew Bash, preferred
* Do not silently install Homebrew unless explicitly enabled

Ubuntu:

* apt
* GNOME Shell integration for Quake mode
* Detect Wayland versus X11
* Detect GNOME Shell version

Optional developer tools:

* uv
* node
* npm
* pnpm
* cmake
* ninja
* python
* Ollama
* LM Studio endpoint configuration
* llama.cpp-compatible endpoint configuration

Optional AI agents:

* OpenCode
* Pi
* Claude Code
* Codex
* Goose

Do not include Yazi in the AI agent list.

## Full Phase List

| Phase | Name                                      | Status                                    |
| ----- | ----------------------------------------- | ----------------------------------------- |
| 0     | Repository foundation                     | Implemented and locally validated         |
| 1     | Common shell workflow                     | Implemented and validated on Windows; needs macOS/Ubuntu validation |
| 2     | WezTerm baseline with tmux-style bindings | Implemented and automated validation passed on Windows; needs manual GUI validation |
| 3     | Quake-mode dropdown                       | Windows validated; macOS/Ubuntu stubbed |
| 4     | Neovim baseline                           | Not started                               |
| 5     | Yazi baseline                             | Not started                               |
| 6     | Rider and minimal Unreal launching        | Not started                               |
| 7     | Project and worktree workflow             | Not started                               |
| 8     | AI agent launcher                         | Not started                               |
| 9     | Agent notifications and status            | Not started                               |
| 10    | Optional model tooling                    | Not started                               |
| 11    | Polish and hardening                      | Not started                               |

Current repository state note: this tracker was added after an initial portable slice already existed. Existing files and behavior still need to be audited against the detailed checklist before broad checkboxes are marked complete.

## Setup Commands

Windows:

```powershell
./setup.ps1 -Phase foundation
./setup.ps1 -Phase shell
./setup.ps1 -Phase wezterm
./setup.ps1 -Phase quake
./setup.ps1 -Phase neovim
./setup.ps1 -Phase yazi
./setup.ps1 -Phase rider
./setup.ps1 -Phase agents
./setup.ps1 -Phase all
```

macOS / Ubuntu:

```bash
./setup.sh --phase foundation
./setup.sh --phase shell
./setup.sh --phase wezterm
./setup.sh --phase quake
./setup.sh --phase neovim
./setup.sh --phase yazi
./setup.sh --phase rider
./setup.sh --phase agents
./setup.sh --phase all
```

Optional convenience entrypoint:

```bash
./setup --phase shell
```

## Phase 0: Repository Foundation

Status: Implemented and locally validated

Goal: Create the repository structure, documentation, setup entrypoints, config examples, and doctor command skeleton.

Scope:

* Create the basic repo layout.
* Create persistent documentation.
* Create the initial setup framework.
* Create the initial doctor command.
* Do not implement WezTerm, Quake mode, Neovim, Yazi, Rider, or agents yet except as documented future phases and placeholders.

Requirements:

* Root documentation must identify this repository's purpose and constraints.
* `PLAN.md` must be the operational source of truth.
* `AGENTS.md` must instruct future agents to read `PLAN.md` and `docs/architecture.md` before changes.
* Setup entrypoints must exist or be explicitly tracked as not yet implemented.
* Checked-in configuration must use placeholder/example files only.
* Platform-specific automation must live under `platform/`.
* Shared dotfile behavior must live under `chezmoi/`.

Deliverables:

* README.md
* AGENTS.md
* PLAN.md
* docs/architecture.md
* docs/implementation-plan.md
* docs/provisioning.md
* setup
* setup.sh
* setup.ps1
* scripts/doctor
* scripts/setup/
* config/workstation.example.toml
* config/agents.example.toml
* config/models.example.toml
* .gitignore
* .editorconfig
* initial test structure

Tasks:

* [x] Create README.md.
* [x] Create AGENTS.md.
* [x] Create PLAN.md.
* [x] Create docs/architecture.md.
* [x] Create docs/implementation-plan.md.
* [x] Create docs/provisioning.md.
* [x] Create setup entrypoint.
* [x] Create setup.sh.
* [x] Create setup.ps1.
* [x] Create scripts/doctor.
* [x] Create scripts/setup/.
* [x] Create config/workstation.example.toml.
* [x] Create config/agents.example.toml.
* [x] Create config/models.example.toml.
* [x] Create .gitignore.
* [x] Create .editorconfig.
* [x] Create initial test structure.
* [x] Add dry-run support to setup where practical.
* [x] Add OS detection to setup.
* [x] Add phase selection to setup.
* [x] Add basic doctor output.

Validation:

* [x] Repository has clear structure.
* [x] `doctor` runs without crashing.
* [x] Setup scripts detect OS and selected phase.
* [x] Setup scripts support dry-run mode.
* [x] No secrets are committed.
* [x] Platform-specific sections are isolated.

Notes:

* Phase 0 is implemented for the repository foundation and local Windows Git Bash validation passed on 2026-07-05.
* Setup is conservative: it verifies and reports, but does not silently install package managers or overwrite user configuration.

Deferred items:

* Package installation and per-platform bootstrap automation remain pending for later phases.

## Phase 1: Common Shell Workflow

Status: Implemented and validated on Windows; needs macOS/Ubuntu validation

Goal: Create a shared Bash-first workflow across Windows, macOS, and Ubuntu.

Scope:

* Windows must use Git Bash, not WSL.
* Day-to-day commands should feel similar across all platforms.
* Prefer Unix-style commands everywhere.
* Add platform and tool detection.
* Add initial helper stubs for future phases.

Requirements:

Windows:

* Use Git for Windows Bash.
* Assume Git for Windows is already installed before setup runs.
* Detect the Git Bash executable robustly.
* Support calling native Windows applications from Bash.
* Preserve Windows-native paths where native tools require them.
* Provide helper functions for path conversion using `cygpath` where necessary.
* Do not assume Linux-only paths.
* Do not require WSL.
* Do not require MSYS2 tmux or Cygwin.
* Be careful with quoting for Windows paths containing spaces.
* Support calling `cmd.exe` and PowerShell safely from Bash only when needed.

macOS:

* Prefer Homebrew Bash when available.
* Fall back cleanly if it is not installed.
* Do not silently install Homebrew unless explicitly enabled in config.

Ubuntu:

* Use normal system Bash.
* Assume GNOME Wayland by default.
* Detect GNOME Shell version.
* Detect Wayland versus X11.

Common shell command expectation:

The normal workflow should use Unix-style commands on every platform:

* `ls`
* `cd`
* `pwd`
* `cat`
* `less`
* `grep`
* `rg`
* `fd`
* `find` where appropriate
* `jq`
* `git`
* `curl`
* `tar`
* `unzip`
* `mkdir`
* `rm`
* `cp`
* `mv`

Deliverables:

* chezmoi-managed `.bashrc`
* chezmoi-managed `.bash_profile`
* shared Bash functions
* shared Bash aliases
* platform detection
* PATH handling
* tool detection
* Git Bash detection on Windows
* Unix-style command availability checks
* documentation for shell behavior
* initial helper stubs

Shared Bash configuration should include:

* common aliases
* common functions
* PATH handling
* platform detection
* tool detection
* safe shell options
* fzf integration when installed
* ripgrep integration
* fd integration
* jq helpers
* git helpers
* project navigation helpers
* worktree helpers
* agent launcher helpers
* Yazi helper function
* Neovim helper function
* Rider helper function
* no aliases that silently change destructive command behavior

Required shell helpers:

* `platform-info`
* `workstation-root`
* `doctor`
* `project`
* `y`
* `nv`
* `rider`
* `wt-create`
* `wt-list`
* `wt-remove`
* `wt-open`
* `agent`
* `agent-notify`

Tasks:

* [x] Add chezmoi-managed `.bashrc`.
* [x] Add chezmoi-managed `.bash_profile`.
* [x] Add shared Bash functions.
* [x] Add shared Bash aliases.
* [x] Add platform detection.
* [x] Add PATH handling.
* [x] Add tool detection.
* [x] Add Git Bash detection on Windows.
* [x] Add Unix-style command availability checks.
* [x] Add shell documentation.
* [x] Add `platform-info` helper.
* [x] Add `workstation-root` helper.
* [x] Add initial `project` helper stub.
* [x] Add initial `y` helper stub.
* [x] Add initial `nv` helper stub.
* [x] Add initial `rider` helper stub.
* [x] Add initial worktree helper stubs.
* [x] Add initial agent helper stubs.
* [x] Add doctor checks for shell phase.

Validation:

* [x] Windows Git Bash opens and loads shared config.
* [x] `ls`, `git`, `rg`, `fd`, and `jq` work from Git Bash when installed.
* [ ] macOS Bash loads shared config.
* [ ] Ubuntu Bash loads shared config.
* [x] `platform-info` identifies the platform.
* [x] `doctor --phase shell` reports shell status.
* [x] Path helpers handle spaces in paths.

Notes:

* Existing tests cover platform and helper behavior under Git for Windows Bash.
* Do not mark platform behavior as validated until tested on that platform.
* 2026-07-05: `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 4 setup tests.
* 2026-07-05: `scripts/doctor --phase foundation` and `scripts/doctor --phase shell` passed under Git for Windows Bash.
* 2026-07-05: `setup.sh --phase shell` passed under Git for Windows Bash and only performed verification plus doctor checks.
* 2026-07-05: User clarified the acceptance bar: on clean Windows after Git for Windows is installed and the repository is cloned, `setup.ps1 -Phase shell` must verify Git/Git Bash, install or verify chezmoi and Phase 1 CLI tools, apply chezmoi, and run automated validation without requiring manual helper checks.
* 2026-07-05: `setup.ps1` now defaults to `shell`, verifies Git/Git Bash, installs/verifies setup-managed Windows Phase 1 tools through `winget`, applies chezmoi, and validates the configured interactive Git Bash shell. `setup.sh` also applies chezmoi and validates the interactive shell when Bash already exists.
* 2026-07-05: `setup.ps1 -Phase shell` passed on this Windows machine. It verified Git/Git Bash, installed/verified chezmoi, ripgrep, fd, jq, and fzf; applied chezmoi; ran repository tests through Git Bash; and validated the configured interactive Git Bash shell.
* 2026-07-05: `scripts/setup/verify.ps1 -Phase shell` passed in a separate PowerShell process after setup.
* 2026-07-05: after Windows provisioning, `fd`, `jq`, and `fzf` are available in configured Git Bash. `fdfind` remains an optional warning on Windows because the command is named `fd`.
* 2026-07-05: ShellCheck was not available in the validation environment.
* Automated interactive Git Bash validation passed. A user-opened fresh terminal window is still a useful smoke test but is no longer required to call the Windows path validated.
* 2026-07-05: Added `scripts/setup/reset-windows.ps1` for conservative Phase 1 reset dry-runs and explicit reset execution. Destructive reset requires `-Apply`; setup-managed package removal requires `-RemovePackages`; Git is never removed by the reset script.
* 2026-07-05: User manually validated Windows dry-runs from PowerShell: `setup.ps1 -Phase shell -DryRun`, `scripts/setup/reset-windows.ps1 -Phase shell`, and `scripts/setup/reset-windows.ps1 -Phase shell -RemovePackages`. Output confirmed Git/Git Bash are verified, Git is not installed by setup, and Git is never removed by reset.
* 2026-07-05: User found the real reset/provision loop could block at a chezmoi prompt after package reinstall. Setup was updated to back up known Phase 1 managed targets and run `chezmoi apply --force` so provisioning remains non-interactive.
* 2026-07-05: User manually validated the full Windows reset/provision loop with package removal. `reset-windows.ps1 -Phase shell -Apply -RemovePackages` removed setup-managed Phase 1 packages and did not remove Git. `setup.ps1 -Phase shell` reinstalled setup-managed tools, applied chezmoi with `--force` without prompting, ran repository tests, and passed interactive Git Bash `doctor --phase shell` validation with only accepted warnings.

Deferred items:

* Full project, worktree, agent, Rider, Yazi, and Neovim helper behavior remains deferred to later phases.

## Phase 2: WezTerm Baseline with Tmux-Style Bindings

Status: Implemented and validated on Windows; needs macOS/Ubuntu validation

Goal: Configure WezTerm as the cross-platform terminal and pane/tab/workspace layer.

Scope:

* Do not use tmux yet.
* Configure WezTerm to mimic tmux-style keybindings.
* Ensure WezTerm launches the correct shell per platform.
* Prepare, but do not complete, Quake workspace integration.

Requirements:

* Tmux-style keybindings
* Ctrl+A leader key
* consistent keybindings on all platforms
* tabs
* pane splits
* one-stroke pane split shortcuts for ergonomics, while preserving tmux-style leader bindings
* named workspaces
* workspace picker
* pane navigation using h, j, k, and l
* pane resizing using H, J, K, and L
* pane zoom
* copy mode
* tab selection
* dedicated Quake workspace placeholder
* agent status display where practical
* platform-aware shell startup
* sensible font fallback without requiring proprietary font files
* no platform-specific Cmd-based primary workflow on macOS
* clean integration with Git Bash on Windows
* no requirement for tmux

Keybinding hierarchy:

* Ctrl+` for OS-level Quake dropdown
* Ctrl+A for terminal pane/tab/workspace actions
* Space as the Neovim leader
* Ctrl+W for Neovim split/window actions

WezTerm tmux-like bindings:

* Ctrl+A, |        split left/right
* Ctrl+A, -        split top/bottom
* Ctrl+A, h        move to pane left
* Ctrl+A, j        move to pane down
* Ctrl+A, k        move to pane up
* Ctrl+A, l        move to pane right
* Ctrl+A, H        resize pane left
* Ctrl+A, J        resize pane down
* Ctrl+A, K        resize pane up
* Ctrl+A, L        resize pane right
* Ctrl+A, c        create new tab
* Ctrl+A, x        close pane with confirmation
* Ctrl+A, z        toggle pane zoom
* Ctrl+A, w        workspace or tab picker
* Ctrl+A, r        rename workspace or tab where practical
* Ctrl+A, 1..9     select tab
* Ctrl+A, [        copy mode
* Ctrl+A, a        send literal Ctrl+A
* Ctrl+A, e        open Yazi in a new pane
* Ctrl+A, E        open Yazi in the current pane
* Ctrl+A, v        open Neovim in the current pane
* Ctrl+A, V        open Neovim in a new pane
* Ctrl+A, u        move to next agent pane needing attention, if implemented later
* Ctrl+`           operating-system-level Quake dropdown toggle, not a WezTerm-only binding

Additional direct split bindings:

* Ctrl+|           split left/right
* Ctrl+-           split top/bottom
* Ctrl+_           split top/bottom fallback when Shift is held

Deliverables:

* chezmoi/dot_config/wezterm/
* wezterm.lua
* keybindings module
* platform shell detection
* workspace helpers
* docs/wezterm.md
* doctor checks for WezTerm

Tasks:

* [x] Add WezTerm config directory placeholder.
* [x] Add base wezterm.lua.
* [x] Add platform-aware shell startup.
* [x] Configure Git Bash startup on Windows.
* [x] Configure Bash startup on macOS/Ubuntu.
* [x] Add tmux-style leader key.
* [x] Add split bindings.
* [x] Add pane movement bindings.
* [x] Add pane resize bindings.
* [x] Add zoom binding.
* [x] Add tab bindings.
* [x] Add copy-mode binding.
* [x] Add workspace picker.
* [x] Add placeholder Quake workspace identity.
* [x] Add docs/wezterm.md.
* [x] Add doctor checks for WezTerm.

Validation:

* [x] WezTerm starts successfully on Windows.
* [ ] It launches the correct shell. Status: Windows Git Bash validated; macOS/Ubuntu pending.
* [x] On Windows, WezTerm launches Git Bash.
* [ ] On macOS and Ubuntu, WezTerm launches Bash.
* [x] Ctrl+A bindings work on Windows. Status: macOS/Ubuntu pending.
* [x] Pane splits and navigation work on Windows. Status: macOS/Ubuntu pending.
* [x] Tabs work on Windows. Status: macOS/Ubuntu pending.
* [x] `doctor --phase wezterm` reports status.

Notes:

* Phase 2 replaces the former non-functional placeholder with an active baseline config.
* 2026-07-05 readiness check: the placeholder file already contains a draft config after the intentional failure line, but it must be audited before activation.
* 2026-07-05 readiness check: `wezterm.exe` is not currently on PATH on the validated Windows machine.
* 2026-07-05 readiness check: `setup.ps1 -Phase wezterm -DryRun` is rejected because setup only accepts `foundation`, `shell`, and `all`.
* 2026-07-05 readiness check: `doctor --phase wezterm` reports the phase as not implemented.
* 2026-07-05: `setup.ps1 -Phase wezterm` installed WezTerm with winget package `wez.wezterm`, applied chezmoi, and passed `doctor --phase wezterm`.
* 2026-07-05: `doctor --phase wezterm` validates WezTerm presence, config presence, absence of the old placeholder failure, and config loading through `wezterm --config-file <path> show-keys`.
* 2026-07-05: Git Bash shell config now adds the WinGet Links directory on Windows so newly installed winget aliases are visible in Git Bash launched from stale parent environments.
* 2026-07-05: Manual WezTerm launch found `SpawnCommandInNewPane` is not a valid key assignment in stable WezTerm 20240203. Replaced it with `SplitPane` for helper panes, added a regression test, reapplied chezmoi, and verified the installed config with `wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys`.
* 2026-07-05: Manual WezTerm launch then found `domain` is not a valid top-level `SplitPane` field. Removed the invalid field from the helper-pane wrapper and changed doctor validation to use `show-keys --lua` so configured leader keys are included in validation output.
* 2026-07-05: Manual WezTerm use showed copy/paste ergonomics were unclear and there is no Windows-style context menu. Added explicit `Ctrl+Shift+C`, `Ctrl+Shift+V`, `Ctrl+Insert`, `Shift+Insert`, and right-click paste bindings.
* 2026-07-05: Manual WezTerm validation confirmed Git Bash starts, but `doctor --phase wezterm` failed from `~` because the repository root was not known outside the worktree. Setup now writes machine-local `~/.config/workstation/env.sh` with `WORKSTATION_REPO_ROOT`; shell startup, `workstation-root`, and `doctor` all load it so validation works from home.
* 2026-07-05: User manually validated a WezTerm-launched Git Bash session from `~`: `echo "$WORKSTATION_REPO_ROOT"` and `workstation-root` both returned `C:/work/cross-platform-workstation`, and `doctor --phase wezterm` passed with only expected warnings for optional `fdfind` and deferred future-phase helpers.
* 2026-07-05: User reported `Ctrl+A`, `|` did not split panes on Windows. Added an equivalent `Ctrl+A`, `Shift+\` binding for the same horizontal split action, documented it as the Windows fallback, reapplied setup, and added a regression test.
* 2026-07-05: User found two-stroke split bindings too clunky. Added one-stroke direct split bindings matching tmux symbols: `Ctrl+|` for left/right and `Ctrl+-` for top/bottom, while preserving the tmux-style `Ctrl+A` bindings. The failed `Ctrl+Shift+\` experiment was replaced because it targeted the physical key rather than the mapped tmux symbol.
* 2026-07-05: User manually validated that `Ctrl+Shift+|` splits left/right and `Ctrl+-` splits top/bottom. User also found `Ctrl+Shift+-` reduced the window/font size, which is expected because shifted minus is `_` rather than the tmux `-` symbol; added `Ctrl+_` and leader `_` fallbacks so holding Shift on minus splits instead of invoking the default size behavior.
* 2026-07-05: User manually validated the Windows WezTerm GUI bindings: direct split shortcuts, tmux-style split bindings, pane movement, pane resize, zoom/unzoom, tab create/select, close-pane confirmation, copy/paste, right-click paste, workspace picker, and `quake` workspace placeholder all work.
* 2026-07-05: Setup/reset validation was extended for Phase 2. Setup now backs up `~/.config/wezterm` before forced chezmoi apply. `reset-windows.ps1` accepts `-Phase wezterm`, removes or backs up `~/.config/wezterm`, and includes WezTerm package removal only when `-RemovePackages` is provided. Git is still never removed. User manually validated the full destructive reset/reinstall loop with `-Apply -RemovePackages`.
* 2026-07-05: Replaced the hard-to-read Solarized Dark WezTerm scheme with an explicit palette matching the default Windows Terminal scheme inherited by the default Windows PowerShell profile on the validated Windows machine. The local Windows Terminal settings had no custom scheme configured.

Deferred items:

* Rich agent status and attention traversal remain deferred.

## Phase 3: Quake-Mode Dropdown

Status: Windows validated; macOS/Ubuntu stubbed

Goal: Add global Ctrl+` dropdown behavior using platform-specific adapters.

Scope:

* Implement desktop-level global shortcut behavior.
* Use platform-specific adapters.
* Preserve all WezTerm state while hidden.
* Place dropdown on the currently focused monitor.

Requirements:

Global shortcut:

* Ctrl+`

The shortcut must work while any application is focused.

On activation:

1. Show a dedicated persistent WezTerm dropdown window.
2. Place it on the monitor containing the currently focused application window.
3. Position it at the top of that monitor.
4. Use approximately 95% of the monitor width and 100% of its work-area height.
5. Focus the terminal immediately.
6. Apply 95% window opacity to the Quake WezTerm window.
7. Preserve all tabs, panes, shells, running commands, editors, file managers, and agents while hidden.

On second activation, when the dropdown is focused:

1. Hide the dropdown window.
2. Do not terminate any processes.

Platform-specific adapters:

* Windows: AutoHotkey v2. Status: implemented, syntax-validated, and manually validated on Windows.
* macOS: Hammerspoon. Status: stubbed/deferred.
* Ubuntu GNOME on Wayland: a GNOME Shell extension or another GNOME-native mechanism. Status: stubbed/deferred.

State machine:

1. If no Quake WezTerm window exists, launch it on the monitor containing the focused application.
2. If the Quake window exists but is hidden, move it to the monitor containing the focused application and focus it.
3. If the Quake window exists and another application is focused, move it to that application’s monitor and focus it.
4. If the Quake window is currently focused, hide it.
5. Preserve all processes and WezTerm state while hidden.

Quake window identity:

* Window title/class/role: wezterm-quake, or the most reliable platform-specific equivalent
* Workspace: quake
* Width: approximately 95% of focused monitor
* Height: approximately 100% of focused monitor work area
* Opacity: 95% for the Quake window
* Position: top center of focused monitor
* Always-on-top if reliable and not disruptive
* No dependency on WSL

Deliverables:

* platform/windows/quake-toggle.ahk
* platform/macos/hammerspoon/init.lua or equivalent
* platform/ubuntu/gnome-extension/ or equivalent GNOME-native integration
* docs/quake-mode.md
* setup support for Quake adapter
* doctor checks for Quake adapter

Tasks:

* [x] Implement Windows AutoHotkey adapter.
* [ ] Implement macOS Hammerspoon adapter.
* [ ] Implement Ubuntu GNOME adapter or documented stub.
* [x] Add setup support for Windows adapter.
* [ ] Add setup support for macOS/Ubuntu adapters.
* [x] Add Quake docs.
* [x] Add doctor checks.
* [x] Add manual validation checklist.
* [x] Add Windows per-user startup registration for the Quake adapter.

Validation:

* [x] Ctrl+` toggles the dropdown on Windows.
* [ ] It appears on the focused monitor. Status: Initial Windows validation confirms dropdown appears on the active machine; multi-monitor focused placement still needs validation.
* [x] It hides without killing the shell on Windows.
* [x] It preserves running commands on Windows with the minimize fallback.
* [ ] It works after switching monitor focus. Status: Needs Windows manual GUI validation.
* [x] Behavior is documented separately for Windows, macOS, and Ubuntu.
* [x] Untested platform-specific behavior is clearly marked.
* [x] `doctor --phase quake` reports adapter status and validates AutoHotkey syntax on Windows.
* [x] `setup.ps1 -Phase quake` installs/verifies AutoHotkey v2 and validates the Quake phase on Windows.
* [x] Windows startup registration works after reboot.
* [x] Final Phase 3 automated validation passed on Windows.

Notes:

* 2026-07-05: Windows adapter replaced the previous stub with an AutoHotkey v2 implementation. It registers `Ctrl+`` through AutoHotkey, launches a dedicated WezTerm `quake` workspace, uses title `wezterm-quake`, targets the focused monitor's work area, sizes to approximately 95% width and initially 55% height, hides when focused, and preserves the GUI process while hidden.
* 2026-07-05: Added `platform/windows/start-quake.ps1` as the supported manual launcher so users do not need to type the long AutoHotkey executable/script path by hand.
* 2026-07-05: `setup.ps1 -Phase quake` installed/verifed AutoHotkey v2 through winget package `AutoHotkey.AutoHotkey`, found the standard install path `C:\Program Files\AutoHotkey\v2`, and passed `doctor --phase quake`.
* 2026-07-05: `doctor --phase quake` validates AutoHotkey availability, adapter presence, v2 requirement, hotkey registration, hide/placement behavior, and script syntax with `AutoHotkey64.exe //Validate`.
* 2026-07-05: Manual GUI validation has not been performed yet. Do not mark focused-monitor behavior, hide/show persistence, or process preservation complete until tested in the Windows desktop session.
* 2026-07-05: Initial Windows GUI validation found that the adapter launched `wezterm.exe`, which created a black non-interactive `wezterm-quake` window while the real interactive terminal opened separately. The adapter now prefers `wezterm-gui.exe` and keeps `wezterm.exe` only as a fallback. This fix still needs live GUI revalidation.
* 2026-07-05: Follow-up Windows validation confirmed launch, sizing, focus, input, and hide behavior, but state was not preserved on restore. The adapter now enables `DetectHiddenWindows True` so `WinExist` can rediscover the hidden dropdown instead of launching a new WezTerm process. Process/state preservation needs retest.
* 2026-07-05: Follow-up inspection after the restore failure showed `AutoHotkey64.exe` and a hidden `wezterm-gui.exe` process were still running, but the dropdown did not reappear. The restore sequence now calls hidden-window detection in the hotkey/find path and calls `WinShow` before `WinRestore`/`WinMove`.
* 2026-07-05: Live retest showed the explicit hidden-window restore path still did not show the window on the next toggle. The Windows adapter now avoids `WinHide` entirely and parks the existing window off-screen, keeping it alive and discoverable for the next toggle.
* 2026-07-05: Live retest of the parking strategy produced a black window plus a separate terminal window, and toggling could not recover cleanly after closing. The adapter now stops tracking launch PIDs and no longer mutates arbitrary window titles. It launches WezTerm with `--class wezterm-quake` and identifies the dropdown by that class.
* 2026-07-05: Live retest of the class-based parking strategy still failed on restore. Process inspection showed WezTerm still running, but no top-level window was enumerable after parking. The adapter now dismisses the dropdown with `WinMinimize` instead of hiding or parking, accepting a possible taskbar entry in exchange for reliable state preservation.
* 2026-07-05: User manually validated the Windows minimize fallback: first toggle launches a working terminal, subsequent `Ctrl+`` toggles dismiss and restore as expected, and shell state is preserved. User found the first-launch small-window-then-resize behavior disruptive.
* 2026-07-05: Added first-launch polish: the adapter computes target monitor geometry before launch, passes approximate WezTerm `initial_cols`/`initial_rows`, passes `--position screen:x,y`, starts WezTerm minimized, then restores and applies final pixel-accurate placement. This needs live GUI retest.
* 2026-07-05: Updated Windows Quake sizing/appearance requirements per user request: height is now 85% of focused monitor height and the Quake window launches with 85% `window_background_opacity`. Width remains 95%.
* 2026-07-05: Updated the Quake opacity request from 85% to 95%. Height remains 85% and width remains 95%.
* 2026-07-05: Updated `doctor --phase quake` to validate the current `WinMinimize` dismiss fallback instead of the abandoned `WinHide` implementation.
* 2026-07-05: Updated the Quake height request from 85% to 100% of the focused monitor work area. Width remains 95% and opacity remains 95%.
* 2026-07-05: Added Windows per-user startup registration. `setup.ps1 -Phase quake` creates `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\cross-platform-workstation-quake.lnk`, which runs `platform/windows/start-quake.ps1` at login. `reset-windows.ps1 -Phase quake -Apply` removes or backs up the shortcut. `doctor --phase quake` verifies the shortcut is present. Setup created the shortcut successfully on the validated Windows machine, doctor verified it, and user manually validated reset dry-run cleanup.
* 2026-07-06: User rebooted Windows and confirmed `Ctrl+`` works as intended without manually running `start-quake.ps1`. Windows startup registration is manually validated.
* 2026-07-06: User reran `setup.ps1 -Phase quake` after reboot. Setup verified Phase 1/2 tools, applied chezmoi, created the startup shortcut, and passed WezTerm plus Quake doctor checks.
* 2026-07-06: Final Phase 3 validation passed on Windows. `doctor --phase quake`, `tests/run.bash`, and `git diff --check` all passed; the Quake doctor warning now only calls out focused-monitor placement and multi-monitor movement as manual GUI validation.

Deferred items:

* macOS Hammerspoon adapter.
* Ubuntu GNOME adapter.
* None for Windows startup registration; reboot validation completed on 2026-07-06.
* Manual validation on all supported platforms.

## Phase 4: Neovim Baseline

Status: Not started

Goal: Add a restrained, maintainable Neovim setup.

Scope:

* Add Neovim config skeleton.
* Use Space as leader.
* Avoid complex AI/editor integration initially.
* Keep behavior clean inside WezTerm.

Requirements:

* Install or verify Neovim.
* Space as leader.
* System clipboard integration where available.
* Sensible defaults.
* Basic file navigation.
* Basic LSP-ready structure, but avoid forcing a huge plugin system unless justified.
* Clean terminal behavior inside WezTerm.
* Good defaults for editing:

  * shell
  * Lua
  * Markdown
  * TOML
  * JSON
  * YAML
  * C++
  * C#
  * Python
  * JavaScript/TypeScript
  * Unreal-adjacent files
* Do not create complex AI-agent Neovim integrations initially.
* Do not create fragile terminal-pane navigation hacks initially.

Shell helpers:

* `nv` opens Neovim in the current directory or with passed files.
* `nvc` checks Neovim config health where possible.
* `edit` may open Neovim by default if appropriate.

WezTerm integration:

* Ctrl+A, v opens Neovim in the current pane.
* Ctrl+A, V opens Neovim in a new pane.

Deliverables:

* chezmoi/dot_config/nvim/
* docs/neovim.md
* shell helper `nv`
* WezTerm bindings for Neovim
* doctor checks for Neovim

Tasks:

* [ ] Add Neovim config directory.
* [ ] Add basic init.lua or equivalent.
* [ ] Add sensible defaults.
* [ ] Add Space leader.
* [ ] Add filetype/editor basics.
* [ ] Add shell helper `nv`.
* [ ] Add optional shell helper `nvc`.
* [ ] Add docs/neovim.md.
* [ ] Add doctor checks.

Validation:

* [ ] `nvim` starts.
* [ ] `nv` works.
* [ ] WezTerm Neovim keybindings work.
* [ ] Neovim does not conflict with Ctrl+A terminal leader.
* [ ] `doctor --phase neovim` reports status.

Notes:

* Existing shell helper stubs may exist, but the phase is not implemented.

Deferred items:

* Complex AI/editor integration.
* Fragile terminal-pane navigation hacks.

## Phase 5: Yazi Baseline

Status: Not started

Goal: Add Yazi as the terminal file manager.

Scope:

* Add Yazi config.
* Add `y` helper.
* Integrate with WezTerm.
* Treat Yazi as a terminal file manager, not an AI agent.

Requirements:

* Install or verify Yazi.
* Yazi should be available from Bash on Windows, macOS, and Ubuntu.
* Use Yazi for fast terminal file navigation.
* Use it inside WezTerm panes.
* Use it to move between project files, worktrees, logs, and Unreal project folders.
* Do not treat it as an AI agent.

Shell helpers:

* `y` opens Yazi in the current directory.
* When exiting Yazi, Bash should change to the directory selected in Yazi if supported.
* Add a safe fallback when Yazi is not installed.

WezTerm integration:

* Ctrl+A, e opens Yazi in a new pane.
* Ctrl+A, E opens Yazi in the current pane.
* Ensure Yazi works in the dedicated Quake workspace.
* Ensure Yazi works inside project worktrees.

Doctor checks:

* Detect yazi.
* Print version.
* Verify config path.
* Verify whether preview dependencies are installed.
* Warn, but do not fail, if optional preview dependencies are missing.

Deliverables:

* chezmoi/dot_config/yazi/
* yazi.toml
* keymap.toml
* theme.toml
* docs/yazi.md
* shell helper `y`
* WezTerm bindings for Yazi
* doctor checks for Yazi

Tasks:

* [ ] Add Yazi config directory.
* [ ] Add yazi.toml.
* [ ] Add keymap.toml.
* [ ] Add theme.toml.
* [ ] Add `y` shell helper.
* [ ] Add WezTerm bindings.
* [ ] Add docs/yazi.md.
* [ ] Add doctor checks.

Validation:

* [ ] `yazi` starts.
* [ ] `y` opens Yazi.
* [ ] Directory-changing-on-exit works where supported.
* [ ] WezTerm Yazi keybindings work.
* [ ] `doctor --phase yazi` reports status.

Notes:

* Yazi must not be listed as an AI agent.

Deferred items:

* Advanced previews and theme customization may be deferred if the baseline is useful.

## Phase 6: Rider and Minimal Unreal Launching

Status: Not started

Goal: Add simple Rider integration for Unreal projects.

Scope:

* Do not build full Unreal automation yet.
* Only implement launching Rider with the `.uproject` or project folder.
* Ensure this works from Git Bash on Windows.

Requirements:

The helper should:

1. Detect whether the current directory is inside a Git repo or project tree.
2. Detect a `.uproject` file nearby where practical.
3. Launch Rider with the `.uproject` file if found.
4. Otherwise launch Rider with the current directory or provided path.
5. Work from Git Bash on Windows.
6. Work from Bash on macOS and Ubuntu where Rider is installed.
7. Preserve quoting for paths containing spaces.
8. Allow a configured Rider executable path.
9. Avoid hard-coding one user-specific path.
10. Fail with a useful message if Rider cannot be found.

Possible commands:

* `rider`
* `rider .`
* `rider path/to/project`
* `rider-uproject`
* `project-open-rider`
* `project <name> --rider`

Windows-specific requirements:

* The command must work from Git Bash.
* It may call native Windows executables.
* It should support `.uproject` paths with spaces.
* It should not require WSL.
* It should not require Visual Studio.
* It should not run Unreal build commands by default.

Deferred Unreal features:

* building Unreal projects
* generating project files
* launching Unreal Editor
* managing Unreal Engine versions
* Visual Studio integration
* tailing Unreal logs
* packaging builds
* running AutomationTool
* running UnrealBuildTool directly

Deliverables:

* shell helper `rider`
* shell helper `rider-uproject`
* project helper support for `.uproject`
* docs/rider.md
* docs/unreal-minimal.md
* config entries for Rider path if autodetection fails
* doctor checks for Rider configuration

Tasks:

* [ ] Add Rider helper.
* [ ] Add `.uproject` detection.
* [ ] Add Rider path config.
* [ ] Add dry-run support.
* [ ] Add Windows Git Bash support.
* [ ] Add docs/rider.md.
* [ ] Add docs/unreal-minimal.md.
* [ ] Add doctor checks.

Validation:

* [ ] From Git Bash on Windows, `rider-uproject` can locate the nearest `.uproject`.
* [ ] It prints the command it intends to run in dry-run mode.
* [ ] It handles spaces in paths.
* [ ] It gives a clear error if Rider is not configured or detected.
* [ ] `doctor --phase rider` reports status.

Notes:

* Existing `docs/unreal.md` may contain related narrative, but this phase requires the minimal Rider-specific files above.

Deferred items:

* Full Unreal build automation.
* Unreal Editor launching.
* Visual Studio integration.

## Phase 7: Project and Worktree Workflow

Status: Not started

Goal: Add project navigation and Git worktree helpers.

Scope:

* Project discovery/navigation.
* Worktree helpers.
* Prepare for one worktree per write-capable agent.

Project workflow:

The `project` command should help open or navigate known projects.

It should be able to:

* list known projects
* jump to a project
* open a project workspace in WezTerm
* open Rider for a project
* open Yazi for a project
* open Neovim for a project

Git worktree workflow:

Design the workflow around one Git worktree per write-capable agent.

Commands:

* `wt-create <name> [base-branch]`
* `wt-list`
* `wt-remove <name>`
* `wt-open <name>`
* `agent-worktree <agent> <task-name> <profile>`

Do not allow multiple write-capable agents to default to the same working directory.

Deliverables:

* scripts/project
* scripts/wt-create
* scripts/wt-list
* scripts/wt-remove
* scripts/wt-open
* docs/worktrees.md
* project config examples
* doctor checks where relevant

Tasks:

* [ ] Add `project` command.
* [ ] Add project list/open support.
* [ ] Add `wt-create`.
* [ ] Add `wt-list`.
* [ ] Add `wt-remove`.
* [ ] Add `wt-open`.
* [ ] Add safety checks.
* [ ] Add docs/worktrees.md.
* [ ] Add tests where practical.

Validation:

* [ ] Worktree commands handle spaces in paths.
* [ ] Worktree commands are safe by default.
* [ ] Project commands work in dry-run mode.
* [ ] `doctor --phase project` reports status where practical.

Notes:

* Shell stubs may exist, but standalone scripts and tested behavior are not implemented.

Deferred items:

* Automated project workspace orchestration until command behavior is tested.

## Phase 8: AI Agent Launcher

Status: Not started

Goal: Add a common agent launcher with adapters for supported tools.

Scope:

* Adapter-based agent launcher.
* Support OpenCode, Pi, Claude Code, Codex, and Goose.
* Do not assume every tool supports every model or provider.

Supported AI tools:

* OpenCode
* Pi
* Claude Code
* Codex
* Goose

Common command:

```bash
agent <tool> <profile> [-- task args...]
```

Examples:

```bash
agent opencode local-coder
agent pi local-fast
agent claude review
agent codex implement
agent goose local-coder
```

Each agent adapter should define:

* executable name or detection logic
* install verification command
* configuration file locations
* supported model/profile mapping, where applicable
* environment variables required
* whether it supports local models
* whether it supports cloud models
* whether it supports MCP
* whether it supports non-interactive execution
* whether it can safely run inside a Git worktree
* title/status integration
* known limitations

The launcher should:

1. Detect the requested agent.
2. Load the requested model/profile.
3. Refuse unsupported profile combinations with a clear message.
4. Start the agent inside the current Git worktree.
5. Set terminal title/status metadata.
6. Call agent-notify when entering running/waiting/complete/failed states where possible.
7. Never store secrets in the repository.
8. Fail gracefully when an agent is unavailable.
9. Clearly distinguish between tools that support local models and tools that do not.
10. Clearly distinguish between tools that support MCP and tools that do not.

Model-profile examples:

* local-fast
* local-coder
* cloud-fast
* cloud-reasoning
* review

Local endpoints:

* Ollama
* LM Studio
* llama.cpp-compatible OpenAI endpoints

Cloud/provider routing:

* native agent provider config
* optional OpenAI-compatible gateway

Deliverables:

* scripts/agent
* scripts/agent-notify
* agents/opencode/
* agents/pi/
* agents/claude/
* agents/codex/
* agents/goose/
* config/agents.example.toml
* config/models.example.toml
* docs/agents.md
* docs/goose.md
* docs/models.md

Tasks:

* [ ] Add `agent` launcher.
* [ ] Add adapter structure.
* [ ] Add OpenCode adapter.
* [ ] Add Pi adapter.
* [ ] Add Claude Code adapter.
* [ ] Add Codex adapter.
* [ ] Add Goose adapter.
* [ ] Add model profile examples.
* [ ] Add docs.
* [ ] Add doctor checks.
* [ ] Add tests where practical.

Validation:

* [ ] `agent --list` works.
* [ ] `agent <tool> --doctor` works.
* [ ] Missing tools produce clear errors.
* [ ] Unsupported model/profile combinations are rejected clearly.
* [ ] No secrets are committed.
* [ ] `doctor --phase agents` reports status.

Notes:

* Existing `docs/agents.md` and placeholder config directories do not complete this phase.
* OpenCode, Pi, Claude Code, Codex, and Goose are independent integrations.

Deferred items:

* Automatic installation of optional agents until the policy is decided.

## Phase 9: Agent Notifications and Status

Status: Not started

Goal: Add basic agent status integration.

Scope:

* Add portable `agent-notify`.
* Integrate with terminal title/status where practical.
* Keep state outside repository.

Supported states:

* running
* waiting
* complete
* failed

`agent-notify <state> <message>` should:

* Change terminal or pane title.
* Emit a supported terminal notification sequence where possible.
* Optionally send a desktop notification.
* Write minimal state into a cache directory outside the repository.
* Allow WezTerm to display agent status where practical.
* Fail gracefully when a notification mechanism is unavailable.

Deliverables:

* scripts/agent-notify
* WezTerm status integration where practical
* cache/state directory outside the repo
* docs/agent-status.md

Tasks:

* [ ] Add `agent-notify`.
* [ ] Add state file format.
* [ ] Add terminal title integration.
* [ ] Add notification sequence where practical.
* [ ] Add WezTerm status integration if practical.
* [ ] Add docs/agent-status.md.
* [ ] Add tests where practical.

Validation:

* [ ] `agent-notify running "test"` works.
* [ ] `agent-notify waiting "test"` works.
* [ ] `agent-notify complete "test"` works.
* [ ] `agent-notify failed "test"` works.
* [ ] WezTerm does not break if status files are missing.

Notes:

* Any state files must live outside the repository.

Deferred items:

* Rich desktop notification behavior if portable support is not reliable.

## Phase 10: Optional Model Tooling

Status: Not started

Goal: Add optional local/cloud model tooling configuration.

Scope:

* Add model config examples.
* Add endpoint detection.
* Do not commit secrets.
* Do not assume every agent supports every provider.

Optional local endpoints:

* Ollama
* LM Studio
* llama.cpp-compatible OpenAI endpoints

Optional cloud/provider routing:

* native agent provider config
* optional OpenAI-compatible gateway

Requirements:

* Do not store secrets.
* Do not assume every agent supports every provider.
* Document limitations clearly.
* Keep model configuration separate from terminal configuration.

Deliverables:

* config/models.example.toml
* docs/models.md
* setup support for optional model tooling
* doctor checks

Tasks:

* [x] Add model config examples.
* [ ] Add endpoint config placeholders.
* [ ] Add doctor checks for configured endpoints.
* [ ] Add docs/models.md.
* [ ] Add setup support for optional tools where appropriate.

Validation:

* [x] Example config files exist.
* [ ] Doctor can detect configured endpoints without exposing secrets.
* [ ] Missing optional model tools do not fail the whole setup.

Notes:

* The example file exists, but model tooling behavior is not implemented.

Deferred items:

* Full model gateway provisioning.
* Automatic cloud credential setup.

## Phase 11: Polish and Hardening

Status: Not started

Goal: Make the repo safer, more maintainable, and easier to use on fresh machines.

Scope:

* Improve setup idempotency.
* Improve diagnostics.
* Improve tests.
* Improve docs.
* Harden path handling and platform behavior.

Requirements:

* No platform-specific behavior should be marked validated without real testing on that platform.
* Setup should be safe to re-run.
* Existing user config should not be silently overwritten.
* Troubleshooting docs should cover common failures.
* Shell and PowerShell scripts should be linted when tools are available.

Deliverables:

* improved setup idempotency
* improved doctor checks
* install logs
* dry-run modes
* backup behavior for overwritten files
* troubleshooting docs
* test coverage
* manual validation checklist

Tasks:

* [ ] Improve setup idempotency.
* [ ] Add install logs.
* [ ] Improve dry-run modes.
* [ ] Add backup behavior for overwritten files.
* [ ] Improve troubleshooting docs.
* [ ] Expand tests.
* [ ] Add manual validation checklist.
* [ ] Review security behavior.
* [ ] Review path quoting behavior.

Validation:

* [ ] Setup is safe to re-run.
* [ ] Existing user configs are not silently overwritten.
* [ ] Clear next steps are printed after setup.
* [ ] Troubleshooting docs cover common failures.
* [ ] Platform-specific untested behavior is clearly marked.

Notes:

* This phase remains pending until the core phases are in place.

Deferred items:

* None beyond the global deferred feature list.

## Config Requirements

`config/workstation.example.toml` should include something like:

```toml
[features]
wezterm = true
quake_mode = true
bash = true
neovim = true
yazi = true
rider = true
agents = false
unreal_minimal = true
local_models = false
tmux = false

[agents]
opencode = false
pi = false
claude = false
codex = false
goose = false

[models]
ollama = false
lm_studio = false
openai_compatible_gateway = false

[editor]
default = "nvim"
ide = "rider"

[rider]
path = ""
prefer_uproject = true

[platform.windows]
use_winget = true
install_autohotkey = true
install_wsl = false
shell = "git-bash"

[platform.macos]
use_homebrew = true
install_homebrew_if_missing = false
install_hammerspoon = true
prefer_homebrew_bash = true

[platform.ubuntu]
use_apt = true
install_gnome_extension = true
assume_wayland = true

[terminal]
backend = "wezterm"
tmux_enabled = false
leader = "CTRL+A"
```

## Setup Architecture

Create a small provisioning framework rather than one huge script.

Suggested structure:

```text
setup
setup.sh
setup.ps1

scripts/setup/
├── common.sh
├── common.ps1
├── detect-platform.sh
├── detect-platform.ps1
├── install-base.sh
├── install-agents.sh
├── install-model-tools.sh
├── apply-dotfiles.sh
├── setup-quake.sh
├── setup-neovim.sh
├── setup-yazi.sh
├── setup-rider.sh
├── verify.sh
└── phases/

platform/
├── windows/
│   ├── install.ps1
│   ├── packages.ps1
│   └── quake-toggle.ahk
├── macos/
│   ├── install.sh
│   ├── packages.sh
│   └── hammerspoon/init.lua
└── ubuntu/
    ├── install.sh
    ├── packages.sh
    └── gnome-extension/
```

The setup scripts must be modular, readable, and testable.

They should not require admin privileges unless necessary.

When admin privileges are needed, explain why and request them explicitly.

## Doctor Command Requirements

Create a doctor command that supports phases.

Examples:

```bash
doctor
doctor --phase foundation
doctor --phase shell
doctor --phase wezterm
doctor --phase quake
doctor --phase neovim
doctor --phase yazi
doctor --phase rider
doctor --phase agents
doctor --phase all
```

The doctor command should report:

* Operating system
* Architecture
* Shell
* Bash version
* WezTerm version
* chezmoi version
* Git version
* Neovim version
* Yazi version
* Rider detection/configuration
* Git Bash path on Windows
* availability of Unix-style commands in Git Bash on Windows
* GNOME version and session type on Ubuntu
* Quake adapter status
* presence of OpenCode
* presence of Pi
* presence of Claude Code
* presence of Codex
* presence of Goose
* presence of Ollama or LM Studio endpoint configuration
* whether required config files are linked or applied
* whether WezTerm config is present
* whether Neovim config is present
* whether Yazi config is present
* whether required directories exist
* missing optional dependencies

The doctor command should return a nonzero exit code only for genuinely required failures in the selected phase.

## Testing Requirements

Add tests for:

* platform detection
* path quoting
* Windows path conversion
* Git Bash detection
* Unix-style command availability checks
* Rider path detection
* `.uproject` detection
* worktree creation
* agent launcher argument parsing
* configuration parsing
* setup phase parsing
* setup feature flag parsing
* idempotent bootstrap helper behavior where practical
* Yazi helper behavior where practical
* Neovim config path detection where practical

Use shellcheck for shell scripts when possible.

Use Pester for important PowerShell functions if useful.

Document manual test procedures for:

* global hotkey
* focused-monitor behavior
* multi-monitor movement
* hide/show persistence
* Ubuntu Wayland behavior
* macOS Spaces behavior
* Windows virtual desktops
* Git Bash Unix-style command workflow
* launching Rider from Git Bash
* opening a `.uproject` in Rider
* opening Yazi from WezTerm
* opening Neovim from WezTerm
* running each supported agent launcher
* running project workspaces
* running worktree workflows

## Documentation Requirements

Create documentation for:

* overall architecture
* phased installation/provisioning
* shell workflow
* Git Bash on Windows
* Unix-style command workflow across platforms
* WezTerm configuration
* Quake-mode behavior
* Bash configuration
* Neovim setup
* Yazi setup
* Rider integration
* minimal Unreal workflow
* agent launcher and supported agents
* Goose integration
* model profile configuration
* Git worktree workflow
* future tmux support
* troubleshooting

## Security Requirements

* Never commit secrets.
* Provide `.example` files for environment variables.
* Add appropriate `.gitignore` entries.
* Document use of OS credential stores or password managers.
* Do not print secrets in diagnostics.
* Make scripts safe under paths containing spaces.
* Avoid curl-pipe-shell installation patterns unless clearly documented and optional.
* Pin external dependencies where practical.
* Do not silently overwrite existing user configuration without making backups or asking for confirmation.
* Do not install WSL.
* Do not hard-code private paths, usernames, API keys, or machine-specific secrets.

## Repository Structure

Start with a structure similar to:

```text
cross-platform-workstation/
├── setup
├── setup.sh
├── setup.ps1
├── README.md
├── AGENTS.md
├── PLAN.md
├── LICENSE
├── .gitignore
├── .editorconfig
├── config/
│   ├── workstation.example.toml
│   ├── agents.example.toml
│   └── models.example.toml
├── scripts/
│   ├── agent
│   ├── agent-notify
│   ├── doctor
│   ├── project
│   ├── rider
│   ├── wt-create
│   ├── wt-list
│   ├── wt-remove
│   ├── wt-open
│   └── setup/
├── agents/
│   ├── opencode/
│   ├── pi/
│   ├── claude/
│   ├── codex/
│   └── goose/
├── tools/
│   ├── neovim/
│   ├── yazi/
│   └── rider/
├── chezmoi/
│   ├── .chezmoi.toml.tmpl
│   ├── dot_bashrc
│   ├── dot_bash_profile
│   └── dot_config/
│       ├── wezterm/
│       ├── nvim/
│       ├── yazi/
│       ├── opencode/
│       ├── pi/
│       ├── goose/
│       └── workstation/
├── platform/
│   ├── windows/
│   │   ├── quake-toggle.ahk
│   │   └── bootstrap.ps1
│   ├── macos/
│   │   ├── hammerspoon/
│   │   └── bootstrap.sh
│   └── ubuntu/
│       ├── gnome-extension/
│       └── bootstrap.sh
├── templates/
│   └── agent-task.md
├── tests/
└── docs/
    ├── architecture.md
    ├── implementation-plan.md
    ├── installation.md
    ├── provisioning.md
    ├── shell.md
    ├── wezterm.md
    ├── quake-mode.md
    ├── neovim.md
    ├── yazi.md
    ├── rider.md
    ├── unreal-minimal.md
    ├── agents.md
    ├── goose.md
    ├── models.md
    ├── worktrees.md
    ├── tmux-future.md
    └── troubleshooting.md
```

## Open Decisions

Track unresolved choices here.

Initial open decisions:

* [ ] Exact GNOME Quake-mode implementation approach.
* [ ] Whether to use a plugin manager for Neovim.
* [ ] Whether Yazi should use a custom theme immediately or start with defaults.
* [ ] Whether setup should install optional AI agents automatically or only detect them initially.
* [ ] Whether future tmux support should be added for macOS/Ubuntu.
* [ ] Exact strategy for Rider executable detection on Windows/macOS/Ubuntu.

## Known Risks

Track risks here.

Initial known risks:

* Ubuntu GNOME Wayland Quake behavior may require manual validation.
* macOS Spaces behavior may require manual validation.
* Windows multi-monitor behavior may require physical-machine testing.
* Git Bash path conversion may have edge cases with native Windows tools.
* Agent CLIs may change their configuration formats over time.
* Rider executable discovery may differ by install method.
* Windows paths with spaces must be tested carefully.
* Phase 1 shell loading still needs manual validation in fresh interactive shells after chezmoi is applied.

## Deferred Features

Track intentionally deferred items here.

Initial deferred features:

* tmux active integration
* full Unreal build automation
* Unreal Editor launching
* Visual Studio integration
* complex Neovim AI integration
* arbitrary Linux desktop support
* full model gateway provisioning
* automatic cloud credential setup

## Unsupported/Deferred Items

This section mirrors and expands the unsupported/deferred policy for quick lookup.

* WSL as a required dependency.
* tmux as an active dependency.
* Full Unreal build automation.
* Visual Studio automation.
* Arbitrary Linux desktops beyond Ubuntu GNOME.
* Perfect Quake-mode behavior on every possible Linux compositor.
* Committed API keys or private credentials.

## Current Next Actions

Current next actions:

1. Commit and push Phase 3 when the Windows behavior is accepted.
2. Validate Phase 2/3 on macOS and Ubuntu only when those platforms are available.
3. Begin Phase 4 Neovim baseline after Phase 3 is saved.
4. Keep `PLAN.md` updated after each implementation or validation session.

## PLAN.md Update Rules

After each implementation session:

1. Update PLAN.md.
2. Mark completed tasks.
3. Mark stubbed tasks as stubbed.
4. Mark untested platform-specific behavior clearly.
5. Add newly discovered issues.
6. Add manual validation steps.
7. Update next actions.
8. Add a dated entry to the change log.
9. Keep the plan truthful and current.
10. Do not mark anything as complete unless it is implemented and either tested or clearly marked as requiring manual validation.
11. If requirements change, update the relevant phase section rather than only adding a note at the bottom.

## Change Log

Add a dated entry after each session.

Format:

```markdown
### YYYY-MM-DD

- Summary of changes
- Phases touched
- Validation performed
- Known gaps
- Next actions
```

### 2026-07-05

- Summary of changes: Completed the Phase 0/1 deliverable: setup entrypoints, setup helper skeleton, provisioning and shell docs, `config/agents.example.toml`, Phase 0/1 example config defaults, shared Bash helpers, explicit future-phase helper stubs, phase-aware doctor checks, repository skeleton placeholders, tests, and `.gitattributes` line-ending policy. Later phases remain placeholders only. WezTerm has an explicit non-functional placeholder so Phase 2 is not accidentally represented as implemented.
- Phases touched: Phase 0, Phase 1, Phase 2 placeholder correction, repository-wide tracking.
- Validation performed: `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 4 setup tests. `scripts/doctor --phase foundation` passed. `scripts/doctor --phase shell` passed with warnings for missing optional tools `fd`, `fdfind`, `jq`, and `fzf`. `setup.sh --phase shell` passed. `setup.ps1 -Phase foundation -DryRun` and `setup.ps1 -Phase shell -DryRun` passed.
- Known gaps: macOS and Ubuntu validation has not been performed. Fresh interactive shell loading after chezmoi apply has not been manually validated. ShellCheck was not available in the validation environment. Later phases are not implemented. Optional Phase 1 tools may be absent and are reported as warnings.
- Next actions: Apply and validate Bash config in fresh shells, validate macOS and Ubuntu, then start Phase 2 only after updating this tracker with validation results.

### 2026-07-05

- Summary of changes: Updated setup behavior after Windows validation showed `chezmoi` was missing. `setup.sh` and `setup.ps1` now default to Phase 1 (`shell`) instead of stopping at Phase 0, detect missing `chezmoi`, and support explicit Windows installation with `--install-missing` / `-InstallMissing`.
- Phases touched: Phase 0, Phase 1.
- Validation performed: `tests/run.bash` passed under Git for Windows Bash after setup changes: 13 config tests, 6 function tests, 5 platform tests, and 7 setup tests. `setup.sh --dry-run`, `setup.sh --phase shell --install-missing --dry-run`, `setup.ps1 -DryRun`, and `setup.ps1 -Phase shell -InstallMissing -DryRun` passed.
- Known gaps: Need to rerun setup/tests and then validate `chezmoi apply` in a fresh Git Bash session.
- Next actions: Run `./setup.sh --phase shell --install-missing`, then apply chezmoi and verify fresh-shell helpers.

### 2026-07-05

- Summary of changes: Revised the Phase 1 Windows setup model so `setup.ps1 -Phase shell` is the clean-machine bootstrap path after Git for Windows is installed and the repository is cloned. It now verifies Git for Windows/Git Bash, installs/verifies chezmoi, ripgrep, fd, jq, and fzf through `winget`; applies chezmoi; runs repository tests through Git Bash; and validates a configured interactive Git Bash shell. `setup.sh` also applies chezmoi and validates the configured shell when Bash already exists.
- Phases touched: Phase 0, Phase 1.
- Validation performed: `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 16 setup tests. `setup.ps1 -DryRun`, `setup.ps1 -Phase shell -DryRun`, `setup.ps1 -Phase foundation -DryRun`, and `setup.sh --dry-run` passed. PowerShell scripts parsed successfully. `git diff --check` passed.
- Known gaps: The real non-dry `setup.ps1 -Phase shell` has not been run yet because it may install packages and apply dotfiles. macOS and Ubuntu validation remain untested.
- Next actions: Run `setup.ps1 -Phase shell` with user approval, then record whether automated Windows provisioning passed.

### 2026-07-05

- Summary of changes: Completed the Windows Phase 1 provisioning path. Fixed winget discovery through the WindowsApps alias, resolved winget-installed executable locations, persisted discovered command directories into the user PATH, fixed chezmoi apply to use the repository source explicitly, and exported `WORKSTATION_REPO_ROOT` during configured-shell validation.
- Phases touched: Phase 1.
- Validation performed: `setup.ps1 -Phase shell` passed end-to-end and was rerun successfully as an idempotency check. `scripts/setup/verify.ps1 -Phase shell` passed in a separate PowerShell process. Repository tests passed through Git Bash. Configured interactive Git Bash validation passed with required tools available: Git, Bash, chezmoi-applied shell config, ripgrep, fd, jq, and fzf.
- Known gaps: macOS and Ubuntu validation remain untested. `fdfind` remains an optional warning on Windows because Windows uses `fd`.
- Next actions: Accept Windows Phase 1 as validated, optionally smoke-test a fresh Git Bash window, then move to Phase 2 or defer macOS/Ubuntu validation explicitly.

### 2026-07-05

- Summary of changes: Fixed installed `doctor` repo-root detection after manual testing showed `doctor --phase shell` failed from the repository root unless `WORKSTATION_REPO_ROOT` was set. The doctor now checks `WORKSTATION_REPO_ROOT`, then the current Git worktree root, then walks upward from the current directory before falling back to its installed path.
- Phases touched: Phase 1.
- Validation performed: `setup.ps1 -Phase shell` passed and applied the updated doctor. An interactive Git Bash command from `/c/work/cross-platform-workstation` ran `doctor --phase shell` successfully with all required checks passing.
- Known gaps: Git Bash instances launched from an already-running PowerShell process may not inherit newly persisted user PATH entries until the parent process is refreshed; newly opened Git Bash windows should see them. macOS and Ubuntu validation remain untested.
- Next actions: User can rerun `doctor --phase shell` from a fresh Git Bash window at the repo root as a final smoke test.

### 2026-07-05

- Summary of changes: Added a conservative Windows Phase 1 reset script at `scripts/setup/reset-windows.ps1`. It dry-runs by default, backs up/removes known Phase 1 dotfiles only when `-Apply` is provided, uninstalls setup-managed Phase 1 packages only with `-RemovePackages`, and never removes Git.
- Phases touched: Phase 1, Phase 11 hardening precursor.
- Validation performed: `scripts/setup/reset-windows.ps1 -Phase shell` dry-run passed and listed the files it would back up/remove. `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 19 setup tests. `git diff --check` passed.
- Known gaps: Actual reset execution has not been run. Package uninstall reset has not been run. macOS and Ubuntu remain untested.
- Next actions: If a setup reset retest is desired, run reset with `-Apply`, then rerun `setup.ps1 -Phase shell`. Keep Git for Windows installed because it is the repository prerequisite.

### 2026-07-05

- Summary of changes: Tightened the Windows bootstrap/reset contract. `setup.ps1` now treats Git for Windows and Git Bash as prerequisites to verify, not tools to install. `scripts/setup/reset-windows.ps1` no longer has any Git removal option and only removes setup-managed packages when `-RemovePackages` is provided.
- Phases touched: Phase 1, Phase 11 hardening precursor.
- Validation performed: `setup.ps1 -Phase shell -DryRun` passed and reported Git/Git Bash as already available without any Git install action. `scripts/setup/reset-windows.ps1 -Phase shell` dry-run passed and reported that Git is never removed. `scripts/setup/reset-windows.ps1 -Phase shell -RemovePackages` dry-run passed and listed only setup-managed packages: chezmoi, ripgrep, fd, jq, and fzf. The user also manually reran these three dry-runs from PowerShell and confirmed matching output. `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 20 setup tests. `git diff --check` passed for tracked changes.
- Known gaps: Actual reset execution and package uninstall reset remain untested. macOS and Ubuntu remain untested.
- Next actions: If a setup reset retest is desired, run `scripts/setup/reset-windows.ps1 -Phase shell -Apply`, then rerun `setup.ps1 -Phase shell`. Do not uninstall Git; it remains a prerequisite.

### 2026-07-05

- Summary of changes: Fixed the real Windows reset/provision loop after user testing showed `chezmoi apply` could block with `.bash_profile has changed since chezmoi last wrote it?`. Setup now backs up known Phase 1 managed targets to `~/.workstation-setup-backup/<timestamp>` and then runs `chezmoi apply --force`.
- Phases touched: Phase 1, Phase 11 hardening precursor.
- Validation performed: `setup.ps1 -Phase shell -DryRun` passed and now reports `chezmoi apply --force`. `chezmoi apply --help` confirmed `--force` makes changes without prompting. `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 6 function tests, 5 platform tests, and 24 setup tests. `git diff --check` passed for tracked changes. User then manually validated `setup.ps1 -Phase shell`, fresh Git Bash `doctor --phase shell`, `platform-info`, `workstation-root`, `reset-windows.ps1 -Phase shell -Apply -RemovePackages`, and a full reinstall via `setup.ps1 -Phase shell`; all required checks passed.
- Known gaps: macOS and Ubuntu remain untested. Reset package removal idempotency should be improved so rerunning removal after packages are already absent reports "not installed" rather than relying on winget behavior.
- Next actions: Optionally harden package uninstall idempotency messages, then commit the Phase 1 reset/provisioning updates if accepted.

### 2026-07-05

- Summary of changes: Prepared the tracker for Phase 2. Confirmed the repository is clean after the Phase 1 commit, audited the current WezTerm placeholder state, and recorded the first Phase 2 entry points.
- Phases touched: Phase 2 planning.
- Validation performed: `wezterm.exe --version` failed because WezTerm is not on PATH. `setup.ps1 -Phase wezterm -DryRun` failed because setup does not yet accept the `wezterm` phase. `doctor --phase wezterm` correctly reports the phase as not implemented.
- Known gaps: Phase 2 implementation has not started. macOS and Ubuntu remain untested.
- Next actions: Implement the WezTerm baseline, setup support, doctor checks, docs, tests, and Windows validation.

### 2026-07-05

- Summary of changes: Implemented the Phase 2 WezTerm baseline. Activated `wezterm.lua`, added tmux-style `Ctrl+A` bindings, platform-aware Bash startup, Windows WezTerm installation through winget package `wez.wezterm`, `setup.ps1`/`setup.sh` phase support, `doctor --phase wezterm`, `docs/wezterm.md`, and tests. Added Windows Git Bash PATH hardening for WinGet Links.
- Phases touched: Phase 1 PATH hardening, Phase 2.
- Validation performed: `setup.ps1 -Phase wezterm -DryRun` passed. `setup.ps1 -Phase wezterm` installed WezTerm 20240203-110809-5046fc22, applied chezmoi, and passed `doctor --phase wezterm`. `tests/run.bash` passed under Git for Windows Bash: 13 config tests, 7 function tests, 5 platform tests, 30 setup tests, and 13 WezTerm tests. Interactive Git Bash `doctor --phase wezterm` passed required checks. `wezterm --config-file <repo>/chezmoi/dot_config/wezterm/wezterm.lua show-keys` succeeded.
- Known gaps: Windows GUI launch and key chords still need manual validation. macOS and Ubuntu remain untested. Yazi/Neovim bindings call helper stubs until later phases. Quake mode remains deferred to Phase 3.
- Next actions: Manually validate Windows WezTerm GUI startup and keybindings, update this tracker, then decide whether to commit or continue hardening before Phase 3.

### 2026-07-05

- Summary of changes: Fixed a manual WezTerm launch failure caused by invalid action `SpawnCommandInNewPane`. Helper-pane bindings now use supported `SplitPane` action.
- Phases touched: Phase 2.
- Validation performed: `wezterm --config-file <repo>/chezmoi/dot_config/wezterm/wezterm.lua show-keys` passed. `setup.ps1 -Phase wezterm` reapplied the corrected config and passed `doctor --phase wezterm`. `wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys` passed. `tests/run.bash` passed under Git for Windows Bash with 14 WezTerm tests. `git diff --check` passed for tracked changes.
- Known gaps: Windows GUI startup should be retried. Key chord validation remains manual. macOS and Ubuntu remain untested.
- Next actions: Reopen WezTerm and confirm it starts without config errors, then test the core `Ctrl+A` bindings.

### 2026-07-05

- Summary of changes: Fixed a second manual WezTerm launch failure caused by invalid top-level `domain` field on `SplitPane`. The helper-pane wrapper now uses only supported `SplitPane` fields, and doctor validation now runs `show-keys --lua`.
- Phases touched: Phase 2.
- Validation performed: `setup.ps1 -Phase wezterm` reapplied the corrected config and passed `doctor --phase wezterm` with `show-keys --lua succeeded`. `tests/run.bash` passed under Git for Windows Bash with 15 WezTerm tests. `git diff --check` passed for tracked changes.
- Known gaps: Windows GUI startup should be retried. Key chord validation remains manual. macOS and Ubuntu remain untested.
- Next actions: Reopen WezTerm and confirm it starts without config errors, then test the core `Ctrl+A` bindings.

### 2026-07-05

- Summary of changes: Added explicit WezTerm clipboard ergonomics after manual testing found copy/paste and context-menu behavior unclear. Right click is now bound to paste, and keyboard copy/paste bindings are documented.
- Phases touched: Phase 2.
- Validation performed: `wezterm --config-file <repo>/chezmoi/dot_config/wezterm/wezterm.lua show-keys --lua` passed. `setup.ps1 -Phase wezterm` applied the updated config and passed `doctor --phase wezterm`. `tests/run.bash` passed under Git for Windows Bash with 20 WezTerm tests. `git diff --check` passed for tracked changes.
- Known gaps: User still needs to manually validate right-click paste, `Ctrl+Shift+C`, `Ctrl+Shift+V`, `Ctrl+Insert`, and `Shift+Insert` inside the WezTerm GUI. macOS and Ubuntu remain untested.
- Next actions: Reopen WezTerm, test clipboard bindings, then continue the core Phase 2 keybinding validation.

### 2026-07-05

- Summary of changes: Fixed `doctor --phase wezterm` from WezTerm sessions launched in `~` by generating and loading a machine-local `WORKSTATION_REPO_ROOT` env file. PowerShell setup writes the file without a UTF-8 BOM, and `functions.sh` plus `doctor` now load it directly so helper behavior is robust outside the repository.
- Phases touched: Phase 1 shell hardening, Phase 2 validation.
- Validation performed: `setup.ps1 -Phase wezterm` regenerated env/config and passed `doctor --phase wezterm`. `tests/run.bash` passed under Git for Windows Bash with 11 function tests, 32 setup tests, and 20 WezTerm tests. An interactive Git Bash launched in `~` resolved `WORKSTATION_REPO_ROOT`, `workstation-root`, and `doctor --phase wezterm` successfully. `git diff --check` passed for tracked changes.
- Known gaps: Core WezTerm key chord validation remains manual. macOS and Ubuntu remain untested.
- Next actions: Reopen WezTerm and run `doctor --phase wezterm` from `~`, then test the core `Ctrl+A` pane/tab/workspace bindings.

### 2026-07-05

- Summary of changes: Completed Windows manual validation for Phase 2 WezTerm. Added and documented direct tmux-symbol split shortcuts, shifted-minus split fallback, clipboard bindings, and robust repo-root loading from WezTerm sessions launched outside the repository.
- Phases touched: Phase 1 shell hardening, Phase 2.
- Validation performed: `setup.ps1 -Phase wezterm` passed. `tests/run.bash` passed under Git for Windows Bash with 13 config tests, 11 function tests, 5 platform tests, 32 setup tests, and 27 WezTerm tests. User manually validated Windows WezTerm GUI behavior: Git Bash startup, repo-root doctor from `~`, pane splits, pane movement, pane resize, zoom, tabs, close-pane confirmation, copy/paste, right-click paste, workspace picker, and `quake` workspace placeholder.
- Known gaps: macOS and Ubuntu Phase 2 validation remain untested. Quake dropdown remains deferred to Phase 3. Yazi and Neovim bindings intentionally call stubs until later phases.
- Next actions: Commit and push Phase 2, then begin Phase 3 or defer macOS/Ubuntu validation explicitly.

### 2026-07-05

- Summary of changes: Hardened setup/reset handling for Phase 2. Setup backup logic now includes the managed WezTerm config directory, and `reset-windows.ps1` now supports `-Phase wezterm`/`all`, includes `~/.config/wezterm` in cleanup targets, and includes setup-managed WezTerm package removal only behind `-RemovePackages`.
- Phases touched: Phase 2, Phase 11 hardening precursor.
- Validation performed: `setup.ps1 -Phase wezterm -DryRun` passed and showed WezTerm config backup. `reset-windows.ps1 -Phase wezterm` dry-run passed and showed WezTerm config cleanup. `reset-windows.ps1 -Phase wezterm -RemovePackages` dry-run passed and showed setup-managed WezTerm package removal while still not removing Git. User then ran `reset-windows.ps1 -Phase wezterm -Apply -RemovePackages`, which backed up/removed managed files and uninstalled chezmoi, ripgrep, fd, jq, fzf, and WezTerm without removing Git. `setup.ps1 -Phase wezterm` then reinstalled/verifed Phase 1 tools plus WezTerm, applied chezmoi, and passed `doctor --phase wezterm`. `tests/run.bash` passed with 38 setup tests and 27 WezTerm tests. `git diff --check` passed with only expected CRLF warnings for PowerShell scripts.
- Known gaps: macOS and Ubuntu remain untested.
- Next actions: Commit and push the Phase 2 setup/reset hardening, then proceed to Phase 3 or defer macOS/Ubuntu validation explicitly.

### 2026-07-05

- Summary of changes: Implemented the Windows Phase 3 Quake-mode adapter. Added AutoHotkey v2 setup support, `doctor --phase quake`, AutoHotkey syntax validation, Windows Quake documentation, a short PowerShell launcher, reset support for AutoHotkey removal, and tests.
- Phases touched: Phase 3, Windows setup/doctor/reset, docs, tests.
- Validation performed: `setup.ps1 -Phase quake -DryRun` passed. `setup.ps1 -Phase quake` installed/verifed AutoHotkey v2, applied chezmoi, passed `doctor --phase wezterm`, and passed `doctor --phase quake`. `doctor --phase quake` validated adapter presence and AutoHotkey syntax through `//Validate`. `reset-windows.ps1 -Phase quake` and `reset-windows.ps1 -Phase quake -RemovePackages` dry-runs passed. `platform/windows/start-quake.ps1` parsed successfully. `tests/run.bash` passed with 24 Quake tests, 46 setup tests, and 27 WezTerm tests. `git diff --check` passed with only expected CRLF warnings.
- Known gaps: Windows global hotkey behavior, focused-monitor placement, hide/show persistence, and process preservation still require manual GUI validation. macOS and Ubuntu adapters remain stubbed/deferred. Windows startup registration for the AutoHotkey adapter is not implemented yet.
- Next actions: Start the AutoHotkey adapter manually with `.\platform\windows\start-quake.ps1`, validate `Ctrl+`` behavior on Windows, update this tracker, then decide whether startup registration belongs in Phase 3 or later hardening.

### 2026-07-05

- Summary of changes: Fixed the Windows Quake adapter launch target after initial GUI validation showed a black non-interactive `wezterm-quake` window and a separate interactive WezTerm window. The adapter now prefers `wezterm-gui.exe` and keeps `wezterm.exe` only as a fallback.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: Code inspection confirmed the previous adapter targeted `wezterm.exe`; process inspection showed both `wezterm.exe` and `wezterm-gui.exe` windows were running. AutoHotkey syntax validation passed. `doctor --phase quake` passed with the expected manual-validation warning. `tests/run.bash` passed with 25 Quake tests, 46 setup tests, and 27 WezTerm tests. `git diff --check` passed with only expected CRLF warnings.
- Known gaps: Live Windows GUI revalidation still required after closing the stale windows and restarting the AutoHotkey adapter. macOS and Ubuntu remain unimplemented.
- Next actions: Close stale WezTerm windows from the failed validation, restart `platform/windows/start-quake.ps1`, then retest `Ctrl+`` launch/focus/hide/persistence behavior.

### 2026-07-05

- Summary of changes: Fixed Windows Quake hide/show state persistence by enabling AutoHotkey hidden-window detection. Without this, `WinHide` hid the dropdown, but the next toggle could not find it and launched a new WezTerm window.
- Phases touched: Phase 3, Windows Quake adapter, tests.
- Validation performed: User manually validated that steps 1-7 of the Windows Quake flow work: launch, sizing/focus/input, and hide. Static Quake tests were updated to require `DetectHiddenWindows True`.
- Known gaps: User reported state was not preserved on step 8 before this fix. The updated adapter still needs live GUI retesting for process/state preservation. Multi-monitor focused placement remains unvalidated.
- Next actions: Restart the AutoHotkey adapter so it loads the updated script, then retest hiding/restoring a running command.

### 2026-07-05

- Summary of changes: Hardened the Windows Quake restore path after live validation showed the hidden `wezterm-gui.exe` process remained running but did not show again. The adapter now enables hidden-window detection in the hotkey/find path and explicitly calls `WinShow` before restore and move.
- Phases touched: Phase 3, Windows Quake adapter, tests.
- Validation performed: Process inspection showed `AutoHotkey64.exe` and hidden `wezterm-gui.exe` still running after hide. Static tests were updated to require the explicit show-before-move restore sequence.
- Known gaps: Live Windows GUI retest is required to confirm the hidden window restores with shell state intact. Multi-monitor focused placement remains unvalidated.
- Next actions: Stop the current adapter and hidden WezTerm process, restart `platform/windows/start-quake.ps1`, then retest hide/show state persistence.

### 2026-07-05

- Summary of changes: Replaced the Windows Quake `WinHide` path with off-screen parking after live validation showed hidden-window restore still failed. The adapter now moves the focused dropdown to an off-screen parking location and later moves the same window back to the focused monitor.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: User confirmed the hidden-window restore fix still did not restore on step 4. The implementation strategy was changed to keep the window discoverable instead of relying on `WinHide`.
- Known gaps: Live Windows GUI retest is required to confirm off-screen parking preserves shell state and restores reliably. Multi-monitor focused placement remains unvalidated.
- Next actions: Stop AutoHotkey and WezTerm, restart `platform/windows/start-quake.ps1`, then retest park/show state persistence.

### 2026-07-05

- Summary of changes: Replaced launch-PID/title tracking for the Windows Quake window with a dedicated WezTerm window class. The adapter now launches WezTerm with `--class wezterm-quake` and finds the dropdown by `ahk_class wezterm-quake`.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: User reported the parking strategy produced a black window plus a separate terminal window and could not recover cleanly after closing. This identified PID/title tracking as too brittle when WezTerm owns multiple windows/processes.
- Known gaps: Live Windows GUI retest is required after killing stale AutoHotkey/WezTerm processes and restarting the adapter. Multi-monitor focused placement remains unvalidated.
- Next actions: Stop all stale AutoHotkey and WezTerm processes, restart `platform/windows/start-quake.ps1`, then retest launch, park, restore, close, and retoggle behavior.

### 2026-07-05

- Summary of changes: Changed the Windows Quake dismiss behavior from off-screen parking to `WinMinimize` after live validation showed parking could leave WezTerm running with no enumerable top-level window to restore.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: User reported class-based parking still did not restore on step 5. Process inspection showed WezTerm was still running. A top-level window enumeration found no WezTerm window after parking, indicating the restore target was no longer available to AutoHotkey.
- Known gaps: Live Windows GUI retest is required to confirm minimize/restore preserves shell state. This may leave a taskbar entry while dismissed. Multi-monitor focused placement remains unvalidated.
- Next actions: Stop all stale AutoHotkey and WezTerm processes, restart `platform/windows/start-quake.ps1`, then retest launch, minimize/dismiss, restore, close, and retoggle behavior.

### 2026-07-05

- Summary of changes: Recorded successful manual Windows validation for the Quake minimize fallback.
- Phases touched: Phase 3.
- Validation performed: User confirmed the Windows Quake dropdown now launches a working terminal and toggles correctly after first launch. The window briefly launches small and is then resized to the expected dimensions, but subsequent toggles work as expected and state is preserved.
- Known gaps: First-launch resize flicker remains a polish issue. Multi-monitor focused placement is still unvalidated. macOS and Ubuntu adapters remain stubbed/deferred. Windows startup registration is not implemented.
- Next actions: Decide whether to polish first-launch sizing now or accept it, then run final Phase 3 validation and commit/push if accepted.

### 2026-07-05

- Summary of changes: Added a first-launch polish pass for the Windows Quake adapter to reduce the visible small-window-then-resize flicker.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: Static tests updated to require initial WezTerm rows/columns, initial screen position, and minimized launch before final placement. AutoHotkey/live GUI validation still needs to be rerun.
- Known gaps: Live Windows GUI retest is required to confirm the flicker is gone or acceptable. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Restart AutoHotkey/WezTerm, retest first launch, then run final Phase 3 validation if accepted.

### 2026-07-05

- Summary of changes: Updated Windows Quake size and opacity defaults. The dropdown now targets 95% width, 85% height, and launches with 85% WezTerm window opacity.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: Static tests updated to require `QuakeHeightRatio := 0.85`, `QuakeOpacity := 0.85`, and the Quake-specific `window_background_opacity` launch override.
- Known gaps: Live Windows GUI retest is required to confirm the new height and opacity. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Restart AutoHotkey/WezTerm, retest first launch, height, opacity, and toggle persistence.

### 2026-07-05

- Summary of changes: Updated Windows Quake opacity from 85% to 95% while keeping 95% width and 85% height.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: Static tests updated to require `QuakeOpacity := 0.95`; AutoHotkey syntax and targeted tests should be rerun.
- Known gaps: Live Windows GUI retest is required to confirm the new opacity. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Restart AutoHotkey/WezTerm, retest first launch, height, opacity, and toggle persistence.

### 2026-07-05

- Summary of changes: Updated the WezTerm baseline color palette to match the default Windows Terminal scheme instead of Solarized Dark.
- Phases touched: Phase 2 appearance, Phase 3 Quake inherits the WezTerm palette.
- Validation performed: Inspected local Windows Terminal settings; the default profile inherits the built-in default scheme and does not define a custom scheme. Static WezTerm tests were updated to require the matching foreground/background and representative ANSI colors.
- Known gaps: Live GUI retest is required to confirm readability in WezTerm and Quake mode. macOS and Ubuntu remain unvalidated.
- Next actions: Apply the updated WezTerm config through setup or chezmoi, restart WezTerm/Quake, and confirm the colors match Windows Terminal closely enough.

### 2026-07-05

- Summary of changes: Updated the Quake doctor check to match the current validated Windows dismiss behavior. The doctor now checks for `WinMinimize` instead of the abandoned `WinHide` path.
- Phases touched: Phase 3 doctor/tests.
- Validation performed: Setup initially applied the updated WezTerm palette but failed `doctor --phase quake` because the doctor still required `WinHide`. The doctor and static Quake tests were updated to match the current adapter. AutoHotkey syntax validation passed, `tests/quake_test.bash` passed, `tests/wezterm_test.bash` passed, `doctor --phase quake` passed, and `setup.ps1 -Phase quake` completed successfully.
- Known gaps: Live GUI retest is still needed for the Windows Terminal palette in WezTerm/Quake.
- Next actions: Restart WezTerm/Quake and confirm the colors match Windows Terminal closely enough.

### 2026-07-05

- Summary of changes: Updated Windows Quake height from 85% to 100% of the focused monitor work area. Width remains 95%; opacity remains 95%.
- Phases touched: Phase 3, Windows Quake adapter, docs, tests.
- Validation performed: Static tests updated to require `QuakeHeightRatio := 1.00`; AutoHotkey syntax and targeted tests should be rerun.
- Known gaps: Live Windows GUI retest is required to confirm full-height placement. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Restart AutoHotkey/WezTerm, retest first launch, full-height sizing, opacity, and toggle persistence.

### 2026-07-05

- Summary of changes: Added Windows startup registration for the Quake hotkey adapter.
- Phases touched: Phase 3 Windows setup/reset/doctor/docs/tests.
- Validation performed: Implementation adds a per-user Startup folder shortcut named `cross-platform-workstation-quake.lnk`, setup registration, reset cleanup, doctor verification, and static tests. `setup.ps1 -Phase quake -DryRun` showed the planned shortcut. `setup.ps1 -Phase quake` created it successfully. PowerShell inspection verified the shortcut target, arguments, working directory, and minimized window style. `doctor --phase quake` verified the shortcut. `reset-windows.ps1 -Phase quake` dry-run showed it would remove or back up the shortcut.
- Known gaps: Reboot validation is required to confirm `Ctrl+`` works after login without manually starting the adapter. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Reboot and confirm the hotkey is active automatically, then run final validation and commit/push Phase 3 if accepted.

### 2026-07-05

- Summary of changes: Recorded user validation of Windows Quake startup registration setup and reset cleanup.
- Phases touched: Phase 3 Windows startup registration.
- Validation performed: User ran `setup.ps1 -Phase quake`; setup created the per-user startup shortcut and passed WezTerm/Quake doctor checks. User ran `doctor --phase quake` separately and it passed with the expected manual-validation warnings. User ran `reset-windows.ps1 -Phase quake` dry-run and it showed the startup shortcut would be removed or backed up.
- Known gaps: Reboot validation is still required to confirm the hotkey starts automatically after login. Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Reboot Windows, confirm `Ctrl+`` works without manually running `start-quake.ps1`, then update this tracker and commit/push Phase 3 if accepted.

### 2026-07-06

- Summary of changes: Recorded successful Windows reboot validation for Quake startup registration and final Phase 3 validation.
- Phases touched: Phase 3 Windows startup registration, doctor, tests, tracking.
- Validation performed: User rebooted Windows and confirmed `Ctrl+`` works as intended without manually running `platform/windows/start-quake.ps1`. User then reran `setup.ps1 -Phase quake`; setup recreated/verified the startup shortcut and passed WezTerm plus Quake doctor checks. Final validation passed with `doctor --phase quake`, `tests/run.bash`, and `git diff --check`.
- Known gaps: Multi-monitor focused placement remains unvalidated. macOS/Ubuntu remain deferred.
- Next actions: Commit/push Phase 3 if accepted, then begin Phase 4 Neovim baseline.
