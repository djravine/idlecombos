# Contributing to IdleCombos

## Requirements

* [AutoHotkey v1.1](https://www.autohotkey.com/download/ahk-install.exe) (NOT v2)
* Windows (required for COM objects and GUI)
* An Idle Champions account with `user_id` and `hash`

## Getting Started

1. Clone the repo: `git clone https://github.com/djravine/idlecombos.git`
2. Right-click `IdleCombos.ahk` and open with AutoHotkey
3. The app will prompt for game detection on first run

## Project Structure

* `IdleCombos.ahk` — Main application (GUI + business logic)
* `IdleCombosLib.ahk` — Extracted pure/testable functions
* `idledict.json` — Champion/chest/campaign ID-to-name data
* `json.ahk` — Bundled JSON parser (do not modify)
* See `AGENTS.md` for detailed code map and conventions

## Code Style

* AutoHotkey v1.1 syntax only
* PascalCase for main functions, camelCase for helpers
* All state in global variables (declared at top of file)
* JSON for persistence (settings, logs, API responses)

## Making Changes

1. Create a branch from `develop`
2. Make your changes
3. Test manually (run the app, verify your feature works)
4. Update `CHANGELOG.md` with your changes
5. Submit a PR to `develop`

## Version Bumping

When releasing, update version in all three locations:

* `IdleCombos.ahk` line 9 (`VersionNumber`)
* `README.md` line 5
* `CHANGELOG.md` (new section at top)

## Dictionary Updates

To add new champions or chests, edit `idledict.json`:

* Add entries to the `champions` or `chests` objects
* Update `MaxChampID` / `MaxChestID` values at the top of the file
* Lookups are handled by `IdleCombosLib.ahk` functions

## Security Notes

* Never log `UserHash` — use `[REDACTED]` in log messages
* API credentials are stored locally in `idlecombosettings.json` (gitignored)
* Do not commit any `.json` data files containing user credentials

## Discord

Questions or discussion: [Discord Support Server](https://discord.gg/wFtrGqd3ZQ)
