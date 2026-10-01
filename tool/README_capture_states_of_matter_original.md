# Capture States of Matter ORIGINAL shots

## Prerequisite

```bat
npm i playwright
npx playwright install chromium
```

Or one-shot:

```bat
npx --yes playwright install chromium
```

## Run

From repo root:

```bat
node tool/capture_states_of_matter_original.js
```

Writes to `requirements/req-states-of-matter/visual-qa/ORIGINAL/` (15 PNG + meta).

## Sources

- **PRIMARY behavior:** local PhET `1.3.0-dev.3` under `phet sourses/states-of-matter-main/` (unbuilt HTML — usually not runnable).
- **Visual ref URL:** `https://phet.colorado.edu/sims/html/states-of-matter/latest/states-of-matter_all.html`

If phet.colorado.edu is blocked/offline, the script exits with code 2 and prints retry steps. Re-run when network works.

## Notes

- Every shot forces pause (`isPlayingProperty = false`) — particles move.
- Ready wait accepts canvas **or** scenery/joist root.
- Pair names with FLUTTER matrix in `visual-qa/manifest.json`.
