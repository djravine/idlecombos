;=============================================================================
; SETTINGS MIGRATION TESTS
;=============================================================================

class SettingsTests
{
	class Migration
	{
		test_MergeAddsNewKeys()
		{
			;Simulate old settings missing a key
			oldSettings := JSON.parse("{""user_id"":123,""hash"":""abc""}")
			defaultSettings := JSON.parse("{""user_id"":0,""hash"":0,""newkey"":""newvalue""}")

			;Merge: add missing keys from defaults
			for key, value in defaultSettings {
				if !oldSettings.HasKey(key) {
					oldSettings[key] := value
				}
			}

			Yunit.Assert(oldSettings.HasKey("newkey"), "Migration should add missing 'newkey'")
			Yunit.Assert(oldSettings.newkey = "newvalue", "New key should have default value")
		}

		test_MergePreservesExistingValues()
		{
			oldSettings := JSON.parse("{""user_id"":123,""hash"":""abc""}")
			defaultSettings := JSON.parse("{""user_id"":0,""hash"":0,""newkey"":""newvalue""}")

			for key, value in defaultSettings {
				if !oldSettings.HasKey(key) {
					oldSettings[key] := value
				}
			}

			Yunit.Assert(oldSettings.user_id = 123, "Migration should preserve existing user_id=123")
			Yunit.Assert(oldSettings.hash = "abc", "Migration should preserve existing hash=abc")
		}

		test_MergeDoesNotOverwrite()
		{
			oldSettings := JSON.parse("{""servername"":""ps4"",""logenabled"":1}")
			defaultSettings := JSON.parse("{""servername"":""master"",""logenabled"":0,""newfield"":""x""}")

			for key, value in defaultSettings {
				if !oldSettings.HasKey(key) {
					oldSettings[key] := value
				}
			}

			Yunit.Assert(oldSettings.servername = "ps4", "Should NOT overwrite servername with default")
			Yunit.Assert(oldSettings.logenabled = 1, "Should NOT overwrite logenabled with default")
			Yunit.Assert(oldSettings.newfield = "x", "Should ADD newfield from defaults")
		}
	}

	class JSONRoundtrip
	{
		test_ParseAndStringify()
		{
			original := "{""user_id"":42,""hash"":""deadbeef"",""servername"":""master""}"
			parsed := JSON.parse(original)
			Yunit.Assert(parsed.user_id = 42, "Parsed user_id should be 42")
			Yunit.Assert(parsed.hash = "deadbeef", "Parsed hash should be deadbeef")

			stringified := JSON.stringify(parsed)
			Yunit.Assert(InStr(stringified, """user_id"":42"), "Stringified should contain user_id:42")
			Yunit.Assert(InStr(stringified, """hash"":""deadbeef"""), "Stringified should contain hash")
		}

		test_EmptyObject()
		{
			parsed := JSON.parse("{}")
			Yunit.Assert(parsed.Count() = 0, "Empty JSON object should have 0 keys")
		}

		test_NestedObject()
		{
			jsonStr := "{""outer"":{""inner"":""value""}}"
			parsed := JSON.parse(jsonStr)
			Yunit.Assert(parsed.outer.inner = "value", "Should parse nested objects")
		}

		test_ArrayValues()
		{
			jsonStr := "{""list"":[1,2,3]}"
			parsed := JSON.parse(jsonStr)
			Yunit.Assert(parsed.list[1] = 1, "Should parse array index 1")
			Yunit.Assert(parsed.list[3] = 3, "Should parse array index 3")
		}
	}

	class SettingsCheckValue
	{
		test_NewSettingsHasCorrectCount()
		{
			;NewSettings from the main app should have exactly SettingsCheckValue keys
			global NewSettings, SettingsCheckValue
			;Parse the NewSettings string (it's already a JSON string)
			testSettings := JSON.parse(NewSettings)
			Yunit.Assert(testSettings.Count() = SettingsCheckValue, "NewSettings key count (" testSettings.Count() ") should equal SettingsCheckValue (" SettingsCheckValue ")")
		}
	}
}
