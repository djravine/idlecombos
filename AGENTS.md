# PROJECT KNOWLEDGE BASE

**Generated:** 2025-05-10
**Commit:** ec44860
**Branch:** develop

## OVERVIEW

IdleCombos - AutoHotkey v1.1 desktop companion app for "Idle Champions" game. Bulk chest buying/opening, blacksmith contracts, bounties, redeem codes, adventure management via game API.

## STRUCTURE

```
idlecombos/
├── IdleCombos.ahk       # MAIN: All app logic (4968 lines, monolithic)
├── idledict.ahk         # DATA: ID-to-name mappings (champions, chests, campaigns, patrons)
├── json.ahk             # LIB: JSON parser (external, bundled) [github.com/Chunjee]
├── images/              # UI button/icon PNGs (13 files)
├── styles/              # Windows msstyles themes (30) + USkin.dll for theming
├── .github/workflows/   # Release packaging + Discord notification
└── *.json               # Runtime data/logs (all gitignored except advdefs.json)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add feature/tab | `IdleCombos.ahk` MyGui.__New() L325-614 | Add to `TabList` global L61 |
| API calls | `IdleCombos.ahk` ServerCall() L3831 | 3 variants: ServerCall, ServerCallNew, ServerCallAlt |
| Parse API response | `IdleCombos.ahk` Parse*Data() L3087-3530 | Called from GetUserDetails() L3031 |
| Add champion/chest | `idledict.ahk` | ChampFromID(), ChestFromID() switch blocks |
| Settings persistence | `IdleCombos.ahk` SaveSettings() L1051 | JSON to idlecombosettings.json |
| Hotkeys | `IdleCombos.ahk` L105-107 | Ctrl+Numpad scheme |
| Game detection | `IdleCombos.ahk` detect*Install() L2712-2847 | Epic, Steam, Standalone |
| Release packaging | `.github/workflows/release.yml` | Tag `v*` triggers; dual archives (themes/no-themes) |

## CODE MAP

| Function | Line | Role |
|----------|------|------|
| MyGui.__New() | 325 | GUI construction, all tabs/controls |
| MyGui.Load() | 616 | Settings load, first-run, credential restore |
| GetUserDetails() | 3031 | Master API fetch + cascade all Parse*() |
| ServerCall() | 3831 | HTTP POST via WinHttp (primary) |
| ServerCallNew() | 3864 | HTTP GET via XMLHTTP (secondary) |
| Buy_Chests() | 1747 | Purchase chests by ID |
| Open_Chests() | 1872 | Open chests with progress tracking |
| UseBlacksmith() | 2097 | Apply blacksmith contracts |
| UseBounty() | 2288 | Apply bounty contracts (alpha, mouse-dependent) |
| LaunchGame() | 3903 | Start game client (Epic/Steam/Standalone) |
| FirstRun() | 2848 | Initial setup wizard |
| Update_Dictionary() | 3983 | Auto-update idledict.ahk from GitHub |

## CONVENTIONS

- **Language**: AutoHotkey v1.1 syntax (NOT v2). `#NoEnv`, `#Persistent`, `:=` assignment.
- **Globals**: 100+ globals declared at top, organized by category (File, Settings, Server, User, Inventory, Patron).
- **Functions**: PascalCase for main actions (`BuySilver`), camelCase for helpers (`detectGameInstallEpic`).
- **State**: All state in global variables, no classes/objects for state management (except `UserDetails` parsed JSON).
- **API pattern**: `ServerCall(callname, parameters)` → HTTP to `{server}.idlechampions.com/~idledragons/post.php`.
- **Data format**: JSON for all persistence (settings, logs, API responses). `JSON.parse()`/`JSON.stringify()` via json.ahk.
- **GUI**: Single window, tab-based (8 tabs). `Gui, MyWindow:Add` pattern. Resize handler at L862.
- **Theming**: USkin.dll loaded at runtime for msstyles application. `SkinForm()` L1014.
- **32-bit forced**: `RunWith(32)` at startup - required for COM/WinHttp.
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
- `advdefs.json` is tracked in git but other JSON data files are gitignored - inconsistent.
- Settings version check (`SettingsCheckValue := 23`) must be incremented when adding new settings keys.

## COMMANDS

```bash
# Run (requires AutoHotkey v1.1 installed)
# Right-click IdleCombos.ahk → Open with AutoHotkey

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

## NOTES

- No tests, no linter, no build step. Manual testing via UI + log inspection.
- `ServerName` defaults to "master" but auto-detects play server from game's WRL file.
- Crash protection: monitors game process, can relaunch on crash (Steam only).
- Dictionary auto-update pulls from `djravine/idlecombos` master branch raw GitHub.
- `.vscode/settings.json` is gitignored but present locally (Snyk scanning, spell-right).
- Dual release archives: "no-themes" (AHK+images only) vs "themes" (includes msstyles+USkin.dll).
- `DummyData` global (L72) appends fixed params to all API calls - likely for API compatibility.
