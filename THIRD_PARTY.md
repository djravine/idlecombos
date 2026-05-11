# Third-Party Dependencies

> Vendored assets shipped with IdleCombos v3.80

All dependencies are vendored (copied into the repository). There is no package manager.

## Runtime Dependencies

### json.ahk — JSON Parser

* **Source**: [Chunjee/json.ahk](https://github.com/Chunjee/json.ahk)
* **License**: MIT
* **Version**: Unknown (no version tag in file; vendored snapshot)
* **SHA-256**: `656204C6FA2A8FC8D3F43BCE73FA1610035CDF9EEE0F27F9BF4E4EA21C67C893`
* **Notes**: AHK v1.1 + v2 compatible JSON parser. Used for all JSON serialisation/deserialisation.

### USkin.dll — Windows Theming

* **Source**: USkin skinning library by SkinSoft ([skinsoft.com](http://www.skinsoft.com/), no longer active). Redistributed across AHK community forums. Original author/distributor unverifiable.
* **License**: Proprietary/Unknown — no license file accompanies the binary
* **Version**: Unknown (no version resource in DLL)
* **Size**: 708,608 bytes
* **SHA-256**: `9CCF45F05DC84F343D63EBCD96D2C2452257C2582EBE05C2FE317A16D62A3347`
* **Risk**: Opaque closed-source binary loaded at runtime via `DllCall("LoadLibrary")`. Cannot be audited. The app verifies the SHA-256 hash before loading to detect tampering.
* **Mitigation**: Theming is optional. If the `styles/` directory is absent (e.g. "no-themes" release), the DLL is never loaded and the app runs with default Windows styling.

### .msstyles Themes (30 files)

* **Source**: Various Windows theme authors (community themes)
* **License**: Unknown (community themes, no license files included)
* **Notes**: Optional UI themes in `styles/`. App functions without them (falls back to default Windows style).

### ScrollBox — Scrollable Text Display

* **Source**: [AHK Forum — Fanatic Guru (2018)](https://www.autohotkey.com/boards/viewtopic.php?t=46516)
* **License**: Unknown (forum post, public domain assumed)
* **Version**: 1.21 (2018-06-09)
* **Location**: `Lib/ScrollBox.ahk`
* **Notes**: Helper function for displaying scrollable text in message boxes.

## Test-Only Dependencies

### Yunit — Test Framework

* **Source**: [Uberi/Yunit](https://github.com/Uberi/Yunit) (master branch)
* **License**: **AGPL-3.0** (see `Lib/Yunit/LICENSE.txt`)
* **Version**: Master branch snapshot (~2022)
* **Location**: `Lib/Yunit/`
* **Notes**: Used only for running unit tests. **Not included in release archives** — verified in `release.yml` (only root `*.ahk` + `Lib/ScrollBox.ahk` are copied; `Lib/Yunit/` is excluded).

#### AGPL-3.0 / MIT Boundary

The root project is MIT-licensed. Yunit is AGPL-3.0. These coexist safely because:

1. **Not distributed together** — release archives exclude `Lib/Yunit/` entirely. End users never receive AGPL-licensed code.
2. **Not linked at runtime** — Yunit is only `#Include`d by test runner scripts (`tests/run_tests*.ahk`), never by the main application (`IdleCombos.ahk`).
3. **Test-only dependency** — AGPL's copyleft provisions apply to "conveying" (distributing) the work. Since Yunit is never conveyed to users, no AGPL obligations attach to the MIT-licensed project.

Developers who clone the repo receive Yunit under its own AGPL-3.0 terms for test execution purposes only.

## Data Files

### idledict.json — Game Dictionary

* **Source**: Maintained by project contributors
* **License**: MIT (same as project)
* **SHA-256**: `80C964B1294F4DA3747ABFDD495ECFBB1C1CF4DAB652D53B651DA63CFBD39E14`
* **Notes**: ID-to-name mappings for champions, chests, campaigns, patrons, and feats. Can be auto-updated from GitHub via Help menu or synced from game API.

## Verification

To verify vendored file integrity:

```powershell
Get-FileHash -Path json.ahk -Algorithm SHA256
Get-FileHash -Path styles\USkin.dll -Algorithm SHA256
Get-FileHash -Path idledict.json -Algorithm SHA256
```

Compare output against the SHA-256 values listed above.
