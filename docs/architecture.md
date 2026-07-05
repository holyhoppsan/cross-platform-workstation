# Architecture

## Goals and invariants

This repository owns a consistent interaction model while allowing each operating system to retain its native process, path, window-management, and credential systems. WezTerm owns terminal multiplexing and named workspaces. Bash owns portable command-line behavior. chezmoi deploys user files. A small native adapter on each platform owns only the global `Ctrl+`` shortcut and dropdown placement.

Windows is not a Unix compatibility target. Git for Windows Bash is the interactive shell, but Unreal Editor, build tools, Explorer, PowerShell, and `cmd.exe` remain native Windows executables using Windows paths. WSL paths and WSL processes are outside the design.

## Component boundaries

### chezmoi source

`chezmoi/` is the deployable source of truth. `.chezmoi.toml.tmpl` records platform facts without secrets. Bash startup loads small modules from `~/.config/workstation/`. WezTerm chooses a shell from the runtime platform and provides one key map everywhere; macOS Command keys are optional OS conventions, not the primary workflow.

### WezTerm

WezTerm owns tabs, panes, workspaces, titles, and status rendering. The Quake window is identified by the dedicated `quake` workspace and a stable GUI window title. WezTerm does not register the global hotkey because terminal key handlers cannot operate while another application is focused.

The first slice renders the current workspace and reads agent state later through a stable cache contract. Project tab orchestration, agent-attention traversal, and rich state parsing are subsequent phases because they require tested WezTerm callback and CLI behavior.

### Native Quake adapters

Each adapter must implement the same state machine:

1. Find the foreground application and its monitor.
2. Find or spawn the persistent WezTerm GUI window attached to workspace `quake`.
3. If that dropdown is foreground, hide it without closing it.
4. Otherwise move it to the target monitor's work area, size it to approximately 95% by 55%, show, raise, and focus it.

The platform directories currently expose documented stubs only. This is deliberate: foreground-monitor and window APIs are version-sensitive and cannot be represented as working until validated on Windows 11, macOS, and supported GNOME Shell releases.

### Shell and platform detection

`~/.config/workstation/platform.sh` uses `uname` and Windows environment markers. It exports one normalized value: `windows`, `macos`, `ubuntu`, or `linux`. The library is side-effect-light and testable with injected uname values. Windows helpers use `cygpath`; they never rewrite arguments implicitly.

### Agents and worktrees

The target agent launcher treats OpenCode, Pi, Claude Code, and Codex as peer tools. Profiles describe intent and provider endpoints, but adapters translate only capabilities a given CLI actually supports. Secrets remain in environment variables, native agent configuration, or an OS credential store.

Every write-capable launch creates or selects a distinct Git worktree. Shared read-only control and review processes may operate from the primary checkout. Agent state is written atomically outside repositories under `${XDG_CACHE_HOME:-~/.cache}/workstation/agents/`; WezTerm consumes summaries from there.

### Configuration and trust

Checked-in TOML files are examples. Local values, API keys, engine locations, and endpoint credentials are ignored. Bootstrap and doctor scripts must redact secret values and report only presence. Installers use package managers and pinned repositories where practical; they do not pipe downloaded scripts into a shell.

## Important tradeoffs

- Native window adapters duplicate a small amount of logic, but provide reliable focused-monitor behavior that portable terminal configuration cannot.
- Bash is the common shell even though macOS ships an old Bash; scripts therefore target conservative Bash syntax. Homebrew Bash is preferred when installed.
- GNOME Shell extensions are tied to Shell API versions. The Ubuntu adapter will declare supported versions and fail visibly on unknown versions instead of guessing.
- State files are more portable than terminal-process introspection. Atomic, minimal files avoid leaking prompts or task contents.
- Project workspace creation is deferred until its process-spawn and naming behavior can be integration-tested; the base key map works without it.

## Platform boundaries

| Concern | Windows 11 | macOS | Ubuntu GNOME |
|---|---|---|---|
| Shell | Git for Windows Bash | Homebrew Bash, then system Bash | system Bash |
| Global hotkey | AutoHotkey v2 | Hammerspoon | GNOME Shell extension |
| Paths | explicit `cygpath` conversion | POSIX | POSIX |
| Package manager | winget | existing Homebrew | apt plus documented WezTerm source |
| Window API validation | Windows virtual desktops | Spaces and permissions | Wayland and Shell versions |
| Unreal | primary, native tools | helper-only future scope | helper-only future scope |

## Verification policy

Portable tests exercise detection and configuration structure. Platform UI behavior requires the manual matrices listed in the implementation plan. Passing repository tests is not evidence that a global shortcut, focused-monitor placement, virtual desktop, Spaces, or Wayland behavior has been validated.

