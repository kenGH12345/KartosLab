# SOURCE_BEHAVIOR_MATRIX — RPL

以 local source 为准。行 = 行为；列 = Screen。

## 1. Reaction 计算

| 行为 | Sandwiches | Molecules | Game |
|---|---|---|---|
| 改 reactant quantity → 重算 products/leftovers | ✅ 实时 | ✅ 实时 | ✅ answer reaction 固定；guess 侧 spinner |
| 改 Custom 系数 → 重算 + 更新 sandwich 图 | ✅ | — | — |
| `isReaction()==false` → 0 products | ✅ Custom | — | — |
| Limiting reactant | 隐式（min floor） | 隐式 | 隐式（教学不单独标注） |

## 2. Before / After 面板

| 行为 | Sandwiches | Molecules | Game |
|---|---|---|---|
| Before 显示 reactant stacks | ✅ | ✅ | ✅ RandomBox |
| After 显示 products + leftovers stacks | ✅ | ✅ | ✅ RandomBox |
| Accordion collapse（减号） | ✅ | ✅ | ❌（Game 用 HideBox） |
| 面板标题 | Before/After **"Reaction"** | Before/After **Reaction** | 无标题栏（RandomBox） |

## 3. Quantities 区（面板下方）

| 行为 | Sandwiches | Molecules | Game |
|---|---|---|---|
| Reactants bracket + spinners | ✅ 可调 | ✅ 可调 | Before 挑战：guess 可调 |
| Products bracket + 只读数 | ✅ | ✅ | After 挑战：guess 可调 |
| Leftovers bracket + 只读数 | ✅ | ✅ | After 挑战：guess 可调 |
| 显示化学 symbol | ❌ | ✅ RichText | ✅ |
| 显示 ingredient 图 | ✅ | ✅ 分子 | ✅ |

## 4. Show / Hide 语义

| 控件 | Sandwiches | Molecules | Game |
|---|---|---|---|
| Show All | ❌ | ❌ | ✅ Settings |
| Hide Molecules | ❌（accordion 折叠≠此控件） | ❌ | ✅ 覆盖 answer 分子区 |
| Hide Numbers | ❌ | ❌ | ✅ 覆盖 answer 数字区 |

**Sandwiches/Molecules**：折叠 accordion = 隐藏 stack 内分子/图标，**数字 spinners 仍可见**。

**Game Hide Molecules**：`hideMoleculesBox` 在 answer box 上；numbers 仍可见（若未 Hide Numbers）。

**Game Hide Numbers**：`hideNumbersBox` 在 answer 侧 static numbers 上；分子仍可见（若未 Hide Molecules）。

NEXT 状态：hide boxes 隐藏，显示完整 answer。

## 5. Reset

| 行为 | Sandwiches | Molecules | Game |
|---|---|---|---|
| Reset All 按钮 | ✅ 右下 | ✅ 右下 | ✅ Settings 右下 |
| 恢复默认 reaction | ✅ Cheese | ✅ Make Water | ✅ level 0 等 |
| quantity → 0 | ✅ | ✅ | ✅（新游戏时） |
| accordion expanded | ✅ reset | ✅ reset | — |
| best score/time | — | — | ✅ 清零 |

## 6. Game 专用

| 行为 | 触发 | 结果 |
|---|---|---|
| Level 选择 | Settings button | `play(level)` → 5 random challenges |
| Check 正确（首次） | Check | +2 分，NEXT |
| Check 错误（首次） | Check | TRY_AGAIN |
| Try Again | button | SECOND_CHECK |
| Check 错误（二次） | Check | SHOW_ANSWER |
| Show Answer | button | 填入正确答案，0 分，NEXT |
| Next | button | 下一 challenge 或 RESULTS |
| 改 guess quantity（TRY_AGAIN 后） | spinner | 自动 → SECOND_CHECK (#37) |
| Check disabled | 全部 guess quantity = 0 | 按钮灰 |
| Perfect score | score == challenges×2 | reward + perfect audio |
| Timer | toggle on | status bar 显示 elapsed |

## 7. Zero / No Reaction

| 场景 | 行为 |
|---|---|
| 全部 reactant quantity = 0 | numberOfReactions = 0；products/leftovers = 0 |
| Custom 系数全 0 或仅 1 个非零且 ≤1 | `isReaction()==false`；方程右侧 No "Reaction" |
| Game zero-product challenge | 故意生成 0 products（每局恰好 1 题） |

## 8. 禁止行为（迁移纪律）

- 不要用 Game visibility 逻辑替换 Sandwiches accordion
- 不要在 View 内直接算 product/leftover（必须 Model → View）
- 不要用 `Icons.refresh` 作 Reset All
- 不要合并三 Screen 为单页
