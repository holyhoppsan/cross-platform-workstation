#Requires AutoHotkey v2.0
#SingleInstance Force

; Windows Phase 3 Quake-mode adapter.
;
; Ctrl+` toggles a dedicated WezTerm window. The script keeps process state
; inside this AutoHotkey session and falls back to a best-effort window title.
; Manual validation is required on each Windows multi-monitor setup.

Persistent
SetTitleMatchMode 2
DetectHiddenWindows True

global QuakeClass := "wezterm-quake"
global QuakeTitle := "wezterm-quake"
global QuakeWorkspace := "quake"
global QuakeWidthRatio := 0.95
global QuakeHeightRatio := 1.00
global QuakeOpacity := 0.95
global QuakeApproxCellWidth := 8
global QuakeApproxCellHeight := 18

Hotkey("^``", ToggleQuake)

ToggleQuake(*) {
    DetectHiddenWindows True
    quakeWindow := FindQuakeWindow()
    if quakeWindow && WinActive("ahk_id " quakeWindow) {
        MinimizeQuakeWindow(quakeWindow)
        return
    }

    bounds := FocusedMonitorWorkArea()

    if !quakeWindow {
        if !LaunchQuakeWindow(bounds) {
            MsgBox("Unable to launch WezTerm. Confirm wezterm-gui.exe or wezterm.exe is available on PATH.", "workstation quake")
            return
        }

        if !WinWait(QuakeWindowSelector(), , 8) {
            MsgBox("WezTerm launched, but its Quake window was not detected.", "workstation quake")
            return
        }
        quakeWindow := FindQuakeWindow()
    }

    if !quakeWindow {
        return
    }

    PlaceQuakeWindow(quakeWindow, bounds)
    WinActivate("ahk_id " quakeWindow)
}

FindQuakeWindow() {
    global QuakeTitle

    DetectHiddenWindows True
    selector := QuakeWindowSelector()
    if WinExist(selector) {
        return WinExist(selector)
    }

    titleSelector := QuakeTitle " ahk_exe wezterm-gui.exe"
    if WinExist(titleSelector) {
        return WinExist(titleSelector)
    }

    return 0
}

QuakeWindowSelector() {
    global QuakeClass

    return "ahk_class " QuakeClass " ahk_exe wezterm-gui.exe"
}

LaunchQuakeWindow(bounds) {
    global QuakeClass, QuakeOpacity, QuakeWorkspace

    exe := FindWezTermExecutable()
    if !exe {
        return 0
    }

    geometry := QuakeGeometry(bounds)
    command := '"' exe '"'
        . ' --config initial_cols=' geometry.cols
        . ' --config initial_rows=' geometry.rows
        . ' --config window_background_opacity=' QuakeOpacity
        . ' start --always-new-process'
        . ' --position screen:' geometry.x ',' geometry.y
        . ' --class ' QuakeClass
        . ' --workspace ' QuakeWorkspace
    Run(command, , "Min")
    return true
}

FindWezTermExecutable() {
    candidates := [
        EnvGet("ProgramFiles") "\WezTerm\wezterm-gui.exe",
        EnvGet("LOCALAPPDATA") "\Programs\WezTerm\wezterm-gui.exe",
        EnvGet("LOCALAPPDATA") "\Microsoft\WinGet\Links\wezterm-gui.exe",
        EnvGet("LOCALAPPDATA") "\Microsoft\WindowsApps\wezterm-gui.exe",
        EnvGet("ProgramFiles") "\WezTerm\wezterm.exe",
        EnvGet("LOCALAPPDATA") "\Microsoft\WinGet\Links\wezterm.exe",
        EnvGet("LOCALAPPDATA") "\Microsoft\WindowsApps\wezterm.exe"
    ]

    for candidate in candidates {
        if candidate && FileExist(candidate) {
            return candidate
        }
    }

    return FindOnPath(["wezterm-gui.exe", "wezterm.exe"])
}

FindOnPath(names) {
    pathValue := EnvGet("PATH")
    for dir in StrSplit(pathValue, ";") {
        if !dir {
            continue
        }
        for name in names {
            candidate := RTrim(dir, "\/") "\" name
            if FileExist(candidate) {
                return candidate
            }
        }
    }
    return ""
}

FocusedMonitorWorkArea() {
    activeWindow := WinExist("A")
    if !activeWindow {
        MonitorGetWorkArea(1, &left, &top, &right, &bottom)
        return { left: left, top: top, right: right, bottom: bottom }
    }

    WinGetPos(&x, &y, &w, &h, "ahk_id " activeWindow)
    centerX := x + (w / 2)
    centerY := y + (h / 2)

    monitorCount := MonitorGetCount()
    Loop monitorCount {
        MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
        if centerX >= left && centerX <= right && centerY >= top && centerY <= bottom {
            return { left: left, top: top, right: right, bottom: bottom }
        }
    }

    MonitorGetWorkArea(1, &left, &top, &right, &bottom)
    return { left: left, top: top, right: right, bottom: bottom }
}

PlaceQuakeWindow(hwnd, bounds) {
    geometry := QuakeGeometry(bounds)

    WinShow("ahk_id " hwnd)
    Sleep(50)
    WinRestore("ahk_id " hwnd)
    WinMove(geometry.x, geometry.y, geometry.width, geometry.height, "ahk_id " hwnd)
}

QuakeGeometry(bounds) {
    global QuakeWidthRatio, QuakeHeightRatio, QuakeApproxCellWidth, QuakeApproxCellHeight

    monitorWidth := bounds.right - bounds.left
    monitorHeight := bounds.bottom - bounds.top
    width := Round(monitorWidth * QuakeWidthRatio)
    height := Round(monitorHeight * QuakeHeightRatio)
    x := bounds.left + Round((monitorWidth - width) / 2)
    y := bounds.top
    cols := Max(80, Round(width / QuakeApproxCellWidth))
    rows := Max(24, Round(height / QuakeApproxCellHeight))

    return { x: x, y: y, width: width, height: height, cols: cols, rows: rows }
}

MinimizeQuakeWindow(hwnd) {
    ; Minimizing keeps the window alive, top-level, and reliably restorable.
    ; Fully hiding or parking off-screen proved unreliable with WezTerm on Windows.
    WinMinimize("ahk_id " hwnd)
}
