# PROJECT KNOWLEDGE BASE

**Generated:** 2025-05-10
**Commit:** ec44860
**Branch:** develop

## OVERVIEW

IdleCombos - AutoHotkey v1.1 desktop companion app for "Idle Champions" game. Bulk chest buying/opening, blacksmith contracts, bounties, redeem codes, adventure management via game API.

## STRUCTURE

```
idlecombos/
├── IdleCombos.ahk       # MAIN: All app logic (monolithic GUI + business logic)
├── IdleCombosLib.ahk    # LIB: Extracted pure/testable functions (shared with tests)
├── idledict.json        # DATA: ID-to-name mappings (champions, chests, campaigns, patrons, feats)
├── json.ahk             # LIB: JSON parser (Chunjee, stable, v1.1+v2 compatible)
├── images/              # UI button/icon PNGs (13 files)
├── styles/              # Windows msstyles themes (30) + USkin.dll for theming
├── Lib/Yunit/           # TEST: Yunit test framework (vendored, AGPL-3.0)
├── tests/               # TEST: Unit test suites (67 tests)
├── .github/workflows/   # CI: lint, syntax check, tests, release packaging
└── *.json               # Runtime data/logs (all gitignored)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add feature/tab | `IdleCombos.ahk` MyGui.__New() | Add to `TabList` global L61 |
| Bump version | `IdleCombos.ahk` L9, `README.md` L5, `CHANGELOG.md` top | All three must match |
| API calls | `IdleCombos.ahk` ServerCall() | Single variant, HTTPS, WinHttp POST |
| Parse API response | `IdleCombos.ahk` Parse*Data() | Called from GetUserDetails() |
| Add champion/chest | `idledict.json` | Add entry to `champions` or `chests` object |
| Settings persistence | `IdleCombos.ahk` SaveSettings() → `IdleCombosLib.ahk` PersistSettings() | JSON to idlecombosettings.json |
| Add testable logic | `IdleCombosLib.ahk` | Pure functions shared between app and tests |
| Add/run tests | `tests/` | Yunit framework; run `tests\run_tests.ahk` or headless CI |
| Hotkeys | `IdleCombos.ahk` L105-107 | Ctrl+Numpad scheme |
| Game detection | `IdleCombos.ahk` detect*Install() | Epic, Steam, Standalone |
| Release packaging | `.github/workflows/release.yml` | Tag `v*` triggers; dual archives (themes/no-themes) |
| CI pipeline | `.github/workflows/ci.yml` | Markdown lint + AHK syntax check + unit tests |

## CODE MAP

| Function | File | Role |
|----------|------|------|
| MyGui.__New() | IdleCombos.ahk | GUI construction, all tabs/controls |
| MyGui.Load() | IdleCombos.ahk | Settings load, first-run, credential restore |
| GetUserDetails() | IdleCombos.ahk | Master API fetch + cascade all Parse*() |
| ServerCall() | IdleCombos.ahk | HTTPS POST via WinHttp (sole API method) |
| Buy_Chests() | IdleCombos.ahk | Purchase chests by ID |
| Open_Chests() | IdleCombos.ahk | Open chests with progress tracking |
| UseBlacksmith() | IdleCombos.ahk | Apply blacksmith contracts |
| UseBounty() | IdleCombos.ahk | Apply bounty contracts (alpha, mouse-dependent) |
| LaunchGame() | IdleCombos.ahk | Start game client (Epic/Steam/Standalone) |
| FirstRun() | IdleCombos.ahk | Initial setup wizard |
| Update_Dictionary() | IdleCombos.ahk | Auto-update idledict.ahk from GitHub (with integrity check) |
| getChestCodes() | IdleCombosLib.ahk | Regex extraction of redeem codes from clipboard |
| CheckServerCallError() | IdleCombosLib.ahk | Detect API connection errors in response |
| ParsePlayServerName() | IdleCombosLib.ahk | Extract server name from API redirect response |
| PersistSettings() | IdleCombosLib.ahk | Atomic JSON write of CurrentSettings to disk |

## CONVENTIONS

- **Language**: AutoHotkey v1.1 syntax (NOT v2). `#NoEnv`, `#Persistent`, `:=` assignment.
- **Globals**: 100+ globals declared at top, organized by category (File, Settings, Server, User, Inventory, Patron).
- **Functions**: PascalCase for main actions (`BuySilver`), camelCase for helpers (`detectGameInstallEpic`).
- **State**: All state in global variables, no classes/objects for state management (except `UserDetails` parsed JSON).
- **API pattern**: `ServerCall(callname, parameters)` → HTTPS to `{server}.idlechampions.com/~idledragons/post.php`. Handles `switch_play_server` redirect (single hop, no loop).
- **Data format**: JSON for all persistence (settings, logs, API responses). `JSON.parse()`/`JSON.stringify()` via json.ahk.
- **GUI**: Single window, tab-based (8 tabs). `Gui, MyWindow:Add` pattern.
- **Theming**: USkin.dll loaded at runtime for msstyles application. `SkinForm()`.
- **32-bit forced**: `RunWith(32)` at startup - required for COM/WinHttp.
- **File encoding**: IdleCombos.ahk MUST have UTF-8 BOM (`EF BB BF`) — required for emoji in GUI. Use `:=` (expression) not `=` (legacy) for string assignments in library functions.
- **Testable code**: Pure functions go in `IdleCombosLib.ahk` (included by both app and tests).
- **Security**: Never log `UserHash` — use `[REDACTED]`. Hash masked in UI display.
- **JSON keys**: `JSON.parse()` stores numeric-looking keys as numbers. Dictionary lookups must use `id + 0` to coerce to numeric for map access.
- **Markdown (GitHub-flavoured)**:
  - No trailing spaces for line breaks; use blank lines between blocks.
  - ATX headings (`##`) with blank line before/after.
  - Unordered lists use `*` (not `-`), no indent for top-level.
  - Fenced code blocks use triple-backtick with language identifier.
  - Max line length: none enforced (wrap at sentence for diffs).
  - No bare URLs; use `[text](url)` links.
  - One trailing newline at EOF; no multiple consecutive blank lines.
  - Reference-style images preferred for long URLs.
  - Table pipes aligned for readability (not enforced by lint).

## ANTI-PATTERNS (THIS PROJECT)

- `UseBounty()` is alpha-quality: requires 1280x720 resolution, mouse automation, prone to failure.
- `idledict.ahk:779` has "DO NOT USE" chest entry (Gold Mithral Hall) - broken game item.
- Variables prefixed `todo` (L3450-3709) are NOT TODO markers - they're display strings for achievement info.
- Settings version check (`SettingsCheckValue := 23`) must be incremented when adding new settings keys.

## COMMANDS

```bash
# Run (requires AutoHotkey v1.1 installed)
# Right-click IdleCombos.ahk → Open with AutoHotkey

# Run tests (interactive, shows GUI results)
# Right-click tests\run_tests.ahk → Open with AutoHotkey

# Run tests (headless, stdout + junit.xml output)
# "C:\Program Files\AutoHotkey\AutoHotkey.exe" tests\run_tests_ci.ahk

# Release (tag-triggered CI)
git tag v3.78 && git push origin v3.78
# Creates draft release with themed/unthemed archives
# Publishing draft triggers Discord webhook notification

# Update dictionary from upstream
# Built-in: Tools menu → Update Dictionary (fetches from GitHub master)
```

## DATA LOAD (Runtime Files)

| File | Loaded By | Purpose | Tracked |
|------|-----------|---------|---------|
| `idlecombosettings.json` | MyGui.Load() L620 | User prefs, credentials (user_id, hash, instance_id) | No (gitignored) |
| `userdetails.json` | GetUserDetails() L3031 | Cached API response (account state) | No (gitignored) |
| `advdefs.json` | LoadAdventure() L2583 | Adventure definitions for start/stop | Yes (tracked) |
| `redeemcodelist.json` | getChestCodes() L4671 | Community redeem codes list | No (gitignored) |
| `redeemcodelog.json` | Redeem history check L1380 | Previously redeemed codes (skip dupes) | No (gitignored) |
| `chestopenlog.json` | Open_Chests() L1872 | Chest open results history | No (gitignored) |
| `blacksmithlog.json` | UseBlacksmith() L2097 | Blacksmith contract results | No (gitignored) |
| `bountylog.json` | UseBounty() L2288 | Bounty contract results | No (gitignored) |
| `journal.json` | (unused/reserved) | Placeholder for future journaling | No (gitignored) |
| `idlecombolog.txt` | LogFile() L2903 | General app activity log | No (gitignored) |
| `webRequestLog.txt` | GetIDFromWRL() L2917 | Game's WRL file (read for user_id/hash auto-detect) | External (game dir) |
| `localSettings.json` | ViewICSettings() L4096 | Game client settings (read/modify) | External (AppData) |

Default WRL path: `{GameInstallDir}\IdleDragons_Data\StreamingAssets\downloaded_files\webRequestLog.txt` (L42).
Also checked at script dir as fallback (L640). Server name extracted from last `getuserdetails` call in WRL.

## NOTES

- 67 unit tests via Yunit framework. CI runs markdownlint + AHK syntax check + tests on push/PR.
- `ServerName` defaults to "master" but auto-detects play server from game's WRL file.
- Crash protection: monitors game process, can relaunch on crash (Steam only).
- Dictionary auto-update pulls from `djravine/idlecombos` master branch raw GitHub (JSON format, with integrity verification).
- `.vscode/settings.json` is gitignored but present locally (Snyk scanning, spell-right).
- Dual release archives: "no-themes" (AHK+images only) vs "themes" (includes msstyles+USkin.dll).
- `DummyData` global (L72) appends fixed params to all API calls - likely for API compatibility.
- Binary assets (`USkin.dll`, `.msstyles`) stay in git — no LFS. Repo is small; simplicity over correctness here.
