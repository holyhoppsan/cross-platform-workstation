# Neovim

Phase 4 adds a restrained Neovim baseline.

The config is intentionally plugin-free for now. It provides stable editor defaults, Space as the leader key, netrw-based file navigation, filetype handling, and an LSP-ready Lua structure without committing to a plugin manager.

## Setup

Windows, from PowerShell:

```powershell
./setup.ps1 -Phase neovim
```

macOS / Ubuntu, from Bash:

```bash
./setup.sh --phase neovim
```

On Windows, setup verifies Git/Git Bash, Phase 1 tools, WezTerm, and Neovim. If Neovim is missing, setup installs it with `winget` package `Neovim.Neovim`.

## Shell Helpers

`nv` opens Neovim in the current directory when no argument is provided, or opens the provided files/directories.

```bash
nv
nv README.md
nv docs/neovim.md
```

`nvc` runs a headless Neovim config-load check.

```bash
nvc
```

`edit` currently delegates to `nv`.

## Key Choices

- Space is the Neovim leader.
- WezTerm keeps `Ctrl+A` as the terminal leader.
- Neovim keeps normal `Ctrl+W` window behavior available.
- No AI/editor integration is added in Phase 4.
- No terminal-pane navigation hacks are added in Phase 4.

## Baseline Keymaps

- `<leader>e`: open netrw file explorer
- `<leader>w`: write file
- `<leader>q`: quit current window
- `<leader>Q`: quit all windows
- `<leader>h`: run `:checkhealth`
- `<leader>sv`: vertical split
- `<leader>sh`: horizontal split
- `Ctrl+h/j/k/l`: move between Neovim windows

## Filetype Coverage

The baseline includes defaults for shell, Lua, Markdown, TOML, JSON, YAML, C, C++, C#, Python, JavaScript, TypeScript, and Unreal-adjacent files such as `.uproject`, `.uplugin`, `.Build.cs`, `.Target.cs`, `.ush`, and `.usf`.

## Validation

```bash
doctor --phase neovim
nvc
nv
```

Windows GUI validation should also confirm:

1. WezTerm opens Git Bash.
2. `Ctrl+A`, `v` opens Neovim in the current pane.
3. `Ctrl+A`, `V` opens Neovim in a new pane.
4. Space leader mappings work inside Neovim.
5. `Ctrl+A` remains the WezTerm leader and does not conflict with Neovim's Space leader.

macOS and Ubuntu behavior must remain marked unvalidated until tested on those platforms.
