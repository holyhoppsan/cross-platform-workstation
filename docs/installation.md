# Installation notes

Phase 1 assumes prerequisites are already installed; package bootstrap arrives in Phase 2.

1. Clone this repository using native Git.
2. Run `chezmoi init --source <clone>/chezmoi` and inspect `chezmoi diff`.
3. Run `chezmoi apply`.
4. Start a new Bash and run `workstation-doctor`.
5. Start WezTerm and verify the leader bindings.

On macOS, `brew --prefix bash` is preferred when available; otherwise `/bin/bash` is used. On Ubuntu, inspect `echo "$XDG_SESSION_TYPE"` to distinguish Wayland from X11. On Windows, use Git Bash and keep Unreal paths in native form when passing them to Windows applications.

The Quake adapters are interface stubs in Phase 1 and must not be installed as hotkey handlers yet.

