# PHASE_2 — Sandwiches Visual QA

日期：2026-09-22  
判定依据：local source + Widget tests + 代码对照（未跑 Flutter 截图对比机）

## Checklist

| Case | Visual | Binding | Notes |
|---|---|---|---|
| Cheese initial (q=0) | PASS | PASS | 空 stacks，方程 2 bread + 1 cheese → sandwich |
| Meat and Cheese | PASS | PASS | 三反应物 |
| Custom invalid | PASS | PASS | No "Reaction" |
| Custom coeffs 2+1 | PASS | PASS | sandwich 图标更新 |
| quantity = 1 | PASS | PASS | stack 显示 1 |
| quantity = 8 (max) | PASS* | PASS | *stack dense；deltaY source 公式 |
| limiting leftover | PASS | PASS | bread=6 cheese=4 → 3 sandwiches, 1 cheese left |
| accordion closed | PASS | PASS | content AnimatedSize 折叠 |
| accordion open | PASS | PASS | |
| Reset | PASS | PASS | Cheese + q=0 + expanded |

## Tags

- `[原版资源一致]` bread/cheese/meat PNG
- `[布局已对齐]` 835×504 logical + 310×240 boxes
- `[动态绘制已对齐]` SandwichNode 交错堆叠算法

## P2 residual

1. Title-bar expand 按钮橙色方块近似 PhET AccordionButton，非像素级
2. Bracket 几何简化
3. Custom 方程 FittedBox 缩小时字号略小于静态 recipe

## Verdict

```text
Sandwiches Visual QA = PASS (P0=0, P1=0)
Overall Status = NOT READY
```
