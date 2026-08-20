# Shell Workflow

Phase 1 creates a Bash-first workflow across Windows, macOS, and Ubuntu.

## Windows

Use the MSYS2 **UCRT64** Bash environment. Do not use WSL. Git for Windows may remain installed only to clone the repository.

Windows-native tools may still require Windows paths. Use:

```bash
winpath "$PWD"
unixpath 'C:\work\cross-platform-workstation'
```

Both helpers preserve spaces by accepting one path argument and quoting it internally.

Install the shared CLI tools inside MSYS2 with `pacman`: `git`, `jq`, `unzip`, `mingw-w64-ucrt-x86_64-ripgrep`, `mingw-w64-ucrt-x86_64-fd`, and `mingw-w64-ucrt-x86_64-fzf`. The Windows setup path verifies these packages rather than relying on the old Git Bash PATH.

## macOS

Use Bash. Homebrew Bash is preferred when already installed, but setup must not silently install Homebrew. The managed shell puts the active Homebrew `bin` and `sbin` directories before system paths so Homebrew-provided Git, Bash, and CLI tools take precedence.

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
- `y`

`y` opens Yazi as the terminal file manager and changes the shell directory on exit when Yazi writes a valid selected directory through `--cwd-file`.

Stubbed for future phases:

- `project`
- `rider`
- `wt-create`
- `wt-list`
- `wt-remove`
- `wt-open`
- `agent`
- `agent-notify`

Stubbed helpers return exit code 64 and explain which future phase owns them.
