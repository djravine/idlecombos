# PROJECT KNOWLEDGE BASE

**Generated:** 2026-05-10
**Branch:** develop

## OVERVIEW

IdleCombos - AutoHotkey v1.1 desktop companion app for "Idle Champions" game. Bulk chest buying/opening, blacksmith contracts, bounties, redeem codes, adventure management via game API.

## STRUCTURE

```text
idlecombos/
├── IdleCombos.ahk       # MAIN: GUI + business logic + API calls
├── IdleCombosLib.ahk    # LIB: Pure/testable functions + shared constants
├── idledict.json        # DATA: ID-to-name mappings (champions, chests, campaigns, patrons, feats)
├── json.ahk             # LIB: JSON parser (Chunjee, vendored, v1.1+v2 compatible)
├── images/              # UI button/icon PNGs (13 files)
├── styles/              # Windows msstyles themes (30) + USkin.dll for theming
├── Lib/
│   ├── ScrollBox.ahk    # LIB: Vendored scrollable text display (Fanatic Guru)
│   └── Yunit/           # TEST: Yunit test framework (vendored, AGPL-3.0)
├── tests/               # TEST: Unit test suites
├── .github/workflows/   # CI: lint, syntax check, tests, release packaging
├── SECURITY.md          # Threat model and security considerations
├── THIRD_PARTY.md       # Vendored asset inventory with SHA-256 hashes
├── SETTINGS_SCHEMA.md   # Settings key history and bump procedure
├── CODE_FLOW.md         # Startup process diagram and timings
└── *.json               # Runtime data/logs (all gitignored)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add feature/tab | `IdleCombos.ahk` MyGui.__New() | Add to `TabList` global L61 |
| Bump version | `IdleCombos.ahk` L9, `README.md` L5, `CHANGELOG.md` top | All three must match; CI verifies |
| API calls | `IdleCombos.ahk` ServerCall() | Single variant, HTTPS, WinHttp POST |
| Parse API response | `IdleCombos.ahk` Parse*Data() | Called from GetUserDetails() |
| Add champion/chest | `idledict.json` | Add entry to `champions` or `chests` object |
| Sync dictionary from API | `IdleCombos.ahk` Sync_Dictionary_From_API() | Help menu; fetches live definitions, diffs, previews, merges |
| Add new patron | `IdleCombosLib.ahk` PatronShortNames + PatronIDs | Also add globals + switch case in ParsePatronDataFromDetails |
| Settings persistence | `IdleCombos.ahk` SaveSettings() → `IdleCombosLib.ahk` PersistSettings() | Atomic JSON write |
| Add new setting key | `IdleCombosLib.ahk` NewSettings + SettingsCheckValue | See SETTINGS_SCHEMA.md |
| Add testable logic | `IdleCombosLib.ahk` | Pure functions shared between app and tests |
| Add/run tests | `tests/` | Yunit framework; run `tests\run_tests.ahk` or headless CI |
| Hotkeys | `IdleCombos.ahk` L105-107 | Ctrl+Numpad scheme |
| Game detection | `IdleCombos.ahk` tryDetectPlatform() + detectCredentialsAndSave() | Epic, Steam, Standalone; FileSelectFile fallback |
| Setup wizard | `IdleCombos.ahk` FirstRun() | Platform picker GUI; File menu + first-run |
| Release packaging | `.github/workflows/release.yml` | Tag `v*` triggers; dual archives (themes/no-themes) |
| CI pipeline | `.github/workflows/ci.yml` | Markdown lint + AHK syntax check + unit tests + version check |

## CODE MAP

| Function | File | Role |
|----------|------|------|
| MyGui.__New() | IdleCombos.ahk | GUI construction, all tabs/controls |
| MyGui.Load() | IdleCombos.ahk | Settings load, first-run, credential restore |
| GetUserDetails() | IdleCombos.ahk | Master API fetch + cascade all Parse*() |
| ServerCall() | IdleCombos.ahk | HTTPS POST via WinHttp (sole API method, mock-aware) |
| BatchAPICall() | IdleCombos.ahk | Shared batch loop helper for chest/blacksmith operations |
| Buy_Chests() | IdleCombos.ahk | Purchase chests by ID (IsBusy guarded) |
| Open_Chests() | IdleCombos.ahk | Open chests with progress tracking (IsBusy guarded) |
| UseBlacksmith() | IdleCombos.ahk | Apply blacksmith contracts (IsBusy guarded) |
| UseBounty() | IdleCombos.ahk | Apply bounty contracts (alpha, mouse-dependent) |
| LaunchGame() | IdleCombos.ahk | Start game client (Epic/Steam/Standalone) |
| FirstRun() | IdleCombos.ahk | Initial setup wizard |
| Update_Dictionary() | IdleCombos.ahk | Auto-update idledict.json from GitHub (with integrity check) |
| applyGameInstall() | IdleCombos.ahk | Shared state assignment for game platform detection |
| SimulateBriv() | IdleCombos.ahk | GUI wrapper for Briv stack calculator |
| Sync_Dictionary_From_API() | IdleCombos.ahk | Fetch live definitions from game API, diff, preview, merge into idledict.json |
| FetchDefinitionsForSync() | IdleCombos.ahk | Two-step API call: resolve defs server, then getDefinitions (no auth) |
| WriteDictionaryJson() | IdleCombos.ahk | Atomic write of dict with .bak backup and parse-back validation |
| ExtractDefinitionMap() | IdleCombosLib.ahk | Convert API defines array [{id,name},...] to {id: name} map |
| ExtractFeatDefinitionMap() | IdleCombosLib.ahk | Feat-specific extractor: combines hero_id + name into "ChampName (FeatName)" |
| DiffDefinitionSection() | IdleCombosLib.ahk | Compare local vs API maps; classify NEW and CHANGED entries |
| BuildSyncPreviewTextMulti() | IdleCombosLib.ahk | Build multi-section human-readable diff preview for ScrollBox |
| ApplySyncSectionToDict() | IdleCombosLib.ahk | Generic merge: apply new + changed entries to any dict section |
| BuildPatronDisplayMap() | IdleCombosLib.ahk | Build reverse lookup: display name → patron ID (from dict) |
| BuildPatronDropdownList() | IdleCombosLib.ahk | Build pipe-delimited patron DDL string from dict names |
| getChestCodes() | IdleCombosLib.ahk | Regex extraction of redeem codes from clipboard |
| CheckServerCallError() | IdleCombosLib.ahk | Detect API connection errors in response |
| ParsePlayServerName() | IdleCombosLib.ahk | Extract server name from API redirect response |
| PersistSettings() | IdleCombosLib.ahk | Atomic JSON write of CurrentSettings to disk |
| ParseWRLCredentials() | IdleCombosLib.ahk | Extract user_id/hash/epic/steam from WRL text |
| EpochToLocalTime() | IdleCombosLib.ahk | Unix epoch to formatted local time string |
| SimulateBrivCalc() | IdleCombosLib.ahk | Pure Briv skip probability math |
| DefaultToZero() | IdleCombosLib.ahk | Set empty/blank values to 0 |
| RotateLogFile() | IdleCombosLib.ahk | Truncate log files exceeding max size |
| SetMockServerCall() | IdleCombosLib.ahk | Enable mock mode for testing API calls |
| ClearMockServerCall() | IdleCombosLib.ahk | Disable mock mode |
| DPAPIEncrypt() | IdleCombosLib.ahk | Encrypt string using Windows DPAPI (CryptProtectData) |
| DPAPIDecrypt() | IdleCombosLib.ahk | Decrypt DPAPI-encrypted value back to plaintext |
| FormatMagnitude() | IdleCombosLib.ahk | Format large numbers with K/M/B/t suffix |
| FormatDuration() | IdleCombosLib.ahk | Format seconds into "Xd Yh Zm" duration string |
| WriteJsonAtomic() | IdleCombosLib.ahk | Atomic JSON write via temp file with validation |
| SafeGet() | IdleCombosLib.ahk | Safely navigate nested object paths without crashing |
| RequireKey() | IdleCombosLib.ahk | Fail-fast check for required nested API paths with LogFile warning |
| AdvFromID() | IdleCombosLib.ahk | Look up adventure name from advdefs.json (static cache) |
| BuildChampDropdownList() | IdleCombosLib.ahk | Sorted "Name (ID)" pipe-delimited list from dict champions |
| BuildChestDropdownList() | IdleCombosLib.ahk | Sorted "Name (ID)" pipe-delimited list from dict chests |
| BuildAdvDropdownList() | IdleCombosLib.ahk | Sorted "Name (ID)" pipe-delimited list from advdefs.json |
| BuildPatronPickerList() | IdleCombosLib.ahk | Patron list with IDs for ComboBox picker |
| PickerExtractID() | IdleCombosLib.ahk | Extract numeric ID from "Name (ID)" format or raw number |
| ExtractChampNamesFromDefines() | IdleCombosLib.ahk | Extract champion names from upgrade/loot defines via possessive regex |
| PromptCount() | IdleCombos.ahk | Slider + spinbox + Max button count prompt for batch operations |
| PromptCredentials() | IdleCombos.ahk | Single dialog for user_id + hash with platform instructions |
| detectCredentialsAndSave() | IdleCombos.ahk | Extract WRL credentials and save without running full setup wizard |
| tryDetectPlatform() | IdleCombos.ahk | Shared detection engine with FileSelectFile fallback for all platforms |
| CrashProtect() | IdleCombos.ahk | Monitor game process, restart on crash (WinWait, 3 attempt limit) |
| CheckEvents() | IdleCombos.ahk | Parse events_details + event_details + event_v2_defines for Event tab |

## CONVENTIONS

* **Language**: AutoHotkey v1.1 syntax (NOT v2). `#NoEnv`, `#Persistent`, `:=` assignment. **Do NOT use v2 syntax** — this includes `MsgBox()` function-style calls, `#Requires`, fat arrow functions (`=>`), or `Map()` objects. AHK v2 is a different language. See below for common pitfalls.
* **AHK v1.1 vs v2 pitfalls**:
  * Use `MsgBox, text` (command) NOT `MsgBox("text")` (v2 function).
  * Use `StringLeft, out, str, n` or `SubStr()` NOT `str.Substring()`.
  * Use `for k, v in obj` NOT `for k, v in obj.OwnProps()`.
  * Use `ComObjCreate("...")` NOT `ComObject("...")`.
  * Use `Gui, Add, ...` commands NOT `myGui := Gui()` object syntax.
  * Use `%varname%` for dynamic variable dereference NOT `%varname%()`.
  * Legacy assignment (`var = value`) does NOT support dot notation (`r.key`). Use expression mode (`:=`) for object property access.
* **Globals**: 100+ globals declared at top, organized by category (File, Settings, Server, User, Inventory, Patron).
* **Functions**: PascalCase for main actions (`BuySilver`), camelCase for helpers (`detectGameInstallEpic`).
* **State**: All state in global variables, no classes/objects for state management (except `UserDetails` parsed JSON).
* **API pattern**: `ServerCall(callname, parameters)` → HTTPS to `{server}.idlechampions.com/~idledragons/post.php`. Handles `switch_play_server` redirect (single hop, no loop).
* **API constraints**: All parameters (including `user_id` and `hash`) MUST be sent as URL query string parameters. The POST body is empty. The game API (`post.php`) only reads from query string (`$_GET`). This is confirmed across all known community implementations (IdleCombos, Leyline77/idleChampions-ahk). Do NOT move parameters to the POST body — it will break all API calls. See `SECURITY.md` for the security implications of credentials in query strings.
* **Data format**: JSON for all persistence (settings, logs, API responses). `JSON.parse()`/`JSON.stringify()` via json.ahk.
* **GUI**: Single window, tab-based (11 tabs). `Gui, MyWindow:Add` pattern. Most tabs use GroupBox cards instead of ListViews (Adventures, Patrons, Event, Pity Timers). Summary and Inventory use GroupBoxes with ListViews inside. Sidebar has GroupBoxes for Platform, Crash Protect, Data Timestamp. ID inputs use ComboBox pickers (champion, chest, patron, adventure). Batch count prompts use slider + spinbox via `PromptCount()`.
* **Patron portraits**: 80×80 PNG images in `images/patron_1.png` through `patron_6.png`. Replace files to update portraits — no code changes needed.
* **Adventure globals**: Standardized to `FG*`/`BG*`/`BG2*`/`BG3*`/`BG4*`/`BG5*` prefix pattern (e.g. `FGAdventure`, `BGCoreName`, `BG4Champions`).
* **Theming**: USkin.dll loaded at runtime for msstyles application. `SkinForm()`.
* **32-bit forced**: `RunWith(32)` at startup - required for COM/WinHttp.
* **File encoding**: IdleCombos.ahk MUST have UTF-8 BOM (`EF BB BF`) — required for emoji in GUI. Use `:=` (expression) not `=` (legacy) for string assignments in library functions. **CRITICAL**: When writing to this file via scripts or tools, ALWAYS preserve the BOM. PowerShell `Set-Content -Encoding UTF8` does NOT write a BOM in PS7+. Use `[System.IO.File]::WriteAllBytes()` with `@(0xEF, 0xBB, 0xBF)` prefix, or verify BOM after any automated write. Loss of BOM causes all emoji and special characters (em dashes, checkmarks) to render as `â€"` / `Ã¢` garbage.
* **Testable code**: Pure functions go in `IdleCombosLib.ahk` (included by both app and tests). Functions that call `ServerCall()` must stay in `IdleCombos.ahk` (not available in test context).
* **TestMode**: `IdleCombosLib.ahk` checks `TestMode` global. Test runners set `TestMode := true` before including the lib to suppress MsgBox/ExitApp.
* **IsBusy guard**: Long-running operations (Buy_Chests, Open_Chests, UseBlacksmith) use `BeginBusyOp()`/`EndBusyOp()` for entry/exit. Prevents hotkey reentrancy.
* **Security**: Never log `UserHash` — use `[REDACTED]`. Hash encrypted at rest via DPAPI (`DPAPIEncrypt`/`DPAPIDecrypt`). Hash masked in UI display. See `SECURITY.md`.
* **JSON keys**: `JSON.parse()` stores numeric-looking keys as numbers. Dictionary lookups must use `id + 0` to coerce to numeric for map access.
* **Patron names**: Two forms exist — short names (`Mirt`, `Vajra`) used as AHK variable prefixes (e.g. `MirtVariants`), and full display names (`Mirt the Moneylender`, `Vajra Safahr`) from the dictionary via `PatronFromID()`. All UI display, exports, and dropdowns use the dict names. Short names are internal identifiers only, stored in `PatronShortNames` constant. To add a new patron: add to `PatronShortNames`, `PatronIDs`, add global variables, add switch case in `ParsePatronDataFromDetails`, and add the dict entry.
* **Dictionary sync**: `Sync_Dictionary_From_API()` fetches live champion, chest, campaign, patron, and feat definitions from the game API's `getDefinitions` endpoint (no authentication needed). Uses two-step server discovery (`getPlayServerForDefinitions` → `getDefinitions`). Supplements champion names from `getuserdetails` defines (upgrade tip_text and loot effect descriptions) for heroes not in `getDefinitions`. Diffs against local dict, shows preview via ScrollBox, merges with `.bak` backup. Does NOT bump `idledict.json` version (preserves GitHub update flow). Preserves curated local overrides (e.g. chest 205 "DO NOT USE"). Pure diff/merge logic in `IdleCombosLib.ahk`, API calls in `IdleCombos.ahk`.
* **Dictionary structure**: `idledict.json` uses ID-keyed objects for all sections (champions, campaigns, chests, patrons, feats). A sentinel key `"0": ""` in champions and campaigns prevents `json.ahk` from serializing sequential numeric keys as arrays. To add a champion: add `"ID": "Name"` to the champions object.
* **Changelog**: Always add entries to `CHANGELOG.md` under the current version section after making changes. Every user-visible fix, feature, or refactor gets a bullet point. This is the primary record of what changed and when.
* **Markdown (GitHub-flavoured)**:
  * No trailing spaces for line breaks; use blank lines between blocks.
  * ATX headings (`##`) with blank line before/after.
  * Unordered lists use `*` (not `-`), no indent for top-level.
  * Fenced code blocks use triple-backtick with language identifier.
  * Max line length: none enforced (wrap at sentence for diffs).
  * No bare URLs; use `[text](url)` links.
  * One trailing newline at EOF; no multiple consecutive blank lines.
  * Reference-style images preferred for long URLs.
  * Table pipes aligned for readability (not enforced by lint).

## ANTI-PATTERNS (THIS PROJECT)

* `UseBounty()` is alpha-quality: requires 1280x720 resolution, mouse automation, prone to failure.
* `idledict.ahk` chest 205 has "DO NOT USE" entry (Gold Mithral Hall) — broken game item. Dictionary sync preserves this via `preserveChestKeys`.
* Variables prefixed `todo` (L3450-3709) are NOT TODO markers - they're display strings for achievement info.
* `SettingsCheckValue` and `NewSettings` are defined in `IdleCombosLib.ahk` (shared by app and tests). Increment `SettingsCheckValue` when adding new settings keys.
* Do NOT put functions that call `ServerCall()` in `IdleCombosLib.ahk` — tests include the lib without the main app, so ServerCall is unavailable. `BatchAPICall()` lives in `IdleCombos.ahk` for this reason.

## COMMANDS

```bash
# Run (requires AutoHotkey v1.1 installed)
# Right-click IdleCombos.ahk → Open with AutoHotkey

# Run tests (interactive, shows GUI results)
# Right-click tests\run_tests.ahk → Open with AutoHotkey

# Run tests (headless, stdout + junit.xml output)
# "C:\Program Files\AutoHotkey\AutoHotkey.exe" tests\run_tests_ci.ahk

# Release (tag-triggered CI)
git tag v3.80 && git push origin v3.80
# Creates draft release with themed/unthemed archives
# Publishing draft triggers Discord webhook notification

# Update dictionary from upstream
# Built-in: Help menu → Update Dictionary from Git (fetches from GitHub master)
# Or: Help menu → Sync Dictionary from API (fetches live definitions from game API)
```

## DATA LOAD (Runtime Files)

| File | Loaded By | Purpose | Tracked |
|------|-----------|---------|---------|
| `idlecombosettings.json` | MyGui.Load() | User prefs, credentials (user_id, DPAPI-encrypted hash, instance_id) | No (gitignored) |
| `userdetails.json` | GetUserDetails() | Cached API response (account state) | No (gitignored) |
| `advdefs.json` | IncompleteVariants() | Adventure definitions (auto-generated from API) | No (gitignored) |
| `redeemcodelist.json` | getChestCodes() | Community redeem codes list | No (gitignored) |
| `redeemcodelog.json` | Redeem history check | Previously redeemed codes (skip dupes) | No (gitignored) |
| `chestopenlog.json` | Open_Chests() | Chest open results history (rotated) | No (gitignored) |
| `blacksmithlog.json` | UseBlacksmith() | Blacksmith contract results (rotated) | No (gitignored) |
| `bountylog.json` | UseBounty() | Bounty contract results (rotated) | No (gitignored) |
| `campaign.json` | IncompleteBase() | Campaign details cache | No (gitignored) |
| `idlecombolog.txt` | LogFile() | General app activity log | No (gitignored) |
| `webRequestLog.txt` | GetIDFromWRL() → ParseWRLCredentials() | Game's WRL file (user_id/hash auto-detect) | External (game dir) |
| `localSettings.json` | ViewICSettings() / UpdateICSetting() | Game client settings (read/modify) | External (AppData) |

Default WRL path: `{GameInstallDir}\IdleDragons_Data\StreamingAssets\downloaded_files\webRequestLog.txt` (L42).
Also checked at script dir as fallback (L640). Server name extracted from last `getuserdetails` call in WRL.

## NOTES

* Unit tests via Yunit framework. CI runs markdownlint + AHK syntax check + tests + version check on push/PR.
* `ServerName` defaults to "master" but auto-detects play server from game's WRL file.
* Crash protection: monitors game process, can relaunch on crash (Steam only).
* Dictionary auto-update pulls from `djravine/idlecombos` master branch raw GitHub (JSON format, with integrity verification).
* `.vscode/settings.json` is gitignored but present locally (Snyk scanning, spell-right).
* Dual release archives: "no-themes" (AHK+images+icon only) vs "themes" (includes msstyles+USkin.dll).
* `DummyData` global is defined in `IdleCombosLib.ahk` — appends fixed params to all API calls for API compatibility.
* Binary assets (`USkin.dll`, `.msstyles`) stay in git — no LFS. Repo is small; simplicity over correctness here.
* All CI workflow actions are SHA-pinned to immutable commit hashes.
* Log files (chest, blacksmith, bounty) are automatically rotated when exceeding 512 KB.
