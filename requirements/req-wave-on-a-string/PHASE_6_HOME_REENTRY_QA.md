# PHASE 6 — HOME RE-ENTRY QA

## Policy

```text
Re-entry policy = Back → dispose · reopen → fresh WoasModel (source initial)
```

## Fresh initial checklist

```text
Manual · Fixed End
Amplitude 0.75 cm · Frequency 1.50 Hz · Pulse Width 0.5 s
Damping 0.2 · Tension 0.8
Playing = true · Normal
Tools OFF · 61 beads = 0
```

| Test | Result |
| ---- | ------ |
| mutate all → Back → reopen | PASS · identical(a,b)=false · expectInitial |
| re-entry ×3 | PASS · three distinct models |
| A/B/C isolation (no Home) | PASS |

Stale wave / timer / ruler / mode / boundary: **none**.
