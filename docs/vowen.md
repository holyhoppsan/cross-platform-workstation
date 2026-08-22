# Vowen Desktop Dictation

Phase 8 adds an optional Vowen installation path for Windows and macOS. Vowen
is a system-wide voice-input application; it is independent of Pi, Codex,
Herdr, MCP servers, model profiles, and repository configuration.

The setup command never downloads or runs Vowen automatically. Its explicit
installation option opens the official download page only, leaving installer
review, Windows SmartScreen decisions, and OS permissions with the machine
owner.

## Install and detect

Windows, from a normal (non-Administrator) PowerShell:

```powershell
./setup.ps1 -Phase vowen
./setup.ps1 -Phase vowen -InstallVowen
```

macOS, from the repository checkout:

```bash
./setup.sh --phase vowen
./setup.sh --phase vowen --install-missing
```

The opt-in commands open Vowen's official Windows or macOS download page. Use
the downloaded installer manually. On macOS, copy `Vowen.app` to
`/Applications` as directed by Vowen's DMG. Do not add Vowen application data,
audio, models, or account credentials to this repository.

After installation, check the optional detection result:

```bash
doctor --phase vowen
```

The doctor does not fail when Vowen is absent. It looks for the normal macOS
application location and common Windows installation locations; manual app
launch remains the final confirmation.

## Permissions and privacy

Grant Vowen microphone access before dictating. On macOS, also grant
Accessibility permission so Vowen can insert text into other applications,
then fully quit and relaunch Vowen. Screen Recording is only needed for
Vowen's Meeting Notes feature, not ordinary dictation.

Vowen can use local or cloud transcription depending on its own settings and
may download models or retain app data outside this repository. Review those
choices in Vowen before using it with sensitive material. For literal coding
or shell prompts, turn off Vowen AI Enhancement if you want transcription
without rewriting.

## Shortcut policy

Keep Vowen's documented defaults initially:

- Windows: hold `Ctrl+Shift` to dictate.
- macOS: hold `Fn` to dictate.

These do not use the workstation's OS-level Quake shortcut (`Ctrl+``) or
WezTerm's `Ctrl+V`/`Ctrl+Shift+V` clipboard handling. Leave Vowen hands-free
mode disabled unless you deliberately choose and test its shortcut. Vowen
shortcuts are configurable in its Settings > Shortcuts; any replacement must
avoid the workstation bindings above.

## WezTerm validation

After permissions are granted, open a fresh local WezTerm window on each
machine. Open a temporary text buffer, for example:

```bash
nvim /tmp/vowen-wezterm-test.txt
```

Place the cursor in Insert mode, hold the Vowen dictation shortcut, say a
short sentence, and release it. Confirm that the expected text arrives in the
buffer, then exit without saving if desired. This avoids accidentally
executing dictated text at a shell prompt.

On Windows, if dictation inserts only a literal `v` or otherwise fails to
paste into an application, use Vowen Settings > General to select its Direct
insertion method and repeat the test. Do not change WezTerm's explicit
clipboard bindings merely to accommodate Vowen.

Finally, test `Ctrl+`` to toggle Quake mode and normal `Ctrl+V` pasting in
WezTerm. Record successful Windows and macOS validation in `PLAN.md` only
after testing on those machines.
