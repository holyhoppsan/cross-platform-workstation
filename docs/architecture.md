# Architecture

## Goals and Invariants

This repository builds a workstation in explicit phases. Phase 0 establishes the repository foundation. Phase 1 establishes a common Bash workflow. Phase 2 establishes WezTerm as the terminal layer. Later phases add Quake mode, editor, file manager, IDE, worktree, AI agent, notification, model, and hardening behavior.

Windows remains native. Git for Windows Bash is used for the Unix-style interactive workflow, but Windows-native tools keep using Windows-native paths when required. Git for Windows is a prerequisite for cloning the repository; setup verifies it but does not install or remove it. WSL paths and WSL dependencies are outside the design.

Shared behavior belongs in `chezmoi/`. Operating-system automation belongs in `platform/`. Optional tools and future integrations may have placeholders, but they must not become required before their phase is implemented.

## Component Boundaries

### PLAN.md

`PLAN.md` is the operational source of truth. It records phases, requirements, status, validation, risks, deferred work, and next actions. Future Codex sessions must read it before changing code.

### Setup Entrypoints

`setup`, `setup.sh`, and `setup.ps1` are thin entrypoints. They parse a phase and dry-run flag, detect the host platform, call modular helpers under `scripts/setup/`, and then run the doctor for the selected phase.

The setup layer is intentionally conservative in Phase 0/1. It verifies and reports; it does not silently install package managers, does not install WSL, and does not overwrite user configuration.

### Shared Bash

`chezmoi/dot_bashrc` and `chezmoi/dot_bash_profile` load modules from `~/.config/workstation/` after chezmoi applies them:

- `platform.sh`: platform, shell, and Git Bash detection
- `shell.sh`: safe interactive defaults, aliases, PATH handling, tool availability checks
- `functions.sh`: helpers and future-phase stubs

Shell helpers must quote variables and preserve paths containing spaces.

### Doctor

`scripts/doctor` runs the same doctor implementation that chezmoi can expose as `workstation-doctor`. The doctor is phase-aware. For Phase 0 and Phase 1 it checks only required foundation and shell behavior. Later phases are reported as not implemented rather than pretending validation exists.

### Platform Placeholders

`platform/windows`, `platform/macos`, and `platform/ubuntu` hold OS-specific bootstrap and future Quake adapter placeholders. Platform UI behavior is unvalidated until tested on the actual platform.

### WezTerm

`chezmoi/dot_config/wezterm/wezterm.lua` configures WezTerm for Phase 2. It launches Git Bash on Windows and Bash on macOS/Ubuntu, uses `Ctrl+A` as a tmux-style terminal leader, and keeps OS-level Quake behavior deferred.

### Future Phases

Quake mode, Neovim, Yazi, Rider, worktree commands, AI agents, notifications, and model tooling are future phases. Placeholder directories may exist so the repository shape is stable, but functional implementations must wait for their phase.

## Verification Policy

Portable tests can validate parsing, platform detection, path conversion, setup argument parsing, config shape, and doctor behavior. They do not validate GUI hotkeys, focused-monitor placement, macOS Spaces, Ubuntu Wayland, Windows virtual desktops, or tool-specific integrations.

Never mark platform-specific behavior as validated unless it was actually tested on that platform.
