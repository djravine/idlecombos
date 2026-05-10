# Application Startup Flow

> IdleCombos v3.80 — AutoHotkey v1.1 startup sequence

## Flow Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                    SCRIPT LAUNCH                            │
│  (User right-clicks IdleCombos.ahk → Open with AutoHotkey)  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  PHASE 1: AUTO-EXECUTE SECTION (L1-313)                      │
│                                                              │
│  1. Script directives                          [instant]     │
│     #NoEnv, #Persistent, #SingleInstance Force               │
│     #include json.ahk, IdleCombosLib.ahk                     │
│                                                              │
│  2. Global variable declarations (L8-231)      [instant]     │
│     ~225 variables across 10 categories:                     │
│     Files, Settings, Server, User, Inventory,                │
│     Patron, Event, Web Tools, GUI, Style                     │
│                                                              │
│  3. Style system enumeration (L232-242)        [<100ms]      │
│     Scan styles/*.msstyles → build StyleList                 │
│                                                              │
│  4. RunWith(32) (L243, def L1001)              [instant*]    │
│     Check if running 32-bit; if 64-bit:                      │
│     → relaunch as AutoHotkeyU32.exe → ExitApp                │
│     (*adds ~500ms if relaunch required)                      │
│                                                              │
│  5. Game install detection (L246-250)          [<50ms]       │
│     Cascade: Epic → Steam → Standalone                       │
│     setGameInstallEpic() (L2476)                             │
│       └─ reads LauncherInstalled.dat, parses JSON            │
│     setGameInstallSteam() (L2509)                            │
│       └─ checks default Steam path                           │
│     setGameInstallStandalone() (L2535)                       │
│       └─ checks default standalone path                      │
│                                                              │
│  6. SetIcon() (L252)                           [instant]     │
│     Set tray icon from IdleCombos.ico                        │
│                                                              │
│  7. OnMessage(0x0200) (L254)                   [instant]     │
│     Register WM_MOUSEMOVE → tooltip handler                  │
│                                                              │
│  8. oMyGUI := new MyGui() (L308)               [PHASE 2+3]   │
│     ──── triggers __New() and Load() ────                    │
│                                                              │
│  9. OnExit("ExitFunc") (L310)                  [instant]     │
│     Register cleanup (USkin.dll unload)                      │
│                                                              │
│  10. return (L313)                             [instant]     │
│      End auto-execute → app enters event loop                │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼ (triggered by step 8)
┌──────────────────────────────────────────────────────────────┐
│  PHASE 2: GUI CONSTRUCTION — MyGui.__New() (L320-609)        │
│                                                              │
│  1. Create window (L322-324)                   [instant]     │
│     Gui, MyWindow:New +Resize -MaximizeBox +MinSize          │
│                                                              │
│  2. Build menu system (L329-414)               [<50ms]       │
│     File menu:                                               │
│       IC Settings (View, Framerate, Particles, UI Scale)     │
│       Launch Game, Update UserDetails                        │
│       Detect Game (Epic/Steam/Standalone/Console)            │
│       Reload, Exit                                           │
│     Tools menu:                                              │
│       Chests (Buy/Open Silver/Gold/Event, Pity Timers)       │
│       Blacksmith (Tiny→Huge contracts, Gear Report, Feats)   │
│       Bounty (Tiny→Large contracts) [Alpha]                  │
│       Redeem Codes, Adventure Manager                        │
│       Briv Stack Calculator, Web Tools                       │
│     Help menu:                                               │
│       Run Setup, Clear Log, Update Dictionary                │
│       List User Details/Champ IDs/Chest IDs/Hotkeys          │
│       About, Github, Discord, Support Ticket                 │
│                                                              │
│  3. Build GUI controls (L416-605)              [<100ms]      │
│     StatusBar (bottom)                                       │
│     Sidebar: Reload/Exit buttons, Crash Protect toggle,      │
│              Data Timestamp, Update button                   │
│     Tab Control (8 tabs):                                    │
│       Summary  │ Adventures │ Inventory │ Patrons            │
│       Champions│ Event      │ Settings  │ Log                │
│     Settings tab:                                            │
│       ServerName edit, Tab/Style dropdowns                   │
│       12 checkboxes (logging, auto-detect, save prefs, etc.) │
│                                                              │
│  4. this.Load() (L608)                         [PHASE 3]     │
│     ──── triggers settings loading ────                      │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼ (triggered by step 4)
┌──────────────────────────────────────────────────────────────┐
│  PHASE 3: SETTINGS & CREDENTIAL LOADING — Load() (L611-715)  │
│                                                              │
│  ┌─ Settings file check (L614-618) ──────────  [<10ms]       │
│  │  If idlecombosettings.json missing:                       │
│  │    → create from NewSettings defaults                     │
│  │    → update GUI                                           │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Parse settings (L619-620) ───────────────  [<10ms]       │
│  │  FileRead + JSON.parse(rawsettings)                       │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Settings migration (L623-634) ───────────  [<10ms]       │
│  │  If key count != SettingsCheckValue (23):                 │
│  │    → merge missing keys from defaults                     │
│  │    → PersistSettings() (atomic JSON write)                │
│  │    → notify user: "settings updated"                      │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ WRL file at script dir? (L637-646) ──────  [<10ms]       │
│  │  If webRequestLog.txt exists locally:                     │
│  │    → prompt: "WRL File detected. Use file?"               │
│  │    → if Yes: set WRLFile, call FirstRun()                 │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ First run? (L647-649) ───────────────────  [BLOCKING*]   │
│  │  If CurrentSettings.firstrun == 0:                        │
│  │    → FirstRun() wizard (user interaction required)        │
│  │    (*blocks until user provides credentials)              │
│  └───────────────────────────────────────────                │
│                           │                                  │
│                           ▼                                  │
│        ┌──── FirstRun() (L2608-2655) ────────────┐           │
│        │  Console user?                          │           │
│        │    → InputBox: user_id                  │           │
│        │    → InputBox: hash                     │           │
│        │  Desktop user?                          │           │
│        │    → MsgBox: "Get from WRL?"            │           │
│        │      Yes → GetIDFromWRL() (L2675)       │           │
│        │             parse WRL for user_id/hash  │           │
│        │             GetPlayServerFromWRL()      │           │
│        │      No  → "Choose dir manually?"       │           │
│        │             or manual InputBox entry    │           │
│        │  → Save credentials to settings         │           │
│        │  → PersistSettings()                    │           │
│        └─────────────────────────────────────────┘           │
│                                                              │
│  ┌─ Load credentials (L650-659) ─────────────  [instant]     │
│  │  If user_id & hash in settings:                           │
│  │    → set UserID, UserHash, InstanceID globals             │
│  │    → StatusBar: "✅ User ID & Hash Ready"                 │
│  │  Else:                                                    │
│  │    → StatusBar: "❌ User ID & Hash not found!"            │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Load preferences (L662-683) ─────────────  [instant]     │
│  │  ServerName, GetDetailsonStart, LaunchGameonStart,        │
│  │  AlwaysSave*, LogEnabled, LoadGameClient, StyleSelection, │
│  │  DisableTooltips, RedeemCodeHistorySkip, etc.             │
│  │                                                           │
│  │  SetStyle(StyleSelection) (L679)            [<100ms]      │
│  │    → SkinForm(USkin.dll, Apply, *.msstyles)               │
│  │    → set BgColour based on theme                          │
│  │                                                           │
│  │  Set active tab (L681-683)                                │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Show GUI (L685-686) ─────────────────────  [<50ms]       │
│  │  this.Update() → populate all GUI controls                │
│  │  this.Show()   → Gui, Show, w600 h275                     │
│  │  ═══════════════════════════════════════════              │
│  │  *** WINDOW VISIBLE TO USER AT THIS POINT ***             │
│  │  ═══════════════════════════════════════════              │
│  └───────────────────────────────────────────                │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  PHASE 4: POST-SHOW INITIALIZATION (L689-715)                │
│                                                              │
│  ┌─ Re-detect game install (L690-697) ───────  [<50ms]       │
│  │  Based on saved LoadGameClient setting:                   │
│  │    1=Epic, 2=Steam, 3=Standalone                          │
│  │    → setGameInstall*() for chosen platform                │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Log startup (L699-700) ──────────────────  [instant]     │
│  │  "IdleCombos v3.78 started."                              │
│  │  "Settings File: ... - Loaded"                            │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Server detection (L702-704) ─────────────  [<500ms]      │
│  │  If not console platform:                                 │
│  │    GetPlayServerFromWRL() (L2716)                         │
│  │      → read WRL file                                      │
│  │      → check for connection errors                        │
│  │      → if ServerDetection enabled:                        │
│  │          GetPlayServer() → ParsePlayServerName()          │
│  │          → update ServerName if changed                   │
│  │          → SaveSettings()                                 │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Auto-fetch user details? (L705-707) ─────  [NETWORK*]    │
│  │  If GetDetailsonStart == "1":                             │
│  │    → GetUserDetails()          [PHASE 5]                  │
│  │    (*1-5 seconds depending on API response)               │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Auto-launch game? (L708-710) ────────────  [BLOCKING*]   │
│  │  If LaunchGameonStart == "1":                             │
│  │    → LaunchGame() (L3481)                                 │
│  │      Run game executable                                  │
│  │      WinWait for "Idle Champions" window                  │
│  │    (*blocks until game window appears)                    │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Final update (L712-714) ─────────────────  [<50ms]       │
│  │  this.Update() → refresh all GUI controls                 │
│  │  Scroll log to bottom                                     │
│  └───────────────────────────────────────────                │
│                                                              │
│  ══════════════════════════════════════════════              │
│  STARTUP COMPLETE → enters AHK event loop                    │
│  (hotkeys, menu actions, crash protect timer)                │
│  ══════════════════════════════════════════════              │
└──────────────────────────────────────────────────────────────┘

         ▼ (only if GetDetailsonStart enabled)

┌──────────────────────────────────────────────────────────────┐
│  PHASE 5: API DATA FETCH — GetUserDetails() (L2762-2809)     │
│                                                              │
│  StatusBar: "⌛ Loading Data... Please wait..."              │
│                                                              │
│  ┌─ API call (L2771-2772) ───────────────────  [1-5 sec]     │
│  │  ServerCall("getuserdetails", params)                     │
│  │    → HTTPS POST to                                        │
│  │      {server}.idlechampions.com/~idledragons/post.php     │
│  │    → WinHttp.WinHttpRequest.5.1 COM object                │
│  │    → Timeouts: resolve=∞, connect=60s, send=30s, recv=2m  │
│  │                                                           │
│  │    Handle switch_play_server redirect:                    │
│  │      → ParsePlayServerName(response)                      │
│  │      → recursive ServerCall() with new server             │
│  │      (single hop, no loop)                                │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Error handling (L2774-2786) ─────────────                │
│  │  Server error? → StatusBar: "❌ API Error..."             │
│  │  JSON parse error? → MsgBox + return                      │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Cache response (L2778-2779) ─────────────  [<10ms]       │
│  │  Write raw JSON → userdetails.json                        │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Parse cascade (L2793-2802) ──────────────  [<500ms]      │
│  │                                                           │
│  │  StatusBar: "⌛ Parsing user data..."                     │
│  │                                                           │
│  │  ParseChampData()         (L3216)                         │
│  │    → champion count, familiars, costumes, epic gear       │
│  │    → Briv slot 4 / zone detection                         │
│  │                                                           │
│  │  ParseAdventureData()     (L2811)                         │
│  │    → current/background adventures (up to 4 instances)    │
│  │    → modron core levels and XP                            │
│  │                                                           │
│  │  ParseTimestamps()        (L2884)                         │
│  │    → convert unix epoch → local time                      │
│  │    → LastUpdated display string                           │
│  │    → NextTGPDrop (time gate piece)                        │
│  │                                                           │
│  │  ParseInventoryData()     (L2918)                         │
│  │    → gems, chests, time gate pieces                       │
│  │    → bounty contracts (tiny/small/medium/large)           │
│  │    → blacksmith contracts (tiny→huge)                     │
│  │    → event tokens, patron currencies                      │
│  │                                                           │
│  │  ParsePatronData()        (L2981)                         │
│  │    → per-patron: variants, FP currency, challenges        │
│  │    → Mirt, Vajra, Strahd, Zariel, Elminster               │
│  │                                                           │
│  │  ParseLootData()          (L3168)                         │
│  │    → available chest counts by type                       │
│  │    → blacksmith level tracking                            │
│  │                                                           │
│  │  CheckAchievements()      (L3284)                         │
│  │    → summary stats for Summary tab                        │
│  │                                                           │
│  │  CheckBlessings()         (L3340)                         │
│  │    → blessing counts per campaign                         │
│  │                                                           │
│  │  CheckPatronProgress()    (L3261)                         │
│  │    → patron variant completion, costs, requirements       │
│  │    → color-coding (red/green) for patron display          │
│  │                                                           │
│  │  CheckEvents()            (L3385)                         │
│  │    → active event name, tokens, hero IDs, chest IDs       │
│  └───────────────────────────────────────────                │
│                                                              │
│  ┌─ Final GUI update (L2803-2806) ───────────  [<100ms]      │
│  │  StatusBar: "⌛ Populating UI tabs..."                    │
│  │  oMyGUI.Update() → push all parsed data to controls       │
│  │  StatusBar: "✅ Loaded and Ready 😎"                     │
│  │  LogFile("User Details - Loaded")                         │
│  └───────────────────────────────────────────                │
└──────────────────────────────────────────────────────────────┘
```

## Timing Summary

| Phase | Duration | Notes |
|-------|----------|-------|
| Phase 1: Auto-execute | ~200ms | Instant unless 32-bit relaunch needed (+500ms) |
| Phase 2: GUI build | ~200ms | Menu + tab construction, no I/O |
| Phase 3: Settings load | ~100ms | File I/O + JSON parse; **blocks on FirstRun() if first launch** |
| Phase 3b: Theme apply | ~100ms | USkin.dll DllCall |
| Phase 3c: GUI show | ~50ms | **Window visible to user** |
| Phase 4: Post-show init | ~500ms | WRL file read + server detection |
| Phase 5: API fetch | 1-5 sec | **Network-dependent**; only if "Get Details on Start" enabled |
| **Total (returning user)** | **~1 sec** | Without API fetch |
| **Total (with API fetch)** | **2-6 sec** | With GetUserDetails() enabled |
| **Total (first run)** | **Variable** | Blocks on user credential input |

## Key Observations

* **GUI shows before API call** — the window is visible during Phase 3, before the potentially slow Phase 5 network call. The status bar shows progress ("Loading Data...").
* **Synchronous API calls** — `ServerCall()` blocks the UI thread. During the 1-5 second API call, the window is unresponsive.
* **Cascading game detection** — tries Epic, then Steam, then Standalone. Runs twice: once in auto-execute (L246) and again in `Load()` (L690) using the saved platform preference.
* **FirstRun() is modal** — blocks the entire startup flow with `MsgBox`/`InputBox` dialogs until the user provides credentials or cancels.
* **No async** — all operations are synchronous on the main thread. Long operations (API calls, file reads, game launch wait) freeze the GUI.

## ServerCall Flow Detail

```text
ServerCall(callname, params, server)
    │
    ├─ Build URL: https://{server}.idlechampions.com/~idledragons/post.php
    │
    ├─ WinHttp.WinHttpRequest.5.1
    │    ├─ SetTimeouts(0, 60000, 30000, 120000)
    │    ├─ Open("POST", url, false)      ← synchronous
    │    ├─ SetRequestHeader(Content-Type)
    │    ├─ Send()
    │    ├─ WaitForResponse()
    │    └─ ResponseText → data
    │
    ├─ switch_play_server in response?
    │    ├─ Yes → ParsePlayServerName() → recursive ServerCall(new_server)
    │    └─ No  → continue
    │
    ├─ CheckServerCallError(data)
    │    ├─ Fail → return empty
    │    └─ Pass → return data
    │
    └─ LogFile("API Call: {callname}")
```

## Hotkey Registration

Hotkeys are active after the auto-execute `return` (L313):

| Hotkey | Action | Function |
|--------|--------|----------|
| Ctrl+Numpad1 | Tiny Blacksmith | Tiny_Blacksmith |
| Ctrl+Numpad2 | Small Blacksmith | Sm_Blacksmith |
| Ctrl+Numpad3 | Medium Blacksmith | Med_Blacksmith |
| Ctrl+Numpad4 | Large Blacksmith | Lg_Blacksmith |
| Ctrl+Numpad5 | Huge Blacksmith | Hg_Blacksmith |
| Ctrl+Numpad/ | Buy Silver Chests | Buy_Silver |
| Ctrl+Numpad* | Buy Gold Chests | Buy_Gold |
| Ctrl+Numpad- | Buy Event Chests | Buy_Event |
| Ctrl+Numpad7 | Open Silver Chests | Open_Silver |
| Ctrl+Numpad8 | Open Gold Chests | Open_Gold |
| Ctrl+Numpad9 | Open Event Chests | Open_Event |
| Ctrl+7 | Tiny Bounty | Tiny_Bounty |
| Ctrl+8 | Small Bounty | Sm_Bounty |
| Ctrl+9 | Medium Bounty | Med_Bounty |
| Ctrl+0 | Large Bounty | Lg_Bounty |

## Crash Protection (Optional)

When enabled via the GUI toggle, `CrashProtect()` (L978) runs a polling loop:

```text
CrashProtect()
    └─ loop
        └─ while game exe not running
            ├─ Sleep 2500ms
            ├─ Run game client
            ├─ increment CrashCount
            ├─ update StatusBar
            └─ Sleep 10000ms
```

Only works with Steam due to game client path requirements.
