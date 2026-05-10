#NoEnv
#SingleInstance Force
SetBatchLines, -1

;Set working directory to project root
SetWorkingDir, %A_ScriptDir%\..

;Include test framework
#Include %A_ScriptDir%\..\Lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\Lib\Yunit\Window.ahk
#Include %A_ScriptDir%\..\Lib\Yunit\StdOut.ahk
#Include %A_ScriptDir%\..\Lib\Yunit\JUnit.ahk

;Include source files under test
#Include %A_ScriptDir%\..\json.ahk
#Include %A_ScriptDir%\..\IdleCombosLib.ahk

;Globals needed by tests
global ServerName := "master"
global ServerError := ""
global DummyData := "&language_id=1&timestamp=0&request_id=0&network_id=11&mobile_client_version=999"
global SettingsCheckValue := 23
global NewSettings := JSON.stringify({"alwayssavechests":1,"alwayssavecontracts":1,"alwayssavecodes":1,"disabletooltips":0,"firstrun":0,"getdetailsonstart":0,"hash":0,"instance_id":0,"launchgameonstart":0,"loadgameclient":0,"logenabled":0,"nosavesetting":0,"servername":"master","user_id":0,"user_id_epic":0,"user_id_steam":0,"tabactive":"Summary","style":"Default","serverdetection":1,"wrlpath":"","blacksmithcontractresults":1,"disableuserdetailsreload":0,"redeemcodehistoryskip":1})
global CurrentSettings := []
global SettingsFile := A_Temp "\idlecombos_test_settings.json"

;Run all test suites
Yunit.Use(YunitWindow, YunitStdout, YunitJUnit).Test(PatronTests, CampaignTests, ChampionTests, ChestTests, CodeParsingTests, SettingsTests, ServerTests)
return

;=============================================================================
; TEST SUITES
;=============================================================================

#Include %A_ScriptDir%\test_idledict.ahk
#Include %A_ScriptDir%\test_codes.ahk
#Include %A_ScriptDir%\test_settings.ahk
#Include %A_ScriptDir%\test_server.ahk
