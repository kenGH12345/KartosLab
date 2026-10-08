# ANDROID_ZH_ACCESSIBILITY_REPORT

> PHASE 8

## Verdict

**PASS** with documented P2

## Runtime checks

| Item | Result |
|---|---|
| Reset control present / tappable | PASS (`KratosResetAllButton` in Collision / Buoyancy / high-risk paths) |
| Chinese control labels | PASS (tabs 比较/探索/实验室…; Faraday 电压表/磁场线; blackbody 全部重置) |
| Object / panel labels Chinese | PASS on entered sims |
| Automation IDs / widget keys | PASS (Buoyancy tab keys `buoyancy_tab_*` still resolvable) |
| Route / Navigator pop | PASS (`goBackHome` → HomeScreen) |

## P2

- Material `BackButton` tooltip / semantics default: English `"Back"`.
  Not expanded into exception whitelist; tracked as Android chrome P2 only.
  Does **not** reset GLOBAL ZH VERIFIED.
