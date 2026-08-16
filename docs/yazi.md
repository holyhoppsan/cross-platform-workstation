# Yazi

Phase 5 adds Yazi as the terminal file manager.

Yazi is not an AI agent. Do not add it to agent adapters, model profiles, or AI launcher configuration.

## Scope

The baseline provides:

- managed config in `chezmoi/dot_config/yazi/`
- `y` shell helper
- directory-changing-on-exit through Yazi `--cwd-file`
- WezTerm integration
- setup, reset, doctor, and tests

## Setup

Windows:

```powershell
./setup.ps1 -Phase yazi
```

macOS / Ubuntu:

```bash
./setup.sh --phase yazi
```

Windows setup installs or verifies the winget package `sxyazi.yazi`.

## Shell Helper

Use:

```bash
y
y path/to/dir
```

When Yazi exits, the helper changes the shell to the directory selected in Yazi if Yazi writes a valid `--cwd-file` path.

If Yazi is missing, the helper returns exit code `127` with a clear message.

## WezTerm Bindings

The Phase 5 bindings are:

| Binding | Action |
| ------- | ------ |
| `Ctrl+A`, `e` | Open Yazi in a new pane |
| `Ctrl+A`, `E` | Open Yazi in the current pane |

The new-pane binding runs through interactive Bash so the `y` shell function is available.

## Doctor

Run:

```bash
doctor --phase yazi
```

The doctor checks:

- Yazi command availability and version
- `yazi.toml`, `keymap.toml`, and `theme.toml`
- `y` helper availability
- WezTerm Yazi keybindings
- optional preview tools such as `ffmpeg`, `7z`/`7zz`, and ImageMagick `magick`

Missing optional preview tools warn but do not fail the phase.

## Reset

Windows reset dry-run:

```powershell
./scripts/setup/reset-windows.ps1 -Phase yazi
./scripts/setup/reset-windows.ps1 -Phase yazi -RemovePackages
```

Apply reset:

```powershell
./scripts/setup/reset-windows.ps1 -Phase yazi -Apply -RemovePackages
```

Git is never removed. Package removal is limited to setup-managed packages for the selected phase and its prerequisites.

## Validation Status

Windows must be validated with setup, reset/reinstall, doctor, and manual WezTerm key checks before Phase 5 is marked complete on Windows.

macOS and Ubuntu behavior must remain marked unvalidated until tested on those platforms.
