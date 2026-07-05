#Requires AutoHotkey v2.0
#SingleInstance Force

; Phase 1 interface stub. It deliberately does not register Ctrl+`.
; Phase 2 must implement and validate:
; - foreground-window monitor selection via Win32 monitor APIs
; - persistent WezTerm workspace "quake" discovery/spawn
; - focused dropdown hide, otherwise move/size/show/focus
MsgBox("workstation: the Windows Quake adapter is not implemented yet. See docs/quake-mode.md.", "workstation Phase 1")
ExitApp

