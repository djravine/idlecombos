# User Manual

> IdleCombos v3.78 — Companion App for Idle Champions

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [First Run](#first-run)
* [Interface Overview](#interface-overview)
* [Tabs](#tabs)
* [Sidebar Controls](#sidebar-controls)
* [Menu Reference](#menu-reference)
* [Keyboard Shortcuts](#keyboard-shortcuts)
* [Settings](#settings)
* [Features In Depth](#features-in-depth)
* [Log Files](#log-files)
* [Themes](#themes)
* [Troubleshooting](#troubleshooting)
* [Security](#security)

## Requirements

* Windows (required for COM objects and native GUI)
* [AutoHotkey v1.1](https://www.autohotkey.com/download/ahk-install.exe) — **not** v2
* An Idle Champions account with `user_id` and `hash` credentials
* One of: Steam, Epic Games, Standalone, or Console installation

## Installation

1. Download a [release archive](https://github.com/djravine/idlecombos/releases) or clone the repo
2. If downloaded, unzip into any folder
3. Install [AutoHotkey v1.1](https://www.autohotkey.com/download/ahk-install.exe) if not already present
4. Right-click `IdleCombos.ahk` and select **Open with AutoHotkey**

The app forces 32-bit mode at startup (required for WinHttp COM). If your system has both 32-bit and 64-bit AutoHotkey installed, the correct version is selected automatically.

## First Run

On first launch the setup wizard runs automatically:

1. **Game Detection** — the app scans for your Idle Champions installation:
   * Epic Games (checks `LauncherInstalled.dat`)
   * Steam (checks default `C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\`)
   * Standalone (checks `C:\Program Files (x86)\Idle Champions\`)
2. **WRL File** — if a `webRequestLog.txt` is found in the app folder or game directory, you are prompted to extract credentials from it
3. **Credentials** — your `user_id` and `hash` are saved to `idlecombosettings.json` (local only, never sent anywhere except the official game API)

If auto-detection fails, you can manually enter your credentials or re-run setup later via **Help → Run Setup**.

## Interface Overview

The app window is divided into three areas:

```text
┌─────────────────────────────────────────┬────────────────┐
│  Tab Content Area                       │  Sidebar       │
│  (Summary, Adventures, Inventory, etc.) │  [Reload][Exit]│
│                                         │  Crash Protect │
│                                         │  Data Timestamp│
│                                         │  [Update]      │
├─────────────────────────────────────────┴────────────────┤
│  Status Bar                                    AHK v1.1  │
└──────────────────────────────────────────────────────────┘
```

The window is resizable. All tab content scales to fit.

## Tabs

### Summary

Displays account statistics after loading user data:

* **Account stats** — Highest Gear Level, Champions Unlocked/Active, Familiars, Costumes, Epic Gear count
* **Incomplete achievements** — items still needed (shown as "Todo" rows)
* **Blessing multipliers** — calculated values for Slow and Steady (Helm), Familiar Faces, Splitting the Party, Veterans of Avernus, Costume Party (Auril), Familiar Stakes (Corellon)

Before data is loaded, the tab shows a prompt to run setup or press Update.

### Adventures

Shows all active adventure instances in a grid:

| Column | Description |
|--------|-------------|
| Instance | Foreground, Background 1/2/3 |
| Adventure | Current adventure name |
| Patron | Active patron (if any) |
| Area | Current area number |
| Champions | Active champion names |
| Core | Modron core name |
| XP | Core experience |
| Progress | Core automation progress |

### Inventory

Complete inventory breakdown in three sections:

**Currency**

* Gems (with conversion: how many Silver or Gold chests you can buy)
* Spent Gems (lifetime)

**Chests**

* Gold Chests (with gold pity timer info)
* Silver Chests
* Time Gate Pieces (with count of full Time Gates and next drop info)

**Bounty Contracts**

* Tiny (12 tokens), Small (72), Medium (576), Large (1,152) bounty contracts
* Total token value and equivalent Free Plays

**Blacksmith Contracts**

* Tiny (1 iLvl), Small (2), Medium (6), Large (24), Huge (120) contracts
* Total item levels available

### Patrons

Grid showing progress for all five patrons:

| Column | Description |
|--------|-------------|
| Patron | Mirt, Vajra, Strahd, Zariel, Elminster |
| Variants | Completed variant adventures |
| Completed | Total completed |
| FP Currency | Free play currency balance |
| Challenges | Weekly challenge progress |
| Influence / Requires | Current influence and requirements |
| Coins / Costs | Patron coin balance and costs |

### Champions

Tracks lifetime statistics for specific champions:

* **Black Viper** — Red Gems collected
* **Morgaen** — Gold collected
* **Torogar** — Zealot Stacks
* **D'hani** — Monsters Painted
* **Zorbu** — Kill counts (Humanoid, Beast, Undead, Drow)

Values are displayed with magnitude suffixes for large numbers.

### Event

Shows the current active event (if any):

* Event name, ID, description
* Event token name and count
* Event heroes
* Event-specific chests

When no event is active, displays "No Event".

### Settings

All configurable options (see the [Settings](#settings) section below for details).

### Log

Read-only text log of all app activity during the current session. Useful for debugging API calls or verifying operations completed successfully.

## Sidebar Controls

| Control | Description |
|---------|-------------|
| **Reload** | Restarts IdleCombos (full script reload) |
| **Exit** | Closes the application |
| **Crash Protect** | Toggle game crash detection (see [Crash Protection](#crash-protection)) |
| **Data Timestamp** | Shows when data was last fetched, with relative time ("5 min ago") |
| **Update** | Fetches fresh user data from the game API |

Sidebar buttons are disabled during bulk operations (buying/opening chests, applying contracts) to prevent conflicts.

## Menu Reference

### File

| Item | Description |
|------|-------------|
| Idle Champions Settings → View Settings | Display game's `localSettings.json` |
| Idle Champions Settings → Framerate | Change the game's target framerate |
| Idle Champions Settings → Particles | Adjust particle effects level |
| Idle Champions Settings → UI Scale | Change the game's UI scale |
| Launch Game Client | Start Idle Champions via detected platform |
| Update UserDetails | Fetch account data from API |
| Detect Game — Epic/Steam/Standalone/Console | Re-run platform detection |
| Reload IdleCombos | Restart the app |
| Exit IdleCombos | Close the app |

### Tools

| Item | Description |
|------|-------------|
| **Chests** | |
| Buy Silver / Gold / Event | Purchase chests with gems or event tokens |
| Open Silver / Gold / Event | Open owned chests (game client must be closed) |
| Pity Timers | Show gold chest pity timer info |
| **Blacksmith** | |
| Use Tiny / Small / Medium / Large / Huge | Apply blacksmith contracts to a champion |
| Item Level Report | Show gear item levels for all champions |
| Active Patron Feats | List feats active under current patron |
| **Bounty (Alpha)** | |
| Use Tiny / Small / Medium / Large | Apply bounty contracts (requires 1280x720, mouse automation) |
| **Redeem Codes** | Enter codes manually or load from web |
| **Adventure Manager** | |
| Load New Adv | Start a new adventure via API |
| End Current / Background 1-3 Adv | End adventures via API |
| Kleho Image | Open Kleho adventure image |
| Incomplete Variants | List variants not yet completed |
| Update Adventure List | Refresh adventure definitions from API |
| **Briv Stack Calculator** | Calculate skip probabilities and stack times |
| **Export to CSV** | Save inventory and patron data to CSV file |
| **Web Tools** | Open external community tools in browser |

### Help

| Item | Description |
|------|-------------|
| Run Setup | Re-run the first-run setup wizard |
| Clear Log | Clear the activity log |
| Clear Redeem Code History | Reset the list of previously redeemed codes |
| Update Dictionary | Download latest champion/chest definitions from GitHub |
| Download Journal | Fetch game journal data |
| List User Details | Show your user ID and masked hash |
| List Champ IDs | Show all champion ID-to-name mappings |
| List Chest IDs | Show all chest ID-to-name mappings |
| List Hotkeys | Show keyboard shortcut reference |
| List Redeem Code History | Show previously redeemed codes |
| About IdleCombos | Version and credits |
| Github Project | Open the GitHub repo |
| Discord Support Server | Open the Discord invite |
| CNE Support Ticket | Open a Codename Entertainment support ticket with your platform IDs |

## Keyboard Shortcuts

### Blacksmith Contracts

| Shortcut | Action |
|----------|--------|
| `Ctrl + Numpad1` | Apply Tiny Blacksmith Contracts |
| `Ctrl + Numpad2` | Apply Small Blacksmith Contracts |
| `Ctrl + Numpad3` | Apply Medium Blacksmith Contracts |
| `Ctrl + Numpad4` | Apply Large Blacksmith Contracts |
| `Ctrl + Numpad5` | Apply Huge Blacksmith Contracts |

### Chest Operations

| Shortcut | Action |
|----------|--------|
| `Ctrl + Numpad/` | Buy Silver Chests |
| `Ctrl + Numpad*` | Buy Gold Chests |
| `Ctrl + NumpadMinus` | Buy Event Chests |
| `Ctrl + Numpad7` | Open Silver Chests |
| `Ctrl + Numpad8` | Open Gold Chests |
| `Ctrl + Numpad9` | Open Event Chests |

### Bounty Contracts

| Shortcut | Action |
|----------|--------|
| `Ctrl + 7` | Apply Tiny Bounty Contracts |
| `Ctrl + 8` | Apply Small Bounty Contracts |
| `Ctrl + 9` | Apply Medium Bounty Contracts |
| `Ctrl + 0` | Apply Large Bounty Contracts |

### General

| Shortcut | Action |
|----------|--------|
| `Ctrl + F5` | Refresh User Details |

## Settings

Access via the **Settings** tab. Click **Save Settings** to persist changes.

### Connection

| Setting | Default | Description |
|---------|---------|-------------|
| Server Name | `master` | API play server. Auto-detected from game files when Server Detection is enabled. |
| Get Play Server Name automatically | On | Reads the game's `webRequestLog.txt` to detect the correct play server. |
| Auto-Refresh Interval | 0 (off) | Automatically refresh user data every N minutes. Set to 0 to disable. |

### Startup

| Setting | Default | Description |
|---------|---------|-------------|
| Get User Details on start | Off | Fetch account data automatically when the app launches. |
| Launch game client on start | Off | Start Idle Champions when the app launches. |
| Tab | Summary | Which tab to show on startup. |

### Logging

| Setting | Default | Description |
|---------|---------|-------------|
| Logging Enabled | Off | Write detailed activity to `idlecombolog.txt`. |
| Always save Chest Open Results | On | Log chest open results to `chestopenlog.json`. |
| Always save Blacksmith Results | On | Log blacksmith results to `blacksmithlog.json`. |
| Always save Code Redeem Results | On | Log code redeem results to `redeemcodelog.json`. |
| Never save results to file | Off | Override: suppress all result logging. |

### Display

| Setting | Default | Description |
|---------|---------|-------------|
| Style | Default | UI theme (requires `styles/` folder with `.msstyles` and `USkin.dll`). |
| Disable Tooltips | Off | Hide mouseover help text on controls. |
| Show Blacksmith Contracts Results | On | Show a dialog with blacksmith results after applying. |

### Other

| Setting | Default | Description |
|---------|---------|-------------|
| Skip Codes in Redeem Code History | On | Skip codes that have already been redeemed (tracked in `redeemcodelog.json`). |
| Disable User Detail Reload (Risky) | Off | Do not auto-refresh data after actions. Data may become stale. |

## Features In Depth

### Buying Chests

1. Go to **Tools → Chests → Buy Silver/Gold/Event** (or use hotkey)
2. Enter the number of chests to buy
3. The app shows your current gem count and cost per chest for confirmation
4. A progress bar appears in the status bar during the operation
5. Chests are purchased in batches via the game API
6. After completion, you are prompted to save results (if logging is enabled)

**Note**: Event chests require entering a Chest ID. Use **Help → List Chest IDs** to find the correct ID.

### Opening Chests

1. **Close the game client first** — the app warns you if the game is running
2. Go to **Tools → Chests → Open Silver/Gold/Event** (or use hotkey)
3. Enter the number of chests to open
4. Progress is tracked in the status bar
5. Results are logged and optionally saved

### Blacksmith Contracts

1. Go to **Tools → Blacksmith → Use [size] Contracts** (or use hotkey)
2. Select a champion to apply contracts to
3. Enter the number of contracts
4. The app applies contracts in batches of up to 1,000
5. Results dialog shows gear level changes (can be copied to clipboard)

### Bounty Contracts (Alpha)

**Warning**: This feature is experimental and fragile.

* Requires the game window at **1280x720** resolution
* Uses mouse automation (ImageSearch + MouseClick) — do not move your mouse during operation
* The game client must be running and visible

### Redeem Codes

1. Go to **Tools → Redeem Codes**
2. Choose one of:
   * **Paste codes** — copy codes to clipboard, then paste into the text box
   * **Load Web** — automatically fetch active codes from the community code site
3. The app extracts valid 12- or 16-character codes, deduplicates them, and strips dashes
4. Previously redeemed codes are skipped if "Skip Codes in Redeem Code History" is enabled
5. Codes are submitted one at a time to the game API
6. Failed codes are automatically retried

### Adventure Manager

* **Load New Adv** — Start a specific adventure by entering the adventure ID
* **End Current/Background Adv** — Terminate an active adventure instance (useful for fixing stuck accounts)
* **Incomplete Variants** — View a list of adventure variants you have not yet completed, filterable by patron
* **Kleho Image** — Open a visual adventure map on the Kleho.ru community site
* **Update Adventure List** — Refresh the local `advdefs.json` from the game API

### Briv Stack Calculator

A mathematical simulator for Briv's skip mechanic:

1. Go to **Tools → Briv Stack Calculator**
2. Enter your Slot 4 item level and target zone
3. The calculator runs a Monte Carlo simulation and reports:
   * Skip levels and true skip chance percentage
   * Average skips, zones, and skip rate per run
   * Estimated Briv stacks and rough completion time

### Export to CSV

Go to **Tools → Export to CSV** to save a snapshot of your inventory, patron progress, and account stats to a timestamped CSV file (`idlecombos_export_YYYY-MM-DD_HHmmss.csv`). You are prompted to open the file after export.

### Crash Protection

Toggle via the sidebar **Toggle** button. When enabled:

* The app monitors the `IdleDragons.exe` process
* If the game crashes or closes, it is automatically restarted
* Works with Steam game client only
* The restart count is shown in the log

Disable crash protection before intentionally closing the game.

### Auto-Refresh

Set a timer interval in Settings (minutes, 0 to disable). When active, the app automatically fetches fresh user data at the configured interval. The refresh is skipped if a bulk operation is in progress.

### Cached Data

On startup, if a cached `userdetails.json` exists and is less than 1 hour old, the app loads it immediately so you see your data without waiting for an API call. A status bar message indicates the cache age. Press **Update** for fresh data at any time.

### Dictionary Updates

The app's champion, chest, and campaign name data comes from `idledict.json`. To get the latest definitions:

1. Go to **Help → Update Dictionary**
2. The file is downloaded from GitHub, validated, and replaced locally
3. The app reloads with updated names

### Game Settings

Via **File → Idle Champions Settings**, you can view and modify the game's local configuration without opening the game:

* **Framerate** — change the target FPS
* **Particles** — adjust particle effect density
* **UI Scale** — change the game's interface scale
* **View Settings** — see the raw `localSettings.json` content

## Log Files

All log files are stored in the app directory and automatically rotated when they exceed 512 KB.

| File | Content | Controlled By |
|------|---------|---------------|
| `idlecombolog.txt` | General activity log | "Logging Enabled" setting |
| `chestopenlog.json` | Chest open results (JSON) | "Always save Chest Open Results" |
| `blacksmithlog.json` | Blacksmith contract results (JSON) | "Always save Blacksmith Results" |
| `bountylog.json` | Bounty contract results (JSON) | Always saved when bounties are used |
| `redeemcodelog.json` | Code redeem results (JSON) | "Always save Code Redeem Results" |
| `redeemcodelist.json` | Cached list of web-loaded codes | Auto-managed |

To clear the activity log: **Help → Clear Log**

To clear redeem code history: **Help → Clear Redeem Code History**

## Themes

If the `styles/` folder is present with `.msstyles` theme files and `USkin.dll`:

1. Go to the **Settings** tab
2. Select a theme from the **Style** dropdown
3. The theme applies immediately
4. Save Settings to remember your choice

30 themes are included in the "themes" release archive. The "no-themes" archive omits them for a smaller download.

The "Default" theme uses the built-in Concave style. Some themes adjust the background colour for better readability (Lakrits, Luminous, Mac, Paper).

## Troubleshooting

### "User ID & Hash not found"

* Run **Help → Run Setup** to re-enter credentials
* Or manually edit `idlecombosettings.json` with your `user_id` and `hash`
* You can find these in the game's `webRequestLog.txt` file

### Game not detected

* Use **File → Detect Game** for your platform
* If installed to a non-default location, the app may not find it automatically
* For Epic Games, ensure the Epic Games Launcher has been run at least once

### API errors or timeouts

* Check your internet connection
* The app retries failed API calls up to 3 times with exponential backoff (1s → 2s → 4s)
* If using a VPN, whitelist AutoHotkey or IdleCombos in your VPN configuration
* Try changing the Server Name in Settings (or enable auto-detection)

### Chests not opening

* Close the game client before opening chests — the app checks for `IdleDragons.exe`
* If the game is running, you see a warning and the operation is cancelled

### Bounty contracts not working

* This feature is alpha-quality and requires specific conditions:
  * Game running at 1280x720 resolution
  * Game window visible and focused
  * Do not move the mouse during the operation
* Consider using blacksmith contracts instead (more reliable, no game window needed)

### Settings reset after update

* Starting with v3.78, settings are migrated non-destructively — new keys are added without overwriting existing preferences
* If your settings file becomes corrupted, the app resets to defaults and shows a warning

### Data shows "No data loaded"

* Press the **Update** button in the sidebar to fetch data
* Or enable "Get User Details on start" in Settings for automatic loading
* If cached data exists (less than 1 hour old), it loads automatically on startup

## Security

* Your `user_id` and `hash` are stored locally in `idlecombosettings.json` — this file is never sent anywhere except the official Idle Champions API server
* The `hash` is masked in the UI and redacted as `[REDACTED]` in log files
* All API communication uses HTTPS
* Dictionary updates are downloaded over HTTPS with integrity validation
* Do not share your `hash` with anyone — it grants full API access to your account
* See [SECURITY.md](SECURITY.md) for the full threat model

## Support

* [Discord Support Server](https://discord.gg/wFtrGqd3ZQ)
* [GitHub Issues](https://github.com/djravine/idlecombos/issues)
* [Changelog](CHANGELOG.md) for version history
