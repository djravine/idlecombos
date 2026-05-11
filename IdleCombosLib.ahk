;=============================================================================
; IdleCombosLib.ahk - Shared library of pure/testable functions
; Both the main app and test suite include this file.
;=============================================================================

;=============================================================================
; TEST MODE
;=============================================================================
; Set to true by test runners BEFORE including this file.
; When true, MsgBox/ExitApp calls in the lib are suppressed.
global TestMode
if !TestMode
	TestMode := false

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

;=============================================================================
; PATRON CONSTANTS (derived from dictionary)
;=============================================================================
; Patrons have two name forms used throughout the app:
;   - Short names: "Mirt", "Vajra", etc. Used as AHK variable prefixes
;     (e.g. MirtVariants, VajraFPCurrency) because AHK v1.1 variables
;     cannot contain spaces. These are INTERNAL identifiers only.
;   - Display names: "Mirt the Moneylender", "Vajra Safahr", etc.
;     Read from idledict.json via PatronFromID(). Shown in UI, exports,
;     and updated by the API dictionary sync.
;
; PatronShortNames: patron_id → short variable prefix (never displayed)
; PatronIDs: ordered list of patron IDs (excluding 0/None)
;=============================================================================

global PatronShortNames := {1: "Mirt", 2: "Vajra", 3: "Strahd", 4: "Zariel", 5: "Elminster"}
global PatronIDs := [1, 2, 3, 4, 5]

;-----------------------------------------------------------------------------
; BuildPatronDisplayMap() - Build reverse lookup: display name → patron ID
; Used by the Variants tab dropdown to map user selection back to a patron ID.
; Keys are full display names from the dictionary (e.g. "Mirt the Moneylender").
; Includes "None" (ID 0) for the unfiltered option.
;-----------------------------------------------------------------------------
BuildPatronDisplayMap() {
	global _dict
	result := {}
	result[PatronFromID(0)] := 0
	for _, pid in PatronIDs
		result[PatronFromID(pid)] := pid
	return result
}

;-----------------------------------------------------------------------------
; BuildPatronDropdownList() - Build pipe-delimited string for GUI DropDownList
; Returns: "None|Mirt the Moneylender|Vajra Safahr|Strahd von Zarovich|..."
; Names come from the dictionary so they update when the dict is synced.
;-----------------------------------------------------------------------------
BuildPatronDropdownList() {
	global _dict
	ddl := PatronFromID(0)
	for _, pid in PatronIDs
		ddl .= "|" PatronFromID(pid)
	return ddl
}

;-----------------------------------------------------------------------------
; BuildChampDropdownList() - Build sorted pipe-delimited champion DDL string
; Format: "Arkhan (157)|Bruenor (1)|Celeste (2)|..."  sorted alphabetically
; Skips empty/blank champion entries.
; Returns: pipe-delimited string for use in DropDownList controls
;-----------------------------------------------------------------------------
BuildChampDropdownList() {
	global _dict
	; Collect "Name (ID)" entries
	champList := ""
	for champID, champName in _dict.champions {
		if (champName = "" || champName = "UNKNOWN")
			continue
		champList .= champName " (" (champID + 0) ")`n"
	}
	; Sort alphabetically (case-insensitive)
	Sort, champList
	; Build pipe-delimited DDL string
	ddl := ""
	Loop, Parse, champList, `n, `r
	{
		if (A_LoopField = "")
			continue
		ddl .= (ddl = "" ? "" : "|") A_LoopField
	}
	return ddl
}

;-----------------------------------------------------------------------------
; BuildChestDropdownList() - Build sorted pipe-delimited chest DDL string
; Format: "Gold Chest (2)|Silver Chest (1)|..."  sorted alphabetically
; Skips empty/blank chest entries.
; Returns: pipe-delimited string for use in ComboBox controls
;-----------------------------------------------------------------------------
BuildChestDropdownList() {
	global _dict
	chestList := ""
	for chestID, chestName in _dict.chests {
		if (chestName = "" || chestName = "UNKNOWN")
			continue
		chestList .= chestName " (" (chestID + 0) ")`n"
	}
	Sort, chestList
	ddl := ""
	Loop, Parse, chestList, `n, `r
	{
		if (A_LoopField = "")
			continue
		ddl .= (ddl = "" ? "" : "|") A_LoopField
	}
	return ddl
}

;-----------------------------------------------------------------------------
; FormatDuration(seconds) - Format seconds into "Xd Yh Zm" string
; Returns: formatted duration string, omitting zero components
;-----------------------------------------------------------------------------
FormatDuration(seconds) {
	seconds := seconds + 0
	if (seconds <= 0)
		return "—"
	d := Floor(seconds / 86400)
	h := Floor(Mod(seconds, 86400) / 3600)
	m := Floor(Mod(seconds, 3600) / 60)
	result := ""
	if (d > 0)
		result .= d "d "
	if (h > 0 || d > 0)
		result .= h "h "
	result .= m "m"
	return result
}

;-----------------------------------------------------------------------------
; AdvFromID(id) - Look up adventure name from advdefs.json cache
; Returns: adventure name if found, or the raw ID as string if not
;-----------------------------------------------------------------------------
AdvFromID(id) {
	static advCache := ""
	if (!IsObject(advCache)) {
		if !FileExist("advdefs.json")
			return id
		FileRead, raw, advdefs.json
		Try {
			advCache := JSON.parse(raw)
		} catch e {
			return id
		}
	}
	name := advCache[id + 0]
	return name != "" ? name : id
}

;-----------------------------------------------------------------------------
; BuildPatronPickerList() - Build pipe-delimited patron list with IDs
; Format: "None (0)|Mirt the Moneylender (1)|..."
; Used by PatronPicker GUI — includes IDs so PickerExtractID() can extract them.
;-----------------------------------------------------------------------------
BuildPatronPickerList() {
	ddl := "None (0)"
	for _, pid in PatronIDs
		ddl .= "|" PatronFromID(pid) " (" pid ")"
	return ddl
}

;-----------------------------------------------------------------------------
; BuildAdvDropdownList() - Build sorted pipe-delimited adventure DDL string
; Reads advdefs.json from the working directory. Returns "" if file absent or
; unparseable (graceful first-run fallback — caller should use InputBox instead).
; Format: "A Brief Tour of the Realms (1)|The Cursed Farmer (3)|..."
; Sorted alphabetically by adventure name.
;-----------------------------------------------------------------------------
BuildAdvDropdownList() {
	FileRead, advRaw, %A_WorkingDir%\advdefs.json
	if (ErrorLevel)
		return ""
	Try {
		advMap := JSON.parse(advRaw)
	} catch {
		return ""
	}
	if (!IsObject(advMap))
		return ""
	advList := ""
	for advID, advName in advMap {
		if (advName = "" || advName = "UNKNOWN")
			continue
		advList .= advName " (" (advID + 0) ")`n"
	}
	Sort, advList
	ddl := ""
	Loop, Parse, advList, `n, `r
	{
		if (A_LoopField = "")
			continue
		ddl .= (ddl = "" ? "" : "|") A_LoopField
	}
	return ddl
}

;-----------------------------------------------------------------------------
; PickerExtractID(selection) - Extract numeric ID from "Name (ID)" format
; If selection ends with "(digits)", extracts and returns that number.
; If selection is all digits (including "0"), returns it as a number.
; Returns "" if neither form is recognised.
;-----------------------------------------------------------------------------
PickerExtractID(selection) {
	RegExMatch(selection, "\((\d+)\)$", m)
	if (m1 != "")
		return m1 + 0
	trimmed := Trim(selection)
	if (trimmed ~= "^\d+$")
		return trimmed + 0
	return ""
}

; Get Patron display name from patron ID (e.g. 1 → "Mirt the Moneylender")
PatronFromID(patronid) {
	global _dict
	result := _dict.patrons[patronid + 0]
	return result ? result : ""
}

; Get campaign name from campaign ID (e.g. 1 → "Grand Tour of the Sword Coast")
campaignFromID(campaignid) {
	global _dict
	result := _dict.campaigns[campaignid + 0]
	return result ? result : "Error: " campaignid
}

; Get champion name from champion ID (e.g. 1 → "Bruenor"). Returns "UNKNOWN" if not found.
ChampFromID(id) {
	global _dict
	result := _dict.champions[id + 0]
	return result ? result : "UNKNOWN"
}

; Get feat description from feat ID (e.g. 3 → "Bruenor (Rally +40%)"). Returns "UNKNOWN" if not found.
FeatFromID(id) {
	global _dict
	result := _dict.feats[id + 0]
	return result ? result : "UNKNOWN"
}

; Get chest name from chest ID (e.g. 1 → "Silver Chest"). Returns "UNKNOWN" if not found.
ChestFromID(id) {
	global _dict
	result := _dict.chests[id + 0]
	return result ? result : "UNKNOWN"
}

; Get Kleho campaign mapping from Time Gate ID. Returns empty string if not found.
KlehoFromID(id) {
	global _dict
	result := _dict.kleho[id + 0]
	return result ? result : ""
}

; Get gold chest ID from champion ID (e.g. 1 → "461" for Bruenor). Returns "UNKNOWN" if not found.
ChestIDFromChampID(id) {
	global _dict
	result := _dict.chest_from_champ[id + 0]
	return result ? result : "UNKNOWN"
}

; Get value from dictionary map by ID with numeric coercion.
DictGet(map, id) {
	return map[id + 0]
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
; CONTRACT METADATA (shared by inventory display, CSV export, and parsing)
;=============================================================================
; Each entry: {buffId, name, varName (global), unit, multiplier}
; Used to avoid duplicating token/iLvl values across GUI, CSV, and parse code.

global BountyContracts := [{buffId: 17, name: "Tiny", var: "CurrentTinyBounties", unit: "Tokens", mult: 12}
	, {buffId: 18, name: "Small", var: "CurrentSmBounties", unit: "Tokens", mult: 72}
	, {buffId: 19, name: "Medium", var: "CurrentMdBounties", unit: "Tokens", mult: 576}
	, {buffId: 20, name: "Large", var: "CurrentLgBounties", unit: "Tokens", mult: 1152}]

global BlacksmithContracts := [{buffId: 31, name: "Tiny", var: "CurrentTinyBS", unit: "iLvl", mult: 1}
	, {buffId: 32, name: "Small", var: "CurrentSmBS", unit: "iLvls", mult: 2}
	, {buffId: 33, name: "Medium", var: "CurrentMdBS", unit: "iLvls", mult: 6}
	, {buffId: 34, name: "Large", var: "CurrentLgBS", unit: "iLvls", mult: 24}
	, {buffId: 1797, name: "Huge", var: "CurrentHgBS", unit: "iLvls", mult: 120}]

;=============================================================================
; SETTINGS DEFAULTS
;=============================================================================

global SettingsCheckValue := 38 ;used to check for outdated settings file
global NewSettings := JSON.stringify({"alwayssavechests":1,"alwayssavecontracts":1,"alwayssavecodes":1,"disabletooltips":0,"firstrun":0,"getdetailsonstart":0,"hash":0,"instance_id":0,"launchgameonstart":0,"loadgameclient":0,"logenabled":0,"nosavesetting":0,"servername":"master","user_id":0,"user_id_epic":0,"user_id_steam":0,"tabactive":"Summary","style":"Default","serverdetection":1,"wrlpath":"","blacksmithcontractresults":1,"disableuserdetailsreload":0,"redeemcodehistoryskip":1,"autorefreshminutes":0,"showapimessages":1,"lastbschamp":0,"lastbstncount":0,"lastbssmcount":0,"lastbsmdcount":0,"lastbslgcount":0,"lastbshgcount":0,"lastbountytncount":0,"lastbountysmcount":0,"lastbountymdcount":0,"lastbountylgcount":0,"lastadvid":0,"lastpatronid":0,"lastchestid":0})

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
; DPAPI CREDENTIAL ENCRYPTION
;=============================================================================
; Uses Windows Data Protection API (CryptProtectData/CryptUnprotectData)
; to encrypt sensitive credentials at rest. Encrypted values are stored as
; hex strings with a "DPAPI:" prefix in the settings JSON.
;
; Only the same Windows user on the same machine can decrypt the data.
; If decryption fails (e.g. settings copied to another machine), the
; credential is cleared and the user is prompted to re-enter it.
;
; Migration: plaintext values (no "DPAPI:" prefix) are used as-is on load,
; then automatically encrypted on the next save. Existing users migrate
; transparently with zero action required.
;
; DPAPIAvailable: probed once at startup via round-trip test. When false,
; all encrypt calls return the plaintext unchanged (graceful fallback).
;=============================================================================

; Probe DPAPI availability via encrypt+decrypt round-trip
global DPAPIAvailable := false
_dpapiProbe := DPAPIEncrypt("probe")
if (_dpapiProbe != "" && SubStr(_dpapiProbe, 1, 6) = "DPAPI:") {
	_dpapiProbeBack := DPAPIDecrypt(_dpapiProbe)
	if (_dpapiProbeBack = "probe")
		DPAPIAvailable := true
}
_dpapiProbe := ""
_dpapiProbeBack := ""

;-----------------------------------------------------------------------------
; DPAPIEncrypt(plainText) - Encrypt a string using Windows DPAPI
; Returns "DPAPI:" + hex-encoded ciphertext, or original value if empty/zero.
; Returns plaintext unchanged if DPAPIAvailable is false (graceful fallback).
; Returns "" on encryption failure.
;-----------------------------------------------------------------------------
DPAPIEncrypt(plainText) {
	if (plainText = "" || plainText = "0" || plainText = 0)
		return plainText

	; Skip encryption if DPAPI probe failed (avoids encrypt-succeed/decrypt-fail loops)
	if (!DPAPIAvailable)
		return plainText

	; Convert string to UTF-8 bytes
	inputLen := StrPut(plainText, "UTF-8") - 1
	VarSetCapacity(inputBuf, inputLen, 0)
	StrPut(plainText, &inputBuf, inputLen, "UTF-8")

	; DATA_BLOB structures (8 bytes on 32-bit: DWORD cbData + LPBYTE pbData)
	VarSetCapacity(blobIn, 8, 0)
	NumPut(inputLen, blobIn, 0, "UInt")
	NumPut(&inputBuf, blobIn, 4, "Ptr")

	VarSetCapacity(blobOut, 8, 0)

	; CryptProtectData — encrypts data bound to current Windows user
	result := DllCall("Crypt32\CryptProtectData"
		, "Ptr", &blobIn       ; pDataIn
		, "Ptr", 0             ; szDataDescr (not used)
		, "Ptr", 0             ; pOptionalEntropy (none — user-context is sufficient)
		, "Ptr", 0             ; pvReserved
		, "Ptr", 0             ; pPromptStruct (no UI prompt)
		, "UInt", 0            ; dwFlags (default — current user only)
		, "Ptr", &blobOut      ; pDataOut
		, "UInt")

	if (!result)
		return ""

	; Read encrypted bytes and convert to hex string for JSON storage
	outLen := NumGet(blobOut, 0, "UInt")
	outPtr := NumGet(blobOut, 4, "Ptr")

	hex := ""
	Loop % outLen
		hex .= Format("{:02X}", NumGet(outPtr + 0, A_Index - 1, "UChar"))

	DllCall("LocalFree", "Ptr", outPtr)
	return "DPAPI:" hex
}

;-----------------------------------------------------------------------------
; DPAPIDecrypt(storedValue) - Decrypt a DPAPI-encrypted value back to plaintext
; Accepts "DPAPI:HEXDATA" (encrypted) or raw plaintext (auto-migration).
; Returns decrypted plaintext, or "" if decryption fails (wrong machine/user).
; Empty/zero values pass through unchanged.
;-----------------------------------------------------------------------------
DPAPIDecrypt(storedValue) {
	if (storedValue = "" || storedValue = "0" || storedValue = 0)
		return storedValue

	; No DPAPI prefix = plaintext from pre-encryption settings (migration case)
	if (SubStr(storedValue, 1, 6) != "DPAPI:")
		return storedValue

	; Strip "DPAPI:" prefix and decode hex to bytes
	hex := SubStr(storedValue, 7)
	hexLen := StrLen(hex)
	if (hexLen = 0 || Mod(hexLen, 2) != 0)
		return ""

	byteLen := hexLen // 2
	VarSetCapacity(inputBuf, byteLen, 0)
	Loop % byteLen {
		pos := (A_Index - 1) * 2 + 1
		NumPut("0x" SubStr(hex, pos, 2) + 0, inputBuf, A_Index - 1, "UChar")
	}

	; DATA_BLOB structures
	VarSetCapacity(blobIn, 8, 0)
	NumPut(byteLen, blobIn, 0, "UInt")
	NumPut(&inputBuf, blobIn, 4, "Ptr")

	VarSetCapacity(blobOut, 8, 0)

	; CryptUnprotectData — decrypts data (must be same Windows user + machine)
	result := DllCall("Crypt32\CryptUnprotectData"
		, "Ptr", &blobIn       ; pDataIn
		, "Ptr", 0             ; ppszDataDescr (not used)
		, "Ptr", 0             ; pOptionalEntropy
		, "Ptr", 0             ; pvReserved
		, "Ptr", 0             ; pPromptStruct
		, "UInt", 0            ; dwFlags
		, "Ptr", &blobOut      ; pDataOut
		, "UInt")

	if (!result)
		return ""

	; Read decrypted bytes as UTF-8 string
	outLen := NumGet(blobOut, 0, "UInt")
	outPtr := NumGet(blobOut, 4, "Ptr")
	plainText := StrGet(outPtr, outLen, "UTF-8")

	DllCall("LocalFree", "Ptr", outPtr)
	return plainText
}

;-----------------------------------------------------------------------------
; IsEncryptedHash(value) - Check if a hash value is DPAPI-encrypted
; Returns true if value starts with "DPAPI:", false otherwise.
;-----------------------------------------------------------------------------
IsEncryptedHash(value) {
	return (SubStr(value, 1, 6) = "DPAPI:")
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
; MAGNITUDE FORMATTING
;=============================================================================

;-----------------------------------------------------------------------------
; FormatMagnitude(value, padWidth) - Format large numbers with K/M/B/t suffix
; e.g. 1500 → "1.50K", 2500000 → "2.50M"
; padWidth: left-pad with spaces to this width (0 = no padding)
; Returns formatted string. Returns "0" if value is 0 or empty.
;-----------------------------------------------------------------------------
FormatMagnitude(value, padWidth := 0) {
	static magSuffixes := ["K","M","B","t"]
	if (!value || value = "" || value = 0)
		return "0"
	magnitude := Floor(log(value) / 3)
	formatted := Format("{:.2f}", value / (1000 ** magnitude)) magSuffixes[magnitude]
	if (padWidth > 0)
		formatted := SubStr("          " formatted, -(padWidth - 1))
	return formatted
}

;=============================================================================
; ATOMIC JSON FILE WRITE
;=============================================================================

;-----------------------------------------------------------------------------
; WriteJsonAtomic(filePath, obj) - Write object as JSON via temp file
; Writes to .tmp first, validates parse-back, then replaces target file.
; Returns true on success, false on any failure (file left unchanged).
;-----------------------------------------------------------------------------
WriteJsonAtomic(filePath, obj) {
	jsonText := JSON.stringify(obj)
	tempFile := filePath ".tmp"
	FileDelete, %tempFile%
	FileAppend, %jsonText%, %tempFile%
	if ErrorLevel {
		FileDelete, %tempFile%
		return false
	}
	; Validate parse-back before replacing target
	FileRead, verifyText, %tempFile%
	Try {
		JSON.parse(verifyText)
	} catch e {
		FileDelete, %tempFile%
		return false
	}
	FileDelete, %filePath%
	FileMove, %tempFile%, %filePath%
	return true
}

;=============================================================================
; SETTINGS PERSISTENCE
;=============================================================================

;-----------------------------------------------------------------------------
; PersistSettings() - Write CurrentSettings to disk as JSON (atomic)
;-----------------------------------------------------------------------------
PersistSettings() {
	global CurrentSettings, SettingsFile
	WriteJsonAtomic(SettingsFile, CurrentSettings)
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

;-----------------------------------------------------------------------------
; SafeGet(obj, keys*) - Safely navigate nested object paths without crashing
; Traverses each key in order. Returns "" if any key is missing or the path
; hits a non-object. Use instead of direct dot-chain on untrusted API data.
; Example: SafeGet(details, "stats", "black_viper_total_gems")
;   → details.stats.black_viper_total_gems or "" if path is broken
;-----------------------------------------------------------------------------
SafeGet(obj, keys*) {
	current := obj
	for _, key in keys {
		if (!IsObject(current) || !current.HasKey(key))
			return ""
		current := current[key]
	}
	return current
}

;-----------------------------------------------------------------------------
; RequireKey(obj, keys*) - Fail-fast check for required nested object paths
; Same traversal as SafeGet, but logs a warning and returns "" with a LogFile
; call if the path is broken. Use for API fields that MUST exist.
; Example: RequireKey(details, "stats", "total_hero_levels")
;-----------------------------------------------------------------------------
RequireKey(obj, keys*) {
	current := obj
	path := ""
	for _, key in keys {
		path .= (path ? "." : "") key
		if (!IsObject(current) || !current.HasKey(key))
			return ""
		current := current[key]
	}
	return current
}

;=============================================================================
; WRL CREDENTIAL PARSING
;=============================================================================

;-----------------------------------------------------------------------------
; UrlEncode(str) - Percent-encode a string for safe use in URL query parameters
; Encodes all characters except unreserved chars (RFC 3986: A-Z a-z 0-9 - _ . ~)
; Handles UTF-8 multi-byte characters correctly.
;-----------------------------------------------------------------------------
UrlEncode(str) {
	if (str = "")
		return ""
	len := StrPut(str, "UTF-8") - 1
	VarSetCapacity(buf, len, 0)
	StrPut(str, &buf, len, "UTF-8")
	encoded := ""
	Loop, %len%
	{
		byte := NumGet(buf, A_Index - 1, "UChar")
		ch := Chr(byte)
		if ch is alnum
			encoded .= ch
		else if (ch = "-" || ch = "_" || ch = "." || ch = "~")
			encoded .= ch
		else
			encoded .= "%" Format("{:02X}", byte)
	}
	return encoded
}

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
	; Convert epoch to UTC timestamp
	timestampvalue := "19700101000000"
	timestampvalue += epochSeconds, s
	; Calculate UTC-to-local offset using AHK date math (handles day boundaries)
	localRef := A_Now
	utcRef := A_NowUTC
	EnvSub, localRef, %utcRef%, Seconds
	; Apply local offset to get local time
	timestampvalue += localRef, s
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

	; Extract bounty and blacksmith contract counts from buffs using shared metadata
	for _, bc in BountyContracts
		bc._val := ""
	for _, bs in BlacksmithContracts
		bs._val := ""

	for k, v in details.buffs {
		for _, bc in BountyContracts {
			if (v.buff_id = bc.buffId)
				bc._val := v.inventory_amount
		}
		for _, bs in BlacksmithContracts {
			if (v.buff_id = bs.buffId)
				bs._val := v.inventory_amount
		}
	}

	tokencount := 0
	for _, bc in BountyContracts {
		; ByRef does not work on object properties in AHK v1.1 — inline the check
		if (bc._val = "")
			bc._val := 0
		result[bc.var] := bc._val
		tokencount += bc._val * bc.mult
	}

	bsLevels := 0
	for _, bs in BlacksmithContracts {
		if (bs._val = "")
			bs._val := 0
		result[bs.var] := bs._val
		bsLevels += bs._val * bs.mult
	}

	; Map short variable names for backward compatibility
	result.tinyBounties := result["CurrentTinyBounties"]
	result.smBounties   := result["CurrentSmBounties"]
	result.mdBounties   := result["CurrentMdBounties"]
	result.lgBounties   := result["CurrentLgBounties"]
	result.tinyBS       := result["CurrentTinyBS"]
	result.smBS         := result["CurrentSmBS"]
	result.mdBS         := result["CurrentMdBS"]
	result.lgBS         := result["CurrentLgBS"]
	result.hgBS         := result["CurrentHgBS"]

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
	result.availableBSLvs := "= " bsLevels " Item Levels"
	return result
}

;-----------------------------------------------------------------------------
; ParseChampDataFromDetails(details) - Extract champion stats from API details
; details: UserDetails.details object
; Returns: object with totalChamps count and champDetails formatted string
;-----------------------------------------------------------------------------
ParseChampDataFromDetails(details) {
	totalChamps := 0
	for k, v in details.heroes {
		if (v.owned == 1) {
			totalChamps += 1
		}
	}
	champDetails := ""
	if (details.stats.black_viper_total_gems) {
		champDetails := champDetails "Black Viper Red Gems: " FormatMagnitude(details.stats.black_viper_total_gems, 10) "`n`n"
	}
	if (details.stats.total_paid_up_front_gold) {
		MorgaenGold := SubStr(details.stats.total_paid_up_front_gold, 1, 4)
		ePos := InStr(details.stats.total_paid_up_front_gold, "E")
		MorgaenGold := MorgaenGold SubStr(details.stats.total_paid_up_front_gold, ePos)
		champDetails := champDetails "M" Chr(244) "rg" Chr(230) "n Gold Collected:   " MorgaenGold "`n`n"
	}
	if (details.stats.torogar_lifetime_zealot_stacks) {
		champDetails := champDetails "Torogar Zealot Stacks: " FormatMagnitude(details.stats.torogar_lifetime_zealot_stacks, 10) "`n`n"
	}
	if (details.stats.zorbu_lifelong_hits_humanoid || details.stats.zorbu_lifelong_hits_beast || details.stats.zorbu_lifelong_hits_undead || details.stats.zorbu_lifelong_hits_drow) {
		champDetails := champDetails "Zorbu Kills:`n"
		champDetails := champDetails " - Humanoid: " FormatMagnitude(details.stats.zorbu_lifelong_hits_humanoid, 10) "`n"
		champDetails := champDetails " - Beast:       " FormatMagnitude(details.stats.zorbu_lifelong_hits_beast, 10) "`n"
		champDetails := champDetails " - Undead:    " FormatMagnitude(details.stats.zorbu_lifelong_hits_undead, 10) "`n"
		champDetails := champDetails " - Drow:         " FormatMagnitude(details.stats.zorbu_lifelong_hits_drow, 10) "`n`n"
	}
	if (details.stats.dhani_monsters_painted) {
		champDetails := champDetails "D'hani Paints: " FormatMagnitude(details.stats.dhani_monsters_painted, 10) "`n`n"
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

	for k, v in details.game_instances {
		InstanceList[v.game_instance_id].current_adventure_id := v.current_adventure_id
		InstanceList[v.game_instance_id].current_area := v.current_area
		InstanceList[v.game_instance_id].Patron := PatronFromID(v.current_patron_id)
		InstanceList[v.game_instance_id].CustomName := v.custom_name
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
			InstanceList[v.instance_id].core_reset := v.area_goal
		else
			InstanceList[v.instance_id].core_reset := ""
		core_level := ceil((sqrt(36000000+8000*v.exp_total)-6000)/4000)
		core_tolevel := v.exp_total-(2000*(core_level-1)**2+6000*(core_level-1))
		core_levelxp := 4000*(core_level+1)
		core_pcttolevel := Floor((core_tolevel / core_levelxp) * 100)
		core_humxp := FormatMagnitude(v.exp_total)
		if (core_level > 15)
			core_level := core_level " - Max 15"
		InstanceList[v.instance_id].core_xp := core_humxp " (Lvl " core_level ")"
		InstanceList[v.instance_id].core_progress := core_tolevel "/" core_levelxp " (" core_pcttolevel "%)"
		InstanceList[v.instance_id].core_progresspct := core_pcttolevel
	}

	champsActiveCount := 0
	bginstance := 0
	bgKeys := ["bg1", "bg2", "bg3"]
	result := {fg: {}, bg1: {}, bg2: {}, bg3: {}, champsActiveCount: 0}

	for k, v in InstanceList {
		; Assign instance fields to the appropriate slot (fg or bg1/bg2/bg3)
		if (k == activeInstance) {
			slotKey := "fg"
		} else if (bginstance < 3) {
			bginstance += 1
			slotKey := bgKeys[bginstance]
		} else {
			continue
		}
		result[slotKey].customName   := v.CustomName
		result[slotKey].adventure    := v.current_adventure_id == -1 ? "Map" : v.current_adventure_id
		result[slotKey].area         := v.current_area
		result[slotKey].patron       := v.Patron
		result[slotKey].coreName     := v.core_name
		result[slotKey].coreReset    := v.core_reset
		result[slotKey].coreXP       := v.core_xp
		result[slotKey].coreProgress := v.core_progress
		result[slotKey].coreProgressPct := v.core_progresspct
		result[slotKey].champCount   := v.ChampionsCount
		champsActiveCount += v.ChampionsCount
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
; Returns: object keyed by patron short name (Mirt/Vajra/Strahd/Zariel/Elminster)
;   each with: variants, fp, challenges, requires, costs, completed, total
;-----------------------------------------------------------------------------
ParsePatronDataFromDetails(details, currentTGPs, currentSilvers, currentGems, currentLgBounties, totalChamps) {
	pNameMap := PatronShortNames

	result := {}
	for k, v in details.patrons {
		pName := pNameMap[v.patron_id]
		if !pName
			continue
		pData := {variants: "", fp: "", challenges: "", requires: "", champs: "", costs: "", completed: "", total: "", unlocked: false}
		if v.unlocked == False {
			pData.variants   := "Locked"
			pData.fp         := "-"
			pData.challenges := "-"
			; Table-driven unlock requirements per patron
			; Each entry: {statKey, statThreshold, champThreshold, requiresLabel, costs: [{varExpr, threshold, label}]}
			; Ensure cost values are numeric before building requirements
			DefaultToZero(currentSilvers)
			DefaultToZero(currentLgBounties)
			DefaultToZero(currentTGPs)
			DefaultToZero(currentGems)

			; Build reqLabels with adventure/campaign names
			reqLabel1 := " iLvls"
			reqLabel2 := " " campaignFromID(15) " Advs"
			advName413 := AdvFromID(413)
			advName873 := AdvFromID(873)
			reqLabel3 := " in " advName413 " (413)"
			reqLabel4 := " in " advName873 " (873)"
			reqLabel5 := " in " advName873 " (873)"

			unlockReqs := {}
			unlockReqs[1] := {statKey: "total_hero_levels", statThresh: 2000, champThresh: 20
				, reqLabel: reqLabel1, costs: [{val: currentTGPs, thresh: 3, label: "TGPs"}, {val: currentSilvers, thresh: 10, label: "Silver"}]}
			unlockReqs[2] := {statKey: "completed_adventures_variants_and_patron_variants_c15", statThresh: 15, champThresh: 30
				, reqLabel: reqLabel2, costs: [{val: currentGems, thresh: 2500, label: "Gems"}, {val: currentSilvers, thresh: 15, label: "Silver"}]}
			unlockReqs[3] := {statKey: "highest_area_completed_ever_c413", statThresh: 250, champThresh: 40
				, reqLabel: reqLabel3, costs: [{val: currentLgBounties, thresh: 10, label: "Lg Bounty"}, {val: currentSilvers, thresh: 20, label: "Silver"}]}
			unlockReqs[4] := {statKey: "highest_area_completed_ever_c873", statThresh: 575, champThresh: 50
				, reqLabel: reqLabel4, costs: [{val: currentSilvers, thresh: 50, label: "Silver"}]}
			unlockReqs[5] := {statKey: "highest_area_completed_ever_c873", statThresh: 575, champThresh: 50
				, reqLabel: reqLabel5, costs: [{val: currentSilvers, thresh: 50, label: "Silver"}]}

			req := unlockReqs[v.patron_id]
			if IsObject(req) {
				; Build requires string from stat + champion thresholds
				statVal := details.stats[req.statKey]
				if (statVal = "")
					statVal := "0"
				pData.requires := statVal "/" req.statThresh req.reqLabel
				pData.requiresMet := (statVal + 0 >= req.statThresh)
				pData.champs := totalChamps "/" req.champThresh " Champs"
				pData.champsMet := (totalChamps + 0 >= req.champThresh)

				; Build costs string from cost items
				costParts := ""
				allMet := true
				for _, c in req.costs {
					if (costParts != "")
						costParts .= ", "
					costParts .= c.val "/" c.thresh " " c.label
					if (c.val + 0 < c.thresh)
						allMet := false
				}
				pData.costs := costParts
				pData.costsMet := allMet
			}
		} else {
			pData.unlocked := true
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
				pData.requires := FormatMagnitude(influenceAmt)
			} else {
				pData.requires := "0"
			}
			if (currencyAmt > 0) {
				pData.costs := FormatMagnitude(currencyAmt)
			} else {
				pData.costs := "0"
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
; ExtractChampNamesFromDefines(upgradeDefines, lootDefines)
; Extracts champion names from getuserdetails defines as a supplement when
; getDefinitions champion_defines is outdated. Parses possessive patterns
; ("ChampName's") from upgrade tip_text and loot effect descriptions.
; Returns: object mapping hero_id → champion name
;-----------------------------------------------------------------------------
ExtractChampNamesFromDefines(upgradeDefines, lootDefines) {
	result := {}
	; Primary: upgrade_defines tip_text ("Grimm's attacks", "Vlithryn's main buff")
	if (IsObject(upgradeDefines)) {
		for _, u in upgradeDefines {
			hid := u.hero_id + 0
			if (hid <= 0 || result.HasKey(hid))
				continue
			tip := u.tip_text
			if (tip != "" && RegExMatch(tip, "(\w+)'s ", m))
				result[hid] := m1
		}
	}
	; Supplement: loot_defines effect descriptions ("of Laurana's Battle Plan")
	if (IsObject(lootDefines)) {
		for _, item in lootDefines {
			hid := item.hero_id + 0
			if (hid <= 0 || result.HasKey(hid))
				continue
			if (IsObject(item.effects)) {
				for _, eff in item.effects {
					if (eff.description != "" && RegExMatch(eff.description, "of (.*?)'s ", m)) {
						result[hid] := m1
						break
					}
				}
			}
		}
	}
	return result
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

;-----------------------------------------------------------------------------
; ExtractFeatDefinitionMap(featArray, apiChampMap, localChampMap)
; Feats use "ChampName (FeatName)" format. API returns hero_id + name.
; Uses apiChampMap first (from same API call), falls back to localChampMap.
;-----------------------------------------------------------------------------
ExtractFeatDefinitionMap(featArray, apiChampMap, localChampMap) {
	result := {}
	skipped := 0
	maxId := 0

	for _, def in featArray {
		if (!IsObject(def)) {
			skipped += 1
			continue
		}
		if (!def.HasKey("id") || !def.HasKey("name")) {
			skipped += 1
			continue
		}

		idNum := def.id + 0
		featName := Trim(def.name)

		if (idNum <= 0 || featName = "") {
			skipped += 1
			continue
		}

		; Build display name: "ChampName (FeatName)"
		heroId := def.HasKey("hero_id") ? (def.hero_id + 0) : 0
		champName := ""
		if (heroId > 0) {
			champName := apiChampMap[heroId]
			if (champName = "")
				champName := localChampMap[heroId]
		}

		if (champName != "")
			displayName := champName " (" featName ")"
		else
			displayName := featName

		result[idNum] := displayName
		if (idNum > maxId)
			maxId := idNum
	}

	return {"items": result, "skipped": skipped, "maxId": maxId}
}

;-----------------------------------------------------------------------------
; BuildSyncPreviewTextMulti(sectionDiffs, totalSkipped)
; sectionDiffs is array of {label: "CHAMPIONS", diff: diffObj}
;-----------------------------------------------------------------------------
BuildSyncPreviewTextMulti(sectionDiffs, totalSkipped := 0) {
	text := "=== Dictionary Sync Preview ===`n"

	for _, section in sectionDiffs {
		d := section.diff
		if (d.newCount = 0 && d.changedCount = 0)
			continue

		text .= "`n" section.label "`n"
		text .= "  New: " d.newCount "  |  Renamed: " d.changedCount "`n"

		if (d.newCount > 0) {
			text .= "`n"
			for _, entry in d.new
				text .= "  + " entry.id ": " entry.name "`n"
		}
		if (d.changedCount > 0) {
			text .= "`n"
			for _, entry in d.changed
				text .= "  ~ " entry.id ": " entry.old_name " -> " entry.new_name "`n"
		}
	}

	; Summary of unchanged sections
	unchangedList := ""
	for _, section in sectionDiffs {
		d := section.diff
		if (d.newCount = 0 && d.changedCount = 0)
			unchangedList .= (unchangedList ? ", " : "") section.label
	}
	if (unchangedList != "")
		text .= "`nNo changes: " unchangedList

	if (totalSkipped > 0)
		text .= "`nSkipped malformed API entries: " totalSkipped

	return text
}

;-----------------------------------------------------------------------------
; ApplySyncSectionToDict(dict, sectionKey, diff)
; Generic merge: applies new + changed entries to any dict section
;-----------------------------------------------------------------------------
ApplySyncSectionToDict(dict, sectionKey, diff) {
	for _, entry in diff.new
		dict[sectionKey][entry.id + 0] := entry.name

	for _, entry in diff.changed
		dict[sectionKey][entry.id + 0] := entry.new_name
}
