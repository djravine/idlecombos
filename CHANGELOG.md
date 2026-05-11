# IDLE COMBOS CHANGELOG

## Special Thanks

To all the Idle Dragoneers who inspired and assisted me!

------

## 3.82

* Fix Crash Protect launching multiple game copies — replaced tight `Sleep 10s` loop with `WinWait` (120s timeout) so it waits for the game to actually start before retrying; gives up after 3 consecutive failures instead of looping forever
* Persist blacksmith last champion and last counts (Tiny/Small/Medium/Large/Huge) across sessions — stored in settings, restored on load
* Persist bounty last counts (Tiny/Small/Medium/Large) across sessions — stored in settings, restored on load
* Replace blacksmith hero ID `InputBox` with a sorted champion `ComboBox` populated from `idledict.json` — pre-selects last-used champion; format is "Name (ID)"; also accepts typed champion IDs
* Replace Buy/Open Event chest `InputBox` prompts with a sorted chest `ComboBox` picker populated from `idledict.json` — format is "Name (ID)"; also accepts typed chest IDs
* Replace Load Adventure patron `InputBox` with a patron `ComboBox` picker — shows "None (0)" through all five patrons with IDs; also accepts typed patron IDs; fixes validation range (was `< 5`, now `<= 5` to include Elminster)
* Add `BuildChestDropdownList()`, `BuildPatronPickerList()`, and `PickerExtractID()` helpers to `IdleCombosLib.ahk`
* Bump `SettingsCheckValue` to 26 with 10 new settings keys: `lastbschamp`, `lastbstncount`, `lastbssmcount`, `lastbsmdcount`, `lastbslgcount`, `lastbshgcount`, `lastbountytncount`, `lastbountysmcount`, `lastbountymdcount`, `lastbountylgcount`
* Replace Load Adventure `InputBox` with a sorted adventure `ComboBox` picker (`ShowAdvPicker()`) populated from `advdefs.json` — pre-selects last-used adventure; falls back to plain `InputBox` if `advdefs.json` does not yet exist; format is "Name (ID)"; also accepts typed adventure IDs
* Add `BuildAdvDropdownList()` helper to `IdleCombosLib.ahk` — reads `advdefs.json`, builds sorted "Name (ID)" list, returns `""` gracefully on first run before API sync
* Persist last-used adventure ID, patron ID, and event chest ID across sessions — stored in settings, pre-filled in respective pickers on next use
* Patron picker now pre-selects the last-used patron; chest picker now pre-selects the last-used event chest
* Bump `SettingsCheckValue` to 27 with 3 new settings keys: `lastadvid`, `lastpatronid`, `lastchestid`

## 3.81

* Fix Event tab not showing data — `CheckEvents()` iterated `event_details` as array but API returns single object; now reads `events_details.active_events` (main event) and `event_details` (mini-event) correctly
* Event tab now shows both Main Event and Mini Event sections with type labels, heroes, chests, and token counts
* Look up event name and token name from `defines.event_v2_defines` (e.g. "The Great Modron March", "Rusted Gears")
* Fix `EpochToLocalTime()` producing future timestamps for UTC+ timezones — naive `A_Now - A_NowUTC` subtraction broke across day boundaries; now uses `EnvSub` date math
* Restructure `idledict.json` champions and campaigns from position-indexed arrays to ID-keyed objects (matching chests/patrons/feats) — easier to manually edit and enables future dictionary sync improvements
* Dictionary sync now extracts champion names from `getuserdetails` defines (upgrade tip_text and loot effect descriptions) as supplement when `getDefinitions` `champion_defines` is outdated for newer heroes

## 3.80

* Fix RunDisableTooltips reading wrong hwnd variable (`hcbx11` → `hcb11`) — tooltip toggle was broken
* Fix Variants tab using undefined `patronChoice` — add GuiControlGet to read `VariantPatronChoice` DDL
* Fix CrashProtect timer checking wrong status string (`Crash Protect\nDisabled` → `Crash Protect: Disabled`) — disable was not stopping the loop
* Fix DPAPI silent plaintext fallback — warn user via log and status bar when DPAPI is unavailable
* Add UrlEncode() helper (RFC 3986) and apply to redeem code path — replaces partial `&`/`#`-only encoding
* Fix CHANGELOG.md markdownlint MD037 errors — wrap glob patterns in backticks
* Add WriteJsonAtomic() parse-back validation — comment claimed it, now implementation matches
* Fix TestMode global declaration — explicit `global TestMode` before conditional set (removes fragile ordering)
* Deduplicate error parsing in GetPlayServerFromWRL — reuse CheckServerCallError() instead of inline copy
* Refactor UpdateICSetting to use WriteJsonAtomic() — removes inline temp-write/replace duplicate
* Add BuildAuthParams() helper — consolidates 12 repeated auth query string constructions
* Consolidate 5 web opener functions into thin wrappers calling shared OpenWebTool()
* Fix champion stats (Black Viper, Torogar, D'hani, Zorbu) missing magnitude suffixes — use FormatMagnitude()
* Update USER_MANUAL.md — move Pity Timers/Item Levels/Incomplete Variants from menu to tab section; fix dictionary menu label
* Fix CODE_DEPLOY.md — CI trigger description now mentions push (not just PRs)
* Fix bug-report.md issue template — replace Browser field with AHK Version and IdleCombos Version
* Fix publish.yml — curl now fails on non-2xx Discord webhook responses
* Add ci.yml least-privilege permissions block (`contents: read`)
* Add lint, syntax check, and version validation to release.yml (was tests-only)
* Fix Log tab not scrolling to bottom — `Edit2` ClassNN was stale after AutoRefresh edit added; use hwnd + DllCall(EM_SETSEL/EM_SCROLLCARET) instead
* Update CODE_FLOW.md — 61 stale line references updated to match current source; remove Pity Timers from Chests menu (now a tab); version v3.78 → v3.80
* Fix DPAPI graceful fallback — probe round-trip at startup, skip encryption when unavailable (hash stored as plaintext instead of being wiped)
* Fix DPAPI decryption failure clearing UserID and auto-clearing stale encrypted hash from settings
* Fix CheckAchievements showing misleading Todo items when data is empty/loading (guard on highest_level_gear)
* Fix cached data loading overwriting DPAPI failure warning in status bar (skip cache when UserID = 0)
* Fix FirstRun now asks which platform (Epic/Steam/Standalone/Console) before detecting game install
* Fix FirstRun auto-fetches user details from API after successful credential setup
* Fix ByRef not working on object properties in ParseInventoryDataFromDetails — inline DefaultToZero check
* Fix RequireKey() calling LogFile() (app-only function) from IdleCombosLib.ahk — broke test loading
* Fix test_GrandTour assertion updated to match API-synced campaign name "A Grand Tour of the Sword Coast"
* Fix test_Extract_NumericCoercion using local variable for id+0 coercion pattern
* Add DPAPI test environment guards — skip encrypt/round-trip tests when CryptProtectData unavailable
* Add ServerName allowlist validation in ServerCall() — reject names not matching `^(master|ps[0-9]+)$`
* Add SHA-256 checksums (SHA256SUMS.txt) to release workflow artifacts
* Add defensive .gitignore patterns for `.env`, `*.pem`, `*.key`, `*.pfx`, `*.crt`, `webRequestLog.txt`
* Add DictGet() helper for numeric-coerced dictionary lookups
* Add OpenChestIfGameClosed() shared guard for silver/gold/event chest opening
* Add EnsureCredentials() helper — replaces 6 repeated "Need User ID & Hash" blocks
* Add BlacksmithContractsUsed() helper — deduplicates contract calculation in error/success paths
* Replace deprecated Discord webhook actions (node20 deprecation) with curl-based notification
* Add CI push trigger for master/develop branches
* Remove unused journal.json placeholder from .gitignore and AGENTS.md
* Document dictionary update TOFU risk assessment in SECURITY.md
* Refactor repeated credential checks into shared EnsureCredentials() helper and deduplicate open-chest guard logic
* Add DictGet() helper for numeric-coerced dictionary lookups and simplify blacksmith contract usage calculation
* Add CI push trigger for master/develop and remove unused journal.json placeholder from ignored/runtime docs
* Add Pity Timers tab — champions grouped by chests-until-epic (was menu-only dialog)
* Add Item Levels tab — gear iLvl report with core/event averages, highest/lowest, shinies (was menu-only dialog)
* Add Incomplete Variants tab — patron-filterable adventure completion tracker with in-tab refresh (was menu-only dialog)
* Add "Sync Dictionary from API" — fetches live champion, chest, campaign, patron, and feat definitions from the game API, diffs against local dictionary, previews changes, and merges with backup (Help menu)
* Tab count: 8 → 11
* Display "Map" instead of "-1" for adventure ID when on the world map
* Add "Show API Messages in Status Bar" setting to toggle verbose parsing/API progress messages
* Improve save dialogs: show what's being saved and target filename (was vague "Save to File?")
* Add numeric input validation to all chest/blacksmith/bounty count prompts (reject non-integer, zero, negative)
* SettingsCheckValue bumped to 25 (new: showapimessages)
* Add USkin.dll SHA-256 hash verification before DllCall("LoadLibrary") — blocks tampered binaries
* Add try/catch + atomic write (temp file → rename) to ViewICSettings/UpdateICSetting
* Add dictionary update downgrade rejection — downloaded version must be >= current
* Mask user hash fully as `****` in List User Details (was showing first/last 4 chars)
* Add WRL file path validation — reject paths outside game/script directory
* Extract 6 Parse*Data() functions to IdleCombosLib.ahk as testable pure versions
* Add tests/test_parsing.ahk with 51 new tests covering all extracted parsing functions
* Refactor game detection: shared tryDetectPlatform() with platform descriptor table replaces 4 near-identical functions
* Untrack advdefs.json — add to .gitignore (was creating dirty working trees)
* Fix release packaging: include Lib/ScrollBox.ahk in archives (app failed to launch without it)
* Make release.yml run tests before packaging (new test job with needs: dependency)
* Fix CI: pin AutoHotkey Chocolatey version to 1.1.37.1 (1.1.37.02 was delisted)
* Fix CI: exclude vendored Lib/Yunit/ from markdownlint (14 false-positive errors)
* Fix CI: change trigger from push+PR to PR-only
* Add retention-days: 30 to CI JUnit artifact upload
* Add USER_MANUAL.md — comprehensive user guide with feature reference, settings, hotkeys, and troubleshooting
* Add CODE_DEPLOY.md — release pipeline documentation
* Add Documentation section to README.md linking all project markdown docs
* Self-host README screenshots (Summary, Adventures, Inventory, Settings) — was single external Imgur link
* Add shared PromptCount() helper for InputBox validation across all batch operations
* Add BeginBusyOp()/EndBusyOp() guard wrapper — fixes bug where cancelling InputBox permanently locked IsBusy
* Remove dead code: ShowPityTimers(), GearReport(), IncompleteVariants/Base/Patron() replaced by tabs (~196 lines)
* Remove redundant menu items moved to tabs (Pity Timers, Item Level Report, Incomplete Variants)
* Remove 15 commented-out debug MsgBox/ScrollBox lines and stale code blocks
* Add live ticking timestamp in sidebar — shows elapsed time (Xs, Xm Xs, Xh Xm, Xd Xh) updated every second
* Fix "Map" adventure display breaking LoadAdventure/EndAdventure checks (still compared against "-1")
* Fix cached user details not setting ActiveInstance/InstanceID before parsing (adventures showed in wrong slots)
* Fix sidebar relative time using local time instead of UTC (showed timezone offset as elapsed time)
* Expand THIRD_PARTY.md: USkin.dll provenance, AGPL/MIT Yunit boundary, ScrollBox location
* Add USER_MANUAL.md to release archives
* Add AGENTS.md convention: always update CHANGELOG.md after making changes
* Rename Help menu "Update Dictionary" to "Update Dictionary from Git" for clarity
* Use full patron display names from dictionary (e.g. "Mirt the Moneylender") in Patrons tab, dropdown, CSV export
* Derive patron dropdown, patronMap, and ListView from dictionary via BuildPatronDropdownList()/BuildPatronDisplayMap() — no more hardcoded patron name lists
* Add PatronShortNames/PatronIDs shared constants in IdleCombosLib.ahk — single source of truth for adding new patrons
* Bump dictionary version to 2.42
* Add tests/test_dictionary_sync.ahk with 42 unit tests covering definition extraction, diffing, preview, merge, and feat formatting
* Fix USkin.dll hash verification fail-open — now blocks DLL load when hash cannot be parsed (was silently loading unverified binary)
* Fix SETTINGS_SCHEMA.md stale: updated from 23 to 25 keys, added autorefreshminutes and showapimessages rows
* Fix CODE_FLOW.md version drift: v3.78 → v3.80
* Fix THIRD_PARTY.md version drift: v3.79 → v3.80
* Fix CODE_DEPLOY.md: CI trigger description corrected from push+PR to PR-only
* Add Lib/ScrollBox.ahk to README.md Includes section and CONTRIBUTING.md Project Structure
* Add SETTINGS_SCHEMA.md cross-link to CONTRIBUTING.md Version Bumping section
* Add export CSV pattern to .gitignore (idlecombos_export_*.csv)
* Refactor: use EndBusyOp() consistently in Buy_Chests/Open_Chests/UseBlacksmith (was manually setting IsBusy := false, missing cleanup on early returns)
* Refactor: bg1/bg2/bg3 instance assignment from 3 identical 8-field blocks to single loop with dynamic slot key
* Refactor: blacksmith contract switch to data-driven metadata object (buff_id → name/variable mapping)
* Refactor: extract FormatMagnitude() helper in IdleCombosLib.ahk — replaces 10 inline SubStr+Format+log+MagList expressions across champion stats, adventure core XP, and patron influence/coins
* Refactor: extract WriteJsonAtomic(filePath, obj) shared helper — used by PersistSettings() and WriteDictionaryJson()
* Add idledict.json JSON validity check to CI (validate job) — catches malformed dictionary before merge
* Add comment headers to all functions in IdleCombosLib.ahk — improved descriptions for all lookup, parsing, and sync functions
* Refactor: patron unlock requirements from 5 near-identical case branches to table-driven descriptor (unlockReqs map)
* Refactor: bounty/blacksmith contract metadata into shared BountyContracts/BlacksmithContracts constants in IdleCombosLib.ahk — single source of truth for names, buff IDs, and multipliers used by inventory parsing, GUI display, CSV export
* Add SafeGet(obj, keys*) and RequireKey(obj, keys*) helpers for safe nested object traversal — fail-fast on missing API paths with LogFile warning
* Encrypt API hash at rest using Windows DPAPI (CryptProtectData) — hash in idlecombosettings.json is now stored as hex ciphertext with "DPAPI:" prefix instead of plaintext
* Auto-migrate existing users: plaintext hashes are detected on load, used as-is, then encrypted and re-saved transparently with zero user action
* Add DPAPIEncrypt/DPAPIDecrypt/IsEncryptedHash helpers to IdleCombosLib.ahk with 18 unit tests (round-trip, passthrough, migration, edge cases)
* Update SECURITY.md: document DPAPI encryption, migration flow, and per-field encryption rationale
* Add comment headers to all functions and label handlers in IdleCombos.ahk (~100 functions documented)
* Update all markdown docs to reflect v3.80 codebase: AGENTS.md, SECURITY.md, CODE_DEPLOY.md, CODE_FLOW.md, THIRD_PARTY.md, USER_MANUAL.md, README.md, CONTRIBUTING.md, SETTINGS_SCHEMA.md

## 3.79

* Add USER_MANUAL.md — comprehensive user guide with feature reference, settings, hotkeys, and troubleshooting
* Add CODE_DEPLOY.md — release pipeline documentation (CI → tag → draft → publish)
* Add Documentation section to README.md linking all project markdown docs
* Add USER_MANUAL.md to release archives (release.yml)
* Fix release packaging: include Lib/ScrollBox.ahk in archives (app failed to launch without it)
* Fix CI: pin AutoHotkey Chocolatey version to 1.1.37.1 (1.1.37.02 was delisted)
* Fix CI: exclude vendored Lib/Yunit/ from markdownlint (14 false-positive errors)
* Fix CI: change trigger from push+PR to PR-only
* Fix CODE_DEPLOY.md markdownlint errors (MD004 dash→asterisk, MD029 ordered list prefix)

## 3.78

* Fix Web Codes feature (site layout changed, old method broken)
* Replace deprecated Internet Explorer COM with XMLHTTP for code fetching
* Simplify Codes window: single "Load Web" button replaces Recent/Special/Permanent
* Load Web now extracts all active codes matching the site's "Copy ALL Recent Active Codes" button
* Remove unused Ctrl+M, Ctrl+N, Ctrl+E, Ctrl+P hotkeys
* Fix infinite loop in ServerCall play server redirect (only redirect if target differs)
* Fix stray brace in GetUserDetails causing data not to display after load
* Fix ParsePlayServerName using legacy assignment (= vs :=) breaking JSON response parsing
* Restore UTF-8 BOM to IdleCombos.ahk (required for emoji rendering in status bar)
* Upgrade all API calls from HTTP to HTTPS
* Redact user hash from log output for security
* Fix typo: `swtichPlayServer` → `switchPlayServer`
* Fix impossible range condition in FeatFromID (id >= 746 and id <= 726 → 784)
* Fix malformed condition in ChestIDFromChampID (id <= id < 154 → id <= 154)
* Fix duplicate case "539" in FeatFromID (unreachable second entry)
* Pin all GitHub Actions to SHA hashes; upgrade checkout to v4
* Add dictionary update integrity verification (download to temp, validate before replacing)
* Settings migration now merges new keys instead of deleting user settings
* Mask user hash in "List User Details" display
* Remove dead code: ServerCallNew, ServerCallAlt, UseBounty2, CustomMsgBox, StrReverse
* Extract pure functions to IdleCombosLib.ahk (shared between app and tests)
* Add Yunit test framework with 67 unit tests
* Add CI pipeline: markdownlint, AHK syntax check, unit tests on push/PR
* Add LICENSE (MIT), CONTRIBUTING.md, .markdownlint.json
* Convert idledict.ahk from 1530-line switch blocks to JSON data file (idledict.json)
* Dictionary update now downloads JSON instead of executable AHK code (security improvement)
* Fix Unicode characters (Môrgæn, Faerûn, Corazón) now display correctly in dictionary
* Fix JSON dictionary key lookups (numeric coercion for map access)
* Fix release packaging: add idledict.json, IdleCombos.ico, LICENSE to archives (was shipping broken)
* Fix ci.yml: replace stale idledict.ahk syntax check with IdleCombosLib.ahk
* Fix stale idledict.ahk references in README.md and CONTRIBUTING.md
* SHA-pin all CI workflow actions (checkout, markdownlint, upload-artifact)
* Add CI version-string consistency check (IdleCombos.ahk vs README.md)
* Add .gitignore entries for campaign.json, formationimages/
* Fix 268 markdownlint errors across all project-owned markdown files
* Add SECURITY.md documenting credential threat model and supply chain risks
* Add THIRD_PARTY.md inventorying all vendored assets with SHA-256 hashes
* Add SETTINGS_SCHEMA.md documenting settings key history and bump procedure
* Add provenance header to json.ahk (source URL, license, SHA-256)
* Make PersistSettings() atomic (write temp file, then rename)
* Add try/catch to JSON.parse() on critical paths (dictionary init, settings load, dictionary update, Epic detection)
* Add TestMode global to suppress MsgBox/ExitApp in test context
* Add MockServerCall mechanism for testable API-handling code (6 new tests)
* Move SettingsCheckValue, NewSettings, DummyData constants to IdleCombosLib.ahk (dedup)
* Extract ScrollBox to Lib/ScrollBox.ahk with provenance header
* Add IsBusy reentrancy guard on Buy_Chests, Open_Chests, UseBlacksmith
* Add RotateLogFile() helper; applied to chest, blacksmith, bounty logs
* Add BatchAPICall() helper to deduplicate chest/blacksmith batch loops
* Patron GUI/parsing/progress deduplication: 5 copy-pasted blocks replaced with data-driven loop
* Game detection deduplication: applyGameInstall() helper replaces repeated state assignment
* IC Settings deduplication: UpdateICSetting() shared helper (SetUIScale, SetFramerate, SetParticles)
* Extract ParseWRLCredentials() to lib: pure credential parsing from WRL text (8 new tests)
* Extract EpochToLocalTime() to lib: timestamp conversion (3 new tests)
* Extract SimulateBrivCalc() to lib: pure Briv stack math (6 new tests)
* Extract DefaultToZero() to lib: zero-defaulting helper (4 new tests)
* Bump dictionary version to 2.41
* Total: 93 unit tests (up from 67)
* Convert Adventures, Inventory, Patrons, Champions, Event tabs from Text to ListView controls
* Convert Summary tab to dual-section ListView (Account Stats + Blessings)
* Summary tab shows contextual state: setup required, loading, or full data
* Redesign Settings tab: two-column layout with separator, wider dropdowns
* Add 2px padding around all tab ListView controls
* GUI default width increased from 600 to 850 to fit ListView columns
* GUI default height increased from 275 to 425
* Resize handler simplified: one MoveDraw per ListView replaces ~25 individual calls
* Adventures Core column split into Core, XP, Progress columns
* Inventory tab: section separators between Currency, Chests, Bounties, Blacksmiths
* Inventory Details column populated on every row (token/iLvl rates, totals)
* Patrons: cleaned up Requires/Costs columns (shorter labels, checkmark when met)
* Champions tab: ListView with Champion, Stat, Value columns
* Event tab: ListView with Detail, Value columns
* Default to "None" when modron core name not in data
* Blacksmith results dialog offers "Copy to clipboard?"
* Chest buy confirmation shows gem count and cost per chest
* Last Updated shows relative time ("5 min ago")
* Sidebar buttons (Reload, Update, Toggle) disabled during IsBusy operations
* Add Ctrl+R hotkey for refresh (GetUserDetails)
* Restore AHK version display in status bar
* Progress bar (status bar %) during bulk chest buy, chest open, and blacksmith operations
* Auto-refresh on configurable timer (Settings: Auto Refresh Minutes, default off)
* Export inventory and patron data to CSV (Tools → Export to CSV)
* TrayTip notification when Time Gate Piece is ready
* ServerCall retry with exponential backoff (3 attempts, 1s→2s→4s)
* Cache UserDetails between sessions (loads cached data on startup, 1-hour TTL)
* Non-blocking: Sleep calls in batch loops allow GUI message pump processing
* SettingsCheckValue bumped to 24 (new: autorefreshminutes)

## 3.77

* Increase Blacksmith calls from 50 to 1000
* Fix dictionary ID search for efficiency
* Add Umberto to dictionary
* Update dictionary with Umberto chests
* Add Bobby to dictionary
* Update dictionary with Bobby chests
* Add Kas to dictionary
* Update dictionary with Kas chests

## 3.76

* Add Elminster GUI (Thanks to koe, Sorry for missing this!)
* Add Duke Ravengard to dictionary
* Update dictionary with Duke Ravengard chests
* Add Aeon to dictionary
* Update dictionary with Aeon chests

## 3.75

* Add Elminster to dictionary (Thanks to koe)
* Update multiple dictionary Campaign From IDs (Thanks to koe)
* Add Redeem Code History
* Skip codes already in Redeem Code History
* Resubmit codes if the result JSON is missing required properties
* Add setting to disable skipping Redeem Codes
* Add Gale to dictionary
* Update dictionary with Gale chests
* Add Diana to dictionary
* Update dictionary with Diana chests

## 3.74

* Add The Dark Urge to dictionary
* Update The Dark Urge with Presto chests
* Update the icon to a greyscale version

## 3.73

* Redraw the GUI to enable dynamic resizing

## 3.72

* Add mouse over tooltips

## 3.71

* Change patron challenges from 10 to 8
* Add theme system

## 3.70

* Add Max Champion ID and Max Chest id to the dictionary file as globals

## 3.69

* Add Presto to dictionary
* Update dictionary with Presto chests
* Add Dynaheir to dictionary
* Update dictionary with Dynaheir chests

## 3.68

* Add Karlach to dictionary
* Update dictionary with Karlach chests

## 3.67

* Add Shadowheart to dictionary
* Update dictionary with Shadowheart chests
* Add Wyll to dictionary
* Update dictionary with Wyll chests

## 3.66

* Fix incorrect variable in 'switch_play_server' in server calls

## 3.65

* Detect 'switch_play_server' in server calls

## 3.64

* Fix chest ID's for buy/redeem
* Increase chest buy limits from 100 to 250

## 3.63

* Add support for consoles
* Catch JSON parse errors on loading user details

## 3.62

* Add counts in redeem codes
* Add server detection in redeem codes
* Add bounty contract warning
* Add more bounty contract logging
* Updates to inventory tab layout
* New settings to disable blacksmith contracts results
* New settings to disable loading user data
* Add server detection in buy chests
* Updates to buy chests message box width
* Increase chest open max to 1000

## 3.61

* This update is brought to you by [Emmotes](https://github.com/Emmotes)
* Add Astarion to dictionary
* Update dictionary with Astarion chests
* Add Commodore Krux to dictionary
* Update dictionary with Commodore Krux chests
* Add Certainty Dran to dictionary
* Update dictionary with Certainty Dran chests
* Add Thellora to dictionary
* Update dictionary with Thellora chests
* Add Jang Sao to dictionary
* Update dictionary with Jang Sao chests
* Update dictionary with many more chests

## 3.60

* Add WebRequestLog file to settings
* Fix play server detection when swapping clients

## 3.59

* Fix bug with data loading due to new changes in API

## 3.58

* Add Vin Ursa to dictionary
* Add Lae'zel to dictionary

## 3.57

* Add Nixie to dictionary
* Update dictionary with Nixie chests
* Add Evandra to dictionary
* Update dictionary with Evandra chests
* Add BBEG to dictionary
* Update dictionary with BBEG chests
* Add Strongheart to dictionary
* Update dictionary with Strongheart chests
* Minor text updates

## 3.56

* Update dictionary with Solaak and Antrius chests
* Add buttons to the redeem codes gui to auto load and run chest codes

## 3.55

* Better server detection and option to disable server detection

## 3.54

* Bounty Contracts fixed and tuned

## 3.53

* Log new play server detection
* Focus tabs on launch

## 3.52

* Move changelog to its own file
* Better play server detection
* Detection of server error

## 3.51

* Fix event chests max buy amount
* Update dictionary with Miria chests

## 3.50

* README update
* Add discord link
* Add github link

## 3.49

* Detect play server from log
* Option to show tab as default
* Test new redeem codes auto load

## 3.48

* Update server name to ps20

## 3.47

* Update dictionary
* Update max hero id

## 3.46

* Add support for bounty contracts via gui

## 3.45

* Revert server call to see if its faster
* Change default server name from 'ps7' to 'master'

## 3.44

* Revert redeem codes
* Add default values to chest prompts
* Change server call to see if its faster

## 3.43

* Update redeem codes as website has changed

## 3.42

* Remove tool windows to give back taskbar visibility

## 3.41

* Fix redeem codes starting with '#' not working

## 3.40

* Fix cancel of buy/chests window

## 3.39

* Update hotkeys

## 3.38

* Add hotkeys
* Add list hotkeys to menu
* Fix open event chest counts

## 3.37

* Update switch statement to fix error with older versions
* Add ahk version to status bar

## 3.36

* new tab: event
* basic testing - buy chests event
* basic testing - open chests event

## 3.35

* Remove style system to fix dangerous file warning in chrome (3rd party dll)

## 3.34

* Fix message box background colours with styles

## 3.33

* Add style support
* Add styles: ayofe, lakrits, luminous, mac, paper

## 3.32

* Save last loaded game client
* Add buy chests event
* Add open chests event
* Add list chest ids
* Store blacksmith contract last used count
* Update buy/open chests menu hotkeys
* Update blacksmith contracts menu hotkeys
* Increase the font size of the "List Champ IDs"
* Increase the font size of the "List User Details"

## 3.31

* Add warduke to dictionary
* Add imoen to dictionary
* Add missing chests to dictionary

## 3.30

* Support for standalone game and launcher

## 3.29

* Add virgil to dictionary
* Add missing chests to dictionary
* Add missing champ ids to chest ids to dictionary
* Hide unknown characters from pity timers

## 3.28

* Add egbert to dictionary
* Add kent to dictionary

## 3.27

* Fix pity timers due to change in json structure

## 3.26

* Overhaul logging system
* Major manual syntax cleanup
* Fix double user details loading bug
* Update icon
* Change to init loading class
* Emojis on status bars
* Champions tab using human readable numbers
* Patron tab spacing

## 3.25

* patron tab bugs fixed
* patron tab added current influence and coins
* remove old files

## 3.24

* Add menu item to show User Details: UID, Hash, Platform
* Update message boxes to have selectable text so we can copy and paste
* Add web tool - SoulReaver Data Viewer
* Fix CNE Open Ticket using correct Steam/Epic ID's and hashes

## 3.23

* Update performance parsing in adventure list (thanks Fmagdi)
* Automatic workflow to make releases

## 3.22

* Add voronika to dictionary
* Add menu items to detect game folder
* Code syntax formatting

## 3.21

* Add valetine to dictionary
* Update redeem code results order
* Add 'how to run' in README.md

## 3.20

* Add working detection for Epic Games installation
* Update to Redeem Codes
* Automation to retrieve Redeem Codes via web
* Add minimum GUI windows sizes
* Other minor fixes

## 3.10

* Add working core 4 and party 4 (thanks Fmagdi)
* Hopeful fix for opening to many chest ban (thanks deathoone)
* Support for huge contracts (thanks NeyahPeterson)

## 3.00

* Disabled log files by default

------

## 2.00

### 2/15/22 servers settle down, reduce timer to .5 secs for Chest

* Open routine
* Work to clean up chest open message box with help from community
* TODO - Note community help names from discord.
* Work to clean up menu so links work in progress, most of it backed Out
* Due to a weird git conflict that would never resolve and roll back to earlier
* Client. including most of the work that had been done to limit log files locally
* Once steam idlecombos working merge recent changes into egs client, and maybe
* Make the dhani paint work. Or focus Idlecombos.

------

## 1.98

* Update idledict content
* Added NERDS as evergreen for equipment screen

## 1.97

* Include fixes for single instance from mikebaldi

## 1.96

* Update dict file to latest content and versioned to 1.96

## 1.95

* Disabled opening chest while client is open

## 1.94

* Updated Cleaned up UI around redeam codes with mikebaldi1980 Help
* Added in party 3 and core 3 with code from HPX
* Updated Eunomiac code to copy and find code from discord combination channel
* Should be robust enough to find chest code in most channel but haven't verified

## 1.93

* More work to clean up window for combination code.

## 1.92

* Added Eunomiac code to copy and find code from discord combination channel

## 1.91

* Added DeathoEye Server update
* Neal's Json escape code for redeeming codes
* Updated dict file to 1.91 champs, chest and feats up to UserDetailsFile

## 1.90

* Patron Zariel
* Dictionary file updated to 1.9

## 1.80

* Pity Timer for Golds on Inventory Tab
* Event Pity Timers in the Chests menu
* More info on number of tokens/FPs available
* Kleho image now works for Events & TGs
* Fix for "Chests Opened: 0" in log output
* Dictionary file updated to 1.8
* (Also resized the window finally) :P
