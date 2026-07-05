# Implementation Plan Narrative

The actionable tracker is [../PLAN.md](../PLAN.md). This document explains the implementation order and rationale.

## Phase Strategy

The repository is implemented in slices. Each phase should leave the repo usable and testable without requiring later phases.

Phase 0 creates the repository foundation: docs, examples, setup entrypoints, skeleton directories, and doctor/test infrastructure.

Phase 1 creates the shared Bash workflow: Git Bash support on Windows, conservative Bash defaults, platform detection, path conversion helpers, Unix-style command checks, and stubs for future commands.

Phase 2 adds the WezTerm baseline. Phases 3 through 11 are intentionally deferred. Their requirements are recorded in `PLAN.md` so future sessions can continue without chat context.

## Current Deliverable

The current deliverable implements Phases 0 through 2.

Implemented:

- root tracker and docs
- setup entrypoints with phase parsing and dry-run support
- Windows Phase 1 bootstrap through PowerShell
- setup helper skeleton
- example config files
- Bash startup modules
- platform detection
- Git Bash detection
- Unix-style command availability checks
- phase-aware doctor
- automated Windows Git Bash validation after setup
- WezTerm baseline configuration
- WezTerm setup and doctor phase support
- initial tests

Not implemented:

- Quake adapters
- Neovim configuration
- Yazi configuration
- Rider launch helpers
- project/worktree workflow
- AI agent launcher
- agent notifications
- model endpoint detection

## Why Keep Placeholders

The final repository shape is known early, so placeholder directories reduce churn and make future phases easier to discover. Placeholders must remain clearly labeled and must not be represented as working behavior.
