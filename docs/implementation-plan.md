# Implementation Plan Narrative

The actionable tracker is [PLAN.md](../PLAN.md). It is the source of truth for requirements, checklists, validation, and next actions. This document explains the intended sequence and the boundaries between phases.

## Phase Strategy

The repository is implemented in independently testable slices. A phase may add configuration, automation, documentation, and tests, but it must not claim platform validation until it has been tested on the relevant operating system.

- Phase 0 establishes repository structure, setup entrypoints, documentation, and doctor/test infrastructure.
- Phase 1 establishes the shared Bash workflow. Windows uses MSYS2 UCRT64 Bash; macOS and Ubuntu use native Bash.
- Phase 2 establishes WezTerm as the terminal, pane, tab, and workspace layer.
- Phase 3 adds the Windows Quake-mode adapter; macOS and Ubuntu adapters remain separate platform work.
- Phase 4 adds the restrained, plugin-free Neovim baseline.
- Phase 5 adds Yazi as a terminal file manager only.
- Phase 5.5 adds the Windows MSYS2 SSH/Mosh and ShadowTerm LAN path.
- Phase 6 prepares and validates the existing workstation stack on the MacBook Pro using an agent-led runbook plus user GUI checks.
- Phase 7 evaluates `just` after the user supplies representative workflow examples.
- Phase 8 adds optional, per-machine Vowen desktop dictation with explicit installer and hotkey validation.
- Phase 9 is optional Tailscale transport for off-LAN ShadowTerm/Mosh access.
- Phases 10 through 15 add Rider/Unreal launching, project/worktree workflow, agent adapters, notifications, optional model tooling, and hardening.

## Current State

Windows and Apple Silicon macOS have completed the documented core-workflow validation. Ubuntu remains unvalidated. The active Windows interactive shell is MSYS2 UCRT64 Bash, and Git for Windows may remain available only for clone/bootstrap compatibility.

Implemented and validated on Windows:

- repository foundation and phase-aware setup/doctor framework;
- shared shell configuration and common CLI tools under MSYS2 UCRT64;
- WezTerm baseline, including UCRT64 startup and core pane/tab bindings;
- Windows Quake-mode adapter, subject to its remaining multi-monitor check;
- Neovim baseline;
- Yazi configuration and the `y` shell workflow;
- key-only MSYS2 SSH, LAN-scoped Mosh, ShadowTerm access, reboot persistence, and temporary LAN interruption recovery.

Not yet validated or implemented:

- Ubuntu behavior;
- macOS Quake multi-monitor placement;
- Vowen desktop-dictation installation and hotkey behavior;
- Tailscale/off-LAN Mosh reachability;
- Rider launcher automation, project/worktree commands, agent launcher/status, model endpoint tooling, and polish/hardening.

## macOS Agent Validation Model

Phase 6 makes the MacBook Pro test repeatable and safe. The agent can perform repository checkout, prerequisite inspection, dry runs, setup, doctor, and non-GUI test commands. It must stop rather than silently install Homebrew, alter security settings, or claim GUI behavior.

The user performs the final interactive validation: WezTerm launch, clipboard behavior, pane bindings, Neovim, Yazi, and any platform-specific desktop integration. Results are then recorded in `PLAN.md`.

## `just` Boundary

`just` is a future convenience layer, not a replacement for `setup.sh`, `setup.ps1`, or `scripts/doctor`. No recipes should be designed until the user provides real examples of their desired workflow. Recipes must not contain secrets, machine-specific paths, or unsafe destructive defaults.

## Why Placeholders Remain

The repository shape includes future components early so each later phase has a clear home. A placeholder or example file is not working behavior and must be labeled accordingly. This keeps the plan honest while avoiding needless structural churn.
