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

global SettingsCheckValue := 24 ;used to check for outdated settings file
global NewSettings := JSON.stringify({"alwayssavechests":1,"alwayssavecontracts":1,"alwayssavecodes":1,"disabletooltips":0,"firstrun":0,"getdetailsonstart":0,"hash":0,"instance_id":0,"launchgameonstart":0,"loadgameclient":0,"logenabled":0,"nosavesetting":0,"servername":"master","user_id":0,"user_id_epic":0,"user_id_steam":0,"tabactive":"Summary","style":"Default","serverdetection":1,"wrlpath":"","blacksmithcontractresults":1,"disableuserdetailsreload":0,"redeemcodehistoryskip":1,"autorefreshminutes":0})

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
