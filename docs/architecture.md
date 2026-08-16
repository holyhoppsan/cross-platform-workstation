# Architecture

## Goals and Invariants

This repository builds a workstation in explicit phases. Phase 0 establishes the repository foundation. Phase 1 establishes a common Bash workflow. Phase 2 establishes WezTerm as the terminal layer. Phase 3 adds the Windows Quake-mode adapter. Phase 4 adds the Neovim baseline. Phase 5 adds the Yazi terminal file manager. Later phases add the IDE, worktree, AI agent, notification, model, and hardening behavior.

Windows remains native. MSYS2 UCRT64 Bash is the intended Unix-style interactive workflow; Git for Windows may remain only as a temporary clone/bootstrap dependency while that migration is validated. Windows-native tools keep using Windows-native paths when required. WSL paths and WSL dependencies are outside the design.

Shared behavior belongs in `chezmoi/`. Operating-system automation belongs in `platform/`. Optional tools and future integrations may have placeholders, but they must not become required before their phase is implemented.

## Component Boundaries

### PLAN.md

`PLAN.md` is the operational source of truth. It records phases, requirements, status, validation, risks, deferred work, and next actions. Future Codex sessions must read it before changing code.

### Setup Entrypoints

`setup`, `setup.sh`, and `setup.ps1` are thin entrypoints. They parse a phase and dry-run flag, detect the host platform, call modular helpers under `scripts/setup/`, and then run the doctor for the selected phase.

The setup layer is intentionally conservative in Phase 0/1. It verifies and reports; it does not silently install package managers, does not install WSL, and does not overwrite user configuration.

### Shared Bash

`chezmoi/dot_bashrc` and `chezmoi/dot_bash_profile` load modules from `~/.config/workstation/` after chezmoi applies them:

- `platform.sh`: platform, shell, and MSYS2 UCRT64 detection
- `shell.sh`: safe interactive defaults, aliases, PATH handling, tool availability checks
- `functions.sh`: helpers and future-phase stubs

Shell helpers must quote variables and preserve paths containing spaces.

### Doctor

`scripts/doctor` runs the same doctor implementation that chezmoi can expose as `workstation-doctor`. The doctor is phase-aware. For Phase 0 and Phase 1 it checks only required foundation and shell behavior. Later phases are reported as not implemented rather than pretending validation exists.

### Platform Placeholders

`platform/windows`, `platform/macos`, and `platform/ubuntu` hold OS-specific bootstrap and future Quake adapter placeholders. Platform UI behavior is unvalidated until tested on the actual platform.

### WezTerm

`chezmoi/dot_config/wezterm/wezterm.lua` configures WezTerm for Phase 2. It launches MSYS2 UCRT64 Bash on Windows and Bash on macOS/Ubuntu, uses `Ctrl+A` as a tmux-style terminal leader, and keeps OS-level Quake behavior deferred.

### Neovim

`chezmoi/dot_config/nvim/` configures Neovim for Phase 4. It is deliberately plugin-free, uses Space as leader, keeps `Ctrl+W` available for Neovim windows, and exposes `nv`, `nvc`, and `edit` through shared shell helpers.

### Yazi

`chezmoi/dot_config/yazi/` configures Yazi for Phase 5. Yazi is only a terminal file manager. It is exposed through the `y` shell helper and WezTerm file-manager bindings, and it must not be added to AI agent adapters or model tooling.

### Windows MSYS2 SSH and Mosh

Phase 5.5 uses MSYS2's own `msys2_sshd` service, not native Windows OpenSSH or WSL. `platform/windows/setup-msys2-mosh.ps1` runs an adapted version of MSYS2's published service recipe, installs a supplied public key for the selected Windows account, and can separately create `LocalSubnet`/Private-profile firewall rules for SSH TCP 22 and Mosh UDP 60001. The initial reachability scope is LAN only. ShadowTerm performs the SSH bootstrap and launches `mosh-server`; Herdr, rather than tmux, owns session persistence.

### Future Phases

Rider, worktree commands, AI agents, notifications, and model tooling are future phases. macOS and Ubuntu Quake adapters also remain future platform work. Placeholder directories may exist so the repository shape is stable, but functional implementations must wait for their phase.

## Verification Policy

Portable tests can validate parsing, platform detection, path conversion, setup argument parsing, config shape, and doctor behavior. They do not validate GUI hotkeys, focused-monitor placement, macOS Spaces, Ubuntu Wayland, Windows virtual desktops, or tool-specific integrations.

Never mark platform-specific behavior as validated unless it was actually tested on that platform.
