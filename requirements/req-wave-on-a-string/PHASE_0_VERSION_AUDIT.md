# PHASE 0 — VERSION AUDIT · Wave on a String

| Source | Version / note |
| ------ | -------------- |
| Local `package.json` | **1.3.0-dev.0** |
| GitHub main (reported) | 1.3.0-dev.0 (matches local; still verified via local file) |
| Official runtime `latest` | May lag or lead dev tag — treat runtime as visual cross-check only |
| User screenshot | Matches current Manual/Fixed initial UI including Pulse radios |

## Feature flags (local package.phet.simFeatures)

| Feature | Value |
| ------- | ----- |
| supportsDynamicLocale | true |
| supportsInteractiveDescription | true |
| supportsSound | true |

## Brands

`phet`, `phet-io`, `adapted-from-phet`

## HISTORICAL (not current spec)

- Flash HTML conversion notes in credits / NO_END comments  
- Older boundary-switch vibration issues (PhET issue trackers) — re-verify only if code still special-cases; current special case is Fixed `zeroOutEndPoint` only  

## VERSION_DELTA candidates for Flutter

See `PHASE_0_SOURCE_AUDIT.md` § Known VERSION_DELTA Candidates (VD-SOUND, VD-A11Y, VD-PHETIO, VD-LOCALE, VD-BEAD-CACHE).
