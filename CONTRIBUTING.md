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

* `IdleCombos.ahk` — Main application (all logic)
* `idledict.ahk` — Champion/chest/campaign ID-to-name dictionary
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

To add new champions or chests, edit `idledict.ahk`:

* `ChampFromID()` — add new champion case
* `ChestFromID()` — add new chest case
* Update `MaxChampID` / `MaxChestID` globals at top

## Security Notes

* Never log `UserHash` — use `[REDACTED]` in log messages
* API credentials are stored locally in `idlecombosettings.json` (gitignored)
* Do not commit any `.json` data files containing user credentials

## Discord

Questions or discussion: [Discord Support Server](https://discord.gg/wFtrGqd3ZQ)
