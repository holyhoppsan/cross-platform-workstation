# WezTerm

Phase 2 configures WezTerm as the terminal, pane, tab, and workspace layer.

## Scope

Implemented in Phase 2:

- platform-aware Bash startup
- Git Bash startup on Windows
- Bash startup on macOS and Ubuntu
- `Ctrl+A` terminal leader
- tmux-style pane, tab, copy-mode, and workspace bindings
- dedicated `quake` workspace identity placeholder
- basic right-status workspace and agent-state display

Deferred:

- OS-level `Ctrl+`` Quake dropdown behavior
- real Yazi and Neovim setup
- rich agent status integration
- tmux integration

## Shell Startup

Windows uses Git for Windows Bash. Setup does not install Git.

WezTerm checks these Windows shell paths in order:

- `%ProgramFiles%/Git/bin/bash.exe`
- `%ProgramFiles%/Git/usr/bin/bash.exe`
- `%LOCALAPPDATA%/Programs/Git/bin/bash.exe`

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
- Space is reserved for the future Neovim leader.
- `Ctrl+W` is reserved for future Neovim window actions.

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
| `Ctrl+A`, `r` | Rename workspace |
| `Ctrl+A`, `1..9` | Select tab |
| `Ctrl+A`, `[` | Copy mode |
| `Ctrl+A`, `a` | Send literal `Ctrl+A` |
| `Ctrl+A`, `q` | Switch to `quake` workspace |
| `Ctrl+A`, `e/E` | Call the Yazi helper stub |
| `Ctrl+A`, `v/V` | Call the Neovim helper stub |
| `Ctrl+A`, `u` | Move to agent pane needing attention, if title metadata is present |

The Yazi and Neovim helpers are intentionally stubs until Phases 4 and 5.

## Clipboard

Explicit clipboard bindings are configured because Windows users expect predictable copy/paste behavior:

| Binding | Action |
| --- | --- |
| `Ctrl+Shift+C` | Copy selection to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+Insert` | Copy selection to clipboard |
| `Shift+Insert` | Paste from clipboard |
| Right click | Paste from clipboard |

WezTerm does not provide a Windows-style context menu in this baseline. Right click is intentionally assigned to paste.

## Validation

PowerShell:

```powershell
./setup.ps1 -Phase wezterm -DryRun
./setup.ps1 -Phase wezterm
```

Git Bash:

```bash
doctor --phase wezterm
```

Manual Windows checks:

1. Open WezTerm.
2. Confirm it starts Git Bash.
3. Press `Ctrl+|` to split horizontally. On a US Windows keyboard this usually means holding `Ctrl+Shift+\`.
4. Press `Ctrl+-` to split vertically. `Ctrl+_` is also bound as a fallback if Shift is held.
5. Press `Ctrl+A`, then `h/j/k/l` to move between panes.
6. Press `Ctrl+A`, then `c` to create a tab.
7. Press `Ctrl+A`, then `1` to return to the first tab.
8. Press `Ctrl+A`, then `[` to enter copy mode.

macOS and Ubuntu behavior must remain marked unvalidated until tested there.
