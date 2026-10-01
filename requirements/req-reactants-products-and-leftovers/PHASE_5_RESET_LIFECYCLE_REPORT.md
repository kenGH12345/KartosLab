# PHASE_5 — Reset & Lifecycle Report

日期：2026-09-22

## Reset Matrix

| Screen | 修改 | Reset | Expected | Result |
|---|---|---|---|---|
| Sandwiches | recipe | Reset | Cheese | PASS |
| Sandwiches | quantity | Reset | 0 | PASS |
| Sandwiches | accordion | Reset | both expanded | PASS |
| Molecules | reaction | Reset | Make Water | PASS |
| Molecules | quantity | Reset | 0 | PASS |
| Molecules | accordion | Reset | both expanded | PASS |
| Game | level/progress | Reset | Settings, score=0 | PASS |
| Game | guess | Reset | challenge=null | PASS |
| Game | feedback / visibility / timer / bestScores | Reset | defaults | PASS |

测试：`test/.../final/lifecycle_reset_test.dart`

## Lifecycle

| Flow | Result |
|---|---|
| Sandwiches create → interact → dispose → recreate | PASS |
| Molecules create → interact → dispose → recreate | PASS |
| Game create → play → dispose → recreate | PASS |
| Game timer stop on settings/reset | PASS（无泄漏 running timer） |

## Leaks checked

| Resource | Finding |
|---|---|
| static / singleton Model | 无 |
| shared ChangeNotifier | 无 |
| GameTimer left running after reset | 无 |
| AnimationController（Game） | 未引入额外 timer/ticker |

## Reset / Lifecycle Result

**PASS**
