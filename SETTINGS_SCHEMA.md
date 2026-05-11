# Settings Schema

> History of `SettingsCheckValue` increments and the keys they added.

`SettingsCheckValue` (defined in `IdleCombosLib.ahk`) is compared against the count of keys in `idlecombosettings.json` at startup. When they differ, new default keys are merged into existing settings without overwriting user values.

## Current Value: 38

## Schema History

| Value | Version | Keys Added | Notes |
|-------|---------|------------|-------|
| 38 | v3.82 | `lastadvid`, `lastpatronid`, `lastchestid` | Persist last-used adventure, patron, chest picker selections |
| 35 | v3.82 | `lastbschamp`, `lastbstncount`, `lastbssmcount`, `lastbsmdcount`, `lastbslgcount`, `lastbshgcount`, `lastbountytncount`, `lastbountysmcount`, `lastbountymdcount`, `lastbountylgcount` | Persist blacksmith champion + counts, bounty counts across sessions |
| 25 | v3.80 | `showapimessages` | Toggle verbose API/parsing progress in status bar |
| 24 | v3.80 | `autorefreshminutes` | Auto-refresh user details interval (0=off) |
| 23 | v3.78 | `redeemcodehistoryskip` | Skip previously redeemed codes |
| 22 | v3.77 | `disableuserdetailsreload` | Disable auto-reload after actions |
| 21 | v3.76 | `blacksmithcontractresults` | Show/hide blacksmith result dialog |
| 20 | v3.75 | `serverdetection`, `wrlpath` | Auto-detect play server from WRL |
| 18 | v3.70 | `style`, `tabactive` | Theme selection, remembered tab |
| 16 | v3.68 | `user_id_epic`, `user_id_steam` | Multi-platform account support |

*Note: Earlier versions used a destructive reset (delete + recreate) when the count mismatched. v3.78 introduced non-destructive key merging.*

## Current Keys (38 total)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `alwayssavechests` | int | 1 | Auto-save chest open results to log |
| `alwayssavecontracts` | int | 1 | Auto-save blacksmith results to log |
| `alwayssavecodes` | int | 1 | Auto-save code redeem results to log |
| `autorefreshminutes` | int | 0 | Auto-refresh user details interval in minutes (0=off) |
| `blacksmithcontractresults` | int | 1 | Show blacksmith result dialog |
| `disabletooltips` | int | 0 | Hide control tooltips |
| `disableuserdetailsreload` | int | 0 | Skip auto-reload after actions |
| `firstrun` | int | 0 | Has setup wizard completed (1=yes) |
| `getdetailsonstart` | int | 0 | Fetch user details on app launch |
| `hash` | str | 0 | API authentication hash |
| `instance_id` | str | 0 | Game session instance ID |
| `lastadvid` | int | 0 | Last-used adventure ID for picker pre-selection |
| `lastbountytncount` | int | 0 | Last-used Tiny Bounty count |
| `lastbountysmcount` | int | 0 | Last-used Small Bounty count |
| `lastbountymdcount` | int | 0 | Last-used Medium Bounty count |
| `lastbountylgcount` | int | 0 | Last-used Large Bounty count |
| `lastbschamp` | int | 0 | Last-used Blacksmith champion ID |
| `lastbstncount` | int | 0 | Last-used Tiny Blacksmith count |
| `lastbssmcount` | int | 0 | Last-used Small Blacksmith count |
| `lastbsmdcount` | int | 0 | Last-used Medium Blacksmith count |
| `lastbslgcount` | int | 0 | Last-used Large Blacksmith count |
| `lastbshgcount` | int | 0 | Last-used Huge Blacksmith count |
| `lastchestid` | int | 0 | Last-used chest ID for picker pre-selection |
| `lastpatronid` | int | 0 | Last-used patron ID for picker pre-selection |
| `launchgameonstart` | int | 0 | Launch game client on app start |
| `loadgameclient` | int | 0 | Platform: 0=none, 1=Epic, 2=Steam, 3=Standalone, 4=Console |
| `logenabled` | int | 0 | Write activity to idlecombolog.txt |
| `nosavesetting` | int | 0 | Never save results to any log |
| `redeemcodehistoryskip` | int | 1 | Skip codes already in redeem history |
| `serverdetection` | int | 1 | Auto-detect play server from WRL |
| `servername` | str | "master" | API server name |
| `showapimessages` | int | 1 | Show verbose API/parsing progress in status bar |
| `style` | str | "Default" | UI theme name |
| `tabactive` | str | "Summary" | Tab shown on startup |
| `user_id` | str | 0 | Idle Champions user ID |
| `user_id_epic` | str | 0 | Epic Games account ID |
| `user_id_steam` | str | 0 | Steam account ID |
| `wrlpath` | str | "" | Path to webRequestLog.txt |

## How to Add a New Setting

1. Add the key with default value to `NewSettings` in `IdleCombosLib.ahk`
2. Increment `SettingsCheckValue` by 1 in `IdleCombosLib.ahk`
3. Add a row to the Schema History table above
4. Update the "Current Keys" table
5. The app will auto-merge the new key on next launch for existing users
