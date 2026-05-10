#NoEnv
#Persistent
#SingleInstance Force
#include %A_ScriptDir%
#include json.ahk
#include IdleCombosLib.ahk
#include Lib\ScrollBox.ahk

;Versions
global VersionNumber := "3.81"
global CurrentDictionary := "2.43"

;Local File globals
global OutputLogFile := ""
global LogFileName := "idlecombolog.txt"
global SettingsFile := "idlecombosettings.json"
global UserDetailsFile := "userdetails.json"
global ChestOpenLogFile := "chestopenlog.json"
global BlacksmithLogFile := "blacksmithlog.json"
global BountyLogFile := "bountylog.json"
global RedeemCodeLogFile := "redeemcodelog.json"
global RedeemCodeListFile := "redeemcodelist.json"
global JournalFile := "journal.json"
global CurrentSettings := []
global IconFolder := ""
global IconFilename := "IdleCombos.ico"
global IconFile := ""
global GameInstallDir := ""
global GamePlatform := ""
global GameClient := ""
global GameClientExe := "IdleDragons.exe"
global GameClientExeStandaloneLauncher := "IdleDragonsLauncher.exe"
global GameInstallDirSteam := "C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\"
global GameInstallDirEpic := ""
global GameInstallDirStandaloneLauncher := "C:\Program Files (x86)\Idle Champions\"
global GameInstallDirStandalone := "C:\Program Files (x86)\Idle Champions\IdleChampions\"
global GameClientEpic := "C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat"
global GameIDEpic := "40cb42e38c0b4a14a1bb133eb3291572"
global GameHashEpic := "57f205884f6c64417c7aa5e84ad9fc8d"
global GameHashSteam := "ce901520efb6bc265a549aeec201bed0"
global GameClientEpicLauncher := "com.epicgames.launcher://apps/" GameIDEpic "?action=launch&silent=true"
global WRLFile := ""
global WRLFilePath := "IdleDragons_Data\StreamingAssets\downloaded_files\webRequestLog.txt"
global DictionaryFile := "https://raw.githubusercontent.com/djravine/idlecombos/master/idledict.json"
global LocalDictionary := "idledict.json"
global ICSettingsFile := A_AppData
StringTrimRight, ICSettingsFile, ICSettingsFile, 7
ICSettingsFile := ICSettingsFile "LocalLow\Codename Entertainment\Idle Champions\localSettings.json"

;Settings globals
global ServerName := "master"
global GetDetailsonStart := 0
global LaunchGameonStart := 0
global FirstRun := 1
global AlwaysSaveChests := 0
global AlwaysSaveContracts := 0
global AlwaysSaveCodes := 0
global NoSaveSetting := 0
global LogEnabled := 0
global LoadGameClient := 0 ;0 none; 1 epic, 2 steam, 3 standalone
global TabActive := "Summary"
global TabList := "Summary|Adventures|Inventory|Patrons|Champions|Pity Timers|Item Levels|Variants|Event|Settings|Log|"
global ServerDetection := 1
global ShowResultsBlacksmithContracts := 1
global DisableUserDetailsReload := 0
global DisableTooltips := 0
global RedeemCodeHistorySkip := 1
global StyleSelection := "Default"
;SettingsCheckValue and NewSettings are defined in IdleCombosLib.ahk
global AutoRefreshMinutes := 0
global ShowAPIMessages := 1

;Server globals
;DummyData is defined in IdleCombosLib.ahk
global CodestoEnter := ""
global ServerError := ""

;User info globals
global UserID := 0
global UserIDEpic := 0
global UserIDSteam := 0
global UserHash := 0
global InstanceID := 0
global UserDetails := []
global ActiveInstance := 0
global CurrentAdventure := ""
global CurrentArea := ""
global CurrentPatron := ""
global CurrentChampions := ""
global BackgroundAdventure := ""
global BackgroundArea := ""
global BackgroundPatron := ""
global BackgroundChampions := ""
global Background2Adventure := ""
global Background2Area := ""
global Background2Patron := ""
global Background2Champions := ""
global Background3Adventure := ""
global Background3Area := ""
global Background3Patron := ""
global Background3Champions := ""
global AchievementGearChamp := ""
global AchievementNeeds := ""
global SummaryDataLoaded := false
global ChampDetails := ""
global TotalChamps := 0
global About := "IdleCombos v" VersionNumber "`n`nOriginal by QuickMythril`nMaintained by DJRavine`nUpdates by Eldoen, dhusemann, NeyahPeterson, deathoone, Fmagdi`n`nSpecial thanks to all the idle dragoneers who inspired and assisted me!"
global HotkeyInfo := "CONTROL + NUMPAD1 - Tiny Blacksmith Contracts`nCONTROL + NUMPAD2 - Small Blacksmith Contracts`nCONTROL + NUMPAD3 - Medium Blacksmith Contracts`nCONTROL + NUMPAD4 - Large Blacksmith Contracts`nCONTROL + NUMPAD5 - Huge Blacksmith Contracts`n"
HotkeyInfo := HotkeyInfo "CONTROL + NUMPAD/ - Buy Silver Chests`nCONTROL + NUMPAD* - Buy Gold Chests`nCONTROL + NUMPAD- - Buy Event Chests`nCONTROL + NUMPAD7 - Open Silver Chests`nCONTROL + NUMPAD8 - Open Gold Chests`nCONTROL + NUMPAD9 - Open Event Chests`n"
HotkeyInfo := HotkeyInfo "CONTROL + 7 - Tiny Bounty Contracts`nCONTROL + 8 - Small Bounty Contracts`nCONTROL + 9 - Medium Bounty Contracts`nCONTROL + 0 - Large Bounty Contracts`n"
HotkeyInfo := HotkeyInfo "CONTROL + F5 - Refresh User Details`n"

;Inventory globals
global CurrentGems := ""
global AvailableChests := ""
global SpentGems := ""
global CurrentGolds := ""
global GoldPity := ""
global CurrentSilvers := ""
global CurrentTGPs := ""
global AvailableTGs := ""
global NextTGPDrop := ""
global CurrentTokens := ""
global CurrentTinyBounties := ""
global CurrentSmBounties := ""
global CurrentMdBounties := ""
global CurrentLgBounties := ""
global AvailableTokens := ""
global AvailableFPs := ""
global CurrentTinyBS := ""
global CurrentSmBS := ""
global CurrentMdBS := ""
global CurrentLgBS := ""
global CurrentHgBS := ""
global AvailableBSLvs := ""

;Loot globals
global ChampionsUnlockedCount := 0
global ChampionsActiveCount := 0
global FamiliarsUnlockedCount := 0
global CostumesUnlockedCount := 0
global EpicGearCount := 0
global BrivSlot4 := 0
global BrivZone := 0

;Modron globals
global FGCoreName := ""
global FGCoreXP := ""
global FGCoreProgress := ""
global BGCoreName := ""
global BGCoreXP := ""
global BGCoreProgress := ""
global BG2CoreName := ""
global BG2CoreXP := ""
global BG2CoreProgress := ""
global BG3CoreName := ""
global BG3CoreXP := ""
global BG3CoreProgress := ""

;Patron globals
global MirtVariants := ""
global MirtCompleted := ""
global MirtVariantTotal := ""
global MirtFPCurrency := ""
global MirtChallenges := ""
global MirtRequires := ""
global MirtCosts := ""
global VajraVariants := ""
global VajraCompleted := ""
global VajraVariantTotal := ""
global VajraFPCurrency := ""
global VajraChallenges := ""
global VajraRequires := ""
global VajraCosts := ""
global StrahdVariants := ""
global StrahdCompleted := ""
global StrahdVariantTotal := ""
global StrahdFPCurrency := ""
global StrahdChallenges := ""
global StrahdRequires := ""
global StrahdCosts := ""
global ZarielVariants := ""
global ZarielCompleted := ""
global ZarielVariantTotal := ""
global ZarielFPCurrency := ""
global ZarielChallenges := ""
global ZarielRequires := ""
global ZarielCosts := ""
global ElminsterVariants := ""
global ElminsterCompleted := ""
global ElminsterVariantTotal := ""
global ElminsterFPCurrency := ""
global ElminsterChallenges := ""
global ElminsterRequires := ""
global ElminsterCosts := ""

;Event globals (main event from events_details.active_events)
global EventID := ""
global EventName := ""
global EventDesc := ""
global EventTokenName := ""
global EventTokens := ""
global EventHeroIDs := ""
global EventChestIDs := ""
global EventHeroes := ""
global EventChests := ""
global EventDetails := ""

;Mini-event globals (from event_details singular object)
global MiniEventID := ""
global MiniEventName := ""
global MiniEventDesc := ""
global MiniEventTokens := ""
global MiniEventHeroes := ""
global MiniEventChests := ""

;Web Tools globals
global WebToolGithub := "https://github.com/djravine/idlecombos"
global WebToolDiscord := "https://discord.gg/wFtrGqd3ZQ"
global WebToolCodes := "https://incendar.com/idlechampions_codes.php"
global WebToolGameViewer := "http://idlechampions.soulreaver.usermd.net"
global WebToolDataViewer := "https://idle.kleho.ru"
global WebToolUtilities := "https://ic.byteglow.com"
global WebToolUtilitiesModron := WebToolUtilities "/modron"
global WebToolUtilitiesFormation := WebToolUtilities "/formation"

;GUI globals
global oMyGUI := ""
global OutputText := ""
global hEditLog := 0
global OutputStatus := "Welcome to IdleCombos v" VersionNumber
global CurrentTime := ""
global IsBusy := false
global CrashProtectStatus := "Crash Protect: Disabled"
global CrashCount := 0
global LastUpdated := "No data loaded"
global LastBSChamp := ""
global LastBSTnCount := ""
global LastBSSmCount := ""
global LastBSMdCount := ""
global LastBSLgCount := ""
global LastBSHgCount := ""
global LastBountyTnCount := ""
global LastBountySmCount := ""
global LastBountyMdCount := ""
global LastBountyLgCount := ""
global foundCodeString := ""
global BgColour := "FFFFFF"

;Style support
global StyleDLLPath := A_ScriptDir "\styles\USkin.dll" ;Location to the USkin.dll file
global StylePath := A_ScriptDir "\styles\" ;Location where you saved the .msstyles files
global StyleChoice := "Default"
global StyleList := "Default||"
global StyleSystem := false
if ( FileExist(StylePath) ) {
	StyleSystem := true
	Loop, % StylePath "*.msstyles" {
		if (A_LoopFilename != "Concave.msstyles") {
			StyleList .= A_LoopFilename . "|"
		}
	}
} else {

}
StyleList := RegExReplace(StyleList, ".msstyles")
RunWith(32) ;Force to start in 32 bit mode

;detect and set game installation paths
if ( setGameInstallEpic() == false ) {
	if ( setGameInstallSteam() == false ) {
		setGameInstallStandalone()
	}
}

SetIcon()

OnMessage(0x0200, "WM_MOUSEMOVE")

; Handle mouse hover events — display context-sensitive tooltips for GUI controls
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	if (DisableTooltips == 0) {
		; MouseGetPos, , , , ctrlHWND, 2
		; ToolTip, % Format("{:d}",ctrlHWND) " - " hwnd
		global hbreload, hbexit, hbtoggle, hbrefresh, hbsave, hedit1, hddl1, hddl2, hcb01, hcb02, hcb03, hcb04, hcb05, hcb06, hcb07, hcb08, hcb09, hcb10, hcb11, hcb12, hcb13, heditAutoRefresh, hEditLog
		switch (hwnd) {
			case hbreload: ; Reload
				ToolTip, % "Reload IdleCombos."
			case hbexit: ; Exit
				ToolTip, % "Exit IdleCombos."
			case hbtoggle: ; Toggle Crash Protection
				ToolTip, % "Turn Idle Champions crash protection on/off."
			case hbrefresh: ; Refresh
				ToolTip, % "Refresh the User Details from the API server."
			case hbsave: ; Save Settings
				ToolTip, % "Save all the settings to file."
			case hedit1: ; Server Name
				ToolTip, % "The Play Server Name where the data will be processed via the API server."
			case hddl1: ; Tab
				ToolTip, % "Select a tab to auto open when starting IdleCombos."
			case hddl2: ; Theme
				ToolTip, % "Select a theme to display IdleCombos with."
			case hcb01: ; Logging Enabled?
				ToolTip, % "Creates a log file 'idlecombolog.txt' and stores every action. Great for debugging."
			case hcb02: ; Get Play Server Name automatically?
				ToolTip, % "Automatically detect the play server from the API and set it accordingly."
			case hcb03: ; Get User Details on start?
				ToolTip, % "Automatically load the user details when starting IdleCombos."
			case hcb04: ; Launch game client on start?
				ToolTip, % "Automatically load Idle Champions game when starting IdleCombos."
			case hcb05: ; Always save Chest Open Results to file?
				ToolTip, % "Creates a log file 'chestopenlog.json' and stores every 'Chest Open' action."
			case hcb06: ; Always save Blacksmith Results to file?
				ToolTip, % "Creates a log file 'blacksmithlog.json' and stores every 'BlackSmith' action."
			case hcb07: ; Always save Code Redeem Results to file?
				ToolTip, % "Creates a log file 'redeemcodelog.json' and stores every 'Code Redeem' action."
			case hcb08: ; Never save results to file?
				ToolTip, % "Do not save any results to the respective log file."
			case hcb09: ; Show Blacksmith Contracts Results?
				ToolTip, % "Show the dialog window with the results from BlackSmith Contracts."
			case hcb10: ; Disable User Detail Reload? (Risky)
				ToolTip, % "Do not reload the user details after certain actions.`nThis is risky as the user details may be out of sync with the server and cause problems.`nPlease use the UPDATE button to refresh the user details manually."
			case hcb11: ; Disable Tooltips?
				ToolTip, % "Show tooltips on window controls"
			case hcb12: ; Skip Codes in Redeem Code History?
				ToolTip, % "Any codes already found in the Redeem Code History will be skipped"
			case heditAutoRefresh: ; Auto-Refresh Interval
				ToolTip, % "Auto-refresh user details every N minutes. Set to 0 to disable."
			case hcb13: ; Show API Messages?
				ToolTip, % "Show API call and data parsing progress in the status bar."
			default:
				ToolTip, % ""
		}
	}
}

oMyGUI := new MyGui()

OnExit("ExitFunc")

;end startup
return

;BEGIN: GUI Defs
class MyGui {
	Width := "850"
	Height := "425"

	__New() {
		Global
		Gui, MyWindow:New
		Gui, MyWindow:+Resize -MaximizeBox +MinSize

		Menu, ICSettingsSubmenu, Add, &View Settings, ViewICSettings
		Menu, ICSettingsSubmenu, Add, &Framerate, SetFramerate
		Menu, ICSettingsSubmenu, Add, &Particles, SetParticles
		Menu, ICSettingsSubmenu, Add, &UI Scale, SetUIScale
		Menu, FileSubmenu, Add, &Idle Champions Settings, :ICSettingsSubmenu

		Menu, FileSubmenu, Add, &Launch Game Client, LaunchGame
		Menu, FileSubmenu, Add, &Update UserDetails, GetUserDetails
		Menu, FileSubmenu, Add
		Menu, FileSubmenu, Add, Detect Game - Epic Games, detectGameInstallEpic
		Menu, FileSubmenu, Add, Detect Game - Steam, detectGameInstallSteam
		Menu, FileSubmenu, Add, Detect Game - Standalone, detectGameInstallStandalone
		Menu, FileSubmenu, Add, Detect Game - Console (PS4/Xbox/Switch/iOS), detectGameInstallConsole
		Menu, FileSubmenu, Add
		Menu, FileSubmenu, Add, &Reload IdleCombos, Reload_Clicked
		Menu, FileSubmenu, Add, E&xit IdleCombos, Exit_Clicked
		Menu, IdleMenu, Add, &File, :FileSubmenu

		Menu, ChestsSubmenu, Add, Buy &Silver, Buy_Silver
		Menu, ChestsSubmenu, Add, Buy &Gold, Buy_Gold
		Menu, ChestsSubmenu, Add, Buy &Event, Buy_Event
		Menu, ChestsSubmenu, Add, Open S&ilver, Open_Silver
		Menu, ChestsSubmenu, Add, Open G&old, Open_Gold
		Menu, ChestsSubmenu, Add, Open E&vent, Open_Event
		Menu, ToolsSubmenu, Add, &Chests, :ChestsSubmenu

		Menu, BlacksmithSubmenu, Add, Use &Tiny Contracts, Tiny_Blacksmith
		Menu, BlacksmithSubmenu, Add, Use &Small Contracts, Sm_Blacksmith
		Menu, BlacksmithSubmenu, Add, Use &Medium Contracts, Med_Blacksmith
		Menu, BlacksmithSubmenu, Add, Use &Large Contracts, Lg_Blacksmith
		Menu, BlacksmithSubmenu, Add, Use &Huge Contracts, Hg_Blacksmith
		Menu, BlacksmithSubmenu, Add, &Active Patron Feats, PatronFeats
		Menu, ToolsSubmenu, Add, &Blacksmith, :BlacksmithSubmenu

		Menu, BountySubmenu, Add, Use &Tiny Contracts, Tiny_Bounty
		Menu, BountySubmenu, Add, Use &Small Contracts, Sm_Bounty
		Menu, BountySubmenu, Add, Use &Medium Contracts, Med_Bounty
		Menu, BountySubmenu, Add, Use &Large Contracts, Lg_Bounty
		Menu, ToolsSubmenu, Add, B&ounty (Alpha Feature), :BountySubmenu

		Menu, ToolsSubmenu, Add, &Redeem Codes, Open_Codes

		Menu, AdvSubmenu, Add, &Load New Adv, LoadAdventure
		Menu, AdvSubmenu, Add, &End Current Adv, EndAdventure
		Menu, AdvSubmenu, Add, End Background Adv, EndBGAdventure
		Menu, AdvSubmenu, Add, End Background2 Adv, EndBG2Adventure
		Menu, AdvSubmenu, Add, End Background3 Adv, EndBG3Adventure
		Menu, AdvSubmenu, Add, &Kleho Image, KlehoImage
		Menu, AdvSubmenu, Add, Update Adventure List, AdventureList
		Menu, ToolsSubmenu, Add, &Adventure Manager, :AdvSubmenu

		Menu, ToolsSubmenu, Add, Briv &Stack Calculator, Briv_Calc

		Menu, ToolsSubmenu, Add, &Export to CSV, ExportCSV

Menu, WebToolsSubmenu, Add, &Data Viewer - Kleho, Open_Web_Data_Viewer
Menu, WebToolsSubmenu, Add, &Game Viewer - SoulReaver, Open_Web_Game_Viewer
Menu, WebToolsSubmenu, Add, Utilities - &ByteGlow, Open_Web_Utilities
Menu, WebToolsSubmenu, Add, Utilities - &Modron Core Calc, Open_Web_Utilities_Modron
Menu, WebToolsSubmenu, Add, Utilities - &Formation Calc, Open_Web_Utilities_Formation
		Menu, ToolsSubmenu, Add, &Web Tools, :WebToolsSubmenu

		Menu, IdleMenu, Add, &Tools, :ToolsSubmenu

		Menu, HelpSubmenu, Add, &Run Setup, FirstRun
		Menu, HelpSubmenu, Add
		Menu, HelpSubmenu, Add, Clear &Log, Clear_Log
		Menu, HelpSubmenu, Add, Clear Redeem Code H&istory, Redeem_Codes_History_Clear
		Menu, HelpSubmenu, Add
		Menu, HelpSubmenu, Add, &Update Dictionary from Git, Update_Dictionary
		Menu, HelpSubmenu, Add, &Sync Dictionary from API, Sync_Dictionary_From_API
		Menu, HelpSubmenu, Add, Download &Journal, Get_Journal
		Menu, HelpSubmenu, Add
		Menu, HelpSubmenu, Add, List &User Details, List_UserDetails
		Menu, HelpSubmenu, Add, List &Champ IDs, List_ChampIDs
		Menu, HelpSubmenu, Add, List C&hest IDs, List_ChestIDs
		Menu, HelpSubmenu, Add, List Hot&keys, Hotkeys_Clicked
		Menu, HelpSubmenu, Add, List &Redeem Code History, Redeem_Codes_History
		Menu, HelpSubmenu, Add
		Menu, HelpSubmenu, Add, &About IdleCombos, About_Clicked
		Menu, HelpSubmenu, Add, &Github Project, Github_Clicked
		Menu, HelpSubmenu, Add, &Discord Support Server, Discord_Clicked
		Menu, HelpSubmenu, Add, CNE &Support Ticket, Open_Ticket
		Menu, IdleMenu, Add, &Help, :HelpSubmenu
		Gui, Menu, IdleMenu

		col1_x := 10
		col2_x := 720
		col3_x := 780
		row_y := 5
		row1_y := 15

		Gui, Add, StatusBar, vStatusBar, %OutputStatus%
		SB_SetParts(700)
		SB_SetText("`tAHK v" A_AhkVersion, 2)
		Gui, Add, GroupBox, x705 y0 w155 h550 vGroup1,

		Gui, MyWindow:Add, Button, x%col2_x% y%row1_y% w65 hwndhbreload vBtnReload gReload_Clicked, Reload
		Gui, MyWindow:Add, Button, x%col3_x% y%row1_y% w65 hwndhbexit vBtnExit gExit_Clicked, Exit

		Gui, MyWindow:Add, Tab3, x0 y%row_y% w705 h550 hwndhtabs vTabs TabActive, % TabList
		Gui, Tab

		row_y := row_y + 25
		row_y := row_y + 25

		Gui, MyWindow:Add, Text, x710 y78 vCrashProtectStatus, % CrashProtectStatus
		Gui, MyWindow:Add, Button, x710 y95 w135 hwndhbtoggle vBtnToggle gCrash_Toggle, Toggle

		Gui, MyWindow:Add, Text, x710 y160 w135 vLastUpdatedTitle, Data Timestamp:
		Gui, MyWindow:Add, Text, x710 y180 w135 h30 vLastUpdated, % LastUpdated
		Gui, MyWindow:Add, Button, x710 y212 w135 hwndhbrefresh vBtnUpdate gUpdate_Clicked, Update

		Gui, Tab, Summary
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vSummaryLV hwndSummaryHwnd +Grid +ReadOnly -Multi +NoSortHdr, Category|Stat|Value|Details
		LV_ModifyCol(1, 80)
		LV_ModifyCol(2, 170)
		LV_ModifyCol(3, 170)
		LV_ModifyCol(4, 230)

		Gui, Tab, Adventures
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vAdventuresLV hwndAdventuresHwnd +Grid +ReadOnly -Multi +NoSortHdr, Instance|Adventure|Patron|Area|Champions|Core|XP|Progress

		Gui, Tab, Inventory
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vInventoryLV hwndInventoryHwnd +Grid +ReadOnly -Multi +NoSortHdr, Item|Count|Details

		Gui, Tab, Patrons
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vPatronsLV hwndPatronsHwnd +Grid +ReadOnly -Multi +NoSortHdr, Patron|Variants|Completed|FP Currency|Challenges|Influence / Requires|Coins / Costs

		Gui, Tab, Champions
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vChampionsLV hwndChampionsHwnd +Grid +ReadOnly -Multi +NoSortHdr, Champion|Stat|Value

		Gui, Tab, Pity Timers
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vPityLV hwndPityHwnd +Grid +ReadOnly -Multi +NoSortHdr, Chests Until Epic|Champions

		Gui, Tab, Item Levels
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vItemLevelsLV hwndItemLevelsHwnd +Grid +ReadOnly -Multi +NoSortHdr, Category|Stat|Value

		Gui, Tab, Variants
		Gui, MyWindow:Add, Text, x10 y38, Patron:
		patronDDL := BuildPatronDropdownList()
		Gui, MyWindow:Add, DropDownList, x55 y34 w180 h60 r7 vVariantPatronChoice gRunVariantRefresh, %patronDDL%
		Gui, MyWindow:Add, Button, x240 y34 w80 gRunVariantRefresh, Refresh
		Gui, MyWindow:Add, ListView, x4 y60 w600 h481 vVariantsLV hwndVariantsHwnd +Grid +ReadOnly -Multi +NoSortHdr, Campaign|Incomplete Adventure IDs

		Gui, Tab, Event
		Gui, MyWindow:Add, ListView, x4 y35 w600 h506 vEventLV hwndEventHwnd +Grid +ReadOnly -Multi +NoSortHdr, Detail|Value

		Gui, Tab, Settings
		Gui, MyWindow:Add, Text, x15 y37 w85, Server Name:
		Gui, MyWindow:Add, Edit, hwndhedit1 vServerName x100 y33 w60
		Gui, MyWindow:Add, Text, x200 y37 w30, Tab:
		Gui, MyWindow:Add, DropDownList, x230 y33 w100 h60 r10 hwndhddl1 vTabActive, % TabList
		Gui, MyWindow:Add, Text, x370 y37 w40, Style:
		Gui, MyWindow:Add, DropDownList, x410 y33 w120 h60 r10 hwndhddl2 vStyleChoice gRunStyleChoice, % StyleList

		col2set := 370
		Gui, MyWindow:Add, Checkbox, hwndhcb01 vLogEnabled x15 y60, Logging Enabled?
		Gui, MyWindow:Add, Checkbox, hwndhcb09 vShowResultsBlacksmithContracts x%col2set% y60, Show Blacksmith Contracts Results?
		Gui, MyWindow:Add, CheckBox, hwndhcb02 vServerDetection x15 y80, Get Play Server Name automatically?
		Gui, MyWindow:Add, Checkbox, hwndhcb12 vRedeemCodeHistorySkip x%col2set% y80, Skip Codes in Redeem Code History?
		Gui, MyWindow:Add, CheckBox, hwndhcb03 vGetDetailsonStart x15 y100, Get User Details on start?
		Gui, MyWindow:Add, Checkbox, hwndhcb10 vDisableUserDetailsReload x%col2set% y100, Disable User Detail Reload? (Risky)
		Gui, MyWindow:Add, CheckBox, hwndhcb04 vLaunchGameonStart x15 y120, Launch game client on start?
		Gui, MyWindow:Add, Checkbox, hwndhcb11 vDisableTooltips gRunDisableTooltips x%col2set% y120, Disable Tooltips?

		Gui, MyWindow:Add, Text, x15 y142 w680 h1 +0x10

		Gui, MyWindow:Add, CheckBox, hwndhcb05 vAlwaysSaveChests x15 y150, Always save Chest Open Results to file?
		Gui, MyWindow:Add, CheckBox, hwndhcb06 vAlwaysSaveContracts x%col2set% y150, Always save Blacksmith Results to file?
		Gui, MyWindow:Add, CheckBox, hwndhcb07 vAlwaysSaveCodes x15 y170, Always save Code Redeem Results to file?
		Gui, MyWindow:Add, Checkbox, hwndhcb08 vNoSaveSetting x%col2set% y170, Never save results to file?

		Gui, MyWindow:Add, Text, x15 y193, Auto-Refresh Interval (minutes, 0=off):
		Gui, MyWindow:Add, Edit, hwndheditAutoRefresh vAutoRefreshMinutes x285 y189 w50,
		Gui, MyWindow:Add, Checkbox, hwndhcb13 vShowAPIMessages x%col2set% y193, Show API Messages in Status Bar?

		Gui, MyWindow:Add, Button, x15 y215 w120 hwndhbsave gSave_Settings, Save Settings
		
		Gui, Tab, Log
		Gui, MyWindow:Add, Edit, x4 y35 w699 h506 hwndhEditLog vOutputText ReadOnly +Limit -Border, %OutputText%

		GuiControl, Focus, SysTabControl321

		this.Load()
	}

	Load() {
		
		;First run checks and setup
		if !FileExist(SettingsFile) {
			FileAppend, %NewSettings%, %SettingsFile%
			LogFile("Settings File: '" SettingsFile "' - Created")
			this.Update()
		}
		FileRead, rawsettings, %SettingsFile%
		Try {
			CurrentSettings := JSON.parse(rawsettings)
		} catch e {
			MsgBox, 48, IdleCombos Warning, % "Settings file is corrupted. Resetting to defaults."
			FileDelete, %SettingsFile%
			FileAppend, %NewSettings%, %SettingsFile%
			CurrentSettings := JSON.parse(NewSettings)
		}
		if !(CurrentSettings.Count() == SettingsCheckValue) {
			;Merge new default keys into existing settings (preserves user data)
			DefaultSettings := JSON.parse(NewSettings)
			for key, value in DefaultSettings {
				if !CurrentSettings.HasKey(key) {
					CurrentSettings[key] := value
				}
			}
			PersistSettings()
			LogFile("Settings File: '" SettingsFile "' - Migrated (added new keys)")
			this.Update()
			MsgBox, Your settings file has been updated with new options. Your existing preferences have been preserved.
		}

		if !(LoadGameClient == 4) {
			if FileExist(A_ScriptDir "\webRequestLog.txt") {
				MsgBox, 4, , % "WRL File detected. Use file?"
				IfMsgBox, Yes
				{
					WRLFile := A_ScriptDir "\webRequestLog.txt"
					FirstRun()
				}
			}
		}
		if !(CurrentSettings.firstrun) {
			FirstRun()
		}
		if (CurrentSettings.user_id && CurrentSettings.hash) {
			UserID := CurrentSettings.user_id
			UserIDEpic := CurrentSettings.user_id_epic
			UserIDSteam := CurrentSettings.user_id_steam
			; Decrypt hash (DPAPI-encrypted values start with "DPAPI:")
			; Plaintext values (pre-encryption users) pass through unchanged
			UserHash := DPAPIDecrypt(CurrentSettings.hash)
			if (UserHash = "" && CurrentSettings.hash != "" && CurrentSettings.hash != "0") {
				; Decryption failed — likely settings from a different machine/user or DPAPI unavailable
				LogFile("WARNING: Hash decryption failed — credentials cleared (re-run setup)")
				UserHash := ""
				UserID := 0
				; Clear the stale encrypted hash so next FirstRun save won't collide
				CurrentSettings.hash := ""
				PersistSettings()
				SB_SetText("⚠️ Hash decryption failed — please re-enter via Help → Run Setup")
			} else {
			; Auto-migrate: if hash was plaintext and DPAPI is available, encrypt it
			if (!IsEncryptedHash(CurrentSettings.hash) && UserHash != "" && UserHash != "0" && DPAPIAvailable) {
				CurrentSettings.hash := DPAPIEncrypt(UserHash)
				PersistSettings()
				LogFile("Settings migrated: hash encrypted with DPAPI")
			}
			if (!DPAPIAvailable && UserHash != "" && UserHash != "0") {
				LogFile("WARNING: DPAPI unavailable — hash is stored as plaintext")
				SB_SetText("⚠️ User ID & Hash Ready (DPAPI unavailable — hash unencrypted)")
			} else {
				SB_SetText("✅ User ID & Hash Ready")
			}
			}
			InstanceID := CurrentSettings.instance_id
		} else {
			SB_SetText("❌ User ID & Hash not found!")
		}

		;Load current settings
		ServerName := CurrentSettings.servername
		GetDetailsonStart := CurrentSettings.getdetailsonstart
		ServerDetection := CurrentSettings.serverdetection
		LaunchGameonStart := CurrentSettings.launchgameonstart
		AlwaysSaveChests := CurrentSettings.alwayssavechests
		AlwaysSaveContracts := CurrentSettings.alwayssavecontracts
		AlwaysSaveCodes := CurrentSettings.alwayssavecodes
		NoSaveSetting := CurrentSettings.nosavesetting
		LogEnabled := CurrentSettings.logenabled
		LoadGameClient := CurrentSettings.loadgameclient
		WRLFile := CurrentSettings.wrlpath
		ShowResultsBlacksmithContracts := CurrentSettings.blacksmithcontractresults
		DisableUserDetailsReload := CurrentSettings.disableuserdetailsreload
		DisableTooltips := CurrentSettings.disabletooltips
		RedeemCodeHistorySkip := CurrentSettings.redeemcodehistoryskip
		AutoRefreshMinutes := CurrentSettings.autorefreshminutes ? CurrentSettings.autorefreshminutes : 0
		ShowAPIMessages := CurrentSettings.showapimessages
		if (AutoRefreshMinutes > 0) {
			SetTimer, AutoRefreshTimer, % AutoRefreshMinutes * 60000
		} else {
			SetTimer, AutoRefreshTimer, Off
		}
		StyleSelection := CurrentSettings.style
		StyleChoice := StyleSelection
		SetStyle(StyleSelection)
		TabActive := CurrentSettings.tabactive
		if (TabActive) {
			GuiControl, Choose, Tabs, % TabActive
		}
		
		this.Update()
		this.Show()


		;detect and set game installation paths
		switch (LoadGameClient) {
			case 1: ;epic
				setGameInstallEpic()
			case 2: ;steam
				setGameInstallSteam()
			case 3: ;standalone
				setGameInstallStandalone()
		}

		LogFile("IdleCombos v" VersionNumber " started.")
		LogFile("Settings File: '" SettingsFile "' - Loaded")

		if !(LoadGameClient == 4) {
			GetPlayServerFromWRL()
		}
		; Feature 6: Load cached user details if available (1-hour TTL)
		; Skip if no valid credentials or if first-run setup just completed (fresh fetch pending)
		if (UserID && !FirstRunFetchPending && FileExist(UserDetailsFile)) {
			FileGetTime, cacheTime, %UserDetailsFile%, M
			EnvSub, cacheTime, %A_Now%, Seconds
			cacheAge := Abs(cacheTime)
			if (cacheAge <= 3600) {
				FileRead, cachedDetails, %UserDetailsFile%
				Try {
					UserDetails := JSON.parse(cachedDetails)
					if (UserDetails.details) {
						InstanceID := UserDetails.details.instance_id
						ActiveInstance := UserDetails.details.active_game_instance_id
						cacheMinutes := Floor(cacheAge / 60)
						ParseChampData()
						ParseAdventureData()
						ParseTimestamps()
						ParseInventoryData()
						ParsePatronData()
						ParseLootData()
						CheckAchievements()
						CheckBlessings()
						CheckPatronProgress()
						CheckEvents()
						SetTimer, TimestampTickTimer, 1000
						this.Update()
						SB_SetText("📋 Cached data (" cacheMinutes " min ago) — press Update for fresh data")
					}
				} catch e {
					errMsg := IsObject(e) ? (e.message " @ " e.file ":" e.line " in " e.what) : e
					LogFile("WARNING: Cached data parse failed: " errMsg)
					SB_SetText("⚠️ Cache error: " errMsg)
				}
			}
		}
		if (GetDetailsonStart == "1") {
			GetUserDetails()
		}
		if (LaunchGameonStart == "1") {
			LaunchGame()
		}

		; Auto-fetch after first-run setup (runs AFTER all Load() init is complete)
		if (FirstRunFetchPending) {
			FirstRunFetchPending := false
			GetUserDetails()
		}

		this.Update()

		DllCall("SendMessage", "Ptr", hEditLog, "UInt", 0xB1, "Ptr", -1, "Ptr", -1) ; EM_SETSEL — caret to end
		DllCall("SendMessage", "Ptr", hEditLog, "UInt", 0xB7, "Ptr", 0, "Ptr", 0)  ; EM_SCROLLCARET — scroll to caret
	}

	Show() {
		;check if minimized if so leave it be
		WinGet, OutputVar , MinMax, IdleCombos v%VersionNumber%
		if (OutputVar = -1) {
			return
		}
		nW := this.Width
		nH := this.Height
		Gui, MyWindow:Show, w%nW% h%nH%, IdleCombos v%VersionNumber%
	}

	Hide() {
		Gui, MyWindow:Hide
	}

	Submit() {
		Gui, MyWindow:Submit, NoHide
	}

	Update() {
		; Disable/enable sidebar buttons based on IsBusy state
		if (IsBusy) {
			GuiControl, Disable, BtnReload
			GuiControl, Disable, BtnUpdate
			GuiControl, Disable, BtnToggle
		} else {
			GuiControl, Enable, BtnReload
			GuiControl, Enable, BtnUpdate
			GuiControl, Enable, BtnToggle
		}
		GuiControl, MyWindow:, OutputText, % OutputText, w250 h210
		Try {
			DllCall("SendMessage", "Ptr", hEditLog, "UInt", 0xB1, "Ptr", -1, "Ptr", -1) ; EM_SETSEL — caret to end
			DllCall("SendMessage", "Ptr", hEditLog, "UInt", 0xB7, "Ptr", 0, "Ptr", 0)  ; EM_SCROLLCARET — scroll to caret
		}
		GuiControl, MyWindow:, CrashProtectStatus, % CrashProtectStatus, w250 h210
		; Relative time is updated by TimestampTickTimer (1s tick)
		GuiControl, MyWindow:, LastUpdated, % LastUpdated

		;Summary
		Gui, MyWindow:Default
		Gui, ListView, SummaryLV
		LV_Delete()
		if (!UserID || UserID == 0) {
			LV_Add("", "", "Setup Required", "Use File → Run Setup", "Configure your game client to get started")
		} else if (!SummaryDataLoaded) {
			if (GetDetailsonStart == "1")
				LV_Add("", "", "Loading", "Fetching user data...", "Please wait")
			else
				LV_Add("", "", "Ready", "User ID & Hash configured", "Press Update to load user data")
		} else {
			LV_Add("", "Account", "Highest Gear Level", UserDetails.details.stats.highest_level_gear, AchievementGearChamp)
			LV_Add("", "Account", "Champions Unlocked", ChampionsUnlockedCount, "")
			LV_Add("", "Account", "Champions Active", ChampionsActiveCount, "Across all instances")
			LV_Add("", "Account", "Familiars", FamiliarsUnlockedCount, "")
			LV_Add("", "Account", "Costumes", CostumesUnlockedCount, "")
			LV_Add("", "Account", "Epic Gear", EpicGearCount, "")
			if (AchievementNeeds != "") {
				LV_Add("", "────────", "───────────────────", "─────────", "───────────────")
				Loop, Parse, AchievementNeeds, `n
				{
					if (A_LoopField != "")
						LV_Add("", "Todo", A_LoopField, "", "Incomplete")
				}
			}
			LV_Add("", "────────", "───────────────────", "─────────", "───────────────")
			if (EpicGearCount && UserDetails.details.reset_upgrade_levels.44)
				LV_Add("", "Blessing", "Slow and Steady (Helm)", "x" Round((1.02 ** EpicGearCount), 2), EpicGearCount " epics")
			if (ChampionsUnlockedCount && UserDetails.details.reset_upgrade_levels.72)
				LV_Add("", "Blessing", "Familiar Faces (Helm)", "x" Round((1.02 ** ChampionsUnlockedCount), 2), ChampionsUnlockedCount " champions")
			if (ChampionsActiveCount && UserDetails.details.reset_upgrade_levels.76)
				LV_Add("", "Blessing", "Splitting the Party (Helm)", "x" Round((1.02 ** ChampionsActiveCount), 2), ChampionsActiveCount " active")
			if (UserDetails.details.reset_upgrade_levels.56) {
				vetAdvs := UserDetails.details.stats.completed_adventures_variants_and_patron_variants_c22
				LV_Add("", "Blessing", "Veterans of Avernus (Tiamat)", "x" Round(1 + (0.1 * vetAdvs), 2), vetAdvs " adventures")
			}
			if (CostumesUnlockedCount && UserDetails.details.reset_upgrade_levels.88)
				LV_Add("", "Blessing", "Costume Party (Auril)", "x" Round((1.20 ** CostumesUnlockedCount), 2), CostumesUnlockedCount " skins")
			if (FamiliarsUnlockedCount && UserDetails.details.reset_upgrade_levels.108)
				LV_Add("", "Blessing", "Familiar Stakes (Corellon)", "x" Round((1.20 ** FamiliarsUnlockedCount), 2), FamiliarsUnlockedCount " familiars")
		}
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")

		;Adventures
		Gui, MyWindow:Default
		Gui, ListView, AdventuresLV
		LV_Delete()
		LV_Add("", "Foreground",    CurrentAdventure,     CurrentPatron,     CurrentArea,     CurrentChampions,     FGCoreName,  FGCoreXP,  FGCoreProgress)
		LV_Add("", "Background 1",  BackgroundAdventure,  BackgroundPatron,  BackgroundArea,  BackgroundChampions,  BGCoreName,  BGCoreXP,  BGCoreProgress)
		LV_Add("", "Background 2",  Background2Adventure, Background2Patron, Background2Area, Background2Champions, BG2CoreName, BG2CoreXP, BG2CoreProgress)
		LV_Add("", "Background 3",  Background3Adventure, Background3Patron, Background3Area, Background3Champions, BG3CoreName, BG3CoreXP, BG3CoreProgress)
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")

;Inventory
Gui, MyWindow:Default
Gui, ListView, InventoryLV
LV_Delete()
; Currency
LV_Add("", "Gems",              CurrentGems,         Floor(CurrentGems/50) " Silver or " Floor(CurrentGems/500) " Gold")
LV_Add("", "Spent Gems",        SpentGems,           "")
LV_Add("", "───────────",       "─────",             "───────────────────────────")
; Chests
LV_Add("", "Gold Chests",       CurrentGolds,        GoldPity)
LV_Add("", "Silver Chests",     CurrentSilvers,      "")
LV_Add("", "Time Gate Pieces",  CurrentTGPs,         Floor(CurrentTGPs/6) " Time Gates | Next: " NextTGPDrop)
LV_Add("", "───────────",       "─────",             "───────────────────────────")
; Bounty Contracts — labels and multipliers from shared BountyContracts constant
tokencount := 0
for _, bc in BountyContracts {
	varName := bc.var
	LV_Add("", bc.name " Bounties", %varName%, bc.mult " " bc.unit " Each")
	tokencount += %varName% * bc.mult
}
LV_Add("", "Total Bounty Tokens", tokencount, Round(tokencount/2500, 2) " Free Plays")
LV_Add("", "───────────",       "─────",             "───────────────────────────")
; Blacksmith Contracts — labels and multipliers from shared BlacksmithContracts constant
bsLevels := 0
for _, bs in BlacksmithContracts {
	varName := bs.var
	LV_Add("", bs.name " Blacksmiths", %varName%, bs.mult " " bs.unit " Each")
	bsLevels += %varName% * bs.mult
}
LV_Add("", "Total Item Levels", bsLevels, "")
Loop % LV_GetCount("Col")
	LV_ModifyCol(A_Index, "AutoHdr")

;Patrons — display names from dict, variable data via short-name prefix
Gui, MyWindow:Default
Gui, ListView, PatronsLV
LV_Delete()
for _, pid in PatronIDs {
	pShort := PatronShortNames[pid]
	pDisplay := PatronFromID(pid)
	LV_Add("", pDisplay, %pShort%Variants, %pShort%Completed, %pShort%FPCurrency, %pShort%Challenges, %pShort%Requires, %pShort%Costs)
}
Loop % LV_GetCount("Col")
	LV_ModifyCol(A_Index, "AutoHdr")

;Champions
Gui, MyWindow:Default
Gui, ListView, ChampionsLV
LV_Delete()
if (SummaryDataLoaded) {
	if (UserDetails.details.stats.black_viper_total_gems) {
		v := UserDetails.details.stats.black_viper_total_gems
		LV_Add("", "Black Viper", "Red Gems", FormatMagnitude(v))
	}
	if (UserDetails.details.stats.total_paid_up_front_gold) {
		v := UserDetails.details.stats.total_paid_up_front_gold
		mg := SubStr(v, 1, 4)
		ePos := InStr(v, "E")
		if (ePos)
			mg := mg SubStr(v, ePos)
		LV_Add("", "M" Chr(244) "rg" Chr(230) "n", "Gold Collected", mg)
	}
	if (UserDetails.details.stats.torogar_lifetime_zealot_stacks) {
		v := UserDetails.details.stats.torogar_lifetime_zealot_stacks
		LV_Add("", "Torogar", "Zealot Stacks", FormatMagnitude(v))
	}
	if (UserDetails.details.stats.dhani_monsters_painted) {
		v := UserDetails.details.stats.dhani_monsters_painted
		LV_Add("", "D'hani", "Paints", FormatMagnitude(v))
	}
	if (UserDetails.details.stats.zorbu_lifelong_hits_humanoid || UserDetails.details.stats.zorbu_lifelong_hits_beast || UserDetails.details.stats.zorbu_lifelong_hits_undead || UserDetails.details.stats.zorbu_lifelong_hits_drow) {
		LV_Add("", "───────", "──────────", "─────────")
		zList := [["Humanoid Kills", UserDetails.details.stats.zorbu_lifelong_hits_humanoid], ["Beast Kills", UserDetails.details.stats.zorbu_lifelong_hits_beast], ["Undead Kills", UserDetails.details.stats.zorbu_lifelong_hits_undead], ["Drow Kills", UserDetails.details.stats.zorbu_lifelong_hits_drow]]
		for _, z in zList {
			v := z[2]
			if (v)
				LV_Add("", "Zorbu", z[1], FormatMagnitude(v))
		}
	}
}
Loop % LV_GetCount("Col")
	LV_ModifyCol(A_Index, "AutoHdr")

		;Pity Timers
		Gui, MyWindow:Default
		Gui, ListView, PityLV
		LV_Delete()
		if (SummaryDataLoaded && UserDetails.details.stats) {
			pityjsonoutput := "{"
			jsoncount := 0
			for k, v in (UserDetails.details.stats) {
				if (InStr(k,"forced_win_counter_")) {
					if (jsoncount > 0)
						pityjsonoutput := pityjsonoutput ","
					jsoncount += 1
					pityjsonoutput := pityjsonoutput """" k """:""" v """"
				}
			}
			pityjsonoutput := pityjsonoutput "}"
			pityjson := JSON.parse(pityjsonoutput)
			newestchamp := JSON.stringify(UserDetails.details.heroes[UserDetails.details.heroes.MaxIndex()].hero_id)
			newestchamp := StrReplace(newestchamp, """")
			chestsforepic := 1
			while (chestsforepic < 11) {
				champlist := ""
				currentchamp := 14
				while (currentchamp < newestchamp) {
					currentchest := "forced_win_counter_" ChestIDFromChampID(currentchamp)
					currentpity := ""
					for k, v in (pityjson) {
						if (k = currentchest)
							currentpity := v
					}
					if (currentpity = chestsforepic) {
						tempchamp := ChampFromID(currentchamp)
						if not InStr(tempchamp, "UNKNOWN")
							champlist := champlist tempchamp ", "
					}
					switch currentchamp {
						case "17": currentchamp += 2
						case "29": currentchamp += 2
						case "66": currentchamp += 3
						default: currentchamp += 1
					}
				}
				if (champlist != "") {
					StringTrimRight, champlist, champlist, 2
					LV_Add("", chestsforepic, champlist)
				}
				chestsforepic += 1
			}
		}
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")

		;Item Levels
		Gui, MyWindow:Default
		Gui, ListView, ItemLevelsLV
		LV_Delete()
		if (SummaryDataLoaded && UserDetails.details.loot) {
			tgl := -1
			tgi := -1
			tcl := -1
			tci := -1
			tel := 0
			tei := 0
			tsc := 0
			tse := 0
			hcl := 0
			hel := 0
			hci := 0
			hei := 0
			lcl := 10000000000
			lel := 10000000000
			lci := 0
			lei := 0
			ccl := 0
			lch := 0
			lsh := 0
			currentloot := UserDetails.details.loot
			dummyitem := {}
			currentloot.push(dummyitem)
			for k, v in currentloot {
				tgl += (v.enchant + 1)
				tgi += 1
				isCore := (lch < 13) || (lch = 13) || (lch = 18) || (lch = 30) || (lch = 67) || (lch = 68) || (lch = 86) || (lch = 87) || (lch = 88) || (lch = 106)
				if (isCore) {
					tcl += (v.enchant + 1)
					tci += 1
					if (lsh)
						tsc += 1
				} else {
					tel += (v.enchant + 1)
					tei += 1
					if (lsh)
						tse += 1
				}
				if (v.hero_id != lch && lch != 0) {
					if (isCore) {
						if (ccl > hcl) {
							hcl := ccl
							hci := lch
						}
						if (ccl < lcl) {
							lcl := ccl
							lci := lch
						}
					} else {
						if (ccl > hel) {
							hel := ccl
							hei := lch
						}
						if (ccl < lel) {
							lel := ccl
							lei := lch
						}
					}
					ccl := 0
				}
				ccl += (v.enchant + 1)
				lch := v.hero_id
				lsh := v.gild
			}
			dummyitem := currentloot.pop()
			LV_Add("", "Overall", "Average Item Level", Round(tgl/tgi))
			LV_Add("", "────────", "───────────────", "─────────")
			LV_Add("", "Core", "Average Level", Round(tcl/tci))
			LV_Add("", "Core", "Highest Average", Round(hcl/6) " (" ChampFromID(hci) ")")
			LV_Add("", "Core", "Lowest Average", Round(lcl/6) " (" ChampFromID(lci) ")")
			LV_Add("", "Core", "Shinies", tsc "/" tci)
			LV_Add("", "────────", "───────────────", "─────────")
			LV_Add("", "Event", "Average Level", Round(tel/tei))
			LV_Add("", "Event", "Highest Average", Round(hel/6) " (" ChampFromID(hei) ")")
			LV_Add("", "Event", "Lowest Average", Round(lel/6) " (" ChampFromID(lei) ")")
			LV_Add("", "Event", "Shinies", tse "/" tei)
		}
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")

		;Event
		Gui, MyWindow:Default
		Gui, ListView, EventLV
		LV_Delete()
		if (EventID != 0 && MiniEventID != 0 && EventID != MiniEventID) {
			; ── Both main event and mini-event active ──
			mainName := EventName != "" ? EventName : "Event " EventID
			LV_Add("", "Type", "Main Event")
			LV_Add("", "Event", mainName)
			LV_Add("", "Event ID", EventID)
			LV_Add("", EventTokenName, EventTokens)
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, EventHeroes, `,
			{
				hero := Trim(A_LoopField)
				if (hero != "")
					LV_Add("", "Hero", hero)
			}
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, EventChests, `,
			{
				chest := Trim(A_LoopField)
				if (chest != "")
					LV_Add("", "Chest", chest)
			}
			LV_Add("", "═══════════", "═══════════════════════════")
			LV_Add("", "Type", "Mini Event")
			LV_Add("", "Event", MiniEventName)
			LV_Add("", "Event ID", MiniEventID)
			LV_Add("", "Description", MiniEventDesc)
			LV_Add("", "Mini Tokens", MiniEventTokens)
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, MiniEventHeroes, `,
			{
				hero := Trim(A_LoopField)
				if (hero != "")
					LV_Add("", "Hero", hero)
			}
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, MiniEventChests, `,
			{
				chest := Trim(A_LoopField)
				if (chest != "")
					LV_Add("", "Chest", chest)
			}
		} else if (MiniEventID != 0) {
			; ── Mini-event only (or mini promoted to primary) ──
			LV_Add("", "Type", "Mini Event")
			LV_Add("", "Event", MiniEventName)
			LV_Add("", "Event ID", MiniEventID)
			LV_Add("", "Description", MiniEventDesc)
			LV_Add("", "Mini Tokens", MiniEventTokens)
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, MiniEventHeroes, `,
			{
				hero := Trim(A_LoopField)
				if (hero != "")
					LV_Add("", "Hero", hero)
			}
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, MiniEventChests, `,
			{
				chest := Trim(A_LoopField)
				if (chest != "")
					LV_Add("", "Chest", chest)
			}
		} else if (EventID != 0) {
			; ── Main event only (no mini-event) ──
			mainName := EventName != "" ? EventName : "Event " EventID
			LV_Add("", "Type", "Main Event")
			LV_Add("", "Event", mainName)
			LV_Add("", "Event ID", EventID)
			LV_Add("", EventTokenName, EventTokens)
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, EventHeroes, `,
			{
				hero := Trim(A_LoopField)
				if (hero != "")
					LV_Add("", "Hero", hero)
			}
			LV_Add("", "───────────", "───────────────────────────")
			Loop, Parse, EventChests, `,
			{
				chest := Trim(A_LoopField)
				if (chest != "")
					LV_Add("", "Chest", chest)
			}
		} else {
			LV_Add("", "Status", EventDesc)
		}
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")

		;Refresh active tab column fill

		;Settings
		GuiControl, MyWindow:, ServerName, % ServerName, w50 h210
		if (LoadGameClient == 4) {
			ServerDetection := 0
			GuiControl, Disable, ServerDetection
		} else {
			GuiControl, Enable, ServerDetection
		}
		GuiControl, MyWindow:, ServerDetection, % ServerDetection, w250 h210
		GuiControl, MyWindow:, GetDetailsonStart, % GetDetailsonStart, w250 h210
		if (LoadGameClient == 4) {
			LaunchGameonStart := 0
			GuiControl, Disable, LaunchGameonStart
		} else {
			GuiControl, Enable, LaunchGameonStart
		}
		GuiControl, MyWindow:, LaunchGameonStart, % LaunchGameonStart, w250 h210
		GuiControl, MyWindow:, AlwaysSaveChests, % AlwaysSaveChests, w250 h210
		GuiControl, MyWindow:, AlwaysSaveContracts, % AlwaysSaveContracts, w250 h210
		GuiControl, MyWindow:, AlwaysSaveCodes, % AlwaysSaveCodes, w250 h210
		GuiControl, MyWindow:, NoSaveSetting, % NoSaveSetting, w250 h210
		GuiControl, MyWindow:, LogEnabled, % LogEnabled, w250 h210
		GuiControl, MyWindow:, ShowResultsBlacksmithContracts, % ShowResultsBlacksmithContracts, w250 h210
		GuiControl, MyWindow:, RedeemCodeHistorySkip, % RedeemCodeHistorySkip, w250 h210
		GuiControl, MyWindow:, DisableUserDetailsReload, % DisableUserDetailsReload, w250 h210
		GuiControl, MyWindow:, DisableTooltips, % DisableTooltips, w250 h210
		GuiControl, MyWindow:, AutoRefreshMinutes, % AutoRefreshMinutes
		GuiControl, MyWindow:, ShowAPIMessages, % ShowAPIMessages
		if (StyleSelection) {
			GuiControl, Choose, StyleChoice, % StyleSelection
		}
		if (TabActive) {
			GuiControl, Choose, TabActive, % TabActive
		}

		;this.Show() - removed
	}
}

; Handle window resize — reposition all controls and ListViews to fit new dimensions
MyWindowGuiSize(GuiHwnd, EventInfo, Width, Height) {
	; SB_SetText( GuiHwnd " | " EventInfo " | " Width " | " Height )

	GuiControl, MoveDraw, Tabs, % "w" . (Width - 155) . " h" . (Height - 28)

	tabW := Width - 161
	tabH := Height - 59
	GuiControl, MoveDraw, SummaryLV, % "w" . tabW . " h" . tabH

	GuiControl, MoveDraw, AdventuresLV, % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, PatronsLV,    % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, InventoryLV,  % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, ChampionsLV,  % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, PityLV,       % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, ItemLevelsLV, % "w" . tabW . " h" . tabH
	GuiControl, MoveDraw, VariantsLV,   % "w" . tabW . " h" . (tabH - 25)
	GuiControl, MoveDraw, EventLV,      % "w" . tabW . " h" . tabH

	GuiControl, MoveDraw, OutputText, % "x4" . " w" . tabW . " h" . (Height - 65)

	GuiControl, MoveDraw, Group1, % "x" . (Width - 155) . " h" . (Height - 25)
	GuiControl, MoveDraw, BtnReload, % "x" . (Width - 145)
	GuiControl, MoveDraw, BtnExit, % "x" . (Width - 75)
	GuiControl, MoveDraw, CrashProtectStatus, % "x" . (Width - 145)
	GuiControl, MoveDraw, BtnToggle, % "x" . (Width - 145)
	GuiControl, MoveDraw, LastUpdatedTitle, % "x" . (Width - 145)
	GuiControl, MoveDraw, LastUpdated, % "x" . (Width - 145)
	GuiControl, MoveDraw, BtnUpdate, % "x" . (Width - 145)
	
	SB_SetParts(Width - 155)
	GuiControl, MoveDraw, StatusBar
}

;Hotkeys
;$F9::Reload
;$F10::ExitApp
;Hotkey - Refresh User Details
^F5::GetUserDetails()
;Hotkeys - Blacksmith Contracts
Control & Numpad1::UseBlacksmith(31) ;Tiny BS
Control & Numpad2::UseBlacksmith(32) ;Small BS
Control & Numpad3::UseBlacksmith(33) ;Medium BS
Control & Numpad4::UseBlacksmith(34) ;Large BS
Control & Numpad5::UseBlacksmith(1797) ;Huge BS
;Hotkeys - Chests
Control & NumpadDiv::BuySilver() ;Buy Chest - Silver
Control & NumpadMult::BuyGold() ;Buy Chest - Gold
Control & NumpadSub::BuyEvent() ;Buy Chest - Event
Control & Numpad7::OpenSilver() ;Open Chest - Silver
Control & Numpad8::OpenGold() ;Open Chest - Gold
Control & Numpad9::OpenEvent() ;Open Chest - Event
;Hotkeys - Bounty Contracts
Control & 7::UseBounty(17) ;Tiny Bounty
Control & 8::UseBounty(18) ;Small Bounty
Control & 9::UseBounty(19) ;Medium Bounty
Control & 0::UseBounty(20) ;Large Bounty

; Label: apply selected theme from dropdown
RunStyleChoice:
	{
		GuiControlGet, StyleChoice,, % hddl2
		SetStyle(StyleChoice)
		return
	}

; Label: toggle tooltip display on/off
RunDisableTooltips:
	{
		GuiControlGet, DisableTooltips,, % hcb11
		if (DisableTooltips == 1) {
			ToolTip, % ""
		}
		return
	}

; Label: refresh Variants tab with filtered patron data
RunVariantRefresh:
	{
		if !EnsureCredentials()
			return
		GuiControlGet, patronChoice,, VariantPatronChoice
		patronMap := BuildPatronDisplayMap()
		patronid := patronMap[patronChoice]
		if (patronid = "")
			patronid := 0

		if !FileExist("advdefs.json") {
			SB_SetText("⌛ Downloading adventure definitions...")
			AdventureList()
		}
		SB_SetText("⌛ Loading incomplete variants...")
		FileRead, AdventureFile, advdefs.json
		AdventureNames := JSON.parse(AdventureFile)

		getparams := BuildAuthParams()
		sResult := ServerCall("getcampaigndetails", getparams)
		campaignresults := JSON.parse(sResult)

		freeplaylist := {}
		for k, v in campaignresults.defines.adventure_defines {
			if (v.repeatable)
				freeplaylist.push(v.id)
		}

		Gui, MyWindow:Default
		Gui, ListView, VariantsLV
		LV_Delete()

		for k, v in campaignresults.campaigns {
			availablelist := {}
			completelist := {}
			if (patronid == 0) {
				for k2, v2 in v.available_adventure_ids
					availablelist.push(v2)
				for k2, v2 in v.completed_adventure_ids
					completelist.push(v2)
			} else {
				for k2, v2 in v.available_patron_adventure_ids {
					for k3, v3 in v2 {
						if ((k3 == patronid) && (v3[1] == 1))
							availablelist.push(k2)
					}
				}
				for k2, v2 in v.completed_patron_adventure_ids {
					for k3, v3 in v2 {
						if ((k3 == patronid) && (v3[1] == 1))
							completelist.push(k2)
					}
				}
			}
			if (availablelist[1]) {
				incompleteIds := ""
				for k2, v2 in availablelist {
					isComplete := false
					for k3, v3 in completelist {
						if (v2 = v3) {
							isComplete := true
							break
						}
					}
					isFreeplay := false
					for k3, v3 in freeplaylist {
						if (v2 = v3) {
							isFreeplay := true
							break
						}
					}
					if (!isComplete && !isFreeplay)
						incompleteIds := incompleteIds v2 ", "
				}
				if (incompleteIds != "") {
					StringTrimRight, incompleteIds, incompleteIds, 2
					LV_Add("", campaignFromID(v.campaign_id), incompleteIds)
				}
			}
		}
		if (LV_GetCount() == 0)
			LV_Add("", "All complete!", "No incomplete variants found for " patronChoice)
		Loop % LV_GetCount("Col")
			LV_ModifyCol(A_Index, "AutoHdr")
		SB_SetText("✅ Variants loaded for " patronChoice)
		return
	}

; Label: menu handler — refresh user details from API
Update_Clicked:
	{
		GetUserDetails()
		return
	}

; Label: menu handler — reload IdleCombos script
Reload_Clicked:
	{
		Reload
		return
	}

; Label: menu handler — exit IdleCombos
Exit_Clicked:
	{
		ExitApp
		return
	}

; Label: toggle crash protection monitoring on/off
Crash_Toggle:
	{
		msgbox, % CrashProtectStatus
		switch CrashProtectStatus {
			case "Crash Protect: Disabled": {
				CrashProtectStatus := "Crash Protect: Enabled"
				oMyGUI.Update()
				SB_SetText("✅ Crash Protect has been enabled!")
				CrashProtect()
			}
			case "Crash Protect: Enabled": {
				CrashProtectStatus := "Crash Protect: Disabled"
				CrashCount := 0
				oMyGUI.Update()
				SB_SetText("✅ Crash Protect has been disabled")
			}
		}
		return
	}

; Monitor game process and restart on crash (Steam only). Runs on a timer.
CrashProtect() {
	loop {
		if (CrashProtectStatus == "Crash Protect: Disabled") {
			return
		}
		While(Not WinExist("ahk_exe IdleDragons.exe")) {
			Sleep 2500
			Run, %GameClient%
			++CrashCount
			SB_SetText("✅ Crash Protect has restarted your client")
			oMyGUI.Update()
			LogFile("Restarts since enabling Crash Protect: " CrashCount)
			Sleep 10000
		}
	}
	return
}

; Cleanup handler called on script exit — remove skin and save settings
ExitFunc() {
	SkinForm(0)
	return
}

; Force script to run in 32-bit mode (required for COM/WinHttp)
RunWith(version){	
	if (A_PtrSize=(version=32?4:8)) ;For 32 set to 4 otherwise 8 for 64 bit
		Return
	SplitPath, A_AhkPath, , ahkDir ;Get directory of AutoHotkey executable
	if (!FileExist(correct := ahkDir "\AutoHotkeyU" version ".exe")) {
		MsgBox, 0x10, "Error", % "Couldn't find the " version " bit Unicode version of Autohotkey in:`n" correct
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%", %A_ScriptDir%
	ExitApp
}

; Load/apply/remove Windows theme via USkin.dll. SHA-256 verified before loading.
SkinForm(DLLPath, Param1 = "Apply", SkinName = ""){
	if (StyleSystem) {
		if(Param1 = Apply) {
			;Verify DLL hash before loading (supply-chain protection)
			if (FileExist(DLLPath)) {
				expectedHash := "9CCF45F05DC84F343D63EBCD96D2C2452257C2582EBE05C2FE317A16D62A3347"
			try {
				RunWait, % "cmd /c certutil -hashfile """ DLLPath """ SHA256 > """ A_Temp "\uskin_hash.txt""", , Hide
				FileRead, hashOutput, %A_Temp%\uskin_hash.txt
				FileDelete, %A_Temp%\uskin_hash.txt
				RegExMatch(hashOutput, "m)^([0-9a-fA-F]{64})$", hashMatch)
				if (hashMatch1 != "") {
					StringUpper, actualHash, hashMatch1
					if (actualHash != expectedHash) {
						LogFile("WARNING: USkin.dll hash mismatch — DLL NOT loaded")
						return
					}
				} else {
					; Hash could not be parsed — fail closed (do not load unverified DLL)
					LogFile("WARNING: USkin.dll hash could not be verified — DLL NOT loaded")
					return
				}
			} catch {
				; certutil or file read failed — fail closed
				LogFile("WARNING: USkin.dll hash verification failed — DLL NOT loaded")
				return
			}
			}
			DllCall("LoadLibrary", str, DLLPath)
			DllCall(DLLPath . "\USkinInit", Int, 0, Int, 0, AStr, SkinName)
		} else if(Param1 = Remove) {
			DllCall(DLLPath . "\USkinRemoveSkin")
		} else if(Param1 = Restore) {
			DllCall(DLLPath . "\USkinRestoreSkin")
		} else if(Param1 = 0) {
			DllCall(DLLPath . "\USkinExit")
		}
	}
}

; Apply selected theme and update background colour
SetStyle(SelectedStyle) {
	if (StyleSystem) {
		if (SelectedStyle) {
			SkinForm(StyleDLLPath, 0)
			if (SelectedStyle == "Default") {
				SkinForm(StyleDLLPath, Apply, StylePath . "Concave.msstyles")
			} else {
				SkinForm(StyleDLLPath, Apply, StylePath . SelectedStyle . ".msstyles")
			}
			switch (SelectedStyle) {
				case "Lakrits": BgColour := "222222"
				case "Luminous": BgColour := "F4F4F3"
				case "Mac": BgColour := "E3E3E3"
				case "Paper": BgColour := "F6F7F9"
				default: BgColour := "FFFFFF"
			}
		}
	}
	return
}

SaveSettings()
{
	oMyGUI.Submit()
	CurrentSettings.alwayssavechests := AlwaysSaveChests
	CurrentSettings.alwayssavecontracts := AlwaysSaveContracts
	CurrentSettings.alwayssavecodes := AlwaysSaveCodes
	CurrentSettings.getdetailsonstart := GetDetailsonStart
	CurrentSettings.instance_id := InstanceID
	CurrentSettings.launchgameonstart := LaunchGameonStart
	CurrentSettings.serverdetection := ServerDetection
	CurrentSettings.loadgameclient := LoadGameClient
	CurrentSettings.logenabled := LogEnabled
	CurrentSettings.nosavesetting := NoSaveSetting
	CurrentSettings.servername := ServerName
	CurrentSettings.tabactive := TabActive
	CurrentSettings.wrlpath := WRLFile
	CurrentSettings.blacksmithcontractresults := ShowResultsBlacksmithContracts
	CurrentSettings.disableuserdetailsreload := DisableUserDetailsReload
	CurrentSettings.disabletooltips := DisableTooltips
	CurrentSettings.redeemcodehistoryskip := RedeemCodeHistorySkip
	CurrentSettings.autorefreshminutes := AutoRefreshMinutes
	CurrentSettings.showapimessages := ShowAPIMessages
	if (AutoRefreshMinutes > 0) {
		SetTimer, AutoRefreshTimer, % AutoRefreshMinutes * 60000
	} else {
		SetTimer, AutoRefreshTimer, Off
	}
	if(StyleChoice == "") {
		CurrentSettings.style := StyleSelection
	} else {
		CurrentSettings.style := StyleChoice
		StyleSelection := StyleChoice
		SetStyle(StyleSelection)
	}
	PersistSettings()
	LogFile("Settings have been saved")
	SB_SetText("✅ Settings have been saved")
	return
}

ExportCSV()
{
	if !EnsureCredentials()
		return
	FormatTime, timestamp, , yyyy-MM-dd_HHmmss
	filename := "idlecombos_export_" timestamp ".csv"
	FileDelete, %filename%
	FileAppend, % "Category,Item,Value,Details`n", %filename%
	; Inventory — bounty and blacksmith from shared metadata constants
	FileAppend, % "Inventory,Gems," CurrentGems ",`n", %filename%
	FileAppend, % "Inventory,Spent Gems," SpentGems ",`n", %filename%
	FileAppend, % "Inventory,Gold Chests," CurrentGolds ",`n", %filename%
	FileAppend, % "Inventory,Silver Chests," CurrentSilvers ",`n", %filename%
	FileAppend, % "Inventory,Time Gate Pieces," CurrentTGPs ",= " Floor(CurrentTGPs/6) " Time Gates`n", %filename%
	for _, bc in BountyContracts {
		varName := bc.var
		FileAppend, % "Inventory," bc.name " Bounties," %varName% "," bc.mult " " bc.unit " Each`n", %filename%
	}
	for _, bs in BlacksmithContracts {
		varName := bs.var
		FileAppend, % "Inventory," bs.name " Blacksmiths," %varName% "," bs.mult " " bs.unit " Each`n", %filename%
	}
	; Patron data — display names from dict, values from short-name globals
	for _, pid in PatronIDs {
		pShort := PatronShortNames[pid]
		pDisplay := PatronFromID(pid)
		FileAppend, % "Patron," pDisplay " Variants," %pShort%Variants ",`n", %filename%
	}
	; Account
	FileAppend, % "Account,Champions Unlocked," ChampionsUnlockedCount ",`n", %filename%
	FileAppend, % "Account,Champions Active," ChampionsActiveCount ",`n", %filename%
	FileAppend, % "Account,Familiars," FamiliarsUnlockedCount ",`n", %filename%
	FileAppend, % "Account,Costumes," CostumesUnlockedCount ",`n", %filename%
	FileAppend, % "Account,Epic Gear," EpicGearCount ",`n", %filename%
	MsgBox, 4, Export Complete, % "Saved to " filename "`n`nOpen file?"
	IfMsgBox, Yes
		Run, %filename%
	LogFile("CSV exported: " filename)
}

; Label: save all current settings to disk
Save_Settings:
	{
		SaveSettings()
		return
	}

; Timer: auto-refresh user details at configured interval
AutoRefreshTimer:
	if (!IsBusy && UserID)
		GetUserDetails()
	return

; Timer: update sidebar elapsed-time display every second
TimestampTickTimer:
	if (SummaryDataLoaded && UserDetails.current_time) {
		elapsed := A_NowUTC
		EnvSub, elapsed, % "19700101000000", Seconds
		diff := elapsed - UserDetails.current_time
		if (diff < 60)
			relTime := diff "s ago"
		else if (diff < 3600)
			relTime := Floor(diff / 60) "m " Mod(diff, 60) "s ago"
		else if (diff < 86400)
			relTime := Floor(diff / 3600) "h " Floor(Mod(diff, 3600) / 60) "m ago"
		else
			relTime := Floor(diff / 86400) "d " Floor(Mod(diff, 86400) / 3600) "h ago"
		GuiControl, MyWindow:, LastUpdated, % LastUpdated "`n(" relTime ")"
	}
	return

; Label: show About dialog with version and credits
About_Clicked:
	{
		ScrollBox(About, "p b1 h100 w510 f{s10, Consolas}", "About")
		return
	}

; Label: show hotkey reference dialog
Hotkeys_Clicked:
	{
		ScrollBox(HotkeyInfo, "p b1 h250 w400 f{s10, Consolas}", "Hotkey Details")
		return
	}

BuySilver()
	{
		Buy_Chests(1)
		return
	}

; Label: buy silver chests via menu
Buy_Silver:
	{
		BuySilver()
		return
	}

BuyGold()
	{
		Buy_Chests(2)
		return
	}

; Label: buy gold chests via menu
Buy_Gold:
	{
		BuyGold()
		return
	}

BuyEvent()
	{
		InputBox, chestid, Opening Chests, % "Enter Chest ID?`n", , 200, 150
		if ErrorLevel
			return
		if (chestid) {
			Buy_Chests(chestid)
		}
		return
	}

; Label: buy event chests via menu (prompts for chest ID)
Buy_Event:
	{
		BuyEvent()
		return
	}

; Shared guard: warn if game client is running, otherwise open chests by ID
OpenChestIfGameClosed(chestid) {
	if (Not WinExist("ahk_exe IdleDragons.exe")) {
		Open_Chests(chestid)
	} else {
		MsgBox, 0, , % "NOTE: It's recommended to close the game client before opening chests"
	}
}

OpenSilver()
	{
		OpenChestIfGameClosed(1)
		return
	}

; Label: open silver chests via menu (checks game client running)
Open_Silver:
	{
		OpenSilver()
		return
	}

OpenGold()
	{
		OpenChestIfGameClosed(2)
		return
	}

; Label: open gold chests via menu (checks game client running)
Open_Gold:
	{
		OpenGold()
		return
	}

OpenEvent()
	{
		InputBox, chestid, Opening Chests, % "Enter Chest ID?`n", , 200, 150
		if ErrorLevel
			return
		if (chestid) {
			OpenChestIfGameClosed(chestid)
		}
		return
	}

; Label: open event chests via menu (prompts for chest ID)
Open_Event:
	{
		OpenEvent()
		return
	}

; Label: open redeem codes window with paste/autoload/submit controls
Open_Codes:
	{
		; GUI MENU
		Menu, FileMenu, Add, Auto Load Codes (Web)`tCtrl+L, Get_Codes_Autoload_Recent
		Menu, FileMenu, Add, Auto Load Codes && Run (Web)`tCtrl+R, Get_Codes_Autoload_Run_Recent
		Menu, FileMenu, Add, &Submit`tCtrl+S, Redeem_Codes
		Menu, FileMenu, Add, Show Submit &History`tCtrl+H, Redeem_Codes_History
		Menu, FileMenu, Add, &Clear Submit History`tCtrl+C, Redeem_Codes_History_Clear
		Menu, EditMenu, Add, Paste`tCtrl+V, Paste
		Menu, EditMenu, Add, Clear`tDel, Delete
		Menu, HelpMenu, Add, Open &Codes (Web)`tCtrl+O, Open_Web_Codes_Page
		Menu, MyMenuBar, Add, &File, :FileMenu
		Menu, MyMenuBar, Add, &Edit, :EditMenu
		Menu, MyMenuBar, Add, &Help, :HelpMenu

		; GUI
		Gui, CodeWindow:New
		Gui, Menu, MyMenuBar
		Gui, CodeWindow: -Resize -MaximizeBox +MinSize
		Gui, CodeWindow:Show, w230 h270, 📜 Codes
		Gui, CodeWindow:Add, Edit, r12 vCodestoEnter w190 x20 y40, IDLE-CHAM-PION-SNOW
		Gui, CodeWindow:Add, Button, vButton_Recent gGet_Codes_Autoload_Run_Recent x20 y10 w190, Load Web
		Gui, CodeWindow:Add, Button, x20 vButton_Submit gRedeem_Codes, Submit
		Gui, CodeWindow:Add, Button, x+10 vButton_Paste gPaste, Paste
		Gui, CodeWindow:Add, Button, x+10 vButton_Delete gDelete, Clear
		Gui, CodeWindow:Add, Button, x+10 gClose_Codes, Close

		; STATUS BAR
		Gui, Add, StatusBar, vCodesOutputStatus, ❗ Codes: 0/1 - Waiting... (1 code per line)
		return
	}

	Paste() {
		getChestCodes()
		loop, parse, foundCodeString, `n, `r
			CodeTotal := a_index
		GuiControl, , CodestoEnter, %foundCodeString%
		if ( CodeTotal == "") {
			CodeTotal := "0"
		}
		GuiControl, , CodesOutputStatus, ❗ Codes: 0/%CodeTotal% - Waiting... (1 code per line)
		return
	}

	Delete() {
		GuiControl, , CodestoEnter,
		GuiControl, , CodesOutputStatus, ❗ Codes: 0/0 - Waiting... (1 code per line)
		return
	}

	Open_Web_Codes_Page() {
		Run, %WebToolCodes%
		return
	}

	Get_Codes_Autoload_Recent() {
		Get_Codes_Autoload()
		return
	}

	Get_Codes_Autoload() {
		;Use XMLHTTP to download page and extract codes from allCodes JS constant
		try {
			WR := ComObjCreate("Msxml2.XMLHTTP.6.0")
			WR.Open("GET", WebToolCodes, false)
			WR.Send()
			html := WR.ResponseText
		} catch e {
			MsgBox, Failed to download codes page!`nPlease check your internet connection.`n`n%e%
			return
		}

		;Extract the allCodes JavaScript constant (matches the site's "Copy ALL Recent Active Codes" button)
		RegExMatch(html, "const allCodes = ""(.+?)""", match)
		if (match1 = "") {
			MsgBox, Could not find codes on the page.`nThe website layout may have changed again.
			return
		}

		;Replace literal \r\n escape sequences with actual newlines
		Codes := StrReplace(match1, "\r\n", "`r`n")

		clipboard := Codes

		if WinExist("📜 Codes") {
			WinActivate
			Delete()
			Paste()
		}
		return
	}

	Get_Codes_Autoload_Run_Recent() {
		Get_Codes_Autoload_Run()
		return
	}

	Get_Codes_Autoload_Run() {
		Get_Codes_Autoload()
		Redeem_Codes()
		return
	}

	Redeem_Codes_History() {
		codelistfile := ""
		If FileExist(RedeemCodeListFile)
			FileRead, codelistfile, %RedeemCodeListFile%
		ScrollBox(codelistfile, "p b1 h300 w210 f{s10, Consolas}", "Redeem Code History")
		return
	}

	Redeem_Codes_History_Clear() {
		FileDelete, %RedeemCodeListFile%
	}

	Redeem_Codes() {
		LogFile("Redeem Code Started")
		Gui, CodeWindow:Submit, NoHide
		Gui, CodeWindow:Add, Text, x+45, Codes Remaining:
		CodeList := StrSplit(CodestoEnter, "`n")
		CodeCount := CodeList.Length()
		if (CodeCount == 0) {
			CodesPending := "🚫 Codes: 0/0 - No Codes Found..."
			GuiControl, , CodesOutputStatus, % CodesPending
		} else {
			; Disable Buttons
			GuiControl, Disable, Button_Recent
			GuiControl, Disable, Button_Special
			GuiControl, Disable, Button_Permanent
			GuiControl, Disable, Button_Submit
			GuiControl, Disable, Button_Paste
			GuiControl, Disable, Button_Delete
			CodeNum := 1
			CodeTotal := CodeCount
			reruncodescount := 0
			reruncodes := ""
			usedcodescount := 0
			usedcodes := ""
			someonescodescount := 0
			someonescodes := ""
			expiredcodescount := 0
			expiredcodes := ""
			earlycodescount := 0
			earlycodes := ""
			invalidcodescount := 0
			invalidcodes := ""
			codegolds := 0
			codesilvers := 0
			codesupplys := 0
			otherchestscount := 0
			otherchestsarray := []
			;otherchests := ""
			codeepicscount := 0
			codeepics := ""
			codetgps := 0
			codepolish := 0
			tempsavesetting := 0
			codelistcount := 0
			codelistcodes := ""
			codelistfile := ""
			If FileExist(RedeemCodeListFile)
				FileRead, codelistfile, %RedeemCodeListFile%
			if (ServerDetection == 1) {
				CodesPending := "⌛ Codes: " CodeNum "/" CodeTotal " - Getting User Details..."
				GuiControl, , CodesOutputStatus, % CodesPending
				GetUserDetails()
				sleep, 2000
			}
			Gui, CodeWindow: Default
			CodesPending := "⌛ Codes: " CodeNum "/" CodeTotal " - Starting..."
			GuiControl, , CodesOutputStatus, % CodesPending
			for k, v in CodeList {
				v := StrReplace(v, "`r")
				v := StrReplace(v, "`n")
				v := Trim(v)
			CurrentCode := v
			sCode := UrlEncode(CurrentCode)
				CodeListFound := InStr(codelistfile, sCode)
				if (CodeListFound > 0 and RedeemCodeHistorySkip) {
					codelistcount += 1
					codelistcodes := codelistcodes sCode "`n"
				} else {
					EnsureCredentials()
					codeparams := BuildAuthParams() "&code=" sCode
					rawresults := ServerCall("redeemcoupon", codeparams)
					coderesults := JSON.parse(rawresults)
					rawloot := JSON.stringify(coderesults.loot_details)
					codeloot := JSON.parse(rawloot)
					if (coderesults.failure_reason == "Outdated instance id") {
						MsgBox, 4, , % "Outdated instance id. Update from server?"
						IfMsgBox, Yes
						{
							GetUserDetails()
							Gui, CodeWindow:Default
							while (InstanceID == 0) {
								sleep, 2000
							}
							codeparams := BuildAuthParams() "&code=" sCode
							rawresults := ServerCall("redeemcoupon", codeparams)
							coderesults := JSON.parse(rawresults)
							rawloot := JSON.stringify(coderesults.loot_details)
							codeloot := JSON.parse(rawloot)
						} else {
							return
						}
					}
					codelistfile := codelistfile "`n" sCode
					FileAppend, %sCode% `n, %RedeemCodeListFile%
					if (coderesults.failure_reason == "You have already redeemed this combination.") {
						usedcodescount += 1
						usedcodes := usedcodes sCode "`n"
					} else if (coderesults.failure_reason == "Someone has already redeemed this combination.") {
						someonescodescount += 1
						someonescodes := someonescodes sCode "`n"
					} else if (coderesults.failure_reason == "This offer has expired") {
						expiredcodescount += 1
						expiredcodes := expiredcodes sCode "`n"
					} else if (coderesults.failure_reason == "You can not yet redeem this combination.") {
						earlycodescount += 1
						earlycodes := earlycodes sCode "`n"
					} else if (coderesults.failure_reason == "This is not a valid combination.") {
						invalidcodescount += 1
						invalidcodes := invalidcodes sCode "`n"
					} else {
						; rerun code if json is missing properties
						if (rawloot.haskey("failure_reason") or !rawloot.haskey("loot_details")) {
							reruncodescount += 1
							reruncodes := reruncodes sCode "`n"
							codeparams := BuildAuthParams() "&code=" sCode
							rawresults := ServerCall("redeemcoupon", codeparams)
							coderesults := JSON.parse(rawresults)
							rawloot := JSON.stringify(coderesults.loot_details)
							codeloot := JSON.parse(rawloot)
						}
						for kk, vv in codeloot {
							if (vv.chest_type_id == "2") {
								codegolds += vv.count
							} else if (vv.chest_type_id == "37") {
								codesupplys += vv.count
							} else if (vv.chest_type_id == "1") {
								codesilvers += vv.count
							} else if (vv.chest_type_id) {
								;otherchests := otherchests ChestFromID(vv.chest_type_id) "`n"
								otherchestscount += vv.count
								othercheststype:= ChestFromID(vv.chest_type_id)
								if ( otherchestsarray.HasKey(othercheststype) ) {
									otherchestsarray[othercheststype] += vv.count
								} else {
									otherchestsarray[othercheststype] := 1
								}
							} else if (vv.add_time_gate_key_piece) {
								codetgps += vv.count
							} else if (vv.add_inventory_buff_id) {
								codeepicscount += vv.count
								switch vv.add_inventory_buff_id {
									case 4: codeepics := codeepics "STR (" vv.count "), "
									case 8: codeepics := codeepics "GF (" vv.count "), "
									case 16: codeepics := codeepics "HP (" vv.count "), "
									case 20: codeepics := codeepics "Bounty (" vv.count "), "
									case 34: codeepics := codeepics "BS (" vv.count "), "
									case 35: codeepics := codeepics "Spec (" vv.count "), "
									case 40: codeepics := codeepics "FB (" vv.count "), "
									case 77: codeepics := codeepics "Spd (" vv.count "), "
									case 36: codepolish += vv.count
											codeepicscount -= vv.count
									default: codeepics := codeepics vv.add_inventory_buff_id " (" vv.count "), "
								}
							}
						}
					} 
					CodeCount := % (CodeCount-1)
					CodeNum := % (CodeTotal-CodeCount)
					if (CurrentSettings.alwayssavecodes || tempsavesetting) {
						FileAppend, "{""submit_code"":""" %sCode% """}"`n, %RedeemCodeLogFile%
						FileAppend, %rawresults%`n, %RedeemCodeLogFile%
					} else if !(CurrentSettings.nosavesetting) {
						MsgBox, 4, Save Redeem Code Results, % "Save code results to " RedeemCodeLogFile "?"
						IfMsgBox, Yes
						{
							tempsavesetting := 1
							FileAppend, %sCode%`n, %RedeemCodeLogFile%
							FileAppend, %rawresults%`n, %RedeemCodeLogFile%
						}
				}
				sleep, 500
			}
			CodeNum := A_Index
			Gui, CodeWindow: Default
			CodesPending := "⌛ Codes: " CodeNum "/" CodeTotal " - Submitting..."
			GuiControl, , CodesOutputStatus, % CodesPending
			Sleep, 10
			}
			CodesPending := "⌛ Codes: " CodeNum "/" CodeTotal " - Loading Results..."
			codemessage := ""
			if (codegolds > 0) {
				codemessage := codemessage "Gold Chests:`n" codegolds "`n"
			}
			if (codesilvers > 0) {
				codemessage := codemessage "Silver Chests:`n" codesilvers "`n"
			}
			if (codesupplys > 0) {
				codemessage := codemessage "Supply Chests:`n" codesupplys "`n"
			}
			if (otherchestscount > 0) {
				codemessage := codemessage "Other Chests (" otherchestscount "):`n"
				for otherchestsindex, otherchestselement in otherchestsarray {
					codemessage := codemessage otherchestsindex " (" otherchestselement ")`n"
				}
				codemessage := codemessage "`n"
			}
			if (codepolish > 0) {
				codemessage := codemessage "Potions of Polish:`n" codepolish "`n"
			}
			if (codetgps > 0) {
				codemessage := codemessage "Time Gate Pieces:`n" codetgps "`n"
			}
			if !(codeepics == "") {
				StringTrimRight, codeepics, codeepics, 2
				codemessage := codemessage "Epic Consumables (" codeepicscount "):`n" codeepics "`n`n"
			}
			if !(earlycodes == "") {
				codemessage := codemessage "Cannot Redeem Yet (" earlycodescount "):`n" earlycodes "`n"
			}
			if !(someonescodes == "") {
				codemessage := codemessage "Someone Else Has Used (" someonescodescount "):`n" someonescodes "`n"
			}
			if !(expiredcodes == "") {
				codemessage := codemessage "Expired (" expiredcodescount "):`n" expiredcodes "`n"
			}
			if !(invalidcodes == "") {
				codemessage := codemessage "Invalid (" invalidcodescount "):`n" invalidcodes "`n"
			}
			if !(usedcodes == "") {
				codemessage := codemessage "You Already Used (" usedcodescount "):`n" usedcodes "`n"
			}
			if !(codelistcodes == "") {
				codemessage := codemessage "Skipped (" codelistcount "):`n" codelistcodes "`n"
			}
			if !(reruncodes == "") {
				codemessage := codemessage "Resubmitted (" reruncodescount "):`n" reruncodes "`n"
			}
			if (codemessage == "") {
				codemessage := "Unknown or No Results"
			}
			GuiControl, , CodesOutputStatus, % CodesPending, w350 h210
			if( DisableUserDetailsReload == 0) {
				GetUserDetails()
			}
			oMyGUI.Update()
			Gui, CodeWindow: Default
			CodesPending := "✅ Codes: " CodeTotal "/" CodeTotal " - Completed! 😎"
			GuiControl, , CodesOutputStatus, % CodesPending
			; Enable Buttons
			GuiControl, Enable, Button_Recent
			GuiControl, Enable, Button_Special
			GuiControl, Enable, Button_Permanent
			GuiControl, Enable, Button_Submit
			GuiControl, Enable, Button_Paste
			GuiControl, Enable, Button_Delete
			ScrollBox(codemessage, "p b1 h200 w250", "Redeem Codes Results")
		
			LogFile("Redeem Code Finished")
		}
		return
	}

; Label: close redeem codes window
Close_Codes:
	{
		Gui, CodeWindow:Destroy
		return
	}

; Label: launch Briv stack calculator with user inputs
Briv_Calc:
	{
		InputBox, BrivSlot4, Briv Slot 4, Please enter the percentage listed`non your Briv Slot 4 item., , 250, 150, , , , , %BrivSlot4%
		if (ErrorLevel=1) {
			return
		}
		InputBox, BrivZone, Area to Reset, Please enter the area you will reset at`nafter building up Steelbones stacks., , 250, 150, , , , , %BrivZone%
		if (ErrorLevel=1) {
			return
		}
		MsgBox, 0, BrivCalc Results, % SimulateBriv(10000)
		return
	}

; Open external tool URL in default browser
OpenWebTool(url) {
	Run, %url%
}

Open_Web_Game_Viewer() {
	OpenWebTool(WebToolGameViewer)
}

Open_Web_Data_Viewer() {
	OpenWebTool(WebToolDataViewer)
}

Open_Web_Utilities() {
	OpenWebTool(WebToolUtilities)
}

Open_Web_Utilities_Formation() {
	OpenWebTool(WebToolUtilitiesFormation)
}

Open_Web_Utilities_Modron() {
	OpenWebTool(WebToolUtilitiesModron)
}

; Label: clear the application log file
Clear_Log:
	{
		MsgBox, 4, Clear Log, Are you sure?
		IfMsgBox, Yes
		{
			FileDelete, %OutputLogFile%
			OutputText := ""
			oMyGUI.Update()
		}
		return
	}

;-----------------------------------------------------------------------------
; Shared helpers for guarded batch operations (#14, #15)
;-----------------------------------------------------------------------------

; PromptCount - Shared InputBox + validation for batch operations
; Returns: positive integer on success, -1 on cancel/invalid
PromptCount(title, prompt, width, height, defaultVal) {
	InputBox, count, %title%, %prompt%, , %width%, %height%, , , , , %defaultVal%
	if ErrorLevel
		return -1
	if count is not integer
	{
		MsgBox, Please enter a valid whole number.
		return -1
	}
	if (count < 1) {
		MsgBox, Please enter a number greater than 0.
		return -1
	}
	return count
}

; EnsureCredentials - Check UserID is set, prompt setup if not
; Returns: true if credentials available, false if user cancelled/missing
EnsureCredentials() {
	if !UserID {
		MsgBox % "Need User ID & Hash"
		FirstRun()
		return (UserID != 0 && UserID != "")
	}
	return true
}

; BeginBusyOp - Guard entry for long-running operations
; Returns: true if operation can proceed, false if blocked
BeginBusyOp() {
	if (IsBusy) {
		SB_SetText("⚠️ Another operation is in progress. Please wait.")
		return false
	}
	IsBusy := true
	if !EnsureCredentials() {
		IsBusy := false
		return false
	}
	return true
}

; EndBusyOp - Cleanup for long-running operations
EndBusyOp(statusMsg := "") {
	IsBusy := false
	if (statusMsg != "")
		SB_SetText(statusMsg)
	if (DisableUserDetailsReload == 0)
		GetUserDetails()
}

; Purchase additional chests to meet the user's open request when they don't own enough
Buy_Extra_Chests(chestid,extracount) {
	chestparams := BuildAuthParams() "&chest_type_id=" chestid "&count="
	gemsspent := 0
	while (extracount > 0) {
		SB_SetText("⌛ " ChestFromID(chestid) " remaining to purchase: " extracount)
		if (extracount < 251) {
			rawresults := ServerCall("buysoftcurrencychest", chestparams extracount)
			extracount -= extracount
		} else {
			rawresults := ServerCall("buysoftcurrencychest", chestparams "250")
			extracount -= 250
		}
		chestresults := JSON.parse(rawresults)
		if (chestresults.success == "0") {
			MsgBox % "Error: " rawresults
			LogFile("Gems Spent: " gemsspent)
			GetUserDetails()
			SB_SetText("⌛ " ChestFromID(chestid) " remaining: " count " (Error: " chestresults.failure_reason ")")
			return
		}
		gemsspent += chestresults.currency_spent
		Sleep 1000
	}
	LogFile("Gems Spent: " gemsspent)
	SB_SetText("✅ " ChestFromID(chestid) " purchase completed")
	return gemsspent
}

; Buy chests by ID with IsBusy guard. Delegates to _Buy_Chests_Inner.
Buy_Chests(chestid) {
	if !BeginBusyOp()
		return
	_Buy_Chests_Inner(chestid)
	EndBusyOp()
}

; Core chest purchase logic — prompt count, validate, batch API calls, save results
_Buy_Chests_Inner(chestid) {
	if !CurrentGems && (chestid = 1 OR chestid = 2) {
		MsgBox, 4, , No gems detected. Check server for user details?
		IfMsgBox, Yes
		{
			GetUserDetails()
		}
	}
	switch true {
		case (chestid = 1): {
			maxbuy := Floor(CurrentGems/50)
			count := PromptCount("Buying Chests", "How many Silver Chests?`n(Gems: " CurrentGems " | Cost: 50 each)`n(Max: " maxbuy ")", 280, 180, maxbuy)
			if (count = -1)
				return
			if (count > maxbuy) {
				MsgBox, 4, , Insufficient gems detected for purchase.`nContinue anyway?
				IfMsgBox, No
				{
					return
				}
			}
		}
		case (chestid = 2): {
			maxbuy := Floor(CurrentGems/500)
			count := PromptCount("Buying Chests", "How many Gold Chests?`n(Gems: " CurrentGems " | Cost: 500 each)`n(Max: " maxbuy ")", 280, 180, maxbuy)
			if (count = -1)
				return
			if (count = "alpha5") {
				chestparams := BuildAuthParams()
				rawresults := ServerCall("alphachests", chestparams)
				MsgBox % rawresults
				GetUserDetails()
				SB_SetText("✨ Ai yi yi, Zordon!")
				return
			}
			if count is not integer
			{
				MsgBox, Please enter a valid whole number.
				return
			}
			if (count < 1) {
				MsgBox, Please enter a number greater than 0.
				return
			}
			if (count > maxbuy) {
				MsgBox, 4, , Insufficient gems detected for purchase.`nContinue anyway?
				IfMsgBox, No
				{
					return
				}
			}
		}
		case (chestid > 3 and chestid <= MaxChestID): {
			maxbuy := Floor(EventTokens/10000)
			count := PromptCount("Buying Chests", "How many " ChestFromID(chestid) "?`n(" EventTokenName ": " EventTokens ")`n(Max: " maxbuy ")", 250, 180, maxbuy)
			if (count = -1)
				return
			if (count = "alpha5") {
				chestparams := BuildAuthParams()
				rawresults := ServerCall("alphachests", chestparams)
				MsgBox % rawresults
				GetUserDetails()
				SB_SetText("✨ Ai yi yi, Zordon!")
				return
			}
			if (count > maxbuy) {
				MsgBox, 4, , Insufficient %EventTokenName% detected for purchase.`nContinue anyway?
				IfMsgBox, No
				{
					return
				}
			}
		}
		default: {
			MsgBox, Invalid chest_id value.
			return
		}
	}
	if (ServerDetection == 1) {
		GetUserDetails()
		sleep, 2000
	}
	chestparams := BuildAuthParams() "&chest_type_id=" chestid "&count="
	gemsspent := 0
	tokenspent := 0
	chestsbought := 0
	while (count > 0) {
		prevCount := count
		rawresults := BatchAPICall("buysoftcurrencychest", chestparams, count, 250, ChestFromID(chestid) " remaining to purchase")
		chestsbought += (prevCount - count)
		chestresults := JSON.parse(rawresults)
		if (chestresults.success == "0") {
			MsgBox % "Error: " rawresults
			if(gemsspent > 0){
				LogFile("Gems spent: " gemsspent)
			}
			if(tokenspent > 0){
				LogFile(EventTokenName " spent: " tokenspent)
			}
			GetUserDetails()
			SB_SetText("⌛ " ChestFromID(chestid) " remaining: " count " (Error: " chestresults.failure_reason ")")
			return
		}
		if(chestid = 1 OR chestid = 2) {
			gemsspent += chestresults.currency_spent
		} else {
			tokenspent += chestresults.currency_spent
		}
		Sleep 500
	}
	if(gemsspent > 0){
		LogFile("Gems spent: " gemsspent)
	}
	if(tokenspent > 0){
		LogFile(EventTokenName " spent: " tokenspent)
	}
	if( DisableUserDetailsReload == 0) {
		GetUserDetails()
	}
	SB_SetText("✅ " chestsbought " " ChestFromID(chestid) " purchase completed.")
	return
}

; Open chests by ID with IsBusy guard. Delegates to _Open_Chests_Inner.
Open_Chests(chestid) {
	if !BeginBusyOp()
		return
	_Open_Chests_Inner(chestid)
	EndBusyOp()
}

; Core chest opening logic — prompt count, validate, batch API calls, log shinies
_Open_Chests_Inner(chestid) {
	RotateLogFile(ChestOpenLogFile)
	if (!CurrentGolds && !CurrentSilvers && !CurrentGems && (chestid = 1 OR chestid = 2) ) {
		MsgBox, 4, , No chests or gems detected. Check server for user details?
		IfMsgBox, Yes
		{
			GetUserDetails()
		}
	}
	switch true {
		case (chestid = 1): {
			count := PromptCount("Opening Chests", "How many Silver Chests?`n(Owned: " CurrentSilvers ")`n(Max: " (CurrentSilvers + Floor(CurrentGems/50)) ")", 200, 180, CurrentSilvers)
			if (count = -1)
				return
			if (count > CurrentSilvers) {
				MsgBox, 4, , % "Spend " ((count - CurrentSilvers)*50) " gems to purchase " (count - CurrentSilvers) " chests before opening?"
				extracount := (count - CurrentSilvers)
				IfMsgBox, Yes
				{
					extraspent := Buy_Extra_Chests(1,extracount)
				} else {
					return
				}
			}
		}
		case (chestid = 2): {
			count := PromptCount("Opening Chests", "How many Gold Chests?`n(Owned: " CurrentGolds ")`n(Max: " (CurrentGolds + Floor(CurrentGems/500)) ")`n`n(Feats earned using this app do not`ncount towards the related achievement.)", 360, 240, CurrentGolds)
			if (count = -1)
				return
			if (count > CurrentGolds) {
				MsgBox, 4, , % "Spend " ((count - CurrentGolds)*500) " gems to purchase " (count - CurrentGolds) " chests before opening?"
				extracount := (count - CurrentGolds)
				IfMsgBox, Yes
				{
					extraspent := Buy_Extra_Chests(2,extracount)
				} else {
					return
				}
			}
		}
		case (chestid > 3 and chestid <= MaxChestID): {
			CurrentChests := 0
			CurrentChestsLookup := ""
			for k, v in UserDetails.details.chests {
				if (k == chestid) {
					CurrentChestsLookup := v
				}
			}
			if(CurrentChestsLookup) {
				CurrentChests := CurrentChestsLookup
			}
			count := PromptCount("Opening Chests", "How many '" ChestFromID(chestid) "' Chests?`n(" EventTokenName ": " EventTokens ")`n(Owned: " CurrentChests ")`n(Max: " (CurrentChests + Floor(EventTokens/10000)) ")`n`n(Feats earned using this app do not`ncount towards the related achievement.)", 360, 240, CurrentChests)
			if (count = -1)
				return
			if (count > CurrentChests) {
				MsgBox, 4, , % "Spend " ((count - CurrentChests)*10000) " " EventTokenName " to purchase " (count - CurrentChests) " chests before opening?"
				extracount := (count - CurrentChests)
				IfMsgBox, Yes
				{
					extraspent := Buy_Extra_Chests(chestid,extracount)
				} else {
					return
				}
			}
		}
		default: {
			MsgBox, Invalid chest_id value.
			return
		}
	}
	chestparams := "&gold_per_second=0&checksum=4c5f019b6fc6eefa4d47d21cfaf1bc68&user_id=" UserID "&hash=" UserHash "&instance_id=" InstanceID "&chest_type_id=" chestid "&game_instance_id=" ActiveInstance "&count="
	tempsavesetting := 0
	lastfeat := ""
	newfeats := ""
	lastshiny := ""
	newshinies := ""
	chestresults_cumulative := {}

	while (count > 0) {
		SB_SetText("⌛ Chests remaining to open: " count)
		if (count < 1000) {
			rawresults := ServerCall("opengenericchest", chestparams count)
			Sleep, 500
			count -= count
		} else {
			rawresults := ServerCall("opengenericchest", chestparams 1000)
			Sleep, 500
			count -= 1000
		}
		if (CurrentSettings.alwayssavechests || tempsavesetting) {
			FileAppend, %rawresults%`n, %ChestOpenLogFile%
		} else {
			if !CurrentSettings.nosavesetting {
				InputBox, dummyvar, Save Chest Results, % "Save " ChestFromID(chestid) " results to " ChestOpenLogFile "?", , 300, 150, , , , , % rawresults
				dummyvar := ""
				if !ErrorLevel {
					FileAppend, %rawresults%`n, %ChestOpenLogFile%
					tempsavesetting := 1
				}
			}
		}
		chestresults := JSON.parse(rawresults)
		if ((chestresults.success == "0") || (chestresults.loot_details == "0")) {
			switch chestid {
				case "1": {
					chestsopened := (CurrentSilvers - chestresults.chests_remaining)
					if (extraspent) {
						chestsopened += (extraspent/50)
					}
					MsgBox % "New Shinies:`n" newshinies
				}
				case "2": {
					chestsopened := (CurrentGolds - chestresults.chests_remaining)
					if (extraspent) {
						chestsopened += (extraspent/500)
					}
					MsgBox % "New Feats:`n" newfeats "`nNew Shinies:`n" newshinies
				}
			}
		MsgBox % "Error: " rawresults
		LogFile("Chests Opened: " Floor(chestsopened))
		if( DisableUserDetailsReload == 0) {
			GetUserDetails()
		}
		SB_SetText("⌛ Chests remaining: " count " (Error)")
		return
	}
		for k, v in chestresults.loot_details {
			if (v.unlock_hero_feat) {
				lastfeat := (FeatFromID(v.unlock_hero_feat) "n")
				newfeats := newfeats lastfeat
			}
			if (v.gilded) {
				if ( !IsObject( chestresults_cumulative[ v.hero_id ] ) ) {
					chestresults_cumulative[ v.hero_id ] := {}
					chestresults_cumulative[ v.hero_id ][ v.slot_id ] := {}
					chestresults_cumulative[ v.hero_id ][ v.slot_id ][ gilded_count ] := 1
					if (v.disenchant_amount == 125)
						chestresults_cumulative[ v.hero_id ][ v.slot_id ][ disenchant_amount ] := v.disenchant_amount
				} else if ( !IsObject( chestresults_cumulative[ v.hero_id ][ v.slot_id ] ) ) {
					chestresults_cumulative[ v.hero_id ][ v.slot_id ] := {}
					chestresults_cumulative[ v.hero_id ][ v.slot_id ][ gilded_count ] := 1
					if (v.disenchant_amount == 125)
						chestresults_cumulative[ v.hero_id ][ v.slot_id ][ disenchant_amount ] := v.disenchant_amount
				} else {
					chestresults_cumulative[ v.hero_id ][ v.slot_id ][ gilded_count ] += 1
					if (v.disenchant_amount == 125)
						chestresults_cumulative[ v.hero_id ][ v.slot_id ][ disenchant_amount ] += v.disenchant_amount
				}
			}
		}
	}

	for k, v in chestresults_cumulative {
		for k2, v2 in v {
			if ( v2.gilded_count <= 1 ) {
				lastshiny := ( ChampFromID( k ) " (Slot " k2 ")" )
			} else {
				lastshiny := ( ChampFromID( k ) " (Slot " k2 " x " v2.gilded_count ")" )
			}
			if ( v2.disenchant_amount ) {
				lastshiny .= " +" v2.disenchant_amount
			}
			newshinies .= lastshiny "`n"
		}
	}
	tempsavesetting := 0
	switch chestid {
		case "1": {
			chestsopened := (CurrentSilvers - chestresults.chests_remaining)
			if (extraspent) {
				chestsopened += (extraspent/50)
			}
			MsgBox % "New Shinies:`n" newshinies
			LogFile("Silver Chests Opened: " Floor(chestsopened))
		}
		case "2": {
			chestsopened := (CurrentGolds - chestresults.chests_remaining)
			if (extraspent) {
				chestsopened += (extraspent/500)
			}
			MsgBox % "New Feats:`n" newfeats "`nNew Shinies:`n" newshinies
			LogFile("Gold Chests Opened: " Floor(chestsopened))
		}
	}
	if( DisableUserDetailsReload == 0) {
		GetUserDetails()
	}
	SB_SetText("✅ Chest opening completed")
	return
}

; Label: use tiny blacksmith contracts
Tiny_Blacksmith:
	{
		UseBlacksmith(31)
		return
	}

; Label: use small blacksmith contracts
Sm_Blacksmith:
	{
		UseBlacksmith(32)
		return
	}

; Label: use medium blacksmith contracts
Med_Blacksmith:
	{
		UseBlacksmith(33)
		return
	}

; Label: use large blacksmith contracts
Lg_Blacksmith:
	{
		UseBlacksmith(34)
		return
	}

; Label: use huge blacksmith contracts
Hg_Blacksmith:
	{
		UseBlacksmith(1797)
		return
	}

; Apply blacksmith contracts by buff_id with IsBusy guard. Delegates to _UseBlacksmith_Inner.
UseBlacksmith(buffid) {
	if !BeginBusyOp()
		return
	_UseBlacksmith_Inner(buffid)
	EndBusyOp()
}

; Calculate blacksmith contracts used from starting count minus remaining
BlacksmithContractsUsed(buffid, remaining) {
	switch buffid {
		case 31:   return (CurrentTinyBS - remaining)
		case 32:   return (CurrentSmBS - remaining)
		case 33:   return (CurrentMdBS - remaining)
		case 34:   return (CurrentLgBS - remaining)
		case 1797: return (CurrentHgBS - remaining)
	}
	return 0
}

; Core blacksmith logic — resolve contract metadata, prompt count, batch API calls, log results
_UseBlacksmith_Inner(buffid) {
	RotateLogFile(BlacksmithLogFile)
	; Contract metadata: buff_id → {current var, last count var, name}
	contractMeta := {31: {cur: "CurrentTinyBS", last: "LastBSTnCount", name: "Tiny"}
		, 32: {cur: "CurrentSmBS", last: "LastBSSmCount", name: "Small"}
		, 33: {cur: "CurrentMdBS", last: "LastBSMdCount", name: "Medium"}
		, 34: {cur: "CurrentLgBS", last: "LastBSLgCount", name: "Large"}
		, 1797: {cur: "CurrentHgBS", last: "LastBSHgCount", name: "Huge"}}
	meta := contractMeta[buffid]
	if !IsObject(meta)
		return
	curVar := meta.cur
	lastVar := meta.last
	currentcontracts := %curVar%
	lastcontracts := %lastVar%
	contractname := meta.name
	if !(lastcontracts) {
		lastcontracts := currentcontracts
	}
	if (lastcontracts > currentcontracts) {
		lastcontracts := currentcontracts
	}
	if !(currentcontracts) {
		MsgBox, 4, , No %contractname% Blacksmith Contracts detected. Check server for user details?
			IfMsgBox, Yes
			{
				GetUserDetails()
			}
	}
	count := PromptCount("Blacksmithing", "How many " contractname " Blacksmith Contracts?`n(Max: " currentcontracts ")", 200, 180, lastcontracts)
	if (count = -1)
		return
	if (count > currentcontracts) {
		MsgBox, 4, , Insufficient %contractname% Blacksmith Contracts detected for use.`nContinue anyway?
		IfMsgBox, No
		{
			return
		}
	}
	heroid := "error"
	InputBox, heroid, Blacksmithing, % "Use " contractname " Blacksmith Contracts on which Champ? (Enter ID)", , 200, 180, , , , , %LastBSChamp%
	if ErrorLevel
		return
	while !((heroid is number) OR ((heroid > 0) && (heroid < 107)) OR ((heroid > 112) && (heroid < 130))) {
		InputBox, heroid, Blacksmithing, % "Please enter a valid Champ ID number", , 200, 180, , , , , %LastBSChamp%
		if ErrorLevel
			return
	}
	MsgBox, 4, , % "Use " count " " contractname " Blacksmith Contracts on " ChampFromID(heroid) "?"
	IfMsgBox, No
	{
		return
	}
	LastBSChamp := heroid
	switch buffid {
		case 31: LastBSTnCount := count
		case 32: LastBSSmCount := count
		case 33: LastBSMdCount := count
		case 34: LastBSLgCount := count
		case 1797: LastBSHgCount := count
	}	
	bscontractparams := "&user_id=" UserID "&hash=" UserHash "&instance_id=" InstanceID "&buff_id=" buffid "&hero_id=" heroid "&num_uses="
	tempsavesetting := 0
	slot1lvs := 0
	slot2lvs := 0
	slot3lvs := 0
	slot4lvs := 0
	slot5lvs := 0
	slot6lvs := 0
	while (count > 0) {
		rawresults := BatchAPICall("useserverbuff", bscontractparams, count, 1000, contractname " Blacksmith Contracts remaining to use")
		if (CurrentSettings.alwayssavecontracts || tempsavesetting) {
			FileAppend, %rawresults%`n, %BlacksmithLogFile%
		} else {
			if !CurrentSettings.nosavesetting {
				InputBox, dummyvar, Save Blacksmith Results, % "Save " contractname " results for " ChampFromID(heroid) " to " BlacksmithLogFile "?", , 350, 150, , , , , % rawresults
				dummyvar := ""
				if !ErrorLevel {
					FileAppend, %rawresults%`n, %BlacksmithLogFile%
					tempsavesetting := 1
				}
			}
		}
		blacksmithresults := JSON.parse(rawresults)
		if ((blacksmithresults.success == "0") || (blacksmithresults.okay == "0")) {
		if(ShowResultsBlacksmithContracts == 1) {
			bsResult := ChampFromID(heroid) " levels gained:`nSlot 1: " slot1lvs "`nSlot 2: " slot2lvs "`nSlot 3: " slot3lvs "`nSlot 4: " slot4lvs "`nSlot 5: " slot5lvs "`nSlot 6: " slot6lvs
			MsgBox, 4, Blacksmith Results, % bsResult "`n`nCopy results to clipboard?"
			IfMsgBox, Yes
				Clipboard := bsResult
		}
		MsgBox % "Error: " rawresults
			contractsused := BlacksmithContractsUsed(buffid, blacksmithresults.buffs_remaining)
			LogFile(contractname "Blacksmith Contracts Used: " Floor(contractsused))
			if( DisableUserDetailsReload == 0) {
				GetUserDetails()
			}
			SB_SetText("⌛ " contractname " Blacksmith Contracts remaining: " count " (Error)")
			return
		}
		rawactions := JSON.stringify(blacksmithresults.actions)
		blacksmithactions := JSON.parse(rawactions)
		for k, v in blacksmithactions {
			switch v.slot_id {
				case 1: slot1lvs += v.amount
				case 2: slot2lvs += v.amount
				case 3: slot3lvs += v.amount
				case 4: slot4lvs += v.amount
				case 5: slot5lvs += v.amount
				case 6: slot6lvs += v.amount
			}
		}
	}
	if(ShowResultsBlacksmithContracts == 1) {
		bsResult := ChampFromID(heroid) " levels gained:`nSlot 1: " slot1lvs "`nSlot 2: " slot2lvs "`nSlot 3: " slot3lvs "`nSlot 4: " slot4lvs "`nSlot 5: " slot5lvs "`nSlot 6: " slot6lvs
		MsgBox, 4, Blacksmith Results, % bsResult "`n`nCopy results to clipboard?"
		IfMsgBox, Yes
			Clipboard := bsResult
	}
	tempsavesetting := 0
	contractsused := BlacksmithContractsUsed(buffid, blacksmithresults.buffs_remaining)
	LogFile(contractname " Blacksmith Contracts used on " ChampFromID(heroid) ": " Floor(contractsused))
	if( DisableUserDetailsReload == 0) {
		GetUserDetails()
	}
	SB_SetText("✅ " contractname " Blacksmith Contracts use completed")
	return
}

; Label: use tiny bounty contracts
Tiny_Bounty:
	{
		UseBounty(17)
		return
	}

; Label: use small bounty contracts
Sm_Bounty:
	{
		UseBounty(18)
		return
	}

; Label: use medium bounty contracts
Med_Bounty:
	{
		UseBounty(19)
		return
	}

; Label: use large bounty contracts
Lg_Bounty:
	{
		UseBounty(20)
		return
	}

; Perform image search and mouse click for bounty automation (alpha)
UseBountyClick(name, imagename, offset_x, offset_y, delay, repeat := 1, move_x := 0, move_y := 0) {
	FileAppend, %name%`n, %BountyLogFile%
	WinGet, PID, PID, Idle Champions
	WinActivate, ahk_pid %PID%
	ImageSearch, ix, iy, 0, 0, a_screenHeight, a_screenWidth, %A_ScriptDir%/images/%imagename%.png
	FileAppend, %name% - Errorlevel: %errorlevel% ix: %ix% iy: %iy%`n, %BountyLogFile%
	if (errorlevel == 0) {
		if (repeat > 1) {
			loop %repeat% {
				MouseClick, left, ix+offset_x, iy+offset_y
				sleep %delay%
			}
		} else {
			MouseClick, left, ix+offset_x, iy+offset_y
			if (move_x || move_y) {
				MouseMove, ix+move_x, iy+move_y
			}
			sleep %delay%
		}
		return 1
	}
	return 0
}

; Apply bounty contracts via mouse automation (alpha — requires 1280x720, not fullscreen)
UseBounty(buffid) {
	RotateLogFile(BountyLogFile)
	EnsureCredentials()
	switch buffid {
		case 17:
			currentcontracts := CurrentTinyBounties
			lastcontracts := LastBountyTnCount
			contractname := "Tiny"
			bountyimage := "bounty_tn"
		case 18:
			currentcontracts := CurrentSmBounties
			lastcontracts := LastBountySmCount
			contractname := "Small"
			bountyimage := "bounty_sm"
		case 19:
			currentcontracts := CurrentMdBounties
			lastcontracts := LastBountyMdCount
			contractname := "Medium"
			bountyimage := "bounty_md"
		case 20:
			currentcontracts := CurrentLgBounties
			lastcontracts := LastBountyLgCount
			contractname := "Large"
			bountyimage := "bounty_lg"
	}
	if !(lastcontracts) {
		lastcontracts := currentcontracts
	}
	if (lastcontracts > currentcontracts) {
		lastcontracts := currentcontracts
	}
	if !(currentcontracts) {
		MsgBox, 4, , No %contractname% Bounty Contracts detected. Check server for user details?
			IfMsgBox, Yes
			{
				GetUserDetails()
			}
	}
	count := PromptCount("Bounties", "How many " contractname " Bounty Contracts?`n(Max: " currentcontracts ")", 200, 180, lastcontracts)
	if (count = -1)
		return
	if (count > currentcontracts) {
		MsgBox, 4, , Insufficient %contractname% Bounty Contracts detected for use.`nContinue anyway?
		IfMsgBox, No
		{
			return
		}
	}
	MsgBox, 4, , % "Use " count " " contractname " Bounty Contracts?`n`nWARNING: This is an alpha feature and is prone to bugs (or just not work at all) and must be run at resolution 1280x720 and not in fullscreen`n`nNOTE: Do not touch the mouse or keyboard until process completed`n`nAUTO PROGRESS will be temporarily turned off for this process"
	IfMsgBox, No
	{
		return
	}
	FileAppend, [PROCESS START] %contractname% Bounty Contracts to use: %count%`n, %BountyLogFile%
	;bounty cancel
	UseBountyClick("BOUNTY CANCEL", "bounty_cancel", 5, 5, 500)
	;inventory close
	UseBountyClick("INVENTORY CLOSE", "inventory_close", 5, 5, 500)
	;turn auto progress off
	autoprogress := 0
	if (UseBountyClick("AUTO PROGRESS OFF", "auto_progress_on", 5, 5, 50) == 1) {
		autoprogress := 1
	}
	;inventory open
	if (UseBountyClick("INVENTORY OPEN", "inventory", 15, 15, 500) == 1) {
		contractsused := 0
		page := 1
		while (count > 0) {
			found := 0
			while (found == 0) { ;search pages for bounties
				if (page == 5) {
					FileAppend, [PROCESS COMPLETED] No %contractname% Bounty Contracts found`n, %BountyLogFile%
					msgbox % "[PROCESS COMPLETED]`n`nNo "contractname " Bounty Contracts found"
					return
				}
				;search inventory page for bounty icon
				found := UseBountyClick("FIND BOUNTY CONTRACT - PAGE " page, bountyimage, 15, 15, 500)
				if (found == 0) {
					page += 1
					UseBountyClick("INVENTORY NEXT PAGE", "inventory_next", 5, 5, 500, 1, 50, 5)
				}
			}
			if (found == 1) {
				SB_SetText("⌛ " contractname " Bounty Contracts remaining to use: " count)
				repeatcount := 0
				if (count < 50) {
					contractsused += count
					repeatcount := count
					count -= count
				} else {
					contractsused += 50
					repeatcount := 50
					count -= 50
				}
				repeatcount -= 1
				;bounty next/increase count
				UseBountyClick("INVENTORY COUNT INCREASE", "bounty_next", 10, 10, 20, repeatcount)
				;bounty go
				UseBountyClick("CLICK GO", "bounty_go", 15, 15, 750)
				if (repeatcount = 49) {
					;additional cancel
					UseBountyClick("ADDITIONAL CANCEL", "additional_cancel", 5, 5, 500)
				}
			}
		}
		;inventory close
		UseBountyClick("INVENTORY CLOSE", "inventory_close", 5, 5, 500)
		if (autoprogress == 1) {
			;turn auto progress on
			UseBountyClick("AUTO PROGRESS ON", "auto_progress_off", 5, 5, 1)
		}
		FileAppend, [PROCESS COMPLETED] %contractname% Bounty Contracts used: %contractsused%`n, %BountyLogFile%
		msgbox % "[PROCESS COMPLETED]`n`n"contractname " Bounty Contracts used: " Floor(contractsused)
		LogFile(contractname " Bounty Contracts used: " Floor(contractsused))
		GetUserDetails()
		SB_SetText("✅ " contractname " Bounty Contracts use completed")
	}
}


global lastadv := 0			;fmagdi - to be used to save ended adventureid for use as default for next load 

; Load a new adventure by ID with optional patron selection
LoadAdventure() {
	GetUserDetails()
	while !(CurrentAdventure == "Map" || CurrentAdventure == "-1") {
		MsgBox, 5, , Please end your current adventure first.
		IfMsgBox, Cancel
		{
			return
		}
	}
	advtoload := lastadv		;fmagdi - defaults to last ended adventure id, or to variable default in globals
	patrontoload := 0
	InputBox, advtoload, Adventure to Load, Please enter the adventure_id`nyou would like to load., , 250, 150, , , , , %advtoload%
	if (ErrorLevel=1) {
		return
	}
	if !((advtoload > 0) && (advtoload < 9999)) {
		MsgBox % "Invalid adventure_id: " advtoload
		return
	}
	InputBox, patrontoload, Patron to Load, Please enter the patron_id`nyou would like to load., , 250, 150, , , , , %patrontoload%
	if (ErrorLevel=1) {
		return
	}
	if !((patrontoload > -1) && (patrontoload < 5)) {
		MsgBox % "Invalid patron_id: " patrontoload
		return
	}
	advparams := BuildAuthParams() "&patron_tier=0&game_instance_id=" ActiveInstance "&adventure_id=" advtoload "&patron_id=" patrontoload
	sResult := ServerCall("setcurrentobjective", advparams)
	GetUserDetails()
	SB_SetText("✅ Selected adventure has been loaded")
	return
}

; End current foreground adventure
EndAdventure() {
	GetUserDetails()				;fmagdi - updates info before ending an adventure to be sure you are ending the correct one
	if (CurrentAdventure == "Map" || CurrentAdventure == "-1") {
		MsgBox, No current adventure active.
		return
	}
	lastadv := CurrentAdventure	;fmagdi - saves ended adventure id for use as default when loading next adventure
	EndAdventureInstance("Current", CurrentAdventure, CurrentPatron, ActiveInstance)
}

; End background party 1 adventure
EndBGAdventure() {
	if (ActiveInstance == "1") {
		bginstance := 2
	} else {
		bginstance := 1
	}
	if (BackgroundAdventure == "-1" or BackgroundAdventure == "") {
		MsgBox, No background adventure active.
		return
	}
	EndAdventureInstance("Background", BackgroundAdventure, BackgroundPatron, bginstance)
}

; End background party 2 adventure
EndBG2Adventure() {
	if (ActiveInstance == "3" or ActiveInstance == "4") {
		bginstance := 2
	} else {
		bginstance := 3
	}
	if (Background2Adventure == "-1" or Background2Adventure == "") {
		MsgBox, No background2 adventure active.
		return
	}
	EndAdventureInstance("Background2", Background2Adventure, Background2Patron, bginstance)
}

; End background party 3 adventure
EndBG3Adventure() {
	if (ActiveInstance == "4") {
		bginstance := 3
	} else {
		bginstance := 4
	}
	if (Background3Adventure == "-1" or Background3Adventure == "") {
		MsgBox, No background3 adventure active.
		return
	}
	EndAdventureInstance("Background3", Background3Adventure, Background3Patron, bginstance)
}

; Generic adventure end handler — confirms and sends softreset API call
EndAdventureInstance(label, adventure, patron, gameInstanceId) {
	MsgBox, 4, , % "Are you sure you want to end your " label " adventure?`nParty: " gameInstanceId " AdvID: " adventure " Patron: " patron
	IfMsgBox, No
	{
		return
	}
	advparams := BuildAuthParams() "&game_instance_id=" gameInstanceId
	sResult := ServerCall("softreset", advparams)
	GetUserDetails()
	SB_SetText("✅ " label " adventure has been ended")
}
;	fmagdi -stop

; Set tray icon from IconFile global
SetIcon() {
	;IdleChampions Icon
	if FileExist(IconFile) {
		Menu, Tray, Icon, %IconFile%
	}
}

; Shared platform detection engine — scans for game install using platform descriptor
tryDetectPlatform(desc, manual) {
	; Shared detection engine for platform-based game install detection.
	; Descriptor fields: checkPath, installDir, clientExe, platformName,
	;   wrlDir, loadClientId, foundMsg, notFoundMsg, skipCallback, isEpic
	; Variables not assigned here (WRLFilePath, GameClientEpic, etc.) are
	; resolved from global scope per AHK v1.1 assume-local scoping rules.

	; Epic uses JSON parsing to locate the install directory at runtime.
	if (desc.isEpic) {
		if FileExist(GameClientEpic) {
			FileRead, EpicJSONString, %GameClientEpic%
			Try {
				EpicJSONobj := JSON.parse(EpicJSONString)
			} catch e {
				if (manual)
					MsgBox, Could not parse Epic Games launcher data.
				return false
			}
			for each, item in EpicJSONobj.InstallationList {
				if item.AppName = GameIDEpic {
					epicInstallDir := item.InstallLocation "\"
					applyGameInstall(epicInstallDir, GameClientEpicLauncher, desc.platformName, epicInstallDir WRLFilePath, desc.loadClientId)
					if manual {
						MsgBox, % desc.foundMsg
						FirstRun()
						GetUserDetails()
					}
					return true
				}
			}
		}
		if manual
			MsgBox, % desc.notFoundMsg
		return false
	}

	; Standard: check if detection path exists, then apply install globals.
	checkPath := desc.checkPath
	if FileExist(checkPath) {
		wrlPath := ""
		if (desc.wrlDir != "")
			wrlPath := desc.wrlDir . WRLFilePath
		applyGameInstall(desc.installDir, desc.clientExe, desc.platformName, wrlPath, desc.loadClientId)
		if manual {
			MsgBox, % desc.foundMsg
			if (!desc.skipCallback) {
				FirstRun()
				GetUserDetails()
			}
		}
		return true
	}
	if manual
		MsgBox, % desc.notFoundMsg
	return false
}

; Detect Epic Games install (menu handler, manual mode)
detectGameInstallEpic() {
	setGameInstallEpic(true)
}

; Detect Epic Games install (auto or manual)
setGameInstallEpic(manual = false) {
	desc := {}
	desc.isEpic       := 1
	desc.platformName := "Epic Game Store"
	desc.loadClientId := 1
	desc.foundMsg     := "Epic Games install found"
	desc.notFoundMsg  := "Epic Games install NOT found"
	return tryDetectPlatform(desc, manual)
}

; Detect Steam install (menu handler, manual mode)
detectGameInstallSteam() {
	setGameInstallSteam(true)
}

; Detect Steam install (auto or manual)
setGameInstallSteam(manual = false) {
	desc := {}
	desc.isEpic       := 0
	desc.checkPath    := GameInstallDirSteam
	desc.installDir   := GameInstallDirSteam
	desc.clientExe    := GameInstallDirSteam . GameClientExe
	desc.platformName := "Steam"
	desc.wrlDir       := GameInstallDirSteam
	desc.loadClientId := 2
	desc.foundMsg     := "Steam install found"
	desc.notFoundMsg  := "Steam install NOT found"
	desc.skipCallback := 0
	return tryDetectPlatform(desc, manual)
}

; Detect Standalone install (menu handler, manual mode)
detectGameInstallStandalone() {
	setGameInstallStandalone(true)
}

; Detect Standalone install (auto or manual)
setGameInstallStandalone(manual = false) {
	desc := {}
	desc.isEpic       := 0
	desc.checkPath    := GameInstallDirStandalone
	desc.installDir   := GameInstallDirStandaloneLauncher
	desc.clientExe    := GameInstallDirStandaloneLauncher . GameClientExeStandaloneLauncher
	desc.platformName := "Standalone"
	desc.wrlDir       := GameInstallDirStandalone
	desc.loadClientId := 3
	desc.foundMsg     := "Standalone install found"
	desc.notFoundMsg  := "Standalone install NOT found"
	desc.skipCallback := 0
	if (tryDetectPlatform(desc, manual))
		return true
	return setGameInstallStandaloneLauncher(manual)
}

; Detect Standalone Launcher install (menu handler, manual mode)
detectGameInstallStandaloneLauncher() {
	setGameInstallStandaloneLauncher(true)
}

; Detect Standalone Launcher install (auto or manual)
setGameInstallStandaloneLauncher(manual = false) {
	desc := {}
	desc.isEpic       := 0
	desc.checkPath    := GameInstallDirStandaloneLauncher
	desc.installDir   := GameInstallDirStandaloneLauncher
	desc.clientExe    := GameInstallDirStandaloneLauncher . GameClientExeStandaloneLauncher
	desc.platformName := "Standalone Launcher"
	desc.wrlDir       := ""
	desc.loadClientId := 3
	desc.foundMsg     := "Standalone Launcher install found`nYou must login to the launcher and install the game first`nAfter the game is installed, launch the game`nThen rerun game detection to grab the User ID and Hash"
	desc.notFoundMsg  := "Standalone Launcher install NOT found"
	desc.skipCallback := 1
	return tryDetectPlatform(desc, manual)
}

;-----------------------------------------------------------------------------
; applyGameInstall - Apply resolved install paths to game-state globals (P3-19)
; Shared by all platform-specific setGameInstall*() functions.
;-----------------------------------------------------------------------------
applyGameInstall(installDir, client, platform, wrlPath, loadClient) {
	global GameInstallDir, GameClient, GamePlatform, WRLFile, IconFile, LoadGameClient, IconFolder, IconFilename
	GameInstallDir  := installDir
	GameClient      := client
	GamePlatform    := platform
	WRLFile         := wrlPath
	IconFile        := IconFolder IconFilename
	LoadGameClient  := loadClient
	SetIcon()
}

; Detect Console platform (menu handler, manual mode)
detectGameInstallConsole() {
	setGameInstallConsole(true)
}

; Detect Console platform (auto or manual)
setGameInstallConsole( manual = false) {
	; Detect Console install
	if FileExist(GameInstallDirStandalone) {
		; GameInstallDir := GameInstallDirStandaloneLauncher
		; GameClient := GameInstallDirStandaloneLauncher GameClientExeStandaloneLauncher
		; WRLFile := GameInstallDirStandalone WRLFilePath
		; IconFile := IconFolder IconFilename
		GamePlatform := "Console"
		LoadGameClient := 4
		ServerDetection := 0
		SetIcon()
		if manual {
	LoadGameClient  := 4
}
		return true
	}
	if manual
		msgbox Console install NOT found
	return false
}

; Initial setup wizard — detect game, extract credentials from WRL or manual input
FirstRun() {
	; Step 1: Ask which platform the game is installed on
	if (LoadGameClient == 4) {
		; Already set to console — skip platform selection
	} else {
		MsgBox, 3, IdleCombos Setup, % "Detect game install from Epic Games?`n`n(Click Yes for Epic, No to try other platforms, Cancel to enter credentials manually)"
		IfMsgBox, Yes
		{
			if (setGameInstallEpic(false)) {
				MsgBox, % "Epic Games install found at:`n" GameInstallDir
			} else {
				MsgBox, Epic Games install not found. You can enter credentials manually.
			}
		}
		IfMsgBox, No
		{
			MsgBox, 3, IdleCombos Setup, % "Detect game install from Steam?`n`n(Click Yes for Steam, No to try Standalone)"
			IfMsgBox, Yes
			{
				if (setGameInstallSteam(false)) {
					MsgBox, % "Steam install found at:`n" GameInstallDir
				} else {
					MsgBox, Steam install not found. You can enter credentials manually.
				}
			}
			IfMsgBox, No
			{
				MsgBox, 4, IdleCombos Setup, % "Detect Standalone install?"
				IfMsgBox, Yes
				{
					if (setGameInstallStandalone(false)) {
						MsgBox, % "Standalone install found at:`n" GameInstallDir
					} else {
						MsgBox, Standalone install not found. You can enter credentials manually.
					}
				}
				IfMsgBox, No
				{
					; Console / manual entry path
					LoadGameClient := 4
				}
			}
		}
		IfMsgBox, Cancel
		{
			; Skip to manual credential entry below
			LoadGameClient := 4
		}
	}

	; Step 2: Get credentials
	if (LoadGameClient == 4) {
		; Console or manual: prompt for user_id and hash directly
		InputBox, UserID, user_id, Please enter your "user_id" value., , 250, 125
		if ErrorLevel
			return
		InputBox, UserHash, hash, Please enter your "hash" value., , 250, 125
		if ErrorLevel
			return
		LogFile("User ID: " UserID " & Hash: [REDACTED] manually entered")
	} else {
		; Platform detected — try reading credentials from WRL
		if (WRLFile != "" && FileExist(WRLFile)) {
			GetIdFromWRL()
			LogFile("Platform: " GamePlatform)
			LogFile("User ID: " UserID " & Hash: [REDACTED] detected in WRL")
			GetPlayServerFromWRL()
		} else {
			MsgBox, 4, , Could not find webRequestLog.txt automatically.`nChoose install directory manually?
			IfMsgBox, Yes
			{
				FileSelectFile, WRLFile, 1, webRequestLog.txt, Select webRequestLog file, webRequestLog.txt
				if ErrorLevel
					return
				GetIdFromWRL()
				GameInstallDir := SubStr(WRLFile, 1, -67)
				GameClient := GameInstallDir "IdleDragons.exe"
			} else {
				InputBox, UserID, user_id, Please enter your "user_id" value., , 250, 125
				if ErrorLevel
					return
				InputBox, UserHash, hash, Please enter your "hash" value., , 250, 125
				if ErrorLevel
					return
				LogFile("User ID: " UserID " & Hash: [REDACTED] manually entered")
			}
		}
	}

	; Step 3: Save credentials
	CurrentSettings.user_id := UserID
	CurrentSettings.user_id_epic := UserIDEpic
	CurrentSettings.user_id_steam := UserIDSteam
	; Encrypt hash for storage (falls back to plaintext if DPAPI unavailable)
	CurrentSettings.hash := DPAPIEncrypt(UserHash)
	if (!DPAPIAvailable && UserHash != "" && UserHash != "0") {
		LogFile("WARNING: DPAPI unavailable — hash stored as plaintext")
		SB_SetText("⚠️ DPAPI unavailable — hash stored without encryption")
	}
	CurrentSettings.firstrun := 1
	CurrentSettings.wrlpath := WRLFile
	PersistSettings()
	LogFile("IdleCombos Setup Completed")
	SB_SetText("✅ User ID & Hash Ready")
	; Flag for Load() to auto-fetch after all initialization completes
	global FirstRunFetchPending := true
}

; Update CurrentTime global with formatted timestamp
UpdateLogTime() {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
}

; Append timestamped message to the application log file
LogFile(LogMessage) {
	if (LogEnabled) {
		OutputLogFile := LogFileName
		if (LogMessage) {
			UpdateLogTime()
			FileAppend, [%CurrentTime%] %LogMessage% `n, %OutputLogFile%
			FileRead, OutputText, %OutputLogFile%
			oMyGUI.Update()
		}
	} else {
		OutputLogFile := ""
	}
}

;-----------------------------------------------------------------------------
; ValidateWRLPath(path) - Ensure WRL file path is safe before reading
; Returns: true if valid, false if rejected
;-----------------------------------------------------------------------------
ValidateWRLPath(path) {
	if (path = "")
		return false
	; Must end with webRequestLog.txt
	SplitPath, path, filename
	if (filename != "webRequestLog.txt") {
		LogFile("WARNING: WRL path rejected — unexpected filename: " filename)
		return false
	}
	; Must be within a known game directory structure or the script dir
	if !InStr(path, "IdleDragons_Data") && !InStr(path, A_ScriptDir) {
		LogFile("WARNING: WRL path rejected — not in game directory or script directory: [REDACTED]")
		return false
	}
	return true
}

; Extract user credentials (user_id, hash) from the game's webRequestLog.txt
GetIDFromWRL() {
	if !ValidateWRLPath(WRLFile)
		return
	FileRead, oData, %WRLFile%
	if ErrorLevel {
		MsgBox, 4, , Could not find webRequestLog.txt file.`nChoose install directory manually?
		IfMsgBox, Yes
		{
			FileSelectFile, WRLFile, 1, webRequestLog.txt, Select webRequestLog file, webRequestLog.txt
			if ErrorLevel
				return
			FileRead, oData, %WRLFile%
		} else {
			return
		}
	}
	creds := ParseWRLCredentials(oData)
	UserID := creds.user_id
	UserHash := creds.hash
	UserIDEpic := creds.epic_id
	UserIDSteam := creds.steam_id
	oData := ; Free the memory.
	return
}

; Extract play server name from the game's webRequestLog.txt
GetPlayServerFromWRL() {
	if !ValidateWRLPath(WRLFile)
		return
	FileRead, oData, %WRLFile%
	if ErrorLevel {
		MsgBox, 4, , Could not find webRequestLog.txt file.`nChoose install directory manually?
		IfMsgBox, Yes
		{
			FileSelectFile, WRLFile, 1, webRequestLog.txt, Select webRequestLog file, webRequestLog.txt
			if ErrorLevel
				return
			FileRead, oData, %WRLFile%
		} else {
			return
		}
	}
	if (!CheckServerCallError(oData)) {
		oData :=
		return
	}
	if (ServerDetection == 1) {
		GetPlayServer(oData)
	}
	return
}

; Parse and detect play server from API response data
GetPlayServer(oData) {
	LogFile("Detecting play server")
	NewServerName := ParsePlayServerName(oData)
	playservername := ServerName
	if (NewServerName != "" && NewServerName != ServerName){
		ServerName := NewServerName
		playservername := NewServerName
		SaveSettings()
		Sleep, 250
		LogFile("Play Server Detected - " NewServerName)
	}
	return playservername
}

; Master API fetch — calls getuserdetails and cascades all Parse*() functions to populate UI
GetUserDetails(newservername = "") {
	If (newservername = "") {
		playservername := ServerName
	} else {
		playservername := newservername
	}
	Gui, MyWindow:Default
	APIStatus("⌛ Loading Data... Please wait...")
	Sleep, 10  ; Allow GUI to update status bar before blocking API call
	; LogFile("Server Name: " playservername)
	getuserparams := BuildAuthParams(false) "&include_free_play_objectives=true&instance_key=1"
	rawdetails := ServerCall("getuserdetails", getuserparams, playservername)
	; ScrollBox(rawdetails, "p b1 h700 w1000 f{s10, Consolas}", "rawdetails")
	if ( ServerError != "") {
		SB_SetText("❌ API Error: " ServerError " - Try to close and reopen Idle Champions - Server might be in Maintenance? 😟")
		ServerError := ""
	} else {
		FileDelete, %UserDetailsFile%
		FileAppend, %rawdetails%, %UserDetailsFile%
		Try {
			UserDetails := JSON.parse(rawdetails)
		} catch e {
			SB_SetText("❌ API Error: Try to close and reopen Idle Champions - Server might be in Maintenance? 😟")
			msgbox, % "API ERROR: " e.message
			return
		}
		InstanceID := UserDetails.details.instance_id
		CurrentSettings.instance_id := InstanceID
		CurrentSettings.loadgameclient := LoadGameClient
		ActiveInstance := UserDetails.details.active_game_instance_id
		PersistSettings()
		APIStatus("⌛ Parsing user data... Please wait...")
		ParseChampData()
		ParseAdventureData()
		ParseTimestamps()
		ParseInventoryData()
		ParsePatronData()
		ParseLootData()
		CheckAchievements()
		CheckBlessings()
		CheckPatronProgress()
		CheckEvents()
		APIStatus("⌛ Populating UI tabs...")
		oMyGUI.Update()
		SetTimer, TimestampTickTimer, 1000
		SB_SetText("✅ Loaded and Ready 😎")
		LogFile("User Details - Loaded")
	}
	return
}

; Extract and assign adventure instance data (foreground + 3 backgrounds) to globals
ParseAdventureData() {
	APIStatus("⌛ Parsing Data - Adventures... Please wait...")
	result := ParseAdventureDataFromDetails(UserDetails.details, ActiveInstance)
	CurrentAdventure     := result.fg.adventure
	CurrentArea          := result.fg.area
	CurrentPatron        := result.fg.patron
	FGCoreName           := result.fg.coreName
	FGCoreXP             := result.fg.coreXP
	FGCoreProgress       := result.fg.coreProgress
	CurrentChampions     := result.fg.champCount
	BackgroundAdventure  := result.bg1.adventure
	BackgroundArea       := result.bg1.area
	BackgroundPatron     := result.bg1.patron
	BGCoreName           := result.bg1.coreName
	BGCoreXP             := result.bg1.coreXP
	BGCoreProgress       := result.bg1.coreProgress
	BackgroundChampions  := result.bg1.champCount
	Background2Adventure := result.bg2.adventure
	Background2Area      := result.bg2.area
	Background2Patron    := result.bg2.patron
	BG2CoreName          := result.bg2.coreName
	BG2CoreXP            := result.bg2.coreXP
	BG2CoreProgress      := result.bg2.coreProgress
	Background2Champions := result.bg2.champCount
	Background3Adventure := result.bg3.adventure
	Background3Area      := result.bg3.area
	Background3Patron    := result.bg3.patron
	BG3CoreName          := result.bg3.coreName
	BG3CoreXP            := result.bg3.coreXP
	BG3CoreProgress      := result.bg3.coreProgress
	Background3Champions := result.bg3.champCount
	ChampionsActiveCount := result.champsActiveCount
}

; Extract and display timestamp data (last API call, next TGP drop, etc.)
ParseTimestamps() {
	APIStatus("⌛ Parsing Data - Timestamps... Please wait...")
	result := ParseTimestampsFromData(UserDetails.current_time, UserDetails.details.stats)
	LastUpdated := result.lastUpdated
	NextTGPDrop := result.nextTGPDrop
	if (result.tgpReady) {
		TrayTip, IdleCombos, Time Gate Piece is ready!, 5, 1
	}
}

; Extract and assign inventory counts (gems, chests, bounties, blacksmith contracts)
ParseInventoryData() {
	APIStatus("⌛ Parsing Data - Inventory... Please wait...")
	result := ParseInventoryDataFromDetails(UserDetails.details)
	CurrentGems         := result.gems
	SpentGems           := result.spentGems
	CurrentGolds        := result.golds
	GoldPity            := result.goldPity
	CurrentSilvers      := result.silvers
	CurrentTGPs         := result.tgps
	AvailableTGs        := result.availableTGs
	AvailableChests     := result.availableChests
	CurrentTinyBounties := result.tinyBounties
	CurrentSmBounties   := result.smBounties
	CurrentMdBounties   := result.mdBounties
	CurrentLgBounties   := result.lgBounties
	CurrentTinyBS       := result.tinyBS
	CurrentSmBS         := result.smBS
	CurrentMdBS         := result.mdBS
	CurrentLgBS         := result.lgBS
	CurrentHgBS         := result.hgBS
	AvailableTokens     := result.availableTokens
	CurrentTokens       := result.currentTokens
	AvailableFPs        := result.availableFPs
	AvailableBSLvs      := result.availableBSLvs
}

; Extract and assign patron progress data (variants, challenges, unlock status)
ParsePatronData() {
	APIStatus("⌛ Parsing Data - Patrons... Please wait...")
	result := ParsePatronDataFromDetails(UserDetails.details, CurrentTGPs, CurrentSilvers, CurrentGems, CurrentLgBounties, TotalChamps)
	for _, pid in PatronIDs {
		pName := PatronShortNames[pid]
		if !result.HasKey(pName)
			continue
		pData          := result[pName]
		pVariantsVar   := pName "Variants"
		pFPVar         := pName "FPCurrency"
		pChallengesVar := pName "Challenges"
		pRequiresVar   := pName "Requires"
		pCostsVar      := pName "Costs"
		pCompletedVar  := pName "Completed"
		pVarTotalVar   := pName "VariantTotal"
		%pVariantsVar%   := pData.variants
		%pFPVar%         := pData.fp
		%pChallengesVar% := pData.challenges
		%pRequiresVar%   := pData.requires
		%pCostsVar%      := pData.costs
		%pCompletedVar%  := pData.completed
		%pVarTotalVar%   := pData.total
	}
}

; Extract and assign loot/gear statistics (champions, familiars, costumes, epics)
ParseLootData() {
	APIStatus("⌛ Parsing Data - Loot... Please wait...")
	result := ParseLootDataFromDetails(UserDetails.details, ActiveInstance)
	ChampionsUnlockedCount := result.champsUnlocked
	FamiliarsUnlockedCount := result.familiarsUnlocked
	CostumesUnlockedCount  := result.costumesUnlocked
	EpicGearCount          := result.epicGearCount
	BrivSlot4              := result.brivSlot4
	BrivZone               := result.brivZone
}

; Extract and assign champion ownership count and stat details
ParseChampData() {
	APIStatus("⌛ Parsing Data - Champions... Please wait...")
	result := ParseChampDataFromDetails(UserDetails.details)
	TotalChamps  := result.totalChamps
	ChampDetails := result.champDetails
}	

; Colour-code patron progress indicators in the Patrons ListView
CheckPatronProgress() {
	APIStatus("⌛ Parsing Data - Patrons... Please wait...")
	; Loop over patrons — avoids 5 near-identical lines (P3-17)
	for _, pid in PatronIDs {
		pName := PatronShortNames[pid]
		pVariantsVar   := pName "Variants"
		pFPVar         := pName "FPCurrency"
		pChallengesVar := pName "Challenges"
		pCompletedVar  := pName "Completed"
		pVarTotalVar   := pName "VariantTotal"
		ColorPatronProgress(pName, %pVariantsVar%, %pFPVar%, %pChallengesVar%, %pCompletedVar%, %pVarTotalVar%)
	}
}

; Apply colour to a single patron's progress row based on completion state
; NOTE: Patron data now rendered in ListView — per-cell colouring not supported.
; Kept as no-op to avoid breaking callers; remove when CheckPatronProgress is refactored.
ColorPatronProgress(name, variants, fpCurrency, challenges, completed, variantTotal) {
	return
}

; Extract and display achievement requirements in the Summary tab
CheckAchievements() {
	APIStatus("⌛ Parsing Data - Achievements... Please wait...")
	AchievementNeeds := ""
	AchievementGearChamp := ""
	; Skip if data appears empty/unloaded (prevents misleading Todo items from zero-data)
	if (!UserDetails.details.stats.highest_level_gear)
		return
	; Find which champion holds the highest gear
	for k, v in UserDetails.details.loot {
		if ((v.enchant + 1) = UserDetails.details.stats.highest_level_gear) {
			AchievementGearChamp := ChampFromID(v.hero_id) " Slot " v.slot_id
		}
	}
	if (UserDetails.details.stats.asharra_bonds < 3) {
		needs := ""
		if !(UserDetails.details.stats.asharra_bond_human)
			needs .= " human"
		if !(UserDetails.details.stats.asharra_bond_elf)
			needs .= " elf"
		if !(UserDetails.details.stats.asharra_bond_exotic)
			needs .= " exotic"
		if (needs != "")
			AchievementNeeds .= "Asharra needs:" needs "`n"
	}
	if !((UserDetails.details.stats.area_175_gromma_spec_a + UserDetails.details.stats.area_175_gromma_spec_b + UserDetails.details.stats.area_175_gromma_spec_c) == 3) {
		needs := ""
		if !(UserDetails.details.stats.area_175_gromma_spec_a == 1)
			needs .= " mountain"
		if !(UserDetails.details.stats.area_175_gromma_spec_b == 1)
			needs .= " arctic"
		if !(UserDetails.details.stats.area_175_gromma_spec_c == 1)
			needs .= " swamp"
		if (needs != "")
			AchievementNeeds .= "Gromma needs:" needs "`n"
	}
	if !((UserDetails.details.stats.krond_cantrip_1_kills > 99) && (UserDetails.details.stats.krond_cantrip_2_kills > 99) && (UserDetails.details.stats.krond_cantrip_3_kills > 99)) {
		needs := ""
		if !(UserDetails.details.stats.krond_cantrip_1_kills > 99)
			needs .= " thunderclap"
		if !(UserDetails.details.stats.krond_cantrip_2_kills > 99)
			needs .= " shockinggrasp"
		if !(UserDetails.details.stats.krond_cantrip_3_kills > 99)
			needs .= " firebolt"
		if (needs != "")
			AchievementNeeds .= "Krond needs:" needs "`n"
	}
	if (UserDetails.details.stats.regis_specializations < 6) {
		needs := ""
		if !(UserDetails.details.stats.regis_back_magic == 1)
			needs .= " <-magic"
		if !(UserDetails.details.stats.regis_back_melee == 1)
			needs .= " <-melee"
		if !(UserDetails.details.stats.regis_back_ranged == 1)
			needs .= " <-ranged"
		if !(UserDetails.details.stats.regis_front_magic == 1)
			needs .= " magic->"
		if !(UserDetails.details.stats.regis_front_melee == 1)
			needs .= " melee->"
		if !(UserDetails.details.stats.regis_front_ranged == 1)
			needs .= " ranged->"
		if (needs != "")
			AchievementNeeds .= "Regis needs:" needs "`n"
	}
	if (UserDetails.details.stats.krydle_return_to_baldurs_gate < 3) {
		needs := ""
		if !(UserDetails.details.stats.krydle_return_to_baldurs_gate_delina == 1)
			needs .= " delina"
		if !(UserDetails.details.stats.krydle_return_to_baldurs_gate_krydle == 1)
			needs .= " krydle"
		if !(UserDetails.details.stats.krydle_return_to_baldurs_gate_minsc == 1)
			needs .= " minsc"
		if (needs != "")
			AchievementNeeds .= "Krydle needs:" needs "`n"
	}
	SummaryDataLoaded := true
}

; Placeholder for blessing data (now handled in Update)
CheckBlessings() {
	; Blessing data is now rendered directly in Update() from UserDetails
	; This function is kept as a no-op for backward compatibility with the call in GetUserDetails()
	return
}

; Extract and display active event details in the Event tab
; Reads from two API paths:
;   events_details (plural)  → main event system (tokens, active_events with heroes/chests)
;   event_details  (singular) → featured/mini-event (name, description, own heroes/chests)
CheckEvents() {
	APIStatus("⌛ Parsing Data - Events... Please wait...")
	; Main event defaults
	EventID := 0
	EventName := ""
	EventDesc := "No Event currently in Progress"
	EventTokenName := "Event Tokens"
	EventTokens := 0
	EventHeroIDs := ""
	EventHeroes := ""
	EventChestIDs := ""
	EventChests := ""
	; Mini-event defaults
	MiniEventID := 0
	MiniEventName := ""
	MiniEventDesc := ""
	MiniEventTokens := 0
	MiniEventHeroes := ""
	MiniEventChests := ""
	; ── Main event: events_details.active_events ──
	evd := UserDetails.details.events_details
	if (IsObject(evd)) {
		EventTokens := evd.tokens + 0
		if (IsObject(evd.active_events)) {
			for i, ae in evd.active_events {
				EventID := ae.event_id + 0
				; Look up event name and token name from defines
				if (IsObject(UserDetails.defines) && IsObject(UserDetails.defines.event_v2_defines)) {
					for di, def in UserDetails.defines.event_v2_defines {
						if (def.id + 0 == EventID) {
							EventName := def.name
							EventDesc := def.description
							if (IsObject(def.static_details) && IsObject(def.static_details.event_token)) {
								tokenName := def.static_details.event_token.name_plural
								if (tokenName != "")
									EventTokenName := tokenName
							}
							break
						}
					}
				}
				; Collect heroes from new, reworked, and flex lists
				heroCount := 0
				EventHeroIDs := ""
				EventHeroes := ""
				heroSources := [ae.new_hero_ids, ae.reworked_hero_ids, ae.flex_hero_ids]
				for si, src in heroSources {
					if (IsObject(src)) {
						for j, hid in src {
							if (heroCount > 0) {
								EventHeroIDs .= ","
								EventHeroes .= ", "
							}
							EventHeroIDs .= hid
							EventHeroes .= ChampFromID(hid) " (" hid ")"
							heroCount += 1
						}
					}
				}
				; Chests from boon_items
				chestCount := 0
				EventChestIDs := ""
				EventChests := ""
				if (IsObject(ae.boon_items) && IsObject(ae.boon_items.chest_type_ids)) {
					for j, cid in ae.boon_items.chest_type_ids {
						if (chestCount > 0) {
							EventChestIDs .= ","
							EventChests .= ", "
						}
						EventChestIDs .= cid
						EventChests .= ChestFromID(cid) " (" cid ")"
						chestCount += 1
					}
				}
				break ; use first active event only
			}
		}
	}
	; ── event_details (singular object) — can be main event OR mini-event ──
	ed := UserDetails.details.event_details
	if (IsObject(ed)) {
		edID := ed.event_id + 0
		edIsMini := IsObject(ed.details) && ed.details.is_mini_event
		; Grab name/description for main event regardless of active status
		if (!edIsMini && edID == EventID && ed.name != "")
			EventName := ed.name
		if (!edIsMini && edID == EventID && ed.description != "")
			EventDesc := ed.description
		if (ed.active) {
			if (edIsMini) {
			; Populate mini-event globals
			MiniEventID := edID
			MiniEventName := ed.name
			MiniEventDesc := ed.description
			MiniEventTokens := ed.user_data.event_tokens + 0
			; Heroes
			heroCount := 0
			MiniEventHeroes := ""
			if (IsObject(ed.details) && IsObject(ed.details.hero_ids)) {
				for i, hid in ed.details.hero_ids {
					if (heroCount > 0)
						MiniEventHeroes .= ", "
					MiniEventHeroes .= ChampFromID(hid) " (" hid ")"
					heroCount += 1
				}
			}
			; Chests
			chestCount := 0
			MiniEventChests := ""
			if (IsObject(ed.details) && IsObject(ed.details.chest_ids)) {
				for i, cid in ed.details.chest_ids {
					if (chestCount > 0)
						MiniEventChests .= ", "
					MiniEventChests .= ChestFromID(cid) " (" cid ")"
					chestCount += 1
				}
			}
			; If no main event, promote mini-event to primary (used by Buy/Open_Chests)
			if (EventID == 0) {
				EventID := MiniEventID
				EventName := MiniEventName
				EventDesc := MiniEventDesc
				EventTokens := MiniEventTokens
				EventHeroes := MiniEventHeroes
				EventChests := MiniEventChests
			}
		} else {
			; event_details IS the main event — enrich main event globals with name/description
			if (ed.name != "")
				EventName := ed.name
			if (ed.description != "")
				EventDesc := ed.description
			; If no main event from events_details, use event_details as primary source
			if (EventID == 0) {
				EventID := edID
				EventTokens := ed.user_data.event_tokens + 0
				heroCount := 0
				EventHeroIDs := ""
				EventHeroes := ""
				if (IsObject(ed.details) && IsObject(ed.details.hero_ids)) {
					for i, hid in ed.details.hero_ids {
						if (heroCount > 0) {
							EventHeroIDs .= ","
							EventHeroes .= ", "
						}
						EventHeroIDs .= hid
						EventHeroes .= ChampFromID(hid) " (" hid ")"
						heroCount += 1
					}
				}
				chestCount := 0
				EventChestIDs := ""
				EventChests := ""
				if (IsObject(ed.details) && IsObject(ed.details.chest_ids)) {
					for i, cid in ed.details.chest_ids {
						if (chestCount > 0) {
							EventChestIDs .= ","
							EventChests .= ", "
						}
						EventChestIDs .= cid
						EventChests .= ChestFromID(cid) " (" cid ")"
						chestCount += 1
					}
				}
			}
		}
	}
	}
	; Build display text (backward compat)
	InfoEventName := EventDesc "`n`n"
	InfoEventTokens := ""
	InfoEventHeroes := ""
	InfoEventChests := ""
	if (EventID != 0) {
		displayName := EventName != "" ? EventName : "Event " EventID
		InfoEventName := displayName " (ID:" EventID ") - " EventDesc "`n`n"
		InfoEventTokens := EventTokenName ": " EventTokens "`n`n"
		InfoEventHeroes := "HEROES: " EventHeroes "`n`n"
		InfoEventChests := "CHESTS: " EventChests "`n`n"
	}
	EventDetails := InfoEventName InfoEventTokens InfoEventHeroes InfoEventChests
}

; Display API status message in the status bar (respects ShowAPIMessages setting)
APIStatus(msg) {
	global ShowAPIMessages
	if (ShowAPIMessages)
		SB_SetText(msg)
}

; Build common auth query string (DummyData + user_id + hash + optional instance_id)
BuildAuthParams(includeInstance := true) {
	global DummyData, UserID, UserHash, InstanceID
	params := DummyData "&user_id=" UserID "&hash=" UserHash
	if (includeInstance)
		params .= "&instance_id=" InstanceID
	return params
}

; HTTPS POST to game API with retry logic and server redirect handling
ServerCall(callname, parameters, newservername = "") {
	global MockServerCallEnabled, MockServerCallResponse
	if (MockServerCallEnabled) {
		return MockServerCallResponse
	}
	If (newservername = "") {
		playservername := ServerName
	} else {
		playservername := newservername
	}
	; Validate server name against allowlist (SEC-3: prevent credential exfiltration via tampered settings)
	if !RegExMatch(playservername, "^(master|ps[0-9]+)$") {
		LogFile("WARNING: Invalid server name rejected: " playservername)
		SB_SetText("❌ Invalid server name: " playservername)
		return ""
	}
		APIStatus("⌛ Contacting API Server (" playservername ")... '" callname "'... Please wait...")
	URLtoCall := "https://" playservername ".idlechampions.com/~idledragons/post.php?call=" callname parameters
	data := ""
	maxRetries := 3
	retryDelay := 1000
	Loop % maxRetries {
		WR := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WR.SetTimeouts(0, 60000, 30000, 120000)
		Try {
			WR.Open("POST", URLtoCall, false)
			WR.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
			WR.Send()
			WR.WaitForResponse()
			data := WR.ResponseText
			WR.Close()
		}
		if (data != "")
			break
		if (A_Index < maxRetries) {
				APIStatus("⚠️ Retry " A_Index "/" maxRetries " in " Floor(retryDelay/1000) "s...")
			Sleep, %retryDelay%
			retryDelay *= 2
		} else {
			SB_SetText("❌ API call failed after " maxRetries " attempts")
			LogFile("API FAILED (" playservername "): " callname)
		}
	}
	LogFile("API Call (" playservername "): " callname)
	if (InStr(data, "switch_play_server")) {
		newserver := ParsePlayServerName(data)
		if (newserver != "" && newserver != playservername) {
			ServerName := newserver
			SaveSettings()
			LogFile("Play Server Switched: " playservername " -> " newserver)
			return ServerCall(callname, parameters, newserver)
		}
	}
	APIStatus("⌛ Contacting API Server (" playservername ")... '" callname "'... Done...")
	if( !CheckServerCallError(data) ) {
		return
	}
	return data
}

;-----------------------------------------------------------------------------
; BatchAPICall - Sends ONE batch to the API server, updates count ByRef.
; Returns the raw response string for that batch.
;   callname     - API call name (e.g. "buysoftcurrencychest")
;   params       - Full query-string prefix ending before the numeric count
;   count        - Remaining quantity (decremented ByRef by this batch)
;   batchSize    - Maximum items per single API call
;   statusPrefix - Text shown in SB before the remaining count
;-----------------------------------------------------------------------------
BatchAPICall(callname, params, ByRef count, batchSize, statusPrefix) {
	batch := (count < batchSize) ? count : batchSize
	APIStatus("⌛ " statusPrefix ": " count)
	rawresults := ServerCall(callname, params batch)
	count -= batch
	return rawresults
}

; Start game client (Epic/Steam/Standalone) based on LoadGameClient setting
LaunchGame() {
	if( GamePlatform == "Standalone Launcher") {
		if (Not WinExist("ahk_exe IdleDragonsLauncher.exe")) {
			Run, %GameClient%, %GameInstallDir%
			SB_SetText("⌛ Game Launcher starting...")
			WinWait, Idle Champions
			LogFile("Game Launcher Launched")
			SB_SetText("✅ Game Launcher has started!")
		} else {
			SB_SetText("✅ Game Launcher is already running!")
		}
		return
	}
	if (Not WinExist("ahk_exe IdleDragons.exe")) {
		Run, %GameClient%, %GameInstallDir%
		SB_SetText("⌛ Game Client starting...")
		WinWait, Idle Champions
		LogFile("Game Client Launched")
		SB_SetText("✅ Game Client has started!")
	} else {
		SB_SetText("✅ Game Client is already running!")
	}
	return
}

; Label: download journal pages from game API
Get_Journal:
	{
		EnsureCredentials()
		if (InstanceID = 0) {
			MsgBox, 4, , No Instance ID detected. Check server for user details?
				IfMsgBox, Yes
				{
					GetUserDetails()
				} else {
					return
				}
		}
		journalparams := "&user_id=" UserID "&hash=" UserHash "&instance_id=" InstanceID "&page="
		InputBox, pagecount, Journal, % "How many pages of Journal to retreive?`n`n(This will overwrite any previous download.)", , 350, 180
		if ErrorLevel
			return
		pagenum := 1
		FileDelete, %JournalFile%
		while !(pagenum > pagecount) {
			SB_SetText("⌛ Journal pages remaining to download: " ((pagecount - pagenum) + 1))
			rawresults := ServerCall("getPlayHistory", journalparams pagenum)
			FileAppend, %rawresults%`n, %JournalFile%
			pagenum += 1
			sleep 1000
		}
		LogFile("Journal pages downloaded: " (pagenum - 1))
		SB_SetText("✅ Journal download completed")
		return
	}

; Label: open CNE support ticket URL in browser
Open_Ticket:
	{
		if (GamePlatform = "Steam"){
			Run, % "https://help.idlechampions.com/?page=help&steam_user_id=" UserIDSteam "&steam_hash=" GameHashSteam "&user_id=" UserID
		} else if (GamePlatform = "Epic Game Store") {
			Run, % "https://help.idlechampions.com/?page=help&network=epicgames&epic_games_user_id=" UserIDEpic "&epic_games_hash=" GameHashEpic "&language_id=1&user_id=" UserIDEpic
		}
		return
	}

; Label: open Discord support server link
Discord_Clicked:
	{
		Run, % WebToolDiscord
		return
	}

; Label: open GitHub project page
Github_Clicked:
	{
		Run, % WebToolGithub
		return
	}

; Download and verify dictionary update from GitHub raw URL
Update_Dictionary() {
	if !(DictionaryVersion == CurrentDictionary) {
		;Download to temp file first for integrity verification
		tempFile := LocalDictionary ".tmp"
		UrlDownloadToFile, %DictionaryFile%, %tempFile%
		if ErrorLevel {
			MsgBox, Failed to download dictionary update.`nPlease check your internet connection.
			FileDelete, %tempFile%
			return
		}
		;Verify downloaded file is valid JSON with expected structure
		FileRead, tempContent, %tempFile%
		Try {
			tempParsed := JSON.parse(tempContent)
		} catch e {
			MsgBox, Downloaded dictionary file is not valid JSON.`nUpdate aborted for safety.
			FileDelete, %tempFile%
			return
		}
		if (!tempParsed.version || !tempParsed.champions) {
			MsgBox, Downloaded dictionary file appears invalid.`nUpdate aborted for safety.
			FileDelete, %tempFile%
			return
		}
		;Reject downgrades — downloaded version must be >= current
		if (tempParsed.version < DictionaryVersion) {
			dlVer := tempParsed.version
			MsgBox, % "Downloaded dictionary (v" dlVer ") is older than current (v" DictionaryVersion ").`nUpdate aborted for safety."
			FileDelete, %tempFile%
			return
		}
		;Replace local dictionary with verified download
		FileDelete, %LocalDictionary%
		FileMove, %tempFile%, %LocalDictionary%
		Reload
		return
	} else {
		MsgBox % "Dictionary file up to date"
	}
	return
}

;=============================================================================
; DICTIONARY SYNC FROM API
;=============================================================================

;-----------------------------------------------------------------------------
; Sync_Dictionary_From_API - Fetch live definitions, diff, preview, merge
;-----------------------------------------------------------------------------
Sync_Dictionary_From_API() {
	global _dict, LocalDictionary, DictionaryVersion, MaxChampID, MaxChestID

	SB_SetText("⌛ Fetching definitions from game API...")

	; Step 1: Fetch definitions
	rawDefs := FetchDefinitionsForSync()
	if (rawDefs = "") {
		MsgBox, 16, Dictionary Sync, Failed to retrieve definitions from the game API.`nNo changes were made.
		SB_SetText("❌ Dictionary sync failed")
		return
	}

	; Step 2: Parse response
	Try {
		defsObj := JSON.parse(rawDefs)
	} catch e {
		MsgBox, 16, Dictionary Sync, Failed to parse definitions JSON.`nNo changes were made.
		SB_SetText("❌ Dictionary sync failed - invalid JSON")
		return
	}

	if (!defsObj.HasKey("success") || !defsObj.success) {
		MsgBox, 16, Dictionary Sync, API returned an error response.`nNo changes were made.
		SB_SetText("❌ Dictionary sync failed - API error")
		return
	}

	; Step 3: Extract definition maps from API response
	hasChamps := IsObject(defsObj.champion_defines) && defsObj.champion_defines.Length() > 0
	hasChests := IsObject(defsObj.chest_type_defines) && defsObj.chest_type_defines.Length() > 0
	hasCampaigns := IsObject(defsObj.campaign_defines) && defsObj.campaign_defines.Length() > 0
	hasPatrons := IsObject(defsObj.patron_defines) && defsObj.patron_defines.Length() > 0
	hasFeats := IsObject(defsObj.feat_defines) && defsObj.feat_defines.Length() > 0

	if (!hasChamps && !hasChests && !hasCampaigns && !hasPatrons && !hasFeats) {
		MsgBox, 16, Dictionary Sync, API response contained no definitions.`nNo changes were made.
		SB_SetText("❌ Dictionary sync failed - empty definitions")
		return
	}

	SB_SetText("⌛ Comparing definitions...")

	; Preserve curated local overrides (chest 205 = "DO NOT USE")
	preserveChestKeys := {}
	for id, name in _dict.chests {
		if (InStr(name, "DO NOT USE"))
			preserveChestKeys[id + 0] := true
	}

	; Extract maps from API arrays
	champResult := hasChamps ? ExtractDefinitionMap(defsObj.champion_defines) : {"items": {}, "skipped": 0, "maxId": 0}
	chestResult := hasChests ? ExtractDefinitionMap(defsObj.chest_type_defines) : {"items": {}, "skipped": 0, "maxId": 0}
	campaignResult := hasCampaigns ? ExtractDefinitionMap(defsObj.campaign_defines) : {"items": {}, "skipped": 0, "maxId": 0}
	patronResult := hasPatrons ? ExtractDefinitionMap(defsObj.patron_defines) : {"items": {}, "skipped": 0, "maxId": 0}

	; Feats need special handling: API returns hero_id + name, local dict stores "ChampName (FeatName)"
	; Build a champion ID→name lookup from the API response for feat formatting
	featResult := hasFeats ? ExtractFeatDefinitionMap(defsObj.feat_defines, champResult.items, _dict.champions) : {"items": {}, "skipped": 0, "maxId": 0}

	; Diff each section
	champDiff := DiffDefinitionSection(_dict.champions, champResult.items)
	chestDiff := DiffDefinitionSection(_dict.chests, chestResult.items, preserveChestKeys)
	campaignDiff := DiffDefinitionSection(_dict.campaigns, campaignResult.items)
	patronDiff := DiffDefinitionSection(_dict.patrons, patronResult.items)
	featDiff := DiffDefinitionSection(_dict.feats, featResult.items)

	; Step 4: Check for changes
	allDiffs := [champDiff, chestDiff, campaignDiff, patronDiff, featDiff]
	totalChanges := 0
	for _, d in allDiffs
		totalChanges += d.newCount + d.changedCount

	if (totalChanges = 0) {
		MsgBox, 64, Dictionary Sync, Dictionary is up to date.`n`nNo new definitions were found.
		SB_SetText("✅ Dictionary is up to date")
		return
	}

	; Step 5: Show preview
	totalSkipped := champResult.skipped + chestResult.skipped + campaignResult.skipped + patronResult.skipped + featResult.skipped
	sectionDiffs := []
	sectionDiffs.Push({"label": "CHAMPIONS", "diff": champDiff})
	sectionDiffs.Push({"label": "CHESTS", "diff": chestDiff})
	sectionDiffs.Push({"label": "CAMPAIGNS", "diff": campaignDiff})
	sectionDiffs.Push({"label": "PATRONS", "diff": patronDiff})
	sectionDiffs.Push({"label": "FEATS", "diff": featDiff})
	previewText := BuildSyncPreviewTextMulti(sectionDiffs, totalSkipped)
	ScrollBox(previewText, "p b1 h400 w700 f{s10, Consolas}", "Dictionary Sync Preview")

	; Step 6: Confirm
	MsgBox, 4, Dictionary Sync, % "Found " totalChanges " change(s).`n`nApply these changes to idledict.json and reload IdleCombos?"
	IfMsgBox, No
	{
		SB_SetText("Dictionary sync cancelled")
		return
	}

	; Step 7: Apply changes
	SB_SetText("⌛ Applying dictionary changes...")
	ApplySyncSectionToDict(_dict, "champions", champDiff)
	ApplySyncSectionToDict(_dict, "chests", chestDiff)
	ApplySyncSectionToDict(_dict, "campaigns", campaignDiff)
	ApplySyncSectionToDict(_dict, "patrons", patronDiff)
	ApplySyncSectionToDict(_dict, "feats", featDiff)

	; Update max IDs
	currentMaxChamp := _dict.max_champ_id + 0
	currentMaxChest := _dict.max_chest_id + 0
	if (champResult.maxId > currentMaxChamp)
		_dict.max_champ_id := "" champResult.maxId
	if (chestResult.maxId > currentMaxChest)
		_dict.max_chest_id := "" chestResult.maxId

	; Step 8: Write with backup
	if !WriteDictionaryJson(_dict) {
		MsgBox, 16, Dictionary Sync, Failed to write idledict.json.`nNo changes were applied.
		SB_SetText("❌ Dictionary sync failed - write error")
		return
	}

	logMsg := "Dictionary Sync:"
	for _, s in sectionDiffs {
		if (s.diff.newCount > 0 || s.diff.changedCount > 0)
			logMsg .= " " s.label " +" s.diff.newCount "/~" s.diff.changedCount
	}
	LogFile(logMsg)
	Reload
	return
}

;-----------------------------------------------------------------------------
; FetchDefinitionsForSync - Two-step: resolve defs server, then getDefinitions
;-----------------------------------------------------------------------------
FetchDefinitionsForSync() {
	global DummyData

	; Step 1: Resolve definitions server
	defsServerRaw := ServerCall("getPlayServerForDefinitions", DummyData, "master")
	if (defsServerRaw = "")
		return ""

	defsServer := ParsePlayServerName(defsServerRaw)
	if (defsServer = "") {
		; Fallback: try master directly
		defsServer := "master"
	}

	; Step 2: Request filtered definitions (no auth needed)
	defsParams := DummyData "&filter=champion_defines,chest_type_defines,campaign_defines,patron_defines,feat_defines"
	return ServerCall("getDefinitions", defsParams, defsServer)
}

;-----------------------------------------------------------------------------
; WriteDictionaryJson(dictObj) - Atomic write with backup
;-----------------------------------------------------------------------------
WriteDictionaryJson(dictObj) {
	global LocalDictionary

	jsonText := JSON.stringify(dictObj)
	tempFile := LocalDictionary ".tmp"
	backupFile := LocalDictionary ".bak"

	; Write to temp file
	FileDelete, %tempFile%
	FileAppend, %jsonText%, %tempFile%, UTF-8
	if ErrorLevel {
		FileDelete, %tempFile%
		return false
	}

	; Validate by parsing back
	FileRead, verifyText, %tempFile%
	Try {
		verifyObj := JSON.parse(verifyText)
	} catch e {
		FileDelete, %tempFile%
		return false
	}

	; Verify required keys survived roundtrip
	if (!verifyObj.HasKey("version") || !verifyObj.HasKey("champions") || !verifyObj.HasKey("chests")) {
		FileDelete, %tempFile%
		return false
	}

	; Backup current file
	if FileExist(LocalDictionary)
		FileCopy, %LocalDictionary%, %backupFile%, 1

	; Replace
	FileDelete, %LocalDictionary%
	FileMove, %tempFile%, %LocalDictionary%
	return true
}

; Label: display user ID, masked hash, and platform IDs
List_UserDetails:
	{
		hashMasked := "****" (StrLen(UserHash) > 0 ? " (" StrLen(UserHash) " chars)" : "")
		userdetailslist := "Game Platform: " GamePlatform "`n"
		userdetailslist := userdetailslist "User ID: " UserID "`n"
		userdetailslist := userdetailslist "User Hash: " hashMasked " (masked for security)`n"
		if UserIDEpic {
			userdetailslist := userdetailslist "Epic Games User ID: " UserIDEpic "`n"
		}
		if UserIDSteam {
			userdetailslist := userdetailslist "Steam User ID: " UserIDSteam "`n"
		}
		ScrollBox(userdetailslist, "p b1 h100 w700 f{s14, Consolas}", "User Details")
		return	
	}

; Label: display all champion IDs and names from dictionary
List_ChampIDs:
	{
		champnamelen := 0
		champname := ""
		id := 1
		champidlist := ""
		while (id <= MaxChampID) {
			champname := ChampFromID(id)
			StringLen, champnamelen, champname
			while (champnamelen < 25) {
				champname := champname " "
				champnamelen += 1
			}
			if (!mod(id, 3)) {
				champidlist := champidlist id ": " champname "`n"
			} else {
				champidlist := champidlist id ": " champname "`t"
			}
			id += 1
		}
		ScrollBox(champidlist, "p b1 h700 w1000 f{s14, Consolas}", "Champion IDs and Names")
		return	
	}


; Label: display all chest IDs and names from dictionary
List_ChestIDs:
	{
		chestnamelen := 0
		chestname := ""
		id := 1
		chestidlist := ""
		while (id <= MaxChestID) {
			chestname := ChestFromID(id)
			StringLen, chestnamelen, chestname
			while (chestnamelen < 40) {
				chestname := chestname " "
				chestnamelen += 1
			}
			if (!mod(id, 2)) {
				chestidlist := chestidlist id ": " chestname "`n"
			} else {
				chestidlist := chestidlist id ": " chestname "`t"
			}
			id += 1
		}
		ScrollBox(chestidlist, "p b1 h700 w1000 f{s14, Consolas}", "Chest IDs and Names")
		return	
	}

; Display game client localSettings.json contents in a dialog
ViewICSettings() {
	rawicsettings := ""
	FileRead, rawicsettings, %ICSettingsFile%
	Try {
		CurrentICSettings := JSON.parse(rawicsettings)
	} catch e {
		MsgBox, 16, IC Settings Error, % "Failed to parse localSettings.json: " e.message
		return
	}
	MsgBox, , localSettings.json file, % rawicsettings
}

; Prompt and update UI scale in game client settings
SetUIScale() {
	UpdateICSetting("UIScale", "UI Scale", "Please enter the desired UI Scale.`n(0.5 - 1.25)", 0.5, 1.25, "UI Scale")
}

; Prompt and update framerate in game client settings
SetFramerate() {
	UpdateICSetting("TargetFramerate", "Framerate", "Please enter the desired Framerate.`n(1 - 240)", 1, 240, "Framerate")
}

; Prompt and update particle percentage in game client settings
SetParticles() {
	UpdateICSetting("PercentOfParticlesSpawned", "Particles", "Please enter the desired Percentage.`n(0 - 100)", 0, 100, "Particles")
}

; Generic game client setting updater — read, modify, and write back localSettings.json
UpdateICSetting(settingKey, title, prompt, minVal, maxVal, logName) {
	FileRead, rawicsettings, %ICSettingsFile%
	Try {
		CurrentICSettings := JSON.parse(rawicsettings)
	} catch e {
		MsgBox, 16, IC Settings Error, % "Failed to parse localSettings.json: " e.message "`nSetting not changed."
		return
	}
	currentVal := CurrentICSettings[settingKey]
	InputBox, newVal, %title%, %prompt%, , 250, 150, , , , , %currentVal%
	if ErrorLevel
		return
	while ((newVal < minVal) || (newVal > maxVal)) {
		InputBox, newVal, %title%, Please enter a valid value.`n(%minVal% - %maxVal%), , 250, 150, , , , , %currentVal%
		if ErrorLevel
			return
	}
	CurrentICSettings[settingKey] := newVal
	if (!WriteJsonAtomic(ICSettingsFile, CurrentICSettings)) {
		MsgBox, 16, IC Settings Error, Failed to write settings. Change not saved.
		return
	}
	LogFile(logName " changed to " newVal)
	SB_SetText("✅ " logName " changed to " newVal)
}

; GUI wrapper for Briv stack calculator — prompts for inputs, displays results
SimulateBriv(i) {
	SB_SetText("⌛ Calculating...")
	r := SimulateBrivCalc(BrivSlot4, BrivZone, i)
	message := "With Briv skip " r.skipLevels " until zone " BrivZone "`n(" r.trueChance "% chance to skip " r.skipLevels " zones)`n`n" i " simulations produced an average:`n" r.avgSkips " skips (" r.avgSkipped " zones skipped)`n" r.avgZones " end zone`n" r.avgSkipRate "% true skip rate`n" r.avgStacks " required stacks with`n" r.roughTime " time in secs to build said stacks very rough guess"
	SB_SetText("✅ Calculation has completed")
	Return message
}

; Generate and open formation image from Kleho for current adventure
KlehoImage() {
	campaignid := 0
	currenttimegate := ""
	kleholink := "https://idle.kleho.ru/assets/fb/"
	for k, v in UserDetails.defines.campaign_defines {
		campaignid := v.id
	}
	if (campaignid == 17) {
		for k, v in UserDetails.details.game_instances {
			if (v.game_instance_id == ActiveInstance) {
				currenttimegate := JSON.stringify(v.defines.adventure_defines[1].requirements[1].champion_id)
			}
		}
		campaignid := KlehoFromID(currenttimegate)
	} else if !((campaignid < 3) or (campaignid == 15) or (campaignid > 21)) {
		for k, v in UserDetails.details.game_instances {
			if (v.game_instance_id == ActiveInstance) {
				campaignid := campaignid "a" JSON.stringify(v.defines.adventure_defines[1].requirements[1].adventure_id)
			}
		}
	}
	kleholink := kleholink campaignid "/"
	for k, v in UserDetails.details.game_instances {
		if (v.game_instance_id == ActiveInstance) {
			for kk, vv in v.formation {
				if (vv > 0) {
					kleholink := kleholink vv "_"
				} else {
					kleholink := kleholink "_"
				}
			}
		}
	}
	StringTrimRight, kleholink, kleholink, 1
	kleholink := kleholink ".png"
	InputBox, dummyvar, Kleho Image, % "Copy link for formation sharing.`n`nSave image to the following file?`nformationimages\Patron-" CurrentPatron "\AdvID-" CurrentAdventure "\Area-" CurrentArea ".png", , , , , , , , % kleholink
	if ErrorLevel {
		dummyvar := ""
		return
	}
	if !(FileExist("\formationimages\")) {
		FileCreateDir, formationimages
	}
	if !(FileExist("\formationimages\Patron-" CurrentPatron)) {
		FileCreateDir, % "formationimages\Patron-" CurrentPatron
	}
	if !(FileExist("\formationimages\Patron-" CurrentPatron "\AdvID-" CurrentAdventure)) {
		FileCreateDir, % "formationimages\Patron-" CurrentPatron "\AdvID-" CurrentAdventure
	}
	UrlDownloadToFile, %kleholink%, % "formationimages\Patron-" CurrentPatron "\AdvID-" CurrentAdventure "\Area-" CurrentArea ".png"
	dummyvar := ""
	return
}

; Fetch and cache adventure definitions from API for the Variants tab
AdventureList() {
	getparams := BuildAuthParams()
	sResult := ServerCall("getcampaigndetails", getparams)
	campaignresults := JSON.parse(sResult)
	freeplayids := {}
	freeplaynames := {}
	for k, v in campaignresults.defines.adventure_defines {
		freeplayids.push(v.id)
		freeplaynames.push(v.name)
	}
	count := 1
	testvar := "{"
	while (count < freeplayids.Count()) {
		testvar := testvar """" JSON.stringify(freeplayids[count]) """:"
		tempname := JSON.stringify(freeplaynames[count])
		testvar := testvar tempname ","
		count += 1
	}
	StringTrimRight, testvar, testvar, 1
	testvar := testvar "}"
	FileDelete, advdefs.json
	FileAppend, %testvar%, advdefs.json
	MsgBox % "advdefs.json saved to file"
	return
}

; Display active patron feats for the heroes in the current formation
PatronFeats() {
	assignedfeats := ""
	for k, v in UserDetails.details.heroes {
		for k2, v2 in v.active_feats {
			switch JSON.stringify(v2) {
				case "272": assignedfeats := assignedfeats "Celeste CON+1`n"
				case "13": assignedfeats := assignedfeats "Celeste INT+1`n"
				case "107": assignedfeats := assignedfeats "Drizzt INT+1`n"
				case "138": assignedfeats := assignedfeats "Nrakk INT+1`n"
				case "193": assignedfeats := assignedfeats "Zorbu INT+1`n"
				case "208": assignedfeats := assignedfeats "Nerys INT+1`n"
				case "229": assignedfeats := assignedfeats "Rosie INT+1`n"
				case "361": assignedfeats := assignedfeats "Gromma INT+1`n"
				default: assignedfeats := assignedfeats
			}
		}
	}
	if (assignedfeats = "") {
		assignedfeats := "None"
	}
	MsgBox % assignedfeats
	return
}
