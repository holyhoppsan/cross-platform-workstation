# WezTerm

Phase 2 configures WezTerm as the terminal, pane, tab, and workspace layer.

## Scope

Implemented in Phase 2:

- platform-aware Bash startup
- MSYS2 UCRT64 Bash startup on Windows
- Bash startup on macOS and Ubuntu
- `Ctrl+A` terminal leader
- tmux-style pane, tab, copy-mode, and workspace bindings
- dedicated `quake` workspace identity placeholder
- basic right-status workspace and agent-state display

Deferred:

- rich agent status integration
- tmux integration

## Shell Startup

Windows uses MSYS2 UCRT64 Bash at `C:/msys64/usr/bin/bash.exe`. WezTerm sets `MSYSTEM=UCRT64` for Windows panes. Git for Windows may remain installed for cloning, but is not used for WezTerm startup.

macOS prefers Homebrew Bash when present:

- `/opt/homebrew/bin/bash`
- `/usr/local/bin/bash`
- `/bin/bash`

Ubuntu uses `/bin/bash --login`.

## Appearance

WezTerm uses an explicit palette matching the default Windows Terminal scheme inherited by the default Windows PowerShell profile on the validated Windows machine. The local Windows Terminal settings do not define a custom color scheme, so the repository records the equivalent default palette directly instead of referencing a machine-local Windows Terminal setting.

## Key Hierarchy

- `Ctrl+`` is reserved for the OS-level Quake adapter in Phase 3.
- `Ctrl+A` is the WezTerm leader for panes, tabs, and workspaces.
- Space is the Neovim leader.
- `Ctrl+W` remains available for Neovim window actions.

## Bindings

| Binding | Action |
| --- | --- |
| `Ctrl+|` | Split pane left/right |
| `Ctrl+-` | Split pane top/bottom |
| `Ctrl+_` | Split pane top/bottom fallback when Shift is held |
| `Ctrl+A`, `|` | Split pane left/right |
| `Ctrl+A`, `Shift+\` | Split pane left/right fallback for Windows keyboards |
| `Ctrl+A`, `-` | Split pane top/bottom |
| `Ctrl+A`, `_` | Split pane top/bottom fallback when Shift is held |
| `Ctrl+A`, `h/j/k/l` | Move between panes |
| `Ctrl+A`, `H/J/K/L` | Resize panes |
| `Ctrl+A`, `c` | Create tab |
| `Ctrl+A`, `x` | Close pane with confirmation |
| `Ctrl+A`, `z` | Toggle pane zoom |
| `Ctrl+A`, `w` | Workspace launcher |
| `Ctrl+A`, `p` | Create or switch to a workspace for a project directory |
| `Ctrl+A`, `r` | Rename workspace |
| `Ctrl+A`, `1..9` | Select tab |
| `Ctrl+A`, `[` | Copy mode |
| `Ctrl+A`, `a` | Send literal `Ctrl+A` |
| `Ctrl+A`, `q` | Switch to `quake` workspace |
| `Ctrl+A`, `e` | Open Yazi in a new pane through the `y` helper |
| `Ctrl+A`, `E` | Open Yazi in the current pane through the `y` helper |
| `Ctrl+A`, `v/V` | Open Neovim through the `nv` helper |
| `Ctrl+A`, `u` | Move to agent pane needing attention, if title metadata is present |

Yazi is a terminal file manager only. It is not part of the AI agent launcher.

## Clipboard

Explicit clipboard bindings are configured for predictable copy/paste behavior. In particular, `Ctrl+V` is terminal-handled so text-paste tools such as dictation applications work in terminal TUIs that otherwise interpret a raw `Ctrl+V` as a special command.

| Binding | Action |
| --- | --- |
| `Ctrl+Shift+C` | Copy selection to clipboard |
| `Ctrl+V` | Paste text from the system clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+Insert` | Copy selection to clipboard |
| `Shift+Insert` | Paste from clipboard |
| Right click | Paste from clipboard |

WezTerm does not provide a Windows-style context menu in this baseline. Right click is intentionally assigned to paste.

This is configured on Windows, macOS, and Ubuntu. It solves a Codex CLI input-path issue rather than a Git Bash issue; native platform behavior still needs manual validation on macOS and Ubuntu.

## Validation

PowerShell:

```powershell
./setup.ps1 -Phase wezterm -DryRun
./setup.ps1 -Phase wezterm
```

MSYS2 UCRT64 Bash:

```bash
doctor --phase wezterm
```

Manual Windows checks:

1. Open WezTerm.
2. Confirm it starts MSYS2 UCRT64 Bash (`echo "$MSYSTEM"` prints `UCRT64`).
3. Press `Ctrl+|` to split horizontally. On a US Windows keyboard this usually means holding `Ctrl+Shift+\`.
4. Press `Ctrl+-` to split vertically. `Ctrl+_` is also bound as a fallback if Shift is held.
5. Press `Ctrl+A`, then `h/j/k/l` to move between panes.
6. Press `Ctrl+A`, then `c` to create a tab.
7. Press `Ctrl+A`, then `1` to return to the first tab.
8. Press `Ctrl+A`, then `[` to enter copy mode.

macOS and Ubuntu behavior must remain marked unvalidated until tested there.
