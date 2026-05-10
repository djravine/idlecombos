# IDLE COMBOS

Companion App for Idle Champions, written in [AHK](https://www.autohotkey.com/).

**v3.78** is the current supported Version. [View changelog.](https://github.com/djravine/idlecombos/blob/master/CHANGELOG.md)

![Screenshot](https://i.imgur.com/LoeTt9r.png)

## Important Notes

* Steam Launcher will not open Idle Champions if Steam is not open and logged in.
* Steam game detection only works if your Steam Library is in the default location.
* If you use a VPN you may have API communication issues. Please whitelist AHK/IdleCombos in your VPN.

## Security Notice

* Your `user_id` and `hash` are sensitive credentials stored locally in `idlecombosettings.json`.
* Do not share your `hash` with anyone — it grants full API access to your account.
* IdleCombos never sends your credentials anywhere except the official game API server.

## Features

* Simple account statistics display
* Easy buying/opening many chests (Gold/Silver/Event)
* Easy apply bulk blacksmith contracts
* Enter multiple redeem codes at once
* Load active codes directly from the web
* [Briv Stack Calculator](https://github.com/Deatho0ne) integration
* Manual starting/stopping adventures (sometimes can fix stuck accounts)
* Can reload game client on crash (Steam only)

## Requirements

* Steam install *or*
* Epic Games install *or*
* Standalone install *or*
* Able to enter your `user_id` & `hash` if on another platform.

## Includes

* `IdleCombos.ahk` — Main application
* `IdleCombosLib.ahk` — Shared library functions
* `idledict.json` — Champion/chest/campaign ID definitions
* [`json.ahk`](https://github.com/Chunjee/json.ahk) — JSON parsing library
* `README.md` — This file

## How To Run

* Install [AutoHotKey v1.1](https://www.autohotkey.com/download/ahk-install.exe)
* Checkout this repo or download a [release](https://github.com/djravine/idlecombos/releases)
* If you downloaded a release, unzip into a folder
* Right-click `IdleCombos.ahk` and open with AutoHotKey
* The application will ask you to detect your App ID from your currently installed Idle Champions install folder

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for developer setup and guidelines.

## Discord

* [Discord Support Server](https://discord.gg/wFtrGqd3ZQ)

## License

[MIT](LICENSE)
