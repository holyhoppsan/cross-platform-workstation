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

* Git for Windows
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
| 2     | WezTerm baseline with tmux-style bindings | Not started                               |
| 3     | Quake-mode dropdown                       | Stubbed                                   |
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
* 2026-07-05: User clarified the acceptance bar: on clean Windows, `setup.ps1 -Phase shell` must install or verify Git for Windows, Git Bash, chezmoi, and Phase 1 CLI tools; apply chezmoi; and run automated validation without requiring manual helper checks.
* 2026-07-05: `setup.ps1` now defaults to `shell`, installs/verifies Windows Phase 1 tools through `winget`, applies chezmoi, and validates the configured interactive Git Bash shell. `setup.sh` also applies chezmoi and validates the interactive shell when Bash already exists.
* 2026-07-05: `setup.ps1 -Phase shell` passed on this Windows machine. It installed/verified Git Bash, chezmoi, ripgrep, fd, jq, and fzf; applied chezmoi; ran repository tests through Git Bash; and validated the configured interactive Git Bash shell.
* 2026-07-05: `scripts/setup/verify.ps1 -Phase shell` passed in a separate PowerShell process after setup.
* 2026-07-05: after Windows provisioning, `fd`, `jq`, and `fzf` are available in configured Git Bash. `fdfind` remains an optional warning on Windows because the command is named `fd`.
* 2026-07-05: ShellCheck was not available in the validation environment.
* Automated interactive Git Bash validation passed. A user-opened fresh terminal window is still a useful smoke test but is no longer required to call the Windows path validated.

Deferred items:

* Full project, worktree, agent, Rider, Yazi, and Neovim helper behavior remains deferred to later phases.

## Phase 2: WezTerm Baseline with Tmux-Style Bindings

Status: Not started

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
* [ ] Add base wezterm.lua.
* [ ] Add platform-aware shell startup.
* [ ] Configure Git Bash startup on Windows.
* [ ] Configure Bash startup on macOS/Ubuntu.
* [ ] Add tmux-style leader key.
* [ ] Add split bindings.
* [ ] Add pane movement bindings.
* [ ] Add pane resize bindings.
* [ ] Add zoom binding.
* [ ] Add tab bindings.
* [ ] Add copy-mode binding.
* [ ] Add workspace picker.
* [ ] Add placeholder Quake workspace identity.
* [ ] Add docs/wezterm.md.
* [ ] Add doctor checks for WezTerm.

Validation:

* [ ] WezTerm starts successfully.
* [ ] It launches the correct shell.
* [ ] On Windows, WezTerm launches Git Bash.
* [ ] On macOS and Ubuntu, WezTerm launches Bash.
* [ ] Ctrl+A bindings work.
* [ ] Pane splits and navigation work.
* [ ] Tabs work.
* [ ] `doctor --phase wezterm` reports status.

Notes:

* WezTerm is intentionally not implemented in the Phase 0/1 deliverable.
* `chezmoi/dot_config/wezterm/wezterm.lua` is an explicit non-functional placeholder that fails if loaded.

Deferred items:

* Rich agent status and attention traversal remain deferred.

## Phase 3: Quake-Mode Dropdown

Status: Stubbed

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
4. Use approximately 95% of the monitor width and 55% of its height.
5. Focus the terminal immediately.
6. Preserve all tabs, panes, shells, running commands, editors, file managers, and agents while hidden.

On second activation, when the dropdown is focused:

1. Hide the dropdown window.
2. Do not terminate any processes.

Platform-specific adapters:

* Windows: AutoHotkey v2
* macOS: Hammerspoon
* Ubuntu GNOME on Wayland: a GNOME Shell extension or another GNOME-native mechanism

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
* Height: approximately 55% of focused monitor
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

* [ ] Implement Windows AutoHotkey adapter.
* [ ] Implement macOS Hammerspoon adapter.
* [ ] Implement Ubuntu GNOME adapter or documented stub.
* [ ] Add setup support for adapters.
* [x] Add Quake docs.
* [x] Add doctor checks.
* [ ] Add manual validation checklist.

Validation:

* [ ] Ctrl+` toggles the dropdown.
* [ ] It appears on the focused monitor.
* [ ] It hides without killing the shell.
* [ ] It preserves running commands.
* [ ] It works after switching monitor focus.
* [ ] Behavior is documented separately for Windows, macOS, and Ubuntu.
* [ ] Untested platform-specific behavior is clearly marked.

Notes:

* Existing platform adapter files are stubs and must not be described as functional.

Deferred items:

* Full native adapter implementation and manual validation on all supported platforms.

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

1. Optionally open a fresh Git Bash window manually and run `doctor --phase shell` as a user smoke test.
2. Validate Phase 1 on macOS Bash and update the Phase 1 validation checklist.
3. Validate Phase 1 on Ubuntu GNOME Bash and update the Phase 1 validation checklist.
4. Decide whether Phase 2 should replace the current WezTerm placeholder with the first real `wezterm.lua`.
5. Begin Phase 2 once the Windows validation result is accepted and macOS/Ubuntu are either validated or explicitly deferred.
6. Keep `PLAN.md` updated after each implementation or validation session.

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

- Summary of changes: Revised the Phase 1 Windows setup model so `setup.ps1 -Phase shell` is the clean-machine bootstrap path. It now installs/verifies Git for Windows, Git Bash, chezmoi, ripgrep, fd, jq, and fzf through `winget`; applies chezmoi; runs repository tests through Git Bash; and validates a configured interactive Git Bash shell. `setup.sh` also applies chezmoi and validates the configured shell when Bash already exists.
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
