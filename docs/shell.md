# Shell Workflow

Phase 1 creates a Bash-first workflow across Windows, macOS, and Ubuntu.

## Windows

Use Git for Windows Bash. Do not use WSL for this repository.

Windows-native tools may still require Windows paths. Use:

```bash
winpath "$PWD"
unixpath 'C:\work\cross-platform-workstation'
```

Both helpers preserve spaces by accepting one path argument and quoting it internally.

## macOS

Use Bash. Homebrew Bash is preferred when already installed, but setup must not silently install Homebrew.

## Ubuntu

Use system Bash. Ubuntu GNOME Wayland is the default platform assumption for future Quake work, but Phase 1 only detects session facts.

## Common Commands

The common workflow expects these Unix-style commands:

```text
ls cd pwd cat grep git curl tar unzip mkdir rm cp mv
```

These tools are useful and reported when available:

```text
rg fd fdfind jq fzf
```

## Helpers

Implemented:

- `platform-info`
- `workstation-root`
- `doctor`
- `winpath`
- `unixpath`
- `mkcd`
- `croot`
- `gfind`
- `fdx`
- `nv`
- `nvc`
- `edit`

Stubbed for future phases:

- `project`
- `y`
- `rider`
- `wt-create`
- `wt-list`
- `wt-remove`
- `wt-open`
- `agent`
- `agent-notify`

Stubbed helpers return exit code 64 and explain which future phase owns them.
