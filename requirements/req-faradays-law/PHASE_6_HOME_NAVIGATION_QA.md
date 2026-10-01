# PHASE 6 — HOME NAVIGATION QA · Faraday's Law

| Scenario | Result |
| --- | --- |
| Home → 物理 → 电磁学 → Faraday's Law card listed | PASS |
| Tap card → `FaradaysLawScreen` rendered (not demo) | PASS |
| AppBar title Faraday's Law | PASS |
| Back → Home; Faraday disposed | PASS |
| Home → Faraday → interact → Back | PASS |
| Home → Faraday → interact → Back → Faraday | PASS (fresh) |
| Home → Faraday → Back → 磁铁与罗盘 → Back → Faraday | PASS (no leak) |

Evidence: `test/faradays_law/home/faradays_law_home_lifecycle_test.dart`
