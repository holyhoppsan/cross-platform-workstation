# Quake-mode contract

The native adapter owns global `Ctrl+``. It targets a persistent WezTerm window attached to workspace `quake`, moves it to the focused application's monitor work area, sizes it to roughly 95% width and 55% height, and focuses it. If that dropdown is already focused, the adapter hides it without terminating the GUI process.

Current adapter files are explicit Phase 1 stubs. See the manual matrix in `implementation-plan.md`; none of the platform UI behavior has been tested yet.

