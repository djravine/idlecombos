;=============================================================================
; EXTRACTED FUNCTION TESTS
;=============================================================================

class WRLParsingTests
{
	class ValidWRL
	{
		test_ExtractsUserID()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&hash=abcdef123&instance_key=1"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.user_id = "12345", "Should extract user_id 12345, got: " creds.user_id)
		}

		test_ExtractsHash()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&hash=abcdef123&instance_key=1"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.hash = "abcdef123", "Should extract hash abcdef123, got: " creds.hash)
		}

		test_ExtractsEpicID()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&hash=abc&instance_key=1&account_id=EPIC999&access_token=tok"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.epic_id = "EPIC999", "Should extract epic_id EPIC999, got: " creds.epic_id)
		}

		test_ExtractsSteamID()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&hash=abc&instance_key=1&steam_user_id=STEAM777&steam_name=player"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.steam_id = "STEAM777", "Should extract steam_id STEAM777, got: " creds.steam_id)
		}

		test_NoEpicOrSteam_ReturnsEmpty()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&hash=abc&instance_key=1"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.epic_id = "", "epic_id should be empty")
			Yunit.Assert(creds.steam_id = "", "steam_id should be empty")
		}
	}

	class InvalidWRL
	{
		test_EmptyText_ReturnsEmptyObject()
		{
			creds := ParseWRLCredentials("")
			Yunit.Assert(creds.user_id = "", "user_id should be empty for empty input")
			Yunit.Assert(creds.hash = "", "hash should be empty for empty input")
		}

		test_NoGetuserdetails_ReturnsEmptyObject()
		{
			creds := ParseWRLCredentials("some random text without the marker")
			Yunit.Assert(creds.user_id = "", "user_id should be empty when marker missing")
		}

		test_MissingHash_ReturnsEmptyHash()
		{
			wrl := "GET getuserdetails&language_id=1&user_id=12345&nohashhere=1"
			creds := ParseWRLCredentials(wrl)
			Yunit.Assert(creds.hash = "", "hash should be empty when &hash= missing")
		}
	}
}

class TimestampTests
{
	test_EpochZero_Returns1970()
	{
		result := EpochToLocalTime(0)
		Yunit.Assert(InStr(result, "1970") || InStr(result, "Jan"), "Epoch 0 should return a 1970 date, got: " result)
	}

	test_KnownEpoch_ReturnsNonEmpty()
	{
		result := EpochToLocalTime(1715350000)
		Yunit.Assert(result != "", "Known epoch should return non-empty string, got: " result)
	}

	test_ReturnsFormattedString()
	{
		result := EpochToLocalTime(1000000)
		Yunit.Assert(StrLen(result) > 5, "Result should be a formatted date string, got: " result)
	}
}

class DefaultToZeroTests
{
	test_EmptyString_BecomesZero()
	{
		val := ""
		DefaultToZero(val)
		Yunit.Assert(val = 0, "Empty string should become 0, got: " val)
	}

	test_NonEmpty_Unchanged()
	{
		val := 42
		DefaultToZero(val)
		Yunit.Assert(val = 42, "Non-empty value should be unchanged, got: " val)
	}

	test_Zero_StaysZero()
	{
		val := 0
		DefaultToZero(val)
		Yunit.Assert(val = 0, "Zero should stay zero, got: " val)
	}

	test_StringValue_Unchanged()
	{
		val := "hello"
		DefaultToZero(val)
		Yunit.Assert(val = "hello", "Non-empty string should be unchanged, got: " val)
	}
}

class BrivCalcTests
{
	test_ReturnsObject()
	{
		r := SimulateBrivCalc(100, 500, 1)
		Yunit.Assert(IsObject(r), "Should return an object")
	}

	test_HasExpectedKeys()
	{
		r := SimulateBrivCalc(100, 500, 1)
		Yunit.Assert(r.HasKey("skipLevels"), "Result should have skipLevels key")
		Yunit.Assert(r.HasKey("trueChance"), "Result should have trueChance key")
		Yunit.Assert(r.HasKey("avgSkips"), "Result should have avgSkips key")
		Yunit.Assert(r.HasKey("avgZones"), "Result should have avgZones key")
		Yunit.Assert(r.HasKey("avgStacks"), "Result should have avgStacks key")
		Yunit.Assert(r.HasKey("roughTime"), "Result should have roughTime key")
	}

	test_SkipLevels_PositiveInteger()
	{
		r := SimulateBrivCalc(100, 500, 5)
		Yunit.Assert(r.skipLevels >= 1, "skipLevels should be >= 1, got: " r.skipLevels)
	}

	test_AvgZones_GreaterThanTarget()
	{
		r := SimulateBrivCalc(100, 500, 10)
		Yunit.Assert(r.avgZones >= 500, "avgZones should be >= target zone 500, got: " r.avgZones)
	}

	test_ZeroSlot4_StillWorks()
	{
		r := SimulateBrivCalc(0, 100, 5)
		Yunit.Assert(r.skipLevels >= 1, "Zero slot4 should still produce valid result")
		Yunit.Assert(r.avgZones >= 100, "avgZones should still exceed target")
	}

	test_HighSlot4_MoreSkips()
	{
		low := SimulateBrivCalc(50, 500, 20)
		high := SimulateBrivCalc(500, 500, 20)
		Yunit.Assert(high.avgSkips >= low.avgSkips, "Higher slot4 should produce more skips")
	}
}
