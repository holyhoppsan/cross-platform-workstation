# Implementation plan

## Phase 1: portable vertical slice

- Establish repository structure and durable constraints.
- Deploy shared Bash and WezTerm configuration with chezmoi.
- Implement testable platform and Git Bash detection.
- Define explicit Quake adapter contracts as non-functional stubs.
- Add a cross-platform doctor command with required versus optional checks.
- Add portable tests and installation documentation.

Exit criteria: Bash modules parse, detection tests pass, WezTerm configuration contains the required base bindings, doctor runs without leaking values, and untested adapters are clearly labeled.

## Phase 2: native dropdown adapters and bootstrap

- Implement AutoHotkey v2 foreground-monitor placement and startup registration.
- Implement Hammerspoon placement, Accessibility checks, and safe config loading.
- Implement a GNOME Shell extension against explicitly supported Shell versions.
- Add idempotent package-manager bootstrap scripts.
- Validate the full hotkey state machine manually on each target OS.

Exit criteria: recorded manual results cover focus, multiple monitors, persistence, Windows virtual desktops, macOS Spaces, and GNOME Wayland. Unknown GNOME versions fail with guidance.

## Phase 3: agent state and launchers

- Define atomic cache-state schema and implement `agent-notify`.
- Implement capability-aware adapters for all four agents using current official CLI documentation.
- Add model-profile parsing without credentials.
- Add WezTerm status and `Ctrl+A u` attention traversal.
- Document provider boundaries and credential-store setup.

Exit criteria: each installed agent can launch independently; unsupported profile/tool combinations fail clearly; state transitions and argument parsing are tested.

## Phase 4: worktrees and project workspaces

- Implement `wt-create`, `wt-list`, `wt-remove`, and `wt-open` with path-safe Git calls.
- Implement `agent-worktree` so write-capable agents never default to one directory.
- Create CONTROL, IMPLEMENT, TEST, REVIEW, LOGS, and conditional UNREAL tabs.
- Add destructive-operation guards and temporary-repository integration tests.

Exit criteria: parallel agents receive distinct worktrees and removal rejects dirty/unmerged work without an explicit override.

## Phase 5: Unreal and production hardening

- Add local Unreal/Visual Studio configuration schema.
- Implement `.uproject` discovery, Explorer opening, editor launch, native builds, and logs.
- Test quoting with spaces and Git Bash to PowerShell/cmd boundaries.
- Pin external sources where possible and complete troubleshooting/runbooks.

Exit criteria: manual Windows test builds a sample native Unreal project from Git Bash without path conversion errors; diagnostics remain secret-safe.

## Manual validation matrix

- `Ctrl+`` from a non-terminal application creates, focuses, hides, and restores one persistent dropdown.
- Active tabs, panes, processes, and agents survive at least ten hide/show cycles.
- Dropdown follows the focused application across monitors with different scale factors.
- Windows: repeat across virtual desktops and verify startup registration.
- macOS: repeat across Spaces/full-screen contexts and verify Accessibility permissions.
- Ubuntu: test Wayland, record GNOME Shell version, then test X11 if supported.
- Unreal: invoke a native build and Editor path containing spaces from Git Bash.

