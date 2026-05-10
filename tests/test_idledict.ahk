;=============================================================================
; PATRON ID TESTS
;=============================================================================

class PatronTests
{
	test_Mirt()
	{
		Yunit.Assert(PatronFromID("1") = "Mirt the Moneylender", "PatronFromID(1) should return Mirt the Moneylender")
	}

	test_Vajra()
	{
		Yunit.Assert(PatronFromID("2") = "Vajra Safahr", "PatronFromID(2) should return Vajra Safahr")
	}

	test_Strahd()
	{
		Yunit.Assert(PatronFromID("3") = "Strahd von Zarovich", "PatronFromID(3) should return Strahd von Zarovich")
	}

	test_Zariel()
	{
		Yunit.Assert(PatronFromID("4") = "Zariel", "PatronFromID(4) should return Zariel")
	}

	test_Elminster()
	{
		Yunit.Assert(PatronFromID("5") = "Elminster", "PatronFromID(5) should return Elminster")
	}

	test_None()
	{
		Yunit.Assert(PatronFromID("0") = "None", "PatronFromID(0) should return None")
	}

	test_InvalidID_ReturnsEmpty()
	{
		result := PatronFromID("99")
		Yunit.Assert(result = "", "PatronFromID(99) should return empty")
	}
}

;=============================================================================
; CAMPAIGN ID TESTS
;=============================================================================

class CampaignTests
{
	test_GrandTour()
	{
		Yunit.Assert(campaignFromID("1") = "Grand Tour of the Sword Coast", "Campaign 1 = Grand Tour")
	}

	test_TombOfAnnihilation()
	{
		Yunit.Assert(campaignFromID("2") = "Tomb of Annihilation", "Campaign 2 = Tomb of Annihilation")
	}

	test_WaterdeepDragonHeist()
	{
		Yunit.Assert(campaignFromID("15") = "Waterdeep: Dragon Heist", "Campaign 15 = Waterdeep")
	}

	test_TimeGates()
	{
		Yunit.Assert(campaignFromID("17") = "Time Gates", "Campaign 17 = Time Gates")
	}

	test_IcewindDale()
	{
		Yunit.Assert(campaignFromID("24") = "Icewind Dale: Rime of the Frostmaiden", "Campaign 24 = Icewind Dale")
	}

	test_InvalidID_ReturnsError()
	{
		result := campaignFromID("999")
		Yunit.Assert(InStr(result, "Error"), "campaignFromID(999) should return error string, got: " result)
	}
}

;=============================================================================
; CHAMPION ID TESTS
;=============================================================================

class ChampionTests
{
	class FirstBlock
	{
		test_Bruenor()
		{
			Yunit.Assert(ChampFromID("1") = "Bruenor", "ChampFromID(1) = Bruenor")
		}

		test_Celeste()
		{
			Yunit.Assert(ChampFromID("2") = "Celeste", "ChampFromID(2) = Celeste")
		}

		test_Nayeli()
		{
			Yunit.Assert(ChampFromID("3") = "Nayeli", "ChampFromID(3) = Nayeli")
		}

		test_Jarlaxle()
		{
			Yunit.Assert(ChampFromID("4") = "Jarlaxle", "ChampFromID(4) = Jarlaxle")
		}

		test_Drizzt()
		{
			Yunit.Assert(ChampFromID("18") = "Drizzt", "ChampFromID(18) = Drizzt")
		}

		test_Barrowin()
		{
			Yunit.Assert(ChampFromID("19") = "Barrowin", "ChampFromID(19) = Barrowin")
		}

		test_Regis()
		{
			Yunit.Assert(ChampFromID("20") = "Regis", "ChampFromID(20) = Regis")
		}
	}

	class MiddleBlocks
	{
		test_ID50()
		{
			result := ChampFromID("50")
			Yunit.Assert(result != "", "ChampFromID(50) should return a name, got: " result)
		}

		test_ID100()
		{
			result := ChampFromID("100")
			Yunit.Assert(result != "", "ChampFromID(100) should return a name, got: " result)
		}

		test_ID137()
		{
			result := ChampFromID("137")
			Yunit.Assert(result != "", "ChampFromID(137) should return a name, got: " result)
		}

		test_MaxChampID()
		{
			result := ChampFromID(MaxChampID)
			Yunit.Assert(result != "", "ChampFromID(MaxChampID=" MaxChampID ") should return a name")
		}
	}

	class Boundaries
	{
		test_ID0_ReturnsUnknown()
		{
			result := ChampFromID("0")
			Yunit.Assert(InStr(result, "UNKNOWN"), "ChampFromID(0) should return UNKNOWN, got: " result)
		}

		test_BeyondMax_ReturnsUnknown()
		{
			beyondMax := MaxChampID + 100
			result := ChampFromID(beyondMax)
			Yunit.Assert(InStr(result, "UNKNOWN"), "ChampFromID(" beyondMax ") should return UNKNOWN, got: " result)
		}

		test_NegativeID_ReturnsUnknown()
		{
			result := ChampFromID("-1")
			Yunit.Assert(InStr(result, "UNKNOWN"), "ChampFromID(-1) should return UNKNOWN, got: " result)
		}
	}
}

;=============================================================================
; CHEST ID TESTS
;=============================================================================

class ChestTests
{
	class KnownChests
	{
		test_SilverChest()
		{
			Yunit.Assert(ChestFromID("1") = "Silver Chest", "ChestFromID(1) = Silver Chest")
		}

		test_GoldChest()
		{
			Yunit.Assert(ChestFromID("2") = "Gold Chest", "ChestFromID(2) = Gold Chest")
		}

		test_GoldStokiChest()
		{
			Yunit.Assert(ChestFromID("4") = "Gold Stoki Chest", "ChestFromID(4) = Gold Stoki Chest")
		}

		test_GoldBarrowinChest()
		{
			Yunit.Assert(ChestFromID("12") = "Gold Barrowin Chest", "ChestFromID(12) = Gold Barrowin Chest")
		}
	}

	class Boundaries
	{
		test_ID0_ReturnsUnknown()
		{
			result := ChestFromID("0")
			Yunit.Assert(InStr(result, "UNKNOWN"), "ChestFromID(0) should return UNKNOWN, got: " result)
		}

		test_MaxChestID()
		{
			result := ChestFromID(MaxChestID)
			Yunit.Assert(result != "", "ChestFromID(MaxChestID=" MaxChestID ") should return a name")
		}

		test_BeyondMax_ReturnsUnknown()
		{
			beyondMax := MaxChestID + 100
			result := ChestFromID(beyondMax)
			Yunit.Assert(InStr(result, "UNKNOWN"), "ChestFromID(" beyondMax ") should return UNKNOWN, got: " result)
		}
	}

	class Consistency
	{
		test_AllIDsUpTo20_ReturnNonEmpty()
		{
			failures := ""
			Loop, 20
			{
				result := ChestFromID(A_Index)
				if (result = "")
					failures .= A_Index " "
			}
			Yunit.Assert(failures = "", "ChestFromID should return names for IDs 1-20, failed: " failures)
		}
	}
}
