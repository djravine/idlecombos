# AutoHotkey v1.1 Testing Frameworks Research

## 1. YUNIT - Official Repository

**GitHub URL**: https://github.com/Uberi/Yunit (master branch)

**Branch**: Use master branch for AHK v1.1 (NOT v2)
- master branch: AHK 1.1.x up to 2.0.a77
- 2 branch: AHK 2.0-beta.1+ (incompatible with v1.1)

**License**: GNU Affero General Public License v3.0 (AGPL-3.0)

**Last Updated**: 2022-08-03

---

## 2. Installation & Setup

### Single-File vs Multi-File

Yunit is **multi-file** but minimal:
- Yunit.ahk (core, mandatory)
- Window.ahk (GUI output, optional)
- Stdout.ahk (console output, optional)
- OutputDebug.ahk (OutputDebug output, optional)
- JUnit.ahk (JUnit XML output, optional)

### Installation Steps for IdleCombos

1. Clone or download Yunit to your project:
   idlecombos/
   ├── IdleCombos.ahk
   ├── idledict.ahk
   ├── Lib/
   │   └── Yunit/
   │       ├── Yunit.ahk
   │       ├── Window.ahk
   │       └── ...
   └── tests/
       └── test_idledict.ahk

2. In your test script, include Yunit:
   #Include <Yunit\Yunit>
   #Include <Yunit\Window>

3. AutoHotkey v1.1 library paths (checked in order):
   - %A_ScriptDir%\Lib\ (USE THIS FOR IdleCombos)
   - %A_MyDocuments%\Lib\
   - %A_AhkPath%\Lib\

---

## 3. Basic Test Syntax

### Minimal Working Example

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#Include <Yunit\Yunit>
#Include <Yunit\Window>
#Include idledict.ahk

Yunit.Use(YunitWindow).Test(IdleDictTests)

class IdleDictTests
{
    Begin()
    {
        ; Setup before each test
    }
    
    End()
    {
        ; Cleanup after each test
    }
    
    test_ChampFromID_returns_string()
    {
        result := ChampFromID(1)
        Yunit.Assert(result != "", "ChampFromID(1) should return non-empty string")
    }
    
    test_ChampFromID_known_value()
    {
        result := ChampFromID(1)
        Yunit.Assert(result = "Barrowin", "ChampFromID(1) should return 'Barrowin'")
    }
    
    test_ChampFromID_invalid_id()
    {
        result := ChampFromID(99999)
        Yunit.Assert(result = "", "ChampFromID(99999) should return empty string")
    }
    
    class Regex_Tests
    {
        test_clipboard_parsing()
        {
            testData := "CODE1,CODE2,CODE3"
            Yunit.Assert(InStr(testData, "CODE1"), "Should find CODE1 in clipboard data")
        }
    }
}

### Key Assertions Available

Yunit provides **only one assertion method**:

Yunit.Assert(Value, Message)

- Value: Expression that must evaluate to true
- Message: Optional error message if assertion fails
- Behavior: Throws exception if Value is false; test passes if no exception

Examples:
- Yunit.Assert(1 = 1)
- Yunit.Assert(result != "", "Result is empty")
- Yunit.Assert(InStr(str, "text"))
- Yunit.Assert(obj.property = expectedValue)

---

## 4. Running Tests & Output

### Output Modules

#### YunitWindow (GUI)
Yunit.Use(YunitWindow).Test(TestSuite)
- Displays results in a tree control window
- Green up arrow = pass
- Yellow triangle = fail

#### YunitStdout (Console)
Yunit.Use(YunitStdout).Test(TestSuite)
- Output format: PASS: Category.TestName or FAIL: Category.TestName ErrorMessage
- View with: "C:\Program Files\AutoHotkey\AutoHotkey.exe" test.ahk | more

#### YunitJUnit (CI/CD)
Yunit.Use(YunitJUnit).Test(TestSuite)
- Generates junit.xml in script directory
- Compatible with Jenkins, GitHub Actions, etc.

### Multiple Outputs
Yunit.Use(YunitWindow, YunitStdout, YunitJUnit).Test(TestSuite)

---

## 5. Alternatives to Yunit

### A. expect.ahk (Simpler, Single-File)

**GitHub**: https://github.com/Chunjee/expect.ahk

**Advantages**:
- Single file (export.ahk)
- No dependencies
- TAP (Test Anything Protocol) compliant
- Simpler API: .equal(), .true(), .false(), .notEqual()
- Built-in reporting to file or MsgBox

**Disadvantages**:
- No nested test categories (flat structure)
- Less mature than Yunit

**Installation**:
#Include expect.ahk\export.ahk
expect := new expect()

**Example**:
expect := new expect()
expect.label("ChampFromID tests")
expect.equal(ChampFromID(1), "Barrowin")
expect.equal(ChampFromID(999), "")
expect.fullReport()
expect.writeResultsToFile(".\test_results.log")

### B. AhkUnit (Older, Class-Based)

**GitHub**: https://github.com/ranvis/AhkUnit

**Status**: Unmaintained (last update 2012)

**Not recommended** for new projects.

---

## 6. Simplest Possible Test Runner (DIY Approach)

If you want **zero dependencies**, here's a minimal test runner:

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#Include idledict.ahk

class SimpleTestRunner
{
    __New()
    {
        this.passed := 0
        this.failed := 0
        this.results := []
    }
    
    Assert(condition, message)
    {
        if (condition)
        {
            this.passed++
            this.results.Push("✓ " message)
        }
        else
        {
            this.failed++
            this.results.Push("✗ " message)
        }
    }
    
    Report()
    {
        output := "Test Results
"
        output .= "============

"
        
        for i, result in this.results
            output .= result "
"
        
        output .= "
============
"
        output .= "Passed: " this.passed "
"
        output .= "Failed: " this.failed "
"
        output .= "Total: " (this.passed + this.failed) "
"
        
        return output
    }
    
    WriteToFile(filepath)
    {
        FileAppend, % this.Report(), % filepath
    }
}

runner := new SimpleTestRunner()

runner.Assert(ChampFromID(1) = "Barrowin", "ChampFromID(1) returns Barrowin")
runner.Assert(ChampFromID(2) = "Celeste", "ChampFromID(2) returns Celeste")
runner.Assert(ChampFromID(999) = "", "ChampFromID(999) returns empty")
runner.Assert(InStr("REDEEM123", "REDEEM"), "InStr finds substring")
runner.Assert(Trim("  hello  ") = "hello", "Trim removes whitespace")

MsgBox, % runner.Report()
runner.WriteToFile("test_results.txt")

ExitApp

---

## 7. Recommendation for IdleCombos

### Best Choice: **Yunit** (master branch)

**Why**:
1. Mature, well-documented framework
2. Supports nested test categories (organize by feature)
3. Multiple output formats (GUI, console, JUnit for CI)
4. Active community (23 forks, 55 stars)
5. Explicitly supports AHK v1.1

**Setup for IdleCombos**:

1. Create Lib/Yunit/ directory with Yunit files
2. Create tests/ directory with test files
3. In tests/run_all_tests.ahk:

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%\..

#Include <Yunit\Yunit>
#Include <Yunit\Window>

#Include idledict.ahk
#Include json.ahk

Yunit.Use(YunitWindow, YunitStdout).Test(
    IdleDictTests,
    ClipboardParsingTests,
    SettingsParsingTests
)

---

## 8. Testing Your Specific Functions

### ChampFromID(id)

class ChampFromIDTests
{
    test_valid_ids()
    {
        Yunit.Assert(ChampFromID(1) != "", "ID 1 should exist")
        Yunit.Assert(ChampFromID(1) != "Unknown", "Should return actual name")
    }
    
    test_invalid_ids()
    {
        Yunit.Assert(ChampFromID(0) = "", "ID 0 invalid")
        Yunit.Assert(ChampFromID(-1) = "", "Negative ID invalid")
        Yunit.Assert(ChampFromID(999999) = "", "Very large ID invalid")
    }
    
    test_return_type()
    {
        result := ChampFromID(1)
        Yunit.Assert(!IsObject(result), "Should return string, not object")
    }
}

### getChestCodes() (Clipboard Parsing)

class ClipboardCodesTests
{
    test_single_code()
    {
        A_Clipboard := "REDEEM123"
        codes := ParseClipboardCodes()
        Yunit.Assert(codes.Count() = 1, "Should find 1 code")
    }
    
    test_multiple_codes_newline_separated()
    {
        A_Clipboard := "CODE1
CODE2
CODE3"
        codes := ParseClipboardCodes()
        Yunit.Assert(codes.Count() = 3, "Should find 3 codes")
    }
    
    test_codes_with_whitespace()
    {
        A_Clipboard := "  CODE1  
  CODE2  "
        codes := ParseClipboardCodes()
        Yunit.Assert(codes[1] = "CODE1", "Should trim whitespace")
    }
}

ParseClipboardCodes()
{
    codes := []
    Loop, Parse, A_Clipboard, 

    {
        code := Trim(A_LoopField)
        if (code != "")
            codes.Push(code)
    }
    return codes
}

### Settings JSON Parsing

class SettingsMigrationTests
{
    test_load_valid_settings()
    {
        jsonStr := "{""version"":23,""user_id"":123,""hash"":""abc""}"
        settings := JSON.parse(jsonStr)
        
        Yunit.Assert(settings.version = 23)
        Yunit.Assert(settings.user_id = 123)
        Yunit.Assert(settings.hash = "abc")
    }
    
    test_migrate_old_version()
    {
        oldJson := "{""version"":22,""user_id"":123}"
        oldSettings := JSON.parse(oldJson)
        
        if (oldSettings.version < 23)
            oldSettings.version := 23
        
        Yunit.Assert(oldSettings.version = 23)
    }
}

---

## Summary

**For IdleCombos, use Yunit (master branch)**:
1. Clone https://github.com/Uberi/Yunit to Lib/Yunit/
2. Create test files in tests/ directory
3. Use #Include <Yunit\Yunit> and #Include <Yunit\Window>
4. Write test classes with methods named test_*
5. Run with Yunit.Use(YunitWindow).Test(TestClass)

**Key assertion**: Yunit.Assert(condition, "message")

**For pure functions** (ChampFromID, parsing, JSON), Yunit is ideal because:
- No side effects to manage
- Simple true/false assertions
- Easy to organize by feature
- Can run in CI/CD pipeline with JUnit output
