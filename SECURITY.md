# Security

> Threat model and security considerations for IdleCombos v3.78

## Credential Storage

IdleCombos stores the following credentials locally in `idlecombosettings.json` (plaintext JSON):

* `user_id` — Idle Champions account identifier
* `hash` — API authentication token (grants full account access)
* `instance_id` — game session identifier
* `user_id_epic` — Epic Games account ID (if applicable)
* `user_id_steam` — Steam account ID (if applicable)

### Why plaintext?

AutoHotkey v1.1 lacks native bindings to Windows Credential Manager or DPAPI. Implementing encrypted storage would require COM interop with `CryptProtectData` or an external helper binary, adding complexity and a new attack surface for minimal gain — the threat model assumes the local machine is trusted.

### Risk

* **If the machine is compromised**, an attacker with filesystem access can read `idlecombosettings.json` and use the `hash` to make API calls on behalf of the user.
* **If the file is shared accidentally** (e.g. included in a screenshot, backup, or support request), the `hash` grants full API access to the account.

### Mitigations in place

* `idlecombosettings.json` is gitignored — never committed to source control.
* `UserHash` is redacted in all log output (`[REDACTED]`).
* `UserHash` is masked in the UI "List User Details" display.
* README.md includes a Security Notice warning users not to share their hash.
* The app only transmits credentials to official game API servers (`*.idlechampions.com`) over HTTPS.

### Residual risks

* The settings file has no filesystem ACL restrictions — any process or user on the machine can read it.
* No password/PIN protection on the app itself.
* Credentials persist until the user manually deletes the settings file or runs setup again.

### Future hardening (not planned)

* Windows Credential Manager via COM (`CredWrite`/`CredRead`) — would require `DllCall` to `advapi32.dll`.
* File-level encryption via DPAPI (`CryptProtectData`) — same COM complexity.
* Prompt for credentials on each launch instead of persisting — poor UX for a desktop companion tool.

## Network Security

### API communication

All API calls use HTTPS via `WinHttp.WinHttpRequest.5.1` COM object:

* Endpoint: `https://{server}.idlechampions.com/~idledragons/post.php`
* Method: POST
* Credentials are sent as URL query parameters (not POST body)

### Risk: credentials in URL query string

Even over HTTPS, URL query strings containing `user_id` and `hash` may appear in:

* Proxy logs (corporate/VPN environments)
* Windows system event logs
* WinHTTP trace logs if enabled
* Browser history (for support ticket URLs)

The game's official API expects parameters in the query string, so changing this requires server-side support.

### TLS trust

WinHTTP relies on the Windows certificate trust store. No certificate pinning is performed. This is standard for desktop applications and consistent with how the game client itself connects.

### Server redirect handling

`ServerCall()` handles `switch_play_server` responses with a single recursive hop — no infinite redirect loop is possible.

## Supply Chain

### Vendored dependencies

| Asset | Source | License | Integrity |
|-------|--------|---------|-----------|
| `json.ahk` | [Chunjee/json.ahk](https://github.com/Chunjee/json.ahk) | MIT | No version pin or SHA in file |
| `USkin.dll` (708 KB) | Unknown Windows theming library | Unknown | No provenance or hash documented |
| `Lib/Yunit/` | [Uberi/Yunit](https://github.com/Uberi/Yunit) | AGPL-3.0 | Vendored from master branch |
| ScrollBox (inline) | AHK forum — Fanatic Guru, 2018 | Unknown | Embedded in `IdleCombos.ahk:4176+` |
| 30 `.msstyles` themes | Various Windows theme authors | Unknown | No provenance documented |

### USkin.dll

This is the highest supply-chain risk. The binary is loaded at runtime via `DllCall("LoadLibrary")` and `DllCall(USkin.dll\USkinInit)`. No hash verification is performed before loading. The source, author, and version are undocumented.

### Dictionary auto-update

`Update_Dictionary()` downloads `idledict.json` from GitHub raw URL (`https://raw.githubusercontent.com/djravine/idlecombos/master/idledict.json`). The download includes basic integrity verification but does not pin to a specific commit SHA or release tag.

## CI/CD Security

* Release and publish workflow actions are SHA-pinned (immutable references).
* CI workflow actions use floating major version tags (`@v4`, `@v19`) — lower risk but not immutable.
* Secrets are accessed via `${{ secrets.* }}` — no hardcoded tokens.
* Release archives do not include `Lib/Yunit/` (AGPL-3.0 test framework excluded from distribution).
* No code signing on release artifacts.
* No SBOM (Software Bill of Materials) generation.

## Reporting Security Issues

If you discover a security vulnerability in IdleCombos, please report it privately via [Discord](https://discord.gg/wFtrGqd3ZQ) rather than opening a public issue.
