;=============================================================================
; DICTIONARY SYNC TESTS
; Tests for ExtractDefinitionMap, DiffDefinitionSection,
; BuildSyncPreviewText, and ApplySyncToDict
;=============================================================================

class DictionarySyncTests
{
	;=========================================================================
	; ExtractDefinitionMap tests
	;=========================================================================

	test_Extract_ValidChampions()
	{
		defs := [{"id": 1, "name": "Bruenor"}, {"id": 2, "name": "Celeste"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[1] = "Bruenor", "Champion 1 should be Bruenor")
		Yunit.Assert(result.items[2] = "Celeste", "Champion 2 should be Celeste")
		Yunit.Assert(result.skipped = 0, "No entries should be skipped")
		Yunit.Assert(result.maxId = 2, "Max ID should be 2")
	}

	test_Extract_SkipsMissingId()
	{
		defs := [{"name": "NoId"}, {"id": 5, "name": "Valid"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[5] = "Valid", "Valid entry should be extracted")
		Yunit.Assert(result.skipped = 1, "One entry should be skipped")
	}

	test_Extract_SkipsMissingName()
	{
		defs := [{"id": 3}, {"id": 4, "name": "HasName"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[4] = "HasName", "Valid entry should be extracted")
		Yunit.Assert(result.skipped = 1, "One entry should be skipped")
	}

	test_Extract_SkipsBlankName()
	{
		defs := [{"id": 1, "name": ""}, {"id": 2, "name": "  "}, {"id": 3, "name": "OK"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[3] = "OK", "Valid entry should be extracted")
		Yunit.Assert(result.skipped = 2, "Two entries should be skipped (empty and whitespace)")
	}

	test_Extract_SkipsZeroId()
	{
		defs := [{"id": 0, "name": "Zero"}, {"id": -1, "name": "Negative"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.skipped = 2, "Zero and negative IDs should be skipped")
	}

	test_Extract_EmptyArray()
	{
		defs := []
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.skipped = 0, "No entries to skip")
		Yunit.Assert(result.maxId = 0, "Max ID should be 0 for empty array")
	}

	test_Extract_NumericCoercion()
	{
		; AHK v1.1 stores numeric keys as numbers — string "10" does NOT auto-coerce.
		; Project convention: always use id+0 for numeric key lookup (see AGENTS.md).
		defs := [{"id": 10, "name": "Ten"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[10] = "Ten", "Numeric ID lookup should work")
		; Verify coercion via local variable (how id+0 is used in practice)
		idStr := "10"
		Yunit.Assert(result.items[idStr + 0] = "Ten", "Coerced string ID lookup should work via id+0 pattern")
	}

	test_Extract_TracksMaxId()
	{
		defs := [{"id": 5, "name": "A"}, {"id": 200, "name": "B"}, {"id": 50, "name": "C"}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.maxId = 200, "Max ID should be 200")
	}

	test_Extract_TrimsWhitespace()
	{
		defs := [{"id": 1, "name": "  Padded Name  "}]
		result := ExtractDefinitionMap(defs)
		Yunit.Assert(result.items[1] = "Padded Name", "Name should be trimmed")
	}

	;=========================================================================
	; DiffDefinitionSection tests
	;=========================================================================

	test_Diff_DetectsNewEntries()
	{
		current := {1: "Bruenor", 2: "Celeste"}
		api := {1: "Bruenor", 2: "Celeste", 3: "Nayeli"}
		diff := DiffDefinitionSection(current, api)
		Yunit.Assert(diff.newCount = 1, "Should find 1 new entry")
		Yunit.Assert(diff.new[1].id = 3, "New entry ID should be 3")
		Yunit.Assert(diff.new[1].name = "Nayeli", "New entry name should be Nayeli")
	}

	test_Diff_DetectsRenames()
	{
		current := {1: "OldName"}
		api := {1: "NewName"}
		diff := DiffDefinitionSection(current, api)
		Yunit.Assert(diff.changedCount = 1, "Should find 1 rename")
		Yunit.Assert(diff.changed[1].old_name = "OldName", "Old name should match")
		Yunit.Assert(diff.changed[1].new_name = "NewName", "New name should match")
	}

	test_Diff_NoChanges()
	{
		current := {1: "Same", 2: "Also Same"}
		api := {1: "Same", 2: "Also Same"}
		diff := DiffDefinitionSection(current, api)
		Yunit.Assert(diff.newCount = 0, "Should find no new entries")
		Yunit.Assert(diff.changedCount = 0, "Should find no renames")
	}

	test_Diff_IgnoresRemovals()
	{
		current := {1: "Keep", 2: "AlsoKeep", 3: "WillBeRemoved"}
		api := {1: "Keep", 2: "AlsoKeep"}
		diff := DiffDefinitionSection(current, api)
		Yunit.Assert(diff.newCount = 0, "No new entries")
		Yunit.Assert(diff.changedCount = 0, "No renames - removal should be ignored")
	}

	test_Diff_PreservesLocalOverrides()
	{
		current := {1: "Normal", 205: "Gold Mithral Hall Chest (DO NOT USE)"}
		api := {1: "Normal", 205: "Gold Mithral Hall Chest"}
		preserve := {205: true}
		diff := DiffDefinitionSection(current, api, preserve)
		Yunit.Assert(diff.changedCount = 0, "Preserved key should not be reported as changed")
	}

	test_Diff_MixedChanges()
	{
		current := {1: "Old1", 2: "Same"}
		api := {1: "New1", 2: "Same", 3: "Brand New"}
		diff := DiffDefinitionSection(current, api)
		Yunit.Assert(diff.newCount = 1, "Should find 1 new entry")
		Yunit.Assert(diff.changedCount = 1, "Should find 1 rename")
	}

	;=========================================================================
	; BuildSyncPreviewText tests
	;=========================================================================

	test_Preview_NoChanges()
	{
		champDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		chestDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		text := BuildSyncPreviewText(champDiff, chestDiff)
		Yunit.Assert(InStr(text, "New: 0"), "Should show 0 new entries")
	}

	test_Preview_WithNewEntries()
	{
		champDiff := {"new": [{"id": 155, "name": "NewHero"}], "changed": [], "newCount": 1, "changedCount": 0}
		chestDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		text := BuildSyncPreviewText(champDiff, chestDiff)
		Yunit.Assert(InStr(text, "+ 155: NewHero"), "Should show new champion entry")
	}

	test_Preview_WithRenames()
	{
		champDiff := {"new": [], "changed": [{"id": 1, "old_name": "Old", "new_name": "New"}], "newCount": 0, "changedCount": 1}
		chestDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		text := BuildSyncPreviewText(champDiff, chestDiff)
		Yunit.Assert(InStr(text, "~ 1: Old -> New"), "Should show rename entry")
	}

	test_Preview_ShowsSkipped()
	{
		champDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		chestDiff := {"new": [], "changed": [], "newCount": 0, "changedCount": 0}
		text := BuildSyncPreviewText(champDiff, chestDiff, 3, 2)
		Yunit.Assert(InStr(text, "Skipped malformed API entries: 5"), "Should show total skipped count")
	}

	;=========================================================================
	; ApplySyncToDict tests
	;=========================================================================

	test_Apply_AddsNewChampions()
	{
		dict := {"champions": {1: "Bruenor"}, "chests": {}, "max_champ_id": "1", "max_chest_id": "0"}
		champDiff := {"new": [{"id": 2, "name": "Celeste"}], "changed": []}
		chestDiff := {"new": [], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 2, 0)
		Yunit.Assert(result.champions[2] = "Celeste", "New champion should be added")
	}

	test_Apply_RenamesChampions()
	{
		dict := {"champions": {1: "OldName"}, "chests": {}, "max_champ_id": "1", "max_chest_id": "0"}
		champDiff := {"new": [], "changed": [{"id": 1, "new_name": "NewName"}]}
		chestDiff := {"new": [], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 1, 0)
		Yunit.Assert(result.champions[1] = "NewName", "Champion should be renamed")
	}

	test_Apply_AddsNewChests()
	{
		dict := {"champions": {}, "chests": {1: "Silver"}, "max_champ_id": "0", "max_chest_id": "1"}
		champDiff := {"new": [], "changed": []}
		chestDiff := {"new": [{"id": 2, "name": "Gold"}], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 0, 2)
		Yunit.Assert(result.chests[2] = "Gold", "New chest should be added")
	}

	test_Apply_UpdatesMaxChampId()
	{
		dict := {"champions": {}, "chests": {}, "max_champ_id": "100", "max_chest_id": "50"}
		champDiff := {"new": [{"id": 155, "name": "NewHero"}], "changed": []}
		chestDiff := {"new": [], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 155, 50)
		Yunit.Assert(result.max_champ_id + 0 = 155, "Max champ ID should update to 155")
	}

	test_Apply_UpdatesMaxChestId()
	{
		dict := {"champions": {}, "chests": {}, "max_champ_id": "100", "max_chest_id": "500"}
		champDiff := {"new": [], "changed": []}
		chestDiff := {"new": [{"id": 600, "name": "NewChest"}], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 100, 600)
		Yunit.Assert(result.max_chest_id + 0 = 600, "Max chest ID should update to 600")
	}

	test_Apply_PreservesMaxIdWhenLower()
	{
		dict := {"champions": {}, "chests": {}, "max_champ_id": "200", "max_chest_id": "500"}
		champDiff := {"new": [], "changed": []}
		chestDiff := {"new": [], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 100, 400)
		Yunit.Assert(result.max_champ_id + 0 = 200, "Max champ ID should stay at 200")
		Yunit.Assert(result.max_chest_id + 0 = 500, "Max chest ID should stay at 500")
	}

	test_Apply_PreservesUntouchedSections()
	{
		dict := {"champions": {}, "chests": {}, "max_champ_id": "0", "max_chest_id": "0", "version": "2.41", "patrons": {1: "Mirt"}, "campaigns": {1: "Grand Tour"}}
		champDiff := {"new": [], "changed": []}
		chestDiff := {"new": [], "changed": []}
		result := ApplySyncToDict(dict, champDiff, chestDiff, 0, 0)
		Yunit.Assert(result.version = "2.41", "Version should be unchanged")
		Yunit.Assert(result.patrons[1] = "Mirt", "Patrons should be unchanged")
		Yunit.Assert(result.campaigns[1] = "Grand Tour", "Campaigns should be unchanged")
	}

	;=========================================================================
	; ExtractFeatDefinitionMap tests
	;=========================================================================

	test_FeatExtract_WithHeroId()
	{
		feats := [{"id": 3, "name": "Rally +40%", "hero_id": 1}]
		champMap := {1: "Bruenor"}
		result := ExtractFeatDefinitionMap(feats, champMap, {})
		Yunit.Assert(result.items[3] = "Bruenor (Rally +40%)", "Should format as 'ChampName (FeatName)', got: " result.items[3])
	}

	test_FeatExtract_FallbackToLocalChamps()
	{
		feats := [{"id": 9, "name": "Global DPS +25%", "hero_id": 2}]
		apiChamps := {}
		localChamps := {2: "Celeste"}
		result := ExtractFeatDefinitionMap(feats, apiChamps, localChamps)
		Yunit.Assert(result.items[9] = "Celeste (Global DPS +25%)", "Should use local champion name as fallback")
	}

	test_FeatExtract_NoHeroId()
	{
		feats := [{"id": 100, "name": "Standalone Feat"}]
		result := ExtractFeatDefinitionMap(feats, {}, {})
		Yunit.Assert(result.items[100] = "Standalone Feat", "Should use feat name only without hero_id")
	}

	test_FeatExtract_UnknownHeroId()
	{
		feats := [{"id": 50, "name": "Mystery Feat", "hero_id": 999}]
		result := ExtractFeatDefinitionMap(feats, {}, {})
		Yunit.Assert(result.items[50] = "Mystery Feat", "Should use feat name only when hero not found")
	}

	test_FeatExtract_SkipsMalformed()
	{
		feats := [{"id": 0, "name": "Bad"}, {"name": "NoId"}, {"id": 5, "name": "Good", "hero_id": 1}]
		champMap := {1: "Bruenor"}
		result := ExtractFeatDefinitionMap(feats, champMap, {})
		Yunit.Assert(result.skipped = 2, "Should skip 2 malformed entries")
		Yunit.Assert(result.items[5] = "Bruenor (Good)", "Valid entry should be extracted")
	}

	;=========================================================================
	; BuildSyncPreviewTextMulti tests
	;=========================================================================

	test_PreviewMulti_ShowsOnlyChangedSections()
	{
		diffs := []
		diffs.Push({"label": "CHAMPIONS", "diff": {"new": [{"id": 155, "name": "NewHero"}], "changed": [], "newCount": 1, "changedCount": 0}})
		diffs.Push({"label": "CHESTS", "diff": {"new": [], "changed": [], "newCount": 0, "changedCount": 0}})
		diffs.Push({"label": "CAMPAIGNS", "diff": {"new": [], "changed": [], "newCount": 0, "changedCount": 0}})
		text := BuildSyncPreviewTextMulti(diffs)
		Yunit.Assert(InStr(text, "CHAMPIONS"), "Should show CHAMPIONS section")
		Yunit.Assert(!InStr(text, "`nCHESTS`n"), "Should not show CHESTS header as separate section (no changes)")
		Yunit.Assert(InStr(text, "No changes:"), "Should list unchanged sections")
	}

	test_PreviewMulti_ShowsSkipped()
	{
		diffs := []
		diffs.Push({"label": "CHAMPS", "diff": {"new": [], "changed": [], "newCount": 0, "changedCount": 0}})
		text := BuildSyncPreviewTextMulti(diffs, 7)
		Yunit.Assert(InStr(text, "Skipped malformed API entries: 7"), "Should show skipped count")
	}

	;=========================================================================
	; ApplySyncSectionToDict tests
	;=========================================================================

	test_ApplySection_AddsNewEntries()
	{
		dict := {"campaigns": {1: "Grand Tour"}}
		diff := {"new": [{"id": 30, "name": "New Campaign"}], "changed": []}
		ApplySyncSectionToDict(dict, "campaigns", diff)
		Yunit.Assert(dict.campaigns[30] = "New Campaign", "New campaign should be added")
		Yunit.Assert(dict.campaigns[1] = "Grand Tour", "Existing campaign should be preserved")
	}

	test_ApplySection_RenamesEntries()
	{
		dict := {"patrons": {1: "OldMirt"}}
		diff := {"new": [], "changed": [{"id": 1, "new_name": "Mirt the Moneylender"}]}
		ApplySyncSectionToDict(dict, "patrons", diff)
		Yunit.Assert(dict.patrons[1] = "Mirt the Moneylender", "Patron should be renamed")
	}

	test_ApplySection_WorksOnFeats()
	{
		dict := {"feats": {3: "Bruenor (Rally +40%)"}}
		diff := {"new": [{"id": 999, "name": "NewChamp (New Feat)"}], "changed": []}
		ApplySyncSectionToDict(dict, "feats", diff)
		Yunit.Assert(dict.feats[999] = "NewChamp (New Feat)", "New feat should be added")
		Yunit.Assert(dict.feats[3] = "Bruenor (Rally +40%)", "Existing feat should be preserved")
	}
}
