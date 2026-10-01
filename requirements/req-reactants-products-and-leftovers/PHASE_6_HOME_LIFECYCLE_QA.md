# PHASE_6 — Home Lifecycle QA

日期：2026-09-22

## Policy

与现有多屏 sim 一致：

```text
open → interact → Back(pop) → dispose controllers → reopen = fresh
```

## Results

| Check | Result |
|---|---|
| open → back → reopen ×2 无异常 | PASS |
| owned Controllers dispose（notifyListeners throws） | PASS |
| 无 duplicate listeners / stale controllers | PASS |
| Game timer 随 Home dispose 停止 | PASS（GameController.dispose → model.dispose） |

## Re-entry freshness

| Path | Result |
|---|---|
| dirty Sandwiches → Back → reopen defaults | PASS |
| dirty Molecules → Back → reopen defaults | PASS |
| Game score/progress → Back → Settings score=0 | PASS |
| dirty all three → reopen all fresh | PASS |
