# PHASE_7 — Final Visual Audit

日期：2026-09-22  
原则：不重画；核对 Phase 5–6 证据 + 当前代码状态。

## Counts

| Sev | Count | Disposition |
|---|---:|---|
| P0 | **0** | — |
| P1 | **0** | — |
| P2 | **5** | Accepted VERSION_DELTA（不阻断 READY）；见 POST_READY hotfix |

## Scene checklist（逻辑终核）

### Sandwiches

| Scene | Gate |
|---|---|
| initial / Custom / invalid Custom / after / reset | PASS（Phase 5 + 119 regression） |

### Molecules

| Scene | Gate |
|---|---|
| Water / Ammonia / Methane / after / reset | PASS |
| FormulaText H₂O NH₃ CH₄ | PASS |

### Game

| Scene | Gate |
|---|---|
| Choose Level / Play / correct / incorrect / Show Answer / Next / Results | PASS |

### Home

| Scene | Gate |
|---|---|
| 化学 → 反应物与生成物 → RPL card | PASS |
| Tabs Sandwiches \| Molecules \| Game | PASS |
| Back / re-entry | PASS |
| 无 double AppBar | PASS |

## Accepted P2 / VERSION_DELTA（非阻断）

1. Game RandomBox 布局近似  
2. ~~非 Molecules 七分子 FormulaText chip~~ → **CLOSED**（`POST_READY_HOTFIX_REPORT`：全池 MoleculeIcon）  
3. FaceWithPoints CustomPainter 近似  
4. FiniteStatusBar / LevelCompleted 语义重建  
5. Level 按钮图标文本示意  
6. Reward confetti 简化  

Remaining Accepted P2 = **5**（条目 1、3–6）。

## Assets

```text
Substituted = 0
```

- Sim 内：原 sandwich PNG + nitroglycerin geometry painters  
- Home 卡片：`Icons.restaurant_outlined`（项目统一 Material 策略，非 sim asset 替代）

## Visual Final

**PASS**（P0=0, P1=0）
