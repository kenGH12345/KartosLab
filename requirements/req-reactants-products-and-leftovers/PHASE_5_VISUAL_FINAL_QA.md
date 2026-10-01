# PHASE_5 — Visual Final QA

日期：2026-09-22  
原则：不重画 UI；只核对 P0/P1；P2 记录不阻断。

## Priority counts

| Sev | Count | Action |
|---|---:|---|
| P0 | **0** | — |
| P1 | **0** | — |
| P2 | 6 | 记录（Phase 4 VERSION_DELTA） |

## Screenshot / scene matrix（逻辑核对）

### Sandwiches

| Scene | P0/P1 | Notes |
|---|---|---|
| initial | OK | Cheese default |
| quantity changed | OK | spinner + stacks |
| Custom | OK | coefficient spinners |
| invalid Custom | OK | No "Reaction" |
| after reaction | OK | leftovers/products |
| reset | OK | KratosResetAllButton |

### Molecules

| Scene | P0/P1 | Notes |
|---|---|---|
| Make Water / Ammonia / Combust Methane | OK | FormulaText + MoleculeIcon |
| quantity changed | OK | stack 跟 Model |
| after / reset | OK | |

### Game

| Scene | P0/P1 | Notes |
|---|---|---|
| Choose Level | OK | 3 levels unlocked（source 无锁） |
| Level 1/2/3 question | OK | Before vs After |
| correct / incorrect / Show Answer / Next | OK | PlayState buttons |
| Results | OK | stars + score |
| Reset | OK | Settings only |

## P2 backlog（不阻断）

1. Game RandomBox 非 scenery 逐像素布局  
2. Game 非七分子以外 FormulaText chip（非 Material / emoji）  
3. FaceWithPoints CustomPainter 近似  
4. FiniteStatusBar / LevelCompletedNode 语义重建  
5. Level 按钮图标为文本示意（?→HCl 等）  
6. Reward confetti 简化 painter  

## Assets

```text
Substituted = 0
```

- Sandwiches：原 sandwich PNG / painter 路径保持  
- Molecules：nitroglycerin 几何 MoleculeIcon  
- Game：无第三方替代图  

## Visual Final Result

**PASS**（P0=0, P1=0）
