#NoEnv
#SingleInstance Force
SetBatchLines, -1

;Set working directory to project root
SetWorkingDir, %A_ScriptDir%\..

;Include test framework (JUnit output only for CI)
#Include %A_ScriptDir%\..\Lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\Lib\Yunit\StdOut.ahk
#Include %A_ScriptDir%\..\Lib\Yunit\JUnit.ahk

;Include source files under test
global TestMode := true
#Include %A_ScriptDir%\..\json.ahk
#Include %A_ScriptDir%\..\IdleCombosLib.ahk

;Globals needed by tests
global ServerName := "master"
global ServerError := ""
;DummyData, SettingsCheckValue, NewSettings are defined in IdleCombosLib.ahk
global CurrentSettings := []
global SettingsFile := A_Temp "\idlecombos_test_settings.json"

;Run all test suites (headless - stdout + junit.xml output)
Yunit.Use(YunitStdout, YunitJUnit).Test(PatronTests, CampaignTests, ChampionTests, ChestTests, CodeParsingTests, SettingsTests, ServerTests, MockServerTests, WRLParsingTests, TimestampTests, DefaultToZeroTests, BrivCalcTests, ParsingTests, DictionarySyncTests)
ExitApp

;=============================================================================
; TEST SUITES
;=============================================================================

#Include %A_ScriptDir%\test_idledict.ahk
#Include %A_ScriptDir%\test_codes.ahk
#Include %A_ScriptDir%\test_settings.ahk
#Include %A_ScriptDir%\test_server.ahk
#Include %A_ScriptDir%\test_mock_server.ahk
#Include %A_ScriptDir%\test_extracted.ahk
#Include %A_ScriptDir%\test_parsing.ahk
#Include %A_ScriptDir%\test_dictionary_sync.ahk
