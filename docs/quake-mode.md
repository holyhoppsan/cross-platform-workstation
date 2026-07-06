# Quake Mode

Phase 3 adds platform-specific global dropdown behavior for WezTerm.

## Contract

The native adapter owns global `Ctrl+``. It targets a persistent WezTerm window attached to workspace `quake`, moves it to the focused application's monitor work area, sizes it to roughly 95% width and 100% height, applies 95% window opacity, and focuses it. If that dropdown is already focused, the adapter hides it from the user's view without terminating the GUI process.

## Windows

Windows uses AutoHotkey v2:

```text
platform/windows/quake-toggle.ahk
```

Setup verifies or installs AutoHotkey v2 through `winget` package `AutoHotkey.AutoHotkey`, verifies WezTerm, registers a per-user Startup shortcut for the hotkey adapter, and runs `doctor --phase quake`.

Run the adapter manually from the repository root:

```powershell
.\platform\windows\start-quake.ps1
```

The launcher resolves the AutoHotkey v2 executable and passes the adapter path safely, avoiding command-line quoting issues with long paths.

`setup.ps1 -Phase quake` also creates this per-user Startup shortcut:

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\cross-platform-workstation-quake.lnk
```

That shortcut runs `platform/windows/start-quake.ps1` at login so `Ctrl+`` is available after restart. `scripts/setup/reset-windows.ps1 -Phase quake -Apply` removes or backs up the shortcut.

The adapter launches `wezterm-gui.exe` first and keeps `wezterm.exe` only as a fallback. It starts WezTerm with `--class wezterm-quake` and uses that window class as the dropdown identity instead of tracking the launch process ID. If the dropdown appears as a black, non-interactive window while a separate normal WezTerm window opens, the adapter is probably targeting the wrong WezTerm-owned window.

On Windows, the current adapter dismisses the dropdown by minimizing the existing window instead of calling `WinHide`. This keeps the WezTerm window top-level and reliably restorable for the next global-hotkey press. Earlier `WinHide` and off-screen parking attempts preserved the process but failed to restore reliably on this Windows setup.

To reduce first-launch resize flicker, the adapter computes the target monitor geometry before starting WezTerm, passes approximate `initial_cols`/`initial_rows`, passes an initial `--position`, starts the process minimized, then restores and applies the exact pixel size.

The opacity setting is applied through the Quake launch command so normal WezTerm windows keep the baseline Phase 2 appearance.

Manual Windows validation:

1. Start `platform/windows/quake-toggle.ahk` with AutoHotkey v2.
2. Focus any non-WezTerm application.
3. Press `Ctrl+``.
4. Confirm a WezTerm window opens on the focused monitor.
5. Confirm it is near the top, about 95% monitor width and 100% monitor work-area height, with 95% opacity.
6. Run a command in the dropdown.
7. Press `Ctrl+`` again while the dropdown is focused.
8. Confirm the dropdown hides and the command/process is not terminated.
9. Focus an application on another monitor.
10. Press `Ctrl+`` and confirm the dropdown moves to that monitor.

Current Windows status: implemented and setup/doctor-checkable, but global hotkey and focused-monitor behavior need manual GUI validation.

## macOS

The Hammerspoon adapter remains deferred.

## Ubuntu GNOME

The GNOME adapter remains deferred.
