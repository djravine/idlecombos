;=============================================================================
; IdleCombosLib.ahk - Shared library of pure/testable functions
; Both the main app and test suite include this file.
;=============================================================================

;=============================================================================
; TEST MODE
;=============================================================================
; Set to true by test runners BEFORE including this file.
; When true, MsgBox/ExitApp calls in the lib are suppressed.
if !TestMode
	global TestMode := false

;=============================================================================
; DICTIONARY (loaded from idledict.json)
;=============================================================================

;Load dictionary data from JSON
FileRead, _dictRaw, %A_WorkingDir%\idledict.json
Try {
	global _dict := JSON.parse(_dictRaw)
} catch e {
	if (!TestMode) {
		MsgBox, 16, IdleCombos Error, % "Failed to parse idledict.json: " e.message "`n`nPlease re-download or run Update Dictionary from the Help menu."
		ExitApp
	}
}
_dictRaw := "" ;Free memory

global DictionaryVersion := _dict.version
global MaxChampID := _dict.max_champ_id
global MaxChestID := _dict.max_chest_id

; Get Patron Name from Patron ID
PatronFromID(patronid) {
	global _dict
	result := _dict.patrons[patronid + 0]
	return result ? result : ""
}

; Get Campaign Name from Campaign ID
campaignFromID(campaignid) {
	global _dict
	result := _dict.campaigns[campaignid + 0]
	return result ? result : "Error: " campaignid
}

; Get Champion Name from Champion ID
ChampFromID(id) {
	global _dict
	result := _dict.champions[id + 0]
	return result ? result : "UNKNOWN"
}

; Get Feat Name from Feat ID
FeatFromID(id) {
	global _dict
	result := _dict.feats[id + 0]
	return result ? result : "UNKNOWN"
}

; Get Chest Name from Chest ID
ChestFromID(id) {
	global _dict
	result := _dict.chests[id + 0]
	return result ? result : "UNKNOWN"
}

; Get Kleho Campaign from Time Gate ID
KlehoFromID(id) {
	global _dict
	result := _dict.kleho[id + 0]
	return result ? result : ""
}

; Get Chest ID from Champion ID
ChestIDFromChampID(id) {
	global _dict
	result := _dict.chest_from_champ[id + 0]
	return result ? result : "UNKNOWN"
}

;=============================================================================
; CODE PARSING
;=============================================================================

;-----------------------------------------------------------------------------
; getChestCodes() - Extract redeem codes from clipboard text
; Returns: newline-separated string of found codes (12 or 16 chars, deduplicated)
;-----------------------------------------------------------------------------
getChestCodes() {
	clipContents := clipboard
	;regexpPattern := "P)\b(?<![A-Za-z0-9-/@#$`%^&!*])([A-Za-z0-9-@#$`%^&!*]{12,20})(?![A-Za-z0-9-/@#$`%^&!*])" ;Original
	regexpPattern := "P)(?<![A-Za-z0-9-\/@#$`%^&!*_=+\(\)\{\}\[\]])([A-Za-z0-9-@#$%^&!*]{12,20})(?![A-Za-z0-9-\/@#$`%^&!*_=+\(\)\{\}\[\]])"
	foundCodeString := ""
	while (clipContents ~= regexpPattern) {
		foundPos := RegExMatch(clipContents, regexpPattern, foundLength)
		foundCode := RegExReplace(SubStr(clipContents, foundPos, foundLength), "-")
		clipContents := SubStr(clipContents, foundPos + foundLength)
		if (InStr(foundCodeString, foundCode) = 0 && (StrLen(foundCode) = 12 || StrLen(foundCode) == 16)) {
			foundCodeString .= foundCode . "`r`n"
		}
	}
	foundCodeString := RegExReplace(foundCodeString, "`r`n$")
	return foundCodeString
}

;=============================================================================
; SERVER / API HELPERS
;=============================================================================

;-----------------------------------------------------------------------------
; CheckServerCallError(data) - Check API response for connection errors
; Returns: true if OK, false if error detected
;-----------------------------------------------------------------------------
CheckServerCallError(data) {
	FoundPos1 := InStr(data, "Error connecting:", 0, -1, 1)
	if(FoundPos1 != 0){
		data1 := SubStr(data, (FoundPos1 + 17))
		FoundPos1 := InStr(data1, "<br/>")
		sServerError := ""
		StringLeft, sServerError, data1, (FoundPos1 - 1)
		ServerError := sServerError
		return false
	}
	return true
}

;-----------------------------------------------------------------------------
; ParsePlayServerName(oData) - Extract play server name from API response
; Returns: server name string (e.g. "ps7") or empty if not found
;-----------------------------------------------------------------------------
ParsePlayServerName(oData) {
	searchString := "play_server"

	FoundPos2 := InStr(oData, searchString)
	if (!FoundPos2)
		return ""
	oData2 := SubStr(oData, (FoundPos2 + 14))
	
	FoundPos2 := InStr(oData2, ":\/\/")
	if (!FoundPos2)
		return ""
	oData3 := SubStr(oData2, (FoundPos2 + 5))

	FoundPos2 := InStr(oData3, ".idlechampions.com\/~idledragons\/")
	if (!FoundPos2)
		return ""
	NewServerName := ""
	StringLeft, NewServerName, oData3, (FoundPos2 - 1)
	return NewServerName
}

;=============================================================================
; SETTINGS DEFAULTS
;=============================================================================

global SettingsCheckValue := 25 ;used to check for outdated settings file
global NewSettings := JSON.stringify({"alwayssavechests":1,"alwayssavecontracts":1,"alwayssavecodes":1,"disabletooltips":0,"firstrun":0,"getdetailsonstart":0,"hash":0,"instance_id":0,"launchgameonstart":0,"loadgameclient":0,"logenabled":0,"nosavesetting":0,"servername":"master","user_id":0,"user_id_epic":0,"user_id_steam":0,"tabactive":"Summary","style":"Default","serverdetection":1,"wrlpath":"","blacksmithcontractresults":1,"disableuserdetailsreload":0,"redeemcodehistoryskip":1,"autorefreshminutes":0,"showapimessages":1})

;=============================================================================
; SERVER CONSTANTS
;=============================================================================

global DummyData := "&language_id=1&timestamp=0&request_id=0&network_id=11&mobile_client_version=999"

;=============================================================================
; MOCK SERVER CALL (P3-27)
;=============================================================================

; When MockServerCallEnabled is true, ServerCall() returns MockServerCallResponse
; instead of making a real HTTP request.  Use SetMockServerCall / ClearMockServerCall
; to control the mock from tests.

global MockServerCallEnabled  := false
global MockServerCallResponse := ""

;-----------------------------------------------------------------------------
; SetMockServerCall(response) - Enable mock mode with a canned response string
;-----------------------------------------------------------------------------
SetMockServerCall(response) {
	global MockServerCallEnabled, MockServerCallResponse
	MockServerCallEnabled  := true
	MockServerCallResponse := response
}

;-----------------------------------------------------------------------------
; ClearMockServerCall() - Disable mock mode and clear the canned response
;-----------------------------------------------------------------------------
ClearMockServerCall() {
	global MockServerCallEnabled, MockServerCallResponse
	MockServerCallEnabled  := false
	MockServerCallResponse := ""
}

;=============================================================================
; LOG ROTATION
;=============================================================================

;-----------------------------------------------------------------------------
; RotateLogFile(filepath, maxSizeKB) - Truncate log file if it exceeds max size
; Keeps the most recent half of the file. Default max: 512 KB.
;-----------------------------------------------------------------------------
RotateLogFile(filepath, maxSizeKB := 512) {
	if !FileExist(filepath)
		return
	FileGetSize, fileSize, %filepath%, K
	if (fileSize > maxSizeKB) {
		FileRead, content, %filepath%
		halfLen := StrLen(content) // 2
		content := SubStr(content, halfLen)
		FileDelete, %filepath%
		FileAppend, %content%, %filepath%
	}
}

;=============================================================================
; SETTINGS PERSISTENCE
;=============================================================================

;-----------------------------------------------------------------------------
; PersistSettings() - Write CurrentSettings to disk as JSON
;-----------------------------------------------------------------------------
PersistSettings() {
	global CurrentSettings, SettingsFile
	newsettings := JSON.stringify(CurrentSettings)
	tempFile := SettingsFile ".tmp"
	FileDelete, %tempFile%
	FileAppend, %newsettings%, %tempFile%
	if ErrorLevel {
		FileDelete, %tempFile%
		return
	}
	FileDelete, %SettingsFile%
	FileMove, %tempFile%, %SettingsFile%
}

;=============================================================================
; LISTVIEW HELPERS
;=============================================================================

;-----------------------------------------------------------------------------
; LV_AutoFill(hwnd) - Auto-size columns, stretch last to fill remaining space
; hwnd: The hwnd of the ListView control
;-----------------------------------------------------------------------------
LV_AutoFill(hwnd) {
	colCount := LV_GetCount("Col")
	if (colCount < 2)
		return
	; Auto-size all columns except last to header/content
	Loop % (colCount - 1)
		LV_ModifyCol(A_Index, "AutoHdr")
	; Use Win32 LVSCW_AUTOSIZE_USEHEADER (-2) on last column
	; This natively fills remaining ListView width
	SendMessage, 0x101E, colCount - 1, -2, , ahk_id %hwnd%  ; LVM_SETCOLUMNWIDTH
}

;=============================================================================
; UTILITY HELPERS
;=============================================================================

;-----------------------------------------------------------------------------
; DefaultToZero(ByRef val) - Set empty/blank values to 0
;-----------------------------------------------------------------------------
DefaultToZero(ByRef val) {
	if (val = "")
		val := 0
}

;=============================================================================
; WRL CREDENTIAL PARSING
;=============================================================================

;-----------------------------------------------------------------------------
; ParseWRLCredentials(text) - Extract user credentials from WRL file content
; Returns: object {user_id, hash, epic_id, steam_id} or empty object on failure
;-----------------------------------------------------------------------------
ParseWRLCredentials(text) {
	result := {user_id: "", hash: "", epic_id: "", steam_id: ""}

	FoundPos := InStr(text, "getuserdetails&language_id=1&user_id=")
	if (!FoundPos)
		return result

	oData2 := SubStr(text, (FoundPos + 37))
	FoundPos := InStr(oData2, "&hash=")
	if (!FoundPos)
		return result
	StringLeft, uid, oData2, (FoundPos - 1)
	result.user_id := uid

	oData3 := SubStr(oData2, (FoundPos + 6))
	FoundPos := InStr(oData3, "&instance_key=")
	if (!FoundPos)
		return result
	StringLeft, uhash, oData3, (FoundPos - 1)
	result.hash := uhash

	FoundPos := InStr(text, "&account_id=")
	if (FoundPos) {
		oData4 := SubStr(text, (FoundPos + 12))
		FoundPos := InStr(oData4, "&access_token=")
		if (FoundPos) {
			StringLeft, epicid, oData4, (FoundPos - 1)
			result.epic_id := epicid
		}
	}

	FoundPos := InStr(text, "&steam_user_id=")
	if (FoundPos) {
		oData5 := SubStr(text, (FoundPos + 15))
		FoundPos := InStr(oData5, "&steam_name=")
		if (FoundPos) {
			StringLeft, steamid, oData5, (FoundPos - 1)
			result.steam_id := steamid
		}
	}

	return result
}

;=============================================================================
; TIMESTAMP CONVERSION
;=============================================================================

;-----------------------------------------------------------------------------
; EpochToLocalTime(epochSeconds) - Convert unix epoch to formatted local time
; Returns: formatted time string like "May 10, 3:45 PM"
;-----------------------------------------------------------------------------
EpochToLocalTime(epochSeconds) {
	localdiff := (A_Now - A_NowUTC)
	if (localdiff < -28000000) {
		localdiff += 70000000
	}
	if (localdiff < -250000) {
		localdiff += 760000
	}
	StringTrimRight, localdiffh, localdiff, 4
	localdiffm := SubStr(localdiff, -3)
	StringTrimRight, localdiffm, localdiffm, 2
	if (localdiffm > 59) {
		localdiffm -= 40
	}
	timestampvalue := "19700101000000"
	timestampvalue += epochSeconds, s
	EnvAdd, timestampvalue, localdiffh, h
	EnvAdd, timestampvalue, localdiffm, m
	FormatTime, result, % timestampvalue, MMM d`, h:mm tt
	return result
}

;=============================================================================
; BRIV STACK CALCULATOR
;=============================================================================

;-----------------------------------------------------------------------------
; SimulateBrivCalc(slot4, zone, iterations) - Pure math simulation
; Returns: object with {skipLevels, trueChance, avgSkips, avgSkipped,
;          avgZones, avgSkipRate, avgStacks, roughTime}
;-----------------------------------------------------------------------------
SimulateBrivCalc(slot4, zone, iterations) {
	chance := ((slot4 / 100) + 1) * 0.25
	trueChance := chance
	skipLevels := 1
	if (chance > 2) {
		while chance >= 1 {
			skipLevels++
			chance /= 2
		}
	} else {
		skipLevels := Floor(chance + 1)
		if (skipLevels > 1) {
			trueChance := 0.5 + ((chance - Floor(chance)) / 2)
		}
	}
	totalLevels := 0
	totalSkips := 0
	Loop % iterations {
		level := 0.0
		skips := 0.0
		Loop {
			Random, x, 0.0, 1.0
			if (x < trueChance) {
				level += skipLevels
				skips++
			}
			level++
		}
		Until level > zone
		totalLevels += level
		totalSkips += skips
	}
	if (skipLevels < 3) {
		displayChance := Round(trueChance * 100, 2)
	} else {
		displayChance := Round(chance * 100, 2)
	}
	avgSkips := Round(totalSkips / iterations, 2)
	avgSkipped := Round(avgSkips * skipLevels, 2)
	avgZones := Round(totalLevels / iterations, 2)
	avgSkipRate := Round((avgSkipped / avgZones) * 100, 2)
	avgStacks := Round((1.032**avgSkips) * 48, 2)
	multiplier := 0.1346894362, additve := 41.86396406
	roughTime := Round(((multiplier * avgStacks) + additve), 2)

	return {skipLevels: skipLevels, trueChance: displayChance, avgSkips: avgSkips
		, avgSkipped: avgSkipped, avgZones: avgZones, avgSkipRate: avgSkipRate
		, avgStacks: avgStacks, roughTime: roughTime}
}

;=============================================================================
; DATA PARSING (pure/testable - no globals written, no GUI calls)
; These functions accept API data as parameters and return result objects.
; IdleCombos.ahk wrappers call these and assign results to globals.
;=============================================================================

;-----------------------------------------------------------------------------
; ParseInventoryDataFromDetails(details) - Extract inventory from API details
; details: UserDetails.details object
; Returns: object with gems, silvers, golds, bounty/blacksmith counts, etc.
;-----------------------------------------------------------------------------
ParseInventoryDataFromDetails(details) {
	result := {}
	result.gems        := details.red_rubies
	result.spentGems   := details.red_rubies_spent
	result.golds       := details.chests.2
	result.goldPity    := "(Epic in Next " details.stats.forced_win_counter_2 ")"
	result.silvers     := details.chests.1
	result.tgps        := details.stats.time_gate_key_pieces
	result.availableTGs := "= " Floor(result.tgps / 6) " Time Gates"
	result.availableChests := "= " Floor(result.gems / 50) " Silver Chests = " Floor(result.gems / 500) " Gold Chests"

	tinyBounties := "", smBounties := "", mdBounties := "", lgBounties := ""
	tinyBS := "", smBS := "", mdBS := "", lgBS := "", hgBS := ""
	for k, v in details.buffs {
		switch v.buff_id {
			case 17:   tinyBounties := v.inventory_amount
			case 18:   smBounties   := v.inventory_amount
			case 19:   mdBounties   := v.inventory_amount
			case 20:   lgBounties   := v.inventory_amount
			case 31:   tinyBS       := v.inventory_amount
			case 32:   smBS         := v.inventory_amount
			case 33:   mdBS         := v.inventory_amount
			case 34:   lgBS         := v.inventory_amount
			case 1797: hgBS         := v.inventory_amount
		}
	}
	DefaultToZero(tinyBounties)
	DefaultToZero(smBounties)
	DefaultToZero(mdBounties)
	DefaultToZero(lgBounties)
	DefaultToZero(tinyBS)
	DefaultToZero(smBS)
	DefaultToZero(mdBS)
	DefaultToZero(lgBS)
	DefaultToZero(hgBS)

	result.tinyBounties := tinyBounties
	result.smBounties   := smBounties
	result.mdBounties   := mdBounties
	result.lgBounties   := lgBounties
	result.tinyBS       := tinyBS
	result.smBS         := smBS
	result.mdBS         := mdBS
	result.lgBS         := lgBS
	result.hgBS         := hgBS

	tokencount := (tinyBounties*12) + (smBounties*72) + (mdBounties*576) + (lgBounties*1152)
	if (details.event_details[1].user_data.event_tokens) {
		tokentotal := details.event_details[1].user_data.event_tokens
		result.availableTokens := "= " tokencount " Tokens   (" Round(tokencount/2500, 2) " Free Plays)"
		result.currentTokens   := "+ " tokentotal " Current      (" Round(tokentotal/2500, 2) " Free Plays)"
		result.availableFPs    := "(Total: " (tokentotal+tokencount) " = " Round((tokentotal + tokencount)/2500, 2) " Free Plays)"
	} else {
		result.availableTokens := "= " tokencount " Tokens"
		result.currentTokens   := "(" Round(tokencount/2500, 2) " Free Plays)"
		result.availableFPs    := ""
	}
	result.availableBSLvs := "= " tinyBS+(smBS*2)+(mdBS*6)+(lgBS*24)+(hgBS*120) " Item Levels"
	return result
}

;-----------------------------------------------------------------------------
; ParseChampDataFromDetails(details) - Extract champion stats from API details
; details: UserDetails.details object
; Returns: object with totalChamps count and champDetails formatted string
;-----------------------------------------------------------------------------
ParseChampDataFromDetails(details) {
	MagList := ["K","M","B","t"]
	totalChamps := 0
	for k, v in details.heroes {
		if (v.owned == 1) {
			totalChamps += 1
		}
	}
	champDetails := ""
	if (details.stats.black_viper_total_gems) {
		ViperGemsValue := details.stats.black_viper_total_gems
		ViperGems := SubStr( "          " Format("{:.2f}",ViperGemsValue / (1000 ** Floor(log(ViperGemsValue)/3))) MagList[Floor(log(ViperGemsValue)/3)], -9)
		champDetails := champDetails "Black Viper Red Gems: " ViperGems "`n`n"
	}
	if (details.stats.total_paid_up_front_gold) {
		MorgaenGold := SubStr(details.stats.total_paid_up_front_gold, 1, 4)
		ePos := InStr(details.stats.total_paid_up_front_gold, "E")
		MorgaenGold := MorgaenGold SubStr(details.stats.total_paid_up_front_gold, ePos)
		champDetails := champDetails "M" Chr(244) "rg" Chr(230) "n Gold Collected:   " MorgaenGold "`n`n"
	}
	if (details.stats.torogar_lifetime_zealot_stacks) {
		TorogarStacksValue := details.stats.torogar_lifetime_zealot_stacks
		TorogarStacks := SubStr( "          " Format("{:.2f}",TorogarStacksValue / (1000 ** Floor(log(TorogarStacksValue)/3))) MagList[Floor(log(TorogarStacksValue)/3)], -9)
		champDetails := champDetails "Torogar Zealot Stacks: " TorogarStacks "`n`n"
	}
	if (details.stats.zorbu_lifelong_hits_humanoid || details.stats.zorbu_lifelong_hits_beast || details.stats.zorbu_lifelong_hits_undead || details.stats.zorbu_lifelong_hits_drow) {
		ZorbuHitsHumanoidValue := details.stats.zorbu_lifelong_hits_humanoid
		ZorbuHitsHumanoid := SubStr( "          " Format("{:.2f}",ZorbuHitsHumanoidValue / (1000 ** Floor(log(ZorbuHitsHumanoidValue)/3))) MagList[Floor(log(ZorbuHitsHumanoidValue)/3)], -9)
		ZorbuHitsBeastValue := details.stats.zorbu_lifelong_hits_beast
		ZorbuHitsBeast := SubStr( "          " Format("{:.2f}",ZorbuHitsBeastValue / (1000 ** Floor(log(ZorbuHitsBeastValue)/3))) MagList[Floor(log(ZorbuHitsBeastValue)/3)], -9)
		ZorbuHitsUndeadValue := details.stats.zorbu_lifelong_hits_undead
		ZorbuHitsUndead := SubStr( "          " Format("{:.2f}",ZorbuHitsUndeadValue / (1000 ** Floor(log(ZorbuHitsUndeadValue)/3))) MagList[Floor(log(ZorbuHitsUndeadValue)/3)], -9)
		ZorbuHitsDrowValue := details.stats.zorbu_lifelong_hits_drow
		ZorbuHitsDrow := SubStr( "          " Format("{:.2f}",ZorbuHitsDrowValue / (1000 ** Floor(log(ZorbuHitsDrowValue)/3))) MagList[Floor(log(ZorbuHitsDrowValue)/3)], -9)
		champDetails := champDetails "Zorbu Kills:`n - Humanoid: " ZorbuHitsHumanoid "`n - Beast:       " ZorbuHitsBeast "`n - Undead:    " ZorbuHitsUndead "`n - Drow:         " ZorbuHitsDrow "`n`n"
	}
	if (details.stats.dhani_monsters_painted) {
		DhaniPaintValue := details.stats.dhani_monsters_painted
		DhaniPaint := SubStr( "          " Format("{:.2f}",DhaniPaintValue / (1000 ** Floor(log(DhaniPaintValue)/3))) MagList[Floor(log(DhaniPaintValue)/3)], -9)
		champDetails := champDetails "D'hani Paints: " DhaniPaint "`n`n"
	}
	return {totalChamps: totalChamps, champDetails: champDetails}
}

;-----------------------------------------------------------------------------
; ParseLootDataFromDetails(details, activeInstance) - Extract loot/gear data
; details: UserDetails.details object
; activeInstance: active game instance ID (integer)
; Returns: object with unlock counts, brivSlot4, brivZone, todogear
;-----------------------------------------------------------------------------
ParseLootDataFromDetails(details, activeInstance) {
	champsUnlocked := 0
	familiarsUnlocked := 0
	costumesUnlocked := 0
	epicGearCount := 0
	todogear := "`nHighest Gear Level: " details.stats.highest_level_gear
	brivrarity := "", brivgild := 0, brivenchant := 0
	for k, v in details.heroes {
		if (v.owned == "1") {
			champsUnlocked += 1
		}
	}
	for k, v in details.familiars {
		familiarsUnlocked += 1
	}
	for k, v in details.unlocked_hero_skins {
		costumesUnlocked += 1
	}
	for k, v in details.loot {
		if (v.rarity == "4") {
			epicGearCount += 1
		}
		if ((v.hero_id == "58") && (v.slot_id == "4")) {
			brivrarity  := v.rarity
			brivgild    := v.gild
			brivenchant := v.enchant
		}
		if ((v.enchant + 1) = details.stats.highest_level_gear) {
			todogear := todogear "`n(" ChampFromID(v.hero_id) " Slot " v.slot_id ")`n"
		}
	}
	brivSlot4 := 0
	switch brivrarity {
		case "0": brivSlot4 := 0
		case "1": brivSlot4 := 10
		case "2": brivSlot4 := 30
		case "3": brivSlot4 := 50
		case "4": brivSlot4 := 100
	}
	brivSlot4 += brivenchant * 0.4
	brivSlot4 *= 1 + (brivgild * 0.5)
	brivZone := 0
	for k, v in details.modron_saves {
		if (v.instance_id == activeInstance) {
			brivZone := v.area_goal
		}
	}
	return {champsUnlocked: champsUnlocked, familiarsUnlocked: familiarsUnlocked
		, costumesUnlocked: costumesUnlocked, epicGearCount: epicGearCount
		, brivSlot4: brivSlot4, brivZone: brivZone, todogear: todogear}
}

;-----------------------------------------------------------------------------
; ParseAdventureDataFromDetails(details, activeInstance) - Extract instance data
; details: UserDetails.details object
; activeInstance: active game instance ID (integer)
; Returns: object with fg/bg1/bg2/bg3 sub-objects and champsActiveCount
;-----------------------------------------------------------------------------
ParseAdventureDataFromDetails(details, activeInstance) {
	InstanceList := [{},{},{},{}]
	CoreList := ["Modest","Strong","Fast","Magic"]
	MagList := ["K","M","B","t"]

	for k, v in details.game_instances {
		InstanceList[v.game_instance_id].current_adventure_id := v.current_adventure_id
		InstanceList[v.game_instance_id].current_area := v.current_area
		InstanceList[v.game_instance_id].Patron := PatronFromID(v.current_patron_id)
		InstanceList[v.game_instance_id].ChampionsCount := 0
		for l, w in v.formation {
			if (w > 0) {
				InstanceList[v.game_instance_id].ChampionsCount += 1
			}
		}
	}
	for k, v in details.modron_saves {
		InstanceList[v.instance_id].core_name := Corelist[v.core_id] ? Corelist[v.core_id] : "None"
		if (v.properties.toggle_preferences.reset == true)
			InstanceList[v.instance_id].core_name := InstanceList[v.instance_id].core_name " (Reset at " v.area_goal ")"
		core_level := ceil((sqrt(36000000+8000*v.exp_total)-6000)/4000)
		core_tolevel := v.exp_total-(2000*(core_level-1)**2+6000*(core_level-1))
		core_levelxp := 4000*(core_level+1)
		core_pcttolevel := Floor((core_tolevel / core_levelxp) * 100)
		core_humxp := Format("{:.2f}",v.exp_total / (1000 ** Floor(log(v.exp_total)/3))) MagList[Floor(log(v.exp_total)/3)]
		if (core_level > 15)
			core_level := core_level " - Max 15"
		InstanceList[v.instance_id].core_xp := core_humxp " (Lvl " core_level ")"
		InstanceList[v.instance_id].core_progress := core_tolevel "/" core_levelxp " (" core_pcttolevel "%)"
	}

	champsActiveCount := 0
	bginstance := 0
	result := {fg: {}, bg1: {}, bg2: {}, bg3: {}, champsActiveCount: 0}

	for k, v in InstanceList {
		if (k == activeInstance) {
			result.fg.adventure    := v.current_adventure_id == -1 ? "Map" : v.current_adventure_id
			result.fg.area         := v.current_area
			result.fg.patron       := v.Patron
			result.fg.coreName     := v.core_name
			result.fg.coreXP       := v.core_xp
			result.fg.coreProgress := v.core_progress
			result.fg.champCount   := v.ChampionsCount
			champsActiveCount += v.ChampionsCount
		} else if (bginstance == 0) {
			result.bg1.adventure    := v.current_adventure_id == -1 ? "Map" : v.current_adventure_id
			result.bg1.area         := v.current_area
			result.bg1.patron       := v.Patron
			result.bg1.coreName     := v.core_name
			result.bg1.coreXP       := v.core_xp
			result.bg1.coreProgress := v.core_progress
			result.bg1.champCount   := v.ChampionsCount
			champsActiveCount += v.ChampionsCount
			bginstance += 1
		} else if (bginstance == 1) {
			result.bg2.adventure    := v.current_adventure_id == -1 ? "Map" : v.current_adventure_id
			result.bg2.area         := v.current_area
			result.bg2.patron       := v.Patron
			result.bg2.coreName     := v.core_name
			result.bg2.coreXP       := v.core_xp
			result.bg2.coreProgress := v.core_progress
			result.bg2.champCount   := v.ChampionsCount
			champsActiveCount += v.ChampionsCount
			bginstance += 1
		} else if (bginstance == 2) {
			result.bg3.adventure    := v.current_adventure_id == -1 ? "Map" : v.current_adventure_id
			result.bg3.area         := v.current_area
			result.bg3.patron       := v.Patron
			result.bg3.coreName     := v.core_name
			result.bg3.coreXP       := v.core_xp
			result.bg3.coreProgress := v.core_progress
			result.bg3.champCount   := v.ChampionsCount
			champsActiveCount += v.ChampionsCount
		}
	}
	result.champsActiveCount := champsActiveCount
	return result
}

;-----------------------------------------------------------------------------
; ParseTimestampsFromData(currentTime, stats) - Extract timestamp data
; currentTime: UserDetails.current_time (unix epoch integer)
; stats: UserDetails.details.stats object
; Returns: object with lastUpdated, nextTGPDrop strings, and tgpReady boolean
;-----------------------------------------------------------------------------
ParseTimestampsFromData(currentTime, stats) {
	return {lastUpdated: EpochToLocalTime(currentTime)
		, nextTGPDrop: EpochToLocalTime(stats.time_gate_key_next_time)
		, tgpReady: (stats.time_gate_key_next_time < currentTime)}
}

;-----------------------------------------------------------------------------
; ParsePatronDataFromDetails(details, currentTGPs, currentSilvers, currentGems,
;   currentLgBounties, totalChamps) - Extract patron unlock/progress data
; details: UserDetails.details object
; currentTGPs, currentSilvers, currentGems, currentLgBounties: inventory counts
; totalChamps: total owned champion count
; Returns: object keyed by patron name (Mirt/Vajra/Strahd/Zariel/Elminster)
;   each with: variants, fp, challenges, requires, costs, completed, total
;-----------------------------------------------------------------------------
ParsePatronDataFromDetails(details, currentTGPs, currentSilvers, currentGems, currentLgBounties, totalChamps) {
	MagList := ["K","M","B","t"]
	pNameMap := []
	pNameMap[1] := "Mirt"
	pNameMap[2] := "Vajra"
	pNameMap[3] := "Strahd"
	pNameMap[4] := "Zariel"
	pNameMap[5] := "Elminster"

	result := {}
	for k, v in details.patrons {
		pName := pNameMap[v.patron_id]
		if !pName
			continue
		pData := {variants: "", fp: "", challenges: "", requires: "", costs: "", completed: "", total: ""}
		if v.unlocked == False {
			pData.variants   := "Locked"
			pData.fp         := "-"
			pData.challenges := "-"
			switch v.patron_id {
				case 1: { ; Mirt
					pData.requires := details.stats.total_hero_levels "/2000 iLvls, " totalChamps "/20 Champs"
					pData.costs    := currentTGPs "/3 TGPs, " currentSilvers "/10 Silver"
					if ((details.stats.total_hero_levels > 1999) && (totalChamps > 19))
						pData.requires := pData.requires " ✓"
					if ((currentTGPs > 2) && (currentSilvers > 9))
						pData.costs := pData.costs " ✓"
				}
				case 2: { ; Vajra
					vajraAdv := details.stats.completed_adventures_variants_and_patron_variants_c15
					if (vajraAdv = "")
						vajraAdv := "0"
					pData.requires := vajraAdv "/15 WD:DH Advs, " totalChamps "/30 Champs"
					pData.costs    := currentGems "/2500 Gems, " currentSilvers "/15 Silver"
					if ((vajraAdv > 14) && (totalChamps > 29))
						pData.requires := pData.requires " ✓"
					if ((currentGems > 2499) && (currentSilvers > 14))
						pData.costs := pData.costs " ✓"
				}
				case 3: { ; Strahd
					strahdAdv := details.stats.highest_area_completed_ever_c413
					if (strahdAdv = "")
						strahdAdv := "0"
					if (currentSilvers = "")
						currentSilvers := "0"
					if (currentLgBounties = "")
						currentLgBounties := "0"
					pData.requires := strahdAdv "/250 Adv 413, " totalChamps "/40 Champs"
					pData.costs    := currentLgBounties "/10 Lg Bounty, " currentSilvers "/20 Silver"
					if ((strahdAdv > 249) && (totalChamps > 39))
						pData.requires := pData.requires " ✓"
					if ((currentLgBounties > 9) && (currentSilvers > 19))
						pData.costs := pData.costs " ✓"
				}
				case 4: { ; Zariel
					zarielAdv := details.stats.highest_area_completed_ever_c873
					if (zarielAdv = "")
						zarielAdv := "0"
					pData.requires := zarielAdv "/575 Adv 873, " totalChamps "/50 Champs"
					pData.costs    := currentSilvers "/50 Silver"
					if ((zarielAdv > 574) && (totalChamps > 49))
						pData.requires := pData.requires " ✓"
					if (currentSilvers > 49)
						pData.costs := pData.costs " ✓"
				}
				case 5: { ; Elminster
					elminsterAdv := details.stats.highest_area_completed_ever_c873
					if (elminsterAdv = "")
						elminsterAdv := "0"
					pData.requires := elminsterAdv "/575 Adv 873, " totalChamps "/50 Champs"
					pData.costs    := currentSilvers "/50 Silver"
					if ((elminsterAdv > 574) && (totalChamps > 49))
						pData.requires := pData.requires " ✓"
					if (currentSilvers > 49)
						pData.costs := pData.costs " ✓"
				}
			}
		} else {
			for kk, vv in v.progress_bars {
				switch vv.id {
					case "variants_completed":
						pData.total     := vv.goal
						pData.completed := vv.count
						pData.variants  := pData.completed " / " pData.total
					case "free_play_limit": pData.fp := vv.count
					case "weekly_challenge_porgress": pData.challenges := vv.count
				}
			}
			influenceAmt := v.influence_current_amount
			currencyAmt  := v.currency_current_amount
			if (influenceAmt > 0) {
				pData.requires := "Influence: " Format("{:.2f}", influenceAmt / (1000 ** Floor(log(influenceAmt)/3))) MagList[Floor(log(influenceAmt)/3)]
			} else {
				pData.requires := "Influence: 0"
			}
			if (currencyAmt > 0) {
				pData.costs := "Coins: " Format("{:.2f}", currencyAmt / (1000 ** Floor(log(currencyAmt)/3))) MagList[Floor(log(currencyAmt)/3)]
			} else {
				pData.costs := "Coins: 0"
			}
		}
		result[pName] := pData
	}
	return result
}

;=============================================================================
; DICTIONARY SYNC - Pure functions for API-based dictionary updates
;=============================================================================

;-----------------------------------------------------------------------------
; ExtractDefinitionMap(definesArray) - Convert API defines array to {id: name}
; Returns object with .items (map) and .skipped (count)
;-----------------------------------------------------------------------------
ExtractDefinitionMap(definesArray) {
	result := {}
	skipped := 0
	maxId := 0

	for _, def in definesArray {
		if (!IsObject(def)) {
			skipped += 1
			continue
		}
		if (!def.HasKey("id") || !def.HasKey("name")) {
			skipped += 1
			continue
		}

		idNum := def.id + 0
		name := Trim(def.name)

		if (idNum <= 0 || name = "") {
			skipped += 1
			continue
		}

		result[idNum] := name
		if (idNum > maxId)
			maxId := idNum
	}

	return {"items": result, "skipped": skipped, "maxId": maxId}
}

;-----------------------------------------------------------------------------
; DiffDefinitionSection(currentMap, apiMap, preserveKeys) - Diff local vs API
; preserveKeys is an object of {id: true} entries that should keep local values
; Returns object with .new (array), .changed (array), .newCount, .changedCount
;-----------------------------------------------------------------------------
DiffDefinitionSection(currentMap, apiMap, preserveKeys := "") {
	newEntries := []
	changedEntries := []

	for id, apiName in apiMap {
		idNum := id + 0

		; Skip preserved local overrides
		if (IsObject(preserveKeys) && preserveKeys.HasKey(idNum))
			continue

		localName := currentMap[idNum]

		if (!localName || localName = "") {
			newEntries.Push({"id": idNum, "name": apiName})
		} else if (localName != apiName) {
			changedEntries.Push({"id": idNum, "old_name": localName, "new_name": apiName})
		}
	}

	return {"new": newEntries, "changed": changedEntries, "newCount": newEntries.Length(), "changedCount": changedEntries.Length()}
}

;-----------------------------------------------------------------------------
; BuildSyncPreviewText(champDiff, chestDiff, champSkipped, chestSkipped)
; Builds human-readable preview string for ScrollBox display
;-----------------------------------------------------------------------------
BuildSyncPreviewText(champDiff, chestDiff, champSkipped := 0, chestSkipped := 0) {
	text := "=== Dictionary Sync Preview ===`n`n"

	; Champions section
	text .= "CHAMPIONS`n"
	text .= "  New: " champDiff.newCount "  |  Renamed: " champDiff.changedCount "`n"
	if (champDiff.newCount > 0) {
		text .= "`n"
		for _, entry in champDiff.new
			text .= "  + " entry.id ": " entry.name "`n"
	}
	if (champDiff.changedCount > 0) {
		text .= "`n"
		for _, entry in champDiff.changed
			text .= "  ~ " entry.id ": " entry.old_name " -> " entry.new_name "`n"
	}

	text .= "`n"

	; Chests section
	text .= "CHESTS`n"
	text .= "  New: " chestDiff.newCount "  |  Renamed: " chestDiff.changedCount "`n"
	if (chestDiff.newCount > 0) {
		text .= "`n"
		for _, entry in chestDiff.new
			text .= "  + " entry.id ": " entry.name "`n"
	}
	if (chestDiff.changedCount > 0) {
		text .= "`n"
		for _, entry in chestDiff.changed
			text .= "  ~ " entry.id ": " entry.old_name " -> " entry.new_name "`n"
	}

	; Skipped entries
	totalSkipped := champSkipped + chestSkipped
	if (totalSkipped > 0)
		text .= "`nSkipped malformed API entries: " totalSkipped

	return text
}

;-----------------------------------------------------------------------------
; ApplySyncToDict(dict, champDiff, chestDiff, champMaxId, chestMaxId)
; Merges diff results into dictionary object. Returns modified dict.
;-----------------------------------------------------------------------------
ApplySyncToDict(dict, champDiff, chestDiff, champMaxId, chestMaxId) {
	; Apply new champions
	for _, entry in champDiff.new
		dict.champions[entry.id + 0] := entry.name

	; Apply renamed champions
	for _, entry in champDiff.changed
		dict.champions[entry.id + 0] := entry.new_name

	; Apply new chests
	for _, entry in chestDiff.new
		dict.chests[entry.id + 0] := entry.name

	; Apply renamed chests
	for _, entry in chestDiff.changed
		dict.chests[entry.id + 0] := entry.new_name

	; Update max IDs if API has higher values
	currentMaxChamp := dict.max_champ_id + 0
	currentMaxChest := dict.max_chest_id + 0

	if (champMaxId > currentMaxChamp)
		dict.max_champ_id := "" champMaxId

	if (chestMaxId > currentMaxChest)
		dict.max_chest_id := "" chestMaxId

	return dict
}
