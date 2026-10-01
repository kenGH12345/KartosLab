# Build an Atom — Dependency Lock

Date: 2026-09-27

Sources locked from `phet sourses/build-an-atom-main/build-an-atom-main/dependencies.json`
(comment header notes `1.9.0-dev.5` snapshot; local `package.json` reports `1.10.0-dev.0`).

## Build an Atom

| Field | Value |
|---|---|
| version | `1.10.0-dev.0` (`package.json`) |
| commit (dependencies.json) | `d5ef0ac590d0b7609af3af34f5c0f5281e2aa376` |
| local path | `phet sourses/build-an-atom-main/build-an-atom-main` |
| git in local tree | no (zip extract); SHA taken from `dependencies.json` |

## shred

| Field | Value |
|---|---|
| repo | https://github.com/phetsims/shred |
| commit | `427a2abe9f84c6d94bffdb99d1bdb0fd6c843be8` |
| branch | main (detached at lock SHA) |
| local path | `phet sourses/shred` |

## vegas

| Field | Value |
|---|---|
| repo | https://github.com/phetsims/vegas |
| commit | `8300aa3f8abb3c1981659963e846455a218482b8` |
| branch | main (detached at lock SHA) |
| local path | `phet sourses/vegas` |

## Policy

Do **not** implement against `latest` shred/vegas. Re-lock SHAs deliberately if upgrading.
