# Third-Party Dependencies

> Vendored assets shipped with IdleCombos v3.78

All dependencies are vendored (copied into the repository). There is no package manager.

## Runtime Dependencies

### json.ahk — JSON Parser

* **Source**: [Chunjee/json.ahk](https://github.com/Chunjee/json.ahk)
* **License**: MIT
* **Version**: Unknown (no version tag in file; vendored snapshot)
* **SHA-256**: `656204C6FA2A8FC8D3F43BCE73FA1610035CDF9EEE0F27F9BF4E4EA21C67C893`
* **Notes**: AHK v1.1 + v2 compatible JSON parser. Used for all JSON serialisation/deserialisation.

### USkin.dll — Windows Theming

* **Source**: Unknown (USkin Windows skinning library)
* **License**: Unknown
* **Version**: Unknown
* **Size**: 708,608 bytes
* **SHA-256**: `9CCF45F05DC84F343D63EBCD96D2C2452257C2582EBE05C2FE317A16D62A3347`
* **Notes**: Optional binary loaded at runtime via `DllCall("LoadLibrary")` for `.msstyles` theme support. Only loaded if `styles/` directory exists.

### .msstyles Themes (30 files)

* **Source**: Various Windows theme authors
* **License**: Unknown (community themes)
* **Notes**: Optional UI themes in `styles/`. App functions without them (falls back to default Windows style).

### ScrollBox — Scrollable Text Display

* **Source**: [AHK Forum — Fanatic Guru (2018)](https://www.autohotkey.com/boards/viewtopic.php?t=46516)
* **License**: Unknown (forum post, public domain assumed)
* **Location**: Inline in `IdleCombos.ahk:4176+`
* **Notes**: Helper function for displaying scrollable text in message boxes.

## Test-Only Dependencies

### Yunit — Test Framework

* **Source**: [Uberi/Yunit](https://github.com/Uberi/Yunit) (master branch)
* **License**: **AGPL-3.0** (see `Lib/Yunit/LICENSE.txt`)
* **Version**: Master branch snapshot (~2022)
* **Location**: `Lib/Yunit/`
* **Notes**: Used only for running unit tests. **Not included in release archives** — verified in `release.yml` (only root `*.ahk` files are copied; `Lib/` is excluded).

## Data Files

### idledict.json — Game Dictionary

* **Source**: Maintained by project contributors
* **License**: MIT (same as project)
* **SHA-256**: `80C964B1294F4DA3747ABFDD495ECFBB1C1CF4DAB652D53B651DA63CFBD39E14`
* **Notes**: ID-to-name mappings for champions, chests, campaigns, patrons, and feats. Can be auto-updated from GitHub via Tools menu.

## Verification

To verify vendored file integrity:

```powershell
Get-FileHash -Path json.ahk -Algorithm SHA256
Get-FileHash -Path styles\USkin.dll -Algorithm SHA256
Get-FileHash -Path idledict.json -Algorithm SHA256
```

Compare output against the SHA-256 values listed above.
