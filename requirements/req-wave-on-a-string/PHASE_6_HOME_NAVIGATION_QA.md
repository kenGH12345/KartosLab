# PHASE 6 — HOME NAVIGATION QA

| Scenario | Result |
| -------- | ------ |
| Home shows 光学与波动 group | PASS |
| Card title + subtitle visible | PASS |
| Tap → `WoasScreen` pushed | PASS |
| AppBar title = Wave on a String | PASS |
| Back → HomeScreen visible · WoasScreen gone | PASS |
| Cross-sim: WOAS → Faraday's Law → Back → WOAS | PASS · fresh Model |

```text
KartosLab Home
    ↓ tap card
WoasScreen (AppBar + PlayArea)
    ↓ Back
Home (dispose Screen + clock + owned Model)
```
