;=============================================================================
; PARSING FUNCTION TESTS
; Tests for the pure Parse*FromDetails functions in IdleCombosLib.ahk.
; Mock data is built using AHK object literals to avoid JSON parsing overhead.
;=============================================================================

class ParsingTests
{
	;-------------------------------------------------------------------------
	; ParseInventoryDataFromDetails tests
	;-------------------------------------------------------------------------
	class Inventory
	{
		test_GemCount()
		{
			details := ParsingTests._MakeInvDetails(1500, 300, 5, 2, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.gems = 1500, "Gems should be 1500, got: " result.gems)
		}

		test_SpentGems()
		{
			details := ParsingTests._MakeInvDetails(1500, 300, 5, 2, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.spentGems = 300, "SpentGems should be 300, got: " result.spentGems)
		}

		test_SilverCount()
		{
			details := ParsingTests._MakeInvDetails(1500, 300, 5, 2, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.silvers = 5, "Silvers should be 5, got: " result.silvers)
		}

		test_GoldCount()
		{
			details := ParsingTests._MakeInvDetails(1500, 300, 5, 2, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.golds = 2, "Golds should be 2, got: " result.golds)
		}

		test_TGPs()
		{
			details := ParsingTests._MakeInvDetails(1000, 0, 3, 0, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.tgps = 18, "TGPs should be 18, got: " result.tgps)
		}

		test_AvailableTGs_Formula()
		{
			; 18 TGPs / 6 = 3 Time Gates
			details := ParsingTests._MakeInvDetails(1000, 0, 0, 0, 18, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(InStr(result.availableTGs, "3 Time Gates"), "availableTGs should show '3 Time Gates', got: " result.availableTGs)
		}

		test_AvailableChests_Formula()
		{
			; 1500 gems = Floor(1500/50)=30 silvers, Floor(1500/500)=3 golds
			details := ParsingTests._MakeInvDetails(1500, 0, 0, 0, 0, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(InStr(result.availableChests, "30 Silver Chests"), "Should show 30 Silver Chests, got: " result.availableChests)
			Yunit.Assert(InStr(result.availableChests, "3 Gold Chests"), "Should show 3 Gold Chests, got: " result.availableChests)
		}

		test_BlacksmithContracts_ParsedByBuffID()
		{
			; buff_id 31=tinyBS(3), 32=smBS(2), 33=mdBS(1)
			buffs := []
			b1 := {buff_id: 31, inventory_amount: 3}
			b2 := {buff_id: 32, inventory_amount: 2}
			b3 := {buff_id: 33, inventory_amount: 1}
			buffs.Push(b1), buffs.Push(b2), buffs.Push(b3)
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, buffs)
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.tinyBS = 3, "tinyBS should be 3, got: " result.tinyBS)
			Yunit.Assert(result.smBS = 2, "smBS should be 2, got: " result.smBS)
			Yunit.Assert(result.mdBS = 1, "mdBS should be 1, got: " result.mdBS)
		}

		test_BountyContracts_ParsedByBuffID()
		{
			; buff_id 17=tinyBounties(5), 18=smBounties(4), 19=mdBounties(3), 20=lgBounties(2)
			buffs := []
			b1 := {buff_id: 17, inventory_amount: 5}
			b2 := {buff_id: 18, inventory_amount: 4}
			b3 := {buff_id: 19, inventory_amount: 3}
			b4 := {buff_id: 20, inventory_amount: 2}
			buffs.Push(b1), buffs.Push(b2), buffs.Push(b3), buffs.Push(b4)
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, buffs)
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.tinyBounties = 5, "tinyBounties should be 5, got: " result.tinyBounties)
			Yunit.Assert(result.smBounties = 4, "smBounties should be 4, got: " result.smBounties)
			Yunit.Assert(result.mdBounties = 3, "mdBounties should be 3, got: " result.mdBounties)
			Yunit.Assert(result.lgBounties = 2, "lgBounties should be 2, got: " result.lgBounties)
		}

		test_MissingBuffs_DefaultToZero()
		{
			; Empty buffs — all contract counts should be 0
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.tinyBS = 0, "tinyBS should default to 0, got: " result.tinyBS)
			Yunit.Assert(result.lgBS = 0, "lgBS should default to 0, got: " result.lgBS)
			Yunit.Assert(result.lgBounties = 0, "lgBounties should default to 0, got: " result.lgBounties)
		}

		test_HugeBSContract_Parsed()
		{
			; buff_id 1797 = huge blacksmith
			buffs := [{buff_id: 1797, inventory_amount: 7}]
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, buffs)
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(result.hgBS = 7, "hgBS should be 7, got: " result.hgBS)
		}

		test_AvailableBSLvs_Formula()
		{
			; tinyBS=2, smBS=1 → 2+(1*2) = 4 Item Levels
			buffs := [{buff_id: 31, inventory_amount: 2}, {buff_id: 32, inventory_amount: 1}]
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, buffs)
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(InStr(result.availableBSLvs, "4 Item Levels"), "Should show 4 Item Levels, got: " result.availableBSLvs)
		}

		test_NoEventTokens_TokenString()
		{
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, [])
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(InStr(result.availableTokens, "0 Tokens"), "No bounties = 0 tokens in string, got: " result.availableTokens)
		}

		test_TokenCount_FromBounties()
		{
			; 1 tinyBounty = 12 tokens
			buffs := [{buff_id: 17, inventory_amount: 1}]
			details := ParsingTests._MakeInvDetails(0, 0, 0, 0, 0, buffs)
			result := ParseInventoryDataFromDetails(details)
			Yunit.Assert(InStr(result.availableTokens, "12 Tokens"), "1 tinyBounty = 12 tokens, got: " result.availableTokens)
		}
	}

	;-------------------------------------------------------------------------
	; ParseChampDataFromDetails tests
	;-------------------------------------------------------------------------
	class Champs
	{
		test_TotalChamps_CountsOwnedEqualsOne()
		{
			details := {}
			details.heroes := [{owned: 1}, {owned: 1}, {owned: 0}]
			details.stats := {}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(result.totalChamps = 2, "Should count 2 owned champs, got: " result.totalChamps)
		}

		test_TotalChamps_NoneOwned()
		{
			details := {}
			details.heroes := [{owned: 0}, {owned: 0}]
			details.stats := {}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(result.totalChamps = 0, "Should be 0 when none owned, got: " result.totalChamps)
		}

		test_TotalChamps_EmptyHeroes()
		{
			details := {}
			details.heroes := []
			details.stats := {}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(result.totalChamps = 0, "Empty heroes = 0 champs, got: " result.totalChamps)
		}

		test_ChampDetails_EmptyWhenNoSpecialStats()
		{
			details := {}
			details.heroes := []
			details.stats := {}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(result.champDetails = "", "champDetails should be empty with no stats, got: " result.champDetails)
		}

		test_ChampDetails_ViperGemsIncluded()
		{
			details := {}
			details.heroes := []
			details.stats := {black_viper_total_gems: 1000000}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(InStr(result.champDetails, "Black Viper"), "champDetails should mention Black Viper, got: " result.champDetails)
		}

		test_ReturnsObject()
		{
			details := {}
			details.heroes := []
			details.stats := {}
			result := ParseChampDataFromDetails(details)
			Yunit.Assert(IsObject(result), "Should return an object")
			Yunit.Assert(result.HasKey("totalChamps"), "Result should have totalChamps key")
			Yunit.Assert(result.HasKey("champDetails"), "Result should have champDetails key")
		}
	}

	;-------------------------------------------------------------------------
	; ParseLootDataFromDetails tests
	;-------------------------------------------------------------------------
	class Loot
	{
		test_ChampsUnlocked_CountsStringOne()
		{
			; ParseLootData checks owned == "1" (string), unlike ParseChampData (integer 1)
			details := ParsingTests._MakeLootDetails(2, 1, 1, [], 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.champsUnlocked = 2, "Should count 2 champs unlocked, got: " result.champsUnlocked)
		}

		test_FamiliarCount()
		{
			details := ParsingTests._MakeLootDetails(0, 3, 0, [], 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.familiarsUnlocked = 3, "Should count 3 familiars, got: " result.familiarsUnlocked)
		}

		test_CostumeCount()
		{
			details := ParsingTests._MakeLootDetails(0, 0, 4, [], 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.costumesUnlocked = 4, "Should count 4 costumes, got: " result.costumesUnlocked)
		}

		test_EpicGearCount()
		{
			; 2 epic (rarity "4") items, 1 non-epic
			loot := [{hero_id: "1", slot_id: "1", rarity: "4", gild: 0, enchant: 0}
				, {hero_id: "2", slot_id: "2", rarity: "4", gild: 0, enchant: 0}
				, {hero_id: "3", slot_id: "3", rarity: "2", gild: 0, enchant: 0}]
			details := ParsingTests._MakeLootDetails(0, 0, 0, loot, 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.epicGearCount = 2, "Should count 2 epic items, got: " result.epicGearCount)
		}

		test_BrivSlot4_Rarity4_NoGildNoEnchant()
		{
			; hero_id="58", slot_id="4", rarity="4", gild=0, enchant=0
			; brivSlot4 = 100 * (1 + 0*0.5) + 0*0.4 = 100
			loot := [{hero_id: "58", slot_id: "4", rarity: "4", gild: 0, enchant: 0}]
			details := ParsingTests._MakeLootDetails(0, 0, 0, loot, 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivSlot4 = 100, "BrivSlot4 rarity4, no gild/enchant = 100, got: " result.brivSlot4)
		}

		test_BrivSlot4_Rarity0()
		{
			; rarity "0" → base = 0
			loot := [{hero_id: "58", slot_id: "4", rarity: "0", gild: 0, enchant: 0}]
			details := ParsingTests._MakeLootDetails(0, 0, 0, loot, 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivSlot4 = 0, "BrivSlot4 rarity0 = 0, got: " result.brivSlot4)
		}

		test_BrivSlot4_WithGild()
		{
			; rarity "4" (100), gild 2 → 100 * (1 + 2*0.5) = 100 * 2 = 200
			loot := [{hero_id: "58", slot_id: "4", rarity: "4", gild: 2, enchant: 0}]
			details := ParsingTests._MakeLootDetails(0, 0, 0, loot, 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivSlot4 = 200, "BrivSlot4 rarity4 gild2 = 200, got: " result.brivSlot4)
		}

		test_BrivSlot4_NoSlot4Gear_IsZero()
		{
			; No Briv slot 4 gear → brivSlot4 stays 0
			loot := [{hero_id: "58", slot_id: "1", rarity: "4", gild: 5, enchant: 10}]
			details := ParsingTests._MakeLootDetails(0, 0, 0, loot, 1, 100)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivSlot4 = 0, "No slot4 gear should leave brivSlot4 at 0, got: " result.brivSlot4)
		}

		test_BrivZone_FromActiveInstance()
		{
			; modron_saves[instance_id=1].area_goal = 250
			details := ParsingTests._MakeLootDetails(0, 0, 0, [], 1, 250)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivZone = 250, "BrivZone should be 250, got: " result.brivZone)
		}

		test_BrivZone_WrongInstance_Zero()
		{
			; modron_saves uses instance_id=2, but activeInstance=1
			details := ParsingTests._MakeLootDetails(0, 0, 0, [], 2, 250)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.brivZone = 0, "BrivZone should be 0 when instance doesn't match, got: " result.brivZone)
		}

		test_ReturnsObjectWithExpectedKeys()
		{
			details := ParsingTests._MakeLootDetails(0, 0, 0, [], 1, 0)
			result := ParseLootDataFromDetails(details, 1)
			Yunit.Assert(result.HasKey("champsUnlocked"), "Missing champsUnlocked")
			Yunit.Assert(result.HasKey("familiarsUnlocked"), "Missing familiarsUnlocked")
			Yunit.Assert(result.HasKey("costumesUnlocked"), "Missing costumesUnlocked")
			Yunit.Assert(result.HasKey("epicGearCount"), "Missing epicGearCount")
			Yunit.Assert(result.HasKey("brivSlot4"), "Missing brivSlot4")
			Yunit.Assert(result.HasKey("brivZone"), "Missing brivZone")
		}
	}

	;-------------------------------------------------------------------------
	; ParseAdventureDataFromDetails tests
	;-------------------------------------------------------------------------
	class Adventure
	{
		test_FGInstance_Area()
		{
			details := ParsingTests._MakeAdvDetails(1, 500, 100, 0)
			result := ParseAdventureDataFromDetails(details, 1)
			Yunit.Assert(result.fg.area = 100, "FG area should be 100, got: " result.fg.area)
		}

		test_FGInstance_AdventureID()
		{
			details := ParsingTests._MakeAdvDetails(1, 500, 100, 0)
			result := ParseAdventureDataFromDetails(details, 1)
			Yunit.Assert(result.fg.adventure = 500, "FG adventure should be 500, got: " result.fg.adventure)
		}

		test_FGInstance_MapWhenMinusOne()
		{
			; current_adventure_id = -1 → "Map"
			details := ParsingTests._MakeAdvDetails(1, -1, 0, 0)
			result := ParseAdventureDataFromDetails(details, 1)
			Yunit.Assert(result.fg.adventure = "Map", "adventure=-1 should show 'Map', got: " result.fg.adventure)
		}

		test_BGInstance_AssignedWhenNotActive()
		{
			; instance 1 = FG, instance 2 = BG1
			details := ParsingTests._MakeAdvDetails2(1, 200, 50, 2, 300, 80)
			result := ParseAdventureDataFromDetails(details, 1)
			Yunit.Assert(result.fg.area = 50, "FG area should be 50, got: " result.fg.area)
			Yunit.Assert(result.bg1.area = 80, "BG1 area should be 80, got: " result.bg1.area)
		}

		test_ChampsActiveCount_SumsAllInstances()
		{
			; instance 1 (FG): 2 champs, instance 2 (BG): 3 champs → total 5
			details := ParsingTests._MakeAdvDetails2(1, 200, 50, 2, 300, 80)
			result := ParseAdventureDataFromDetails(details, 1)
			; FG has 2 champs (from _MakeAdvDetails2), BG has 3 champs
			Yunit.Assert(result.champsActiveCount = 5, "champsActiveCount should be 5, got: " result.champsActiveCount)
		}

		test_ReturnsObjectWithFGKey()
		{
			details := ParsingTests._MakeAdvDetails(1, 500, 100, 0)
			result := ParseAdventureDataFromDetails(details, 1)
			Yunit.Assert(IsObject(result), "Should return object")
			Yunit.Assert(result.HasKey("fg"), "Should have fg key")
			Yunit.Assert(result.HasKey("champsActiveCount"), "Should have champsActiveCount key")
		}
	}

	;-------------------------------------------------------------------------
	; ParseTimestampsFromData tests
	;-------------------------------------------------------------------------
	class Timestamps
	{
		test_LastUpdated_NonEmpty()
		{
			stats := {time_gate_key_next_time: 1715350000}
			result := ParseTimestampsFromData(1715360000, stats)
			Yunit.Assert(result.lastUpdated != "", "lastUpdated should be non-empty, got: " result.lastUpdated)
		}

		test_NextTGPDrop_NonEmpty()
		{
			stats := {time_gate_key_next_time: 1715350000}
			result := ParseTimestampsFromData(1715360000, stats)
			Yunit.Assert(result.nextTGPDrop != "", "nextTGPDrop should be non-empty, got: " result.nextTGPDrop)
		}

		test_TGPReady_WhenKeyInPast()
		{
			; tgp_next_time (1000) < currentTime (2000) → ready
			stats := {time_gate_key_next_time: 1000}
			result := ParseTimestampsFromData(2000, stats)
			Yunit.Assert(result.tgpReady = true, "TGP should be ready when key time is past, got: " result.tgpReady)
		}

		test_TGPNotReady_WhenKeyInFuture()
		{
			; tgp_next_time (3000) > currentTime (2000) → not ready
			stats := {time_gate_key_next_time: 3000}
			result := ParseTimestampsFromData(2000, stats)
			Yunit.Assert(result.tgpReady = false, "TGP should not be ready when key time is future, got: " result.tgpReady)
		}

		test_ReturnsObjectWithExpectedKeys()
		{
			stats := {time_gate_key_next_time: 1000}
			result := ParseTimestampsFromData(2000, stats)
			Yunit.Assert(result.HasKey("lastUpdated"), "Missing lastUpdated")
			Yunit.Assert(result.HasKey("nextTGPDrop"), "Missing nextTGPDrop")
			Yunit.Assert(result.HasKey("tgpReady"), "Missing tgpReady")
		}
	}

	;-------------------------------------------------------------------------
	; ParsePatronDataFromDetails tests
	;-------------------------------------------------------------------------
	class Patron
	{
		test_LockedPatron_VariantsIsLocked()
		{
			details := {}
			details.stats := {total_hero_levels: 500}
			patron := {patron_id: 1, unlocked: 0, progress_bars: []}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 5)
			Yunit.Assert(result.Mirt.variants = "Locked", "Locked patron should show 'Locked', got: " result.Mirt.variants)
		}

		test_LockedPatron_FPIsDash()
		{
			details := {}
			details.stats := {total_hero_levels: 500}
			patron := {patron_id: 1, unlocked: 0, progress_bars: []}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 5)
			Yunit.Assert(result.Mirt.fp = "-", "Locked patron fp should be '-', got: " result.Mirt.fp)
		}

		test_LockedPatron_ChallengesIsDash()
		{
			details := {}
			details.stats := {total_hero_levels: 500}
			patron := {patron_id: 2, unlocked: 0, progress_bars: []}
			details.stats.completed_adventures_variants_and_patron_variants_c15 := 10
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 5)
			Yunit.Assert(result.Vajra.challenges = "-", "Locked Vajra challenges should be '-', got: " result.Vajra.challenges)
		}

		test_UnlockedPatron_VariantsCount()
		{
			details := {}
			details.stats := {}
			progress := [{id: "variants_completed", count: 10, goal: 20}
				, {id: "free_play_limit", count: 5000}
				, {id: "weekly_challenge_porgress", count: 8}]
			patron := {patron_id: 1, unlocked: 1, progress_bars: progress
				, influence_current_amount: 1000000, currency_current_amount: 500000}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 5, 20, 3000, 0, 50)
			Yunit.Assert(result.Mirt.variants = "10 / 20", "Unlocked variants should show '10 / 20', got: " result.Mirt.variants)
		}

		test_UnlockedPatron_FPCurrency()
		{
			details := {}
			details.stats := {}
			progress := [{id: "free_play_limit", count: 5000}, {id: "variants_completed", count: 5, goal: 10}]
			patron := {patron_id: 1, unlocked: 1, progress_bars: progress
				, influence_current_amount: 1000000, currency_current_amount: 500000}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 0)
			Yunit.Assert(result.Mirt.fp = 5000, "FP currency should be 5000, got: " result.Mirt.fp)
		}

		test_UnlockedPatron_WeeklyChallenges()
		{
			details := {}
			details.stats := {}
			progress := [{id: "weekly_challenge_porgress", count: 8}, {id: "variants_completed", count: 5, goal: 10}]
			patron := {patron_id: 1, unlocked: 1, progress_bars: progress
				, influence_current_amount: 500, currency_current_amount: 200}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 0)
			Yunit.Assert(result.Mirt.challenges = 8, "Weekly challenges should be 8, got: " result.Mirt.challenges)
		}

		test_UnknownPatronID_NotInResult()
		{
			details := {}
			details.stats := {}
			patron := {patron_id: 99, unlocked: 0, progress_bars: []}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 0)
			Yunit.Assert(!result.HasKey("Patron99"), "patron_id=99 should be skipped")
			Yunit.Assert(!result.HasKey("Mirt"), "No Mirt for patron_id=99")
		}

		test_MultiplePatrons_BothInResult()
		{
			details := {}
			details.stats := {total_hero_levels: 0, completed_adventures_variants_and_patron_variants_c15: 0}
			p1 := {patron_id: 1, unlocked: 0, progress_bars: []}
			p2 := {patron_id: 2, unlocked: 0, progress_bars: []}
			details.patrons := [p1, p2]
			result := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 0)
			Yunit.Assert(result.HasKey("Mirt"), "Mirt should be in result")
			Yunit.Assert(result.HasKey("Vajra"), "Vajra should be in result")
		}

		test_LockedMirt_RequiresContainsHeroLevels()
		{
			details := {}
			details.stats := {total_hero_levels: 1500}
			patron := {patron_id: 1, unlocked: 0, progress_bars: []}
			details.patrons := [patron]
			result := ParsePatronDataFromDetails(details, 3, 15, 0, 0, 25)
			Yunit.Assert(InStr(result.Mirt.requires, "1500"), "Mirt requires should include hero levels 1500, got: " result.Mirt.requires)
		}

		test_LockedMirt_CheckmarkWhenRequirementsMet()
		{
			; When TGPs>2 and silvers>9, a checkmark suffix is appended — costs string gets longer
			details := {}
			details.stats := {total_hero_levels: 2500}
			patron := {patron_id: 1, unlocked: 0, progress_bars: []}
			details.patrons := [patron]
			resultNo  := ParsePatronDataFromDetails(details, 0, 0, 0, 0, 25)   ; requirements NOT met
			resultYes := ParsePatronDataFromDetails(details, 5, 15, 0, 0, 25)  ; requirements met
			Yunit.Assert(StrLen(resultYes.Mirt.costs) > StrLen(resultNo.Mirt.costs), "Costs should be longer with checkmark suffix, no=" StrLen(resultNo.Mirt.costs) " yes=" StrLen(resultYes.Mirt.costs))
		}
	}

	;-------------------------------------------------------------------------
	; Helper methods to construct mock details objects
	;-------------------------------------------------------------------------

	; Build minimal inventory details
	_MakeInvDetails(gems, spentGems, silvers, golds, tgps, buffs) {
		d := {}
		d.red_rubies       := gems
		d.red_rubies_spent := spentGems
		d.chests           := {}
		d.chests[1]        := silvers
		d.chests[2]        := golds
		d.stats            := {}
		d.stats.forced_win_counter_2   := 0
		d.stats.time_gate_key_pieces   := tgps
		d.buffs            := buffs
		d.event_details    := []
		return d
	}

	; Build minimal loot details
	_MakeLootDetails(numChamps, numFamiliars, numCostumes, loot, saveInstanceID, saveZone) {
		d := {}
		d.stats := {highest_level_gear: 50}
		d.heroes := []
		Loop % numChamps {
			d.heroes.Push({owned: "1"})
		}
		d.familiars := []
		Loop % numFamiliars {
			d.familiars.Push({id: A_Index})
		}
		d.unlocked_hero_skins := []
		Loop % numCostumes {
			d.unlocked_hero_skins.Push({id: A_Index})
		}
		d.loot := loot
		save := {instance_id: saveInstanceID, area_goal: saveZone}
		d.modron_saves := [save]
		return d
	}

	; Build minimal adventure details (single instance)
	_MakeAdvDetails(instanceID, adventureID, area, patronID) {
		d := {}
		d.game_instances := []
		inst := {}
		inst.game_instance_id    := instanceID
		inst.current_adventure_id := adventureID
		inst.current_area        := area
		inst.current_patron_id   := patronID
		inst.formation           := [1, 1, 0, 0]   ; 2 champs
		d.game_instances.Push(inst)
		save := {}
		save.instance_id := instanceID
		save.core_id     := 1
		save.exp_total   := 10000
		save.area_goal   := 200
		save.properties  := {toggle_preferences: {reset: false}}
		d.modron_saves   := [save]
		return d
	}

	; Build minimal adventure details (two instances)
	_MakeAdvDetails2(inst1ID, adv1, area1, inst2ID, adv2, area2) {
		d := {}
		d.game_instances := []
		i1 := {game_instance_id: inst1ID, current_adventure_id: adv1, current_area: area1
			, current_patron_id: 0, formation: [1, 1, 0, 0]}   ; 2 champs
		i2 := {game_instance_id: inst2ID, current_adventure_id: adv2, current_area: area2
			, current_patron_id: 0, formation: [1, 1, 1, 0]}   ; 3 champs
		d.game_instances.Push(i1)
		d.game_instances.Push(i2)
		s1 := {instance_id: inst1ID, core_id: 1, exp_total: 10000, area_goal: 200
			, properties: {toggle_preferences: {reset: false}}}
		s2 := {instance_id: inst2ID, core_id: 2, exp_total: 20000, area_goal: 300
			, properties: {toggle_preferences: {reset: false}}}
		d.modron_saves := [s1, s2]
		return d
	}
}
