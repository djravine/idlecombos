;=============================================================================
; CODE PARSING TESTS (getChestCodes regex)
;=============================================================================

class CodeParsingTests
{
	class ValidCodes
	{
		test_Single12CharCode()
		{
			clipboard := "ABCDEFGHIJKL"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "ABCDEFGHIJKL"), "Should find 12-char code")
		}

		test_Single16CharCode()
		{
			clipboard := "ABCDEFGHIJKLMNOP"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "ABCDEFGHIJKLMNOP"), "Should find 16-char code")
		}

		test_CodeWithDashes_StrippedTo12()
		{
			clipboard := "IDLE-CHAM-PION-SNOW"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "IDLECHAMPIONSNOW"), "Should strip dashes and find 16-char code")
		}

		test_CodeWithDashes_StrippedTo12Chars()
		{
			clipboard := "TAKE-THIS-LOOT-CODE"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "TAKETHISLOOTCODE"), "Should strip dashes: TAKETHISLOOTCODE")
		}

		test_MultipleCodes()
		{
			clipboard := "IDLE-CHAM-PION-SNOW`r`nTAKE-THIS-LOOT-CODE"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "IDLECHAMPIONSNOW"), "Should find first code")
			Yunit.Assert(InStr(result, "TAKETHISLOOTCODE"), "Should find second code")
		}

		test_CodesWithSurroundingText()
		{
			clipboard := "Here is your code: IDLE-CHAM-PION-SNOW and enjoy!"
			result := getChestCodes()
			Yunit.Assert(InStr(result, "IDLECHAMPIONSNOW"), "Should extract code from surrounding text")
		}
	}

	class InvalidCodes
	{
		test_TooShort_Rejected()
		{
			clipboard := "ABCDE"
			result := getChestCodes()
			Yunit.Assert(result = "", "5-char string should not match as a code")
		}

		test_TooLong_Rejected()
		{
			clipboard := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			result := getChestCodes()
			Yunit.Assert(result = "", "26-char string should not match as a code")
		}

		test_EmptyClipboard()
		{
			clipboard := ""
			result := getChestCodes()
			Yunit.Assert(result = "", "Empty clipboard should return empty")
		}

		test_OnlySpaces()
		{
			clipboard := "     "
			result := getChestCodes()
			Yunit.Assert(result = "", "Whitespace-only should return empty")
		}
	}

	class Deduplication
	{
		test_DuplicateCodesRemoved()
		{
			clipboard := "IDLE-CHAM-PION-SNOW`r`nIDLE-CHAM-PION-SNOW`r`nIDLE-CHAM-PION-SNOW"
			result := getChestCodes()
			;Count occurrences - should only appear once
			count := 0
			pos := 1
			Loop
			{
				pos := InStr(result, "IDLECHAMPIONSNOW", false, pos)
				if (!pos)
					break
				count++
				pos++
			}
			Yunit.Assert(count = 1, "Duplicate codes should be deduplicated, found: " count)
		}
	}

	class SpecialCharacters
	{
		test_CodeWithHash()
		{
			clipboard := "WOAH-#LAU-RANA"
			result := getChestCodes()
			Yunit.Assert(result != "", "Code with # should be found")
		}

		test_CodeWithExclamation()
		{
			clipboard := "PACK-AGED-ELIV-ERY!"
			result := getChestCodes()
			Yunit.Assert(result != "", "Code with ! should be found")
		}

		test_CodeWithAmpersand()
		{
			clipboard := "#OVE-R&UN-DURR"
			result := getChestCodes()
			Yunit.Assert(result != "", "Code with & should be found")
		}
	}
}
