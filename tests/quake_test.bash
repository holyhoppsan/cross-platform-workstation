#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

adapter=$(cat "$repo_root/platform/windows/quake-toggle.ahk")
launcher=$(cat "$repo_root/platform/windows/start-quake.ps1")
doc=$(cat "$repo_root/docs/quake-mode.md")
doctor=$(cat "$repo_root/chezmoi/dot_config/workstation/doctor")

assert_contains "$adapter" '#Requires AutoHotkey v2.0' 'Windows Quake adapter requires AutoHotkey v2'
assert_contains "$adapter" 'Hotkey("^``", ToggleQuake)' 'Windows Quake adapter registers Ctrl+backtick'
assert_contains "$adapter" 'LaunchQuakeWindow' 'Windows Quake adapter can launch WezTerm'
assert_contains "$adapter" 'start --always-new-process' 'Windows Quake adapter launches a dedicated process'
assert_contains "$adapter" '--config initial_cols=' 'Windows Quake adapter pre-sizes first launch columns'
assert_contains "$adapter" '--config initial_rows=' 'Windows Quake adapter pre-sizes first launch rows'
assert_contains "$adapter" '--config window_background_opacity=' 'Windows Quake adapter sets Quake-specific opacity'
assert_contains "$adapter" '--position screen:' 'Windows Quake adapter pre-positions first launch'
assert_contains "$adapter" 'Run(command, , "Min")' 'Windows Quake adapter starts first launch minimized before final placement'
assert_contains "$adapter" '--workspace ' 'Windows Quake adapter launches dedicated workspace'
assert_contains "$adapter" '--class ' 'Windows Quake adapter launches with dedicated window class'
assert_contains "$adapter" 'QuakeWindowSelector' 'Windows Quake adapter finds window by dedicated selector'
assert_not_contains "$adapter" 'ahk_pid' 'Windows Quake adapter does not track transient launch PID'
assert_contains "$adapter" 'WezTerm\wezterm-gui.exe' 'Windows Quake adapter prefers interactive WezTerm GUI executable'
assert_contains "$adapter" 'WezTerm\wezterm.exe' 'Windows Quake adapter keeps CLI executable as fallback'
assert_contains "$adapter" 'FocusedMonitorWorkArea' 'Windows Quake adapter detects focused monitor'
assert_contains "$adapter" 'MinimizeQuakeWindow' 'Windows Quake adapter minimizes focused dropdown'
assert_contains "$adapter" 'WinMinimize' 'Windows Quake adapter uses restorable minimize path'
assert_not_contains "$adapter" 'WinHide' 'Windows Quake adapter avoids unreliable WinHide restore path'
assert_contains "$adapter" 'DetectHiddenWindows True' 'Windows Quake adapter can discover hidden windows if needed'
assert_contains "$adapter" 'WinShow("ahk_id " hwnd)' 'Windows Quake adapter shows hidden window before moving it'
assert_contains "$adapter" 'WinMove' 'Windows Quake adapter moves and sizes dropdown'
assert_contains "$adapter" 'QuakeWidthRatio := 0.95' 'Windows Quake adapter uses required width ratio'
assert_contains "$adapter" 'QuakeHeightRatio := 1.00' 'Windows Quake adapter uses requested height ratio'
assert_contains "$adapter" 'QuakeOpacity := 0.95' 'Windows Quake adapter uses requested opacity'
assert_contains "$adapter" 'QuakeGeometry' 'Windows Quake adapter centralizes geometry calculation'
assert_not_contains "$adapter" 'not implemented yet' 'Windows Quake adapter is no longer a stub'

assert_contains "$launcher" 'quake-toggle.ahk' 'Windows Quake launcher starts adapter script'
assert_contains "$launcher" 'AutoHotkey64.exe' 'Windows Quake launcher resolves AutoHotkey executable'
assert_contains "$launcher" 'Start-Process' 'Windows Quake launcher starts background adapter'

assert_contains "$doc" 'AutoHotkey v2' 'Quake docs describe Windows AutoHotkey dependency'
assert_contains "$doc" 'start-quake.ps1' 'Quake docs use short PowerShell launcher'
assert_contains "$doc" 'cross-platform-workstation-quake.lnk' 'Quake docs describe startup shortcut'
assert_contains "$doc" 'Manual Windows validation' 'Quake docs include manual validation'
assert_contains "$doc" 'macOS' 'Quake docs keep macOS status visible'
assert_contains "$doc" 'Ubuntu GNOME' 'Quake docs keep Ubuntu status visible'

assert_contains "$doctor" 'check_quake' 'doctor implements Quake checks'
assert_contains "$doctor" 'AutoHotkey' 'doctor checks AutoHotkey'
assert_contains "$doctor" 'WinMinimize' 'doctor checks current Quake dismiss behavior'
assert_not_contains "$doctor" 'Quake hide behavior' 'doctor no longer requires old WinHide behavior'
assert_contains "$doctor" 'Quake startup' 'doctor checks Quake startup registration'
assert_contains "$doctor" 'cross-platform-workstation-quake.lnk' 'doctor checks expected Quake startup shortcut'
assert_not_contains "$doctor" 'AutoHotkey64.exe /?' 'doctor does not invoke AutoHotkey GUI help'
assert_contains "$doctor" '//Validate' 'doctor validates AutoHotkey syntax from Git Bash'
assert_contains "$doctor" 'Quake manual validation' 'doctor marks Quake GUI behavior manual'
assert_contains "$doctor" 'focused-monitor placement and multi-monitor movement require manual GUI validation' 'doctor warning only calls out unvalidated Quake GUI behavior'

finish_tests
