# Security

> Threat model and security considerations for IdleCombos v3.80

## Credential Storage

IdleCombos stores the following credentials locally in `idlecombosettings.json`:

* `user_id` — Idle Champions account identifier (plaintext)
* `hash` — API authentication token, **encrypted at rest with Windows DPAPI**
* `instance_id` — game session identifier (plaintext)
* `user_id_epic` — Epic Games account ID (plaintext, if applicable)
* `user_id_steam` — Steam account ID (plaintext, if applicable)

### DPAPI encryption (v3.80+)

The `hash` field is encrypted using Windows Data Protection API (`CryptProtectData`) before being written to `idlecombosettings.json`. The encrypted value is stored as a hex string with a `DPAPI:` prefix. Only the same Windows user account on the same machine can decrypt it.

* **Automatic migration**: Existing users with plaintext hashes are migrated transparently on first load — the plaintext is decrypted as-is, then re-encrypted and saved.
* **Portability**: If settings are copied to a different machine or Windows user, DPAPI decryption will fail. The hash is cleared and the user is prompted to re-enter it via File → Run Setup / Change Platform.
* **In-memory**: The hash is decrypted into memory (`UserHash` global) at load time and used in plaintext for API calls. It is never written to disk in plaintext after migration.

### Why not full encryption?

* `user_id` is not secret — it's visible in the game client and community tools.
* `instance_id` rotates per session and has no standalone value.
* Platform IDs (`user_id_epic`, `user_id_steam`) are public identifiers.
* Only `hash` grants API access and warrants encryption.

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

* Windows Credential Manager via COM (`CredWrite`/`CredRead`) — would eliminate file-based storage entirely.
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
| `USkin.dll` (708 KB) | Unknown Windows theming library | Unknown | SHA-256 verified before `LoadLibrary` |
| `Lib/Yunit/` | [Uberi/Yunit](https://github.com/Uberi/Yunit) | AGPL-3.0 | Vendored from master branch |
| `Lib/ScrollBox.ahk` | AHK forum — Fanatic Guru, 2018 | Unknown | Vendored at `Lib/ScrollBox.ahk` |
| 30 `.msstyles` themes | Various Windows theme authors | Unknown | No provenance documented |

### USkin.dll

This is the highest supply-chain risk. The binary is loaded at runtime via `DllCall("LoadLibrary")` and `DllCall(USkin.dll\USkinInit)`. The app verifies the SHA-256 hash before loading — if the hash cannot be computed or does not match, the DLL is **not** loaded (fail-closed). The source, author, and version are documented in `THIRD_PARTY.md`.

### Dictionary auto-update

`Update_Dictionary()` downloads `idledict.json` from GitHub raw URL (`https://raw.githubusercontent.com/djravine/idlecombos/master/idledict.json`). The download is fetched from the mutable `master` branch (not a pinned commit or signed release tag).

**Current integrity checks:**

* Downloaded file must be valid JSON (parse-back verification)
* Required keys must be present (`version`, `champions`)
* Version downgrades are rejected (`downloaded.version >= current.version`)

**Not verified:**

* No cryptographic signature or checksum from a separate trust anchor
* No commit SHA pinning — relies on GitHub account security (TOFU model)

**Risk assessment (LOW):** The dictionary contains only display-name mappings (champion, chest, campaign, patron, feat names). A tampered dictionary cannot steal credentials, execute code, or modify application behaviour — it can only cause incorrect display names in the UI. The HTTPS transport and structural validation provide reasonable protection for this threat level.

## CI/CD Security

* CI workflow actions are SHA-pinned (immutable references) in all three workflows.
* Secrets are accessed via `${{ secrets.* }}` — no hardcoded tokens.
* Release archives do not include `Lib/Yunit/` (AGPL-3.0 test framework excluded from distribution).
* No code signing on release artifacts.
* No SBOM (Software Bill of Materials) generation.

## Reporting Security Issues

If you discover a security vulnerability in IdleCombos, please report it privately via [Discord](https://discord.gg/wFtrGqd3ZQ) rather than opening a public issue.
