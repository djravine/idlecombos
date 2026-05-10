# Deploy Process

> How to release a new version of IdleCombos.

## Pipeline Overview

```text
develop ──PR──► master ──tag v*──► release.yml (draft) ──publish──► publish.yml (Discord)
                  │
                  └── ci.yml runs on push/PR (lint, syntax, tests, version check)
```

Three GitHub Actions workflows form the pipeline:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push to `master`/`develop`, PRs | Lint, AHK syntax check, unit tests, version consistency |
| `release.yml` | Tag push matching `v*` | Package dual archives, create draft release |
| `publish.yml` | Release published (draft → public) | Send Discord notification |

## Pre-Release Checklist

Before tagging a release, complete these steps on `develop`:

* [ ] All changes committed and pushed
* [ ] CI passing on `develop` (lint + syntax + tests)
* [ ] `CHANGELOG.md` updated with new version section at top
* [ ] Version bumped in **all three** locations (CI enforces match):

| File | Location | Format |
|------|----------|--------|
| `IdleCombos.ahk` | Line 10 | `global VersionNumber := "X.YZ"` |
| `README.md` | Line 5 | `**vX.YZ**` |
| `CHANGELOG.md` | Top section | `## X.YZ` |

* [ ] `SettingsCheckValue` incremented in `IdleCombosLib.ahk` if new settings keys were added (see [SETTINGS_SCHEMA.md](SETTINGS_SCHEMA.md))
* [ ] `idledict.json` updated if champions/chests were added (bump `MaxChampID`/`MaxChestID`)

## Release Steps

### 1. Merge to master

```bash
git checkout master
git merge develop
git push origin master
```

Wait for CI to pass on `master`.

### 2. Tag the release

```bash
git tag v3.78
git push origin v3.78
```

The `v*` tag push triggers `release.yml`.

### 3. Review draft release

`release.yml` creates a **draft** release on GitHub with four archives:

| Archive | Contents |
|---------|----------|
| `idlecombos-v3.78-no-themes.zip` | AHK scripts, `idledict.json`, icon, images, docs |
| `idlecombos-v3.78-no-themes.tar.gz` | Same as above (tar) |
| `idlecombos-v3.78-themes.zip` | Everything above + `styles/*.msstyles` + `USkin.dll` |
| `idlecombos-v3.78-themes.tar.gz` | Same as above (tar) |

Go to [GitHub Releases](https://github.com/djravine/idlecombos/releases) and review the draft:

* Verify all four archives are present
* Spot-check archive contents (correct files, correct version)
* Edit release notes if needed (CHANGELOG entry is a good source)

### 4. Publish

Click **Publish release** on the draft. This triggers `publish.yml`, which sends a Discord notification to the support server via webhook.

## What Gets Packaged

`release.yml` copies these files into the archive root:

```text
idlecombos-vX.YZ/
├── IdleCombos.ahk
├── IdleCombosLib.ahk
├── json.ahk
├── idledict.json
├── IdleCombos.ico
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── USER_MANUAL.md
├── LICENSE
├── images/
│   └── *.png              (13 GUI assets)
└── styles/                (themes archive only)
    ├── USkin.dll
    └── *.msstyles          (30 theme files)
```

**Excluded from releases** (intentionally):

* `Lib/Yunit/` — AGPL-3.0 test framework, not needed at runtime
* `tests/` — unit tests
* `.github/` — CI/CD workflows
* `AGENTS.md`, `CODE_REVIEW.md`, `CODE_DEPLOY.md`, `CODE_FLOW.md`, `SECURITY.md`, `SETTINGS_SCHEMA.md`, `THIRD_PARTY.md` — developer-only docs
* `.vscode/` — editor config
* `advdefs.json` — regenerated at runtime from API
* All gitignored runtime files (settings, logs, caches)

### Known Packaging Gap

`Lib/ScrollBox.ahk` is `#Include`d by `IdleCombos.ahk` but is **not** copied into the release archive. If this file is required at runtime, `release.yml` needs a step to copy `Lib/` contents. Currently the app will fail to launch from a release archive if ScrollBox is expected.

## CI Pipeline Detail

`ci.yml` runs three parallel jobs on every push and PR:

### lint (ubuntu-latest)

* Runs `markdownlint-cli2` on all `**/*.md` files
* Uses `.markdownlint.json` config at repo root

### validate (windows-latest)

* Installs AutoHotkey v1.1.37.02 via Chocolatey
* Syntax-checks `IdleCombos.ahk` and `IdleCombosLib.ahk` with `/iLib NUL /ErrorStdOut`
* Verifies `VersionNumber` in `IdleCombos.ahk` matches the version in `README.md`

### test (windows-latest)

* Installs AutoHotkey v1.1.37.02 via Chocolatey
* Runs `tests\run_tests_ci.ahk` headlessly (2-minute timeout)
* Uploads `tests/junit.xml` as artifact

## Secrets

| Secret | Used By | Purpose |
|--------|---------|---------|
| `GITHUB_TOKEN` | `release.yml` | Create draft release and upload assets (auto-provided) |
| `DISCORD_WEBHOOK` | `publish.yml` | Post release notification to Discord support server |

No user-managed secrets are needed for CI. `DISCORD_WEBHOOK` must be configured in the repo's GitHub Secrets for publish notifications to work.

## Rollback

If a release has issues:

1. **Unpublish**: Convert the GitHub release back to draft (hides download links)
2. **Delete tag** (if needed):

```bash
git tag -d v3.78
git push origin :refs/tags/v3.78
```

1. **Fix** on `develop`, merge to `master`, re-tag

Release archives are replaceable (`allowUpdates: true` in `release.yml`), so re-tagging the same version will overwrite the existing draft assets.

## Hotfix Process

For urgent fixes that cannot wait for a full release cycle:

1. Branch from `master`: `git checkout -b hotfix/description master`
2. Apply minimal fix
3. Bump version (patch increment)
4. Merge to both `master` and `develop`
5. Tag and release as normal
