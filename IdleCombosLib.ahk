;=============================================================================
; IdleCombosLib.ahk - Shared library of pure/testable functions
; Both the main app and test suite include this file.
;=============================================================================

;=============================================================================
; DICTIONARY (loaded from idledict.json)
;=============================================================================

;Load dictionary data from JSON
FileRead, _dictRaw, %A_WorkingDir%\idledict.json
global _dict := JSON.parse(_dictRaw)
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
	return result ? result : "UNKNOWN (" id ")"
}

; Get Feat Name from Feat ID
FeatFromID(id) {
	global _dict
	result := _dict.feats[id + 0]
	return result ? result : "UNKNOWN (" id ")"
}

; Get Chest Name from Chest ID
ChestFromID(id) {
	global _dict
	result := _dict.chests[id + 0]
	return result ? result : "UNKNOWN (" id ")"
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
	return result ? result : "UNKNOWN (" id ")"
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
; SETTINGS PERSISTENCE
;=============================================================================

;-----------------------------------------------------------------------------
; PersistSettings() - Write CurrentSettings to disk as JSON
;-----------------------------------------------------------------------------
PersistSettings() {
	global CurrentSettings, SettingsFile
	newsettings := JSON.stringify(CurrentSettings)
	FileDelete, %SettingsFile%
	FileAppend, %newsettings%, %SettingsFile%
}
