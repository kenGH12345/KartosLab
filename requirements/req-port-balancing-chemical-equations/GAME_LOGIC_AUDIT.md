# GAME_LOGIC_AUDIT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Source**: `js/game/**`  
> **日期**: 2026-09-23

---

## 1. High-level flow

```text
Choose Your Level
    → startGame()
        → challenges = level.getChallenges()   // 5 or playAll
        → timer.start() if enabled
        → state = check
    → User edits coefficients
    → Check
        → attempts++
        → if isSimplified:
              award points (2 | 1 | 0 by attempt)
              score += points
              state = next
              if last challenge → endGame()
        → else if attempts < 2:
              state = tryAgain
        → else:
              if last → endGame()
              state = showAnswer
    → Try Again → state = check
    → Show Answer → state = next  (then view calls equation.balance())
    → Next → next challenge | levelCompleted
    → Level Complete → Continue → startOver() → levelSelection
```

State enum（`GameState.ts`）：

```text
levelSelection | check | tryAgain | showAnswer | next | levelCompleted
```

非法转移在 assert 下拒绝（见 `isValidGameStateTransition`）。

---

## 2. Levels

| Level | Class | Icon molecule | Show Why view | Pool size | firstBigMolecule |
|-------|-------|---------------|---------------|-----------|------------------|
| 1 | `GameLevel1` | `HCl` | always `balanceScales` | 21 | **false**（首题禁止 big molecule） |
| 2 | `GameLevel2` | `H2O` | random 50% scales / barCharts | 11 | true (default) |
| 3 | `GameLevel3` | `NH3` | always `barCharts` | 14 | true + **exclusionsMap** |

`Molecule.isBig()`：`atoms.length > 5`。

Coefficients range（all game）：**0…7**。

Challenges per play：**5**（`CHALLENGES_PER_GAME`）。  
Perfect score = `5 * POINTS_FIRST_ATTEMPT` = **10**。

---

## 3. Challenge datasets（禁止手写新题）

### Level 1 (`EquationPool1`) — 21 equations

含（balanced coeffs）：

- `PCl5 → PCl3 + Cl2`
- `CH3OH → CO + 2 H2`
- `2 H2 + O2 → 2 H2O`
- `H2 + F2 → 2 HF`
- `2 HCl → H2 + Cl2`
- `CH2O + H2 → CH3OH`
- `C2H6 → C2H4 + H2`
- `C2H2 + 2 H2 → C2H6`
- `C + O2 → CO2`
- `2 C + O2 → 2 CO`
- `2 CO2 → 2 CO + O2`
- `2 CO → C + CO2`
- `C + 2 S → CS2`
- `2 NH3 → N2 + 3 H2`
- `2 NO → N2 + O2`
- `2 NO2 → 2 NO + O2`
- `2 N2 + O2 → 2 N2O`
- `P4 + 6 H2 → 4 PH3`
- `P4 + 6 F2 → 4 PF3`
- `4 PCl3 → P4 + 6 Cl2`
- `2 SO3 → 2 SO2 + O2`

### Level 2 (`EquationPool2`) — 11 equations（全 2+2）

- `2 C + 2 H2O → CH4 + CO2`
- `CH4 + H2O → 3 H2 + CO`
- `CH4 + 2 O2 → CO2 + 2 H2O`
- `C2H4 + 3 O2 → 2 CO2 + 2 H2O`
- `C2H6 + Cl2 → C2H5Cl + HCl`
- `CH4 + 4 S → CS2 + 2 H2S`
- `CS2 + 3 O2 → CO2 + 2 SO2`
- `SO2 + 2 H2 → S + 2 H2O`
- `SO2 + 3 H2 → H2S + 2 H2O`
- `2 F2 + H2O → OF2 + 2 HF`
- `OF2 + H2O → O2 + 2 HF`

### Level 3 (`EquationPool3`) — 14 equations

正反成对 + NH3 氧化系列；抽中某式会按 `exclusionsMap` 剔除反向与同系反应物（详见源码 `EquationPool3.ts`）。代表：

- `C2H5OH + 3 O2 → 2 CO2 + 3 H2O` ↔ reverse  
- `2 C2H6 + 7 O2 → 4 CO2 + 6 H2O` ↔ reverse  
- `2 C2H2 + 5 O2 → 4 CO2 + 2 H2O` ↔ reverse  
- `4 NH3 + 3 O2 → 2 N2 + 6 H2O` ↔ reverse  
- `4 NH3 + 5 O2 → 4 NO + 6 H2O` ↔ reverse  
- `4 NH3 + 7 O2 → 4 NO2 + 6 H2O` ↔ reverse  
- `4 NH3 + 6 NO → 5 N2 + 6 H2O` ↔ reverse  

抽题：`EquationPool.getEquations(n)` — `dotRandom`、无重复、应用 exclusions、首题 big-molecule 规则。

---

## 4. Scoring / Stars / Points

| Constant | Value |
|----------|-------|
| `POINTS_FIRST_ATTEMPT` | 2 |
| `POINTS_SECOND_ATTEMPT` | 1 |
| After 2 fails | 0 points；走 Show Answer |

- **正确定义** = `challenge.isSimplifiedProperty`（最简配平）。  
- **仅 balanced 非 simplified** → `BalancedNotSimplifiedPanel`（✓ Balanced + ✗ Not Simplified）；**不得分**；可 Try Again / Show Answer。  
- **Not balanced** → `NotBalancedPanel`（sad face + Not Balanced + Show Why）。  

Stars（level selection）：

- `ScoreDisplayStars(bestScoreProperty, numberOfStars: 5, perfectScore: 10)`  
- 反映 **历史最佳分**，非当前局；Reset All 清 best；Start Over **不清** best。

Try Again：不影响已得 score（尚未得分）；attempts 已增加。  
Show Answer：不得分；显示最简系数。  
Show Why：只改可视化可见性，不影响 score。

---

## 5. Timer

| Item | Behavior |
|------|----------|
| Model | `vegas.GameTimer` |
| Enable | `timerEnabledProperty`（默认 **false**）；LevelSelection `TimerToggleButton` |
| Start | `startGame()` 若 enabled |
| Stop | `endGame()` |
| Reset | `resetToStart()` / full `reset()` |
| Display | Status bar when enabled；best time on level button when `timerEnabled` |
| Best time | `GameUtils.updateScoreAndBestTime` — 仅完美分时更新 best time 语义（vegas） |
| New best | `isNewBestTime` flag → LevelCompleted UI |

---

## 6. Feedback UI

| Condition | Panel | Buttons / Extra |
|-----------|-------|-----------------|
| Simplified | `BalancedAndSimplifiedPanel` | Face + Balanced + Simplified + `+N` points + **Next** |
| Balanced !Simplified | `BalancedNotSimplifiedPanel` | Face + Balanced + Not Simplified + Try Again \| Show Answer |
| Not balanced | `NotBalancedPanel` | Sad face + Not Balanced + Try Again \| Show Answer + **Show Why / Hide Why** |

Show Why：嵌入缩小的 `BalanceScalesNode` 或 `BarChartsNode`（按 level `getViewMode()`），解释**元素计数**不平衡。

Audio（Check）：`GameAudioPlayer.correctAnswer()` iff simplified，else `wrongAnswer()`。  
Level complete：perfect → `gameOverPerfectScore` + Reward；else `gameOverImperfectScore`。

---

## 7. Show Answer vs Show Why（禁止简化）

| | Show Why | Show Answer |
|--|----------|-------------|
| When | NotBalanced panel | After 2nd fail（或 NotSimplified 路径上的按钮） |
| Model | 不改系数 | `showAnswer()` → state `next` → **`equation.balance()`** |
| View | Toggle 守恒可视化 | 写入最简系数；系数不可编辑；Next 可见（若未 simplified——balance 后已 simplified，Next 在 feedback 路径） |
| Score | 无 | 无 |

`initNext` 细节：

- coeffs 不可编辑  
- `nextButton.visible = !isSimplified`（balance() 之后通常为 false，故正确答对时 Next 在 feedback panel 内）  
- feedback 仅当 `pointsProperty > 0` 时保持可见  
- `balance()` **最后**调用

---

## 8. Reset vs Start Over

| | Reset All (level select) | Start Over (in challenge) |
|--|--------------------------|---------------------------|
| bestScore / bestTime | **清零** | **保留** |
| timerEnabled | reset | 保留 |
| level | null | null |
| score / attempts / timer | reset | reset |
| State | levelSelection | levelSelection |

---

## 9. UI during play

- Visualization：**Particles only**（Game 无 View combo）  
- Boxes taller（285×340）  
- Check 居中于 particles 底部；需 `hasNonZeroCoefficient` 才 enable  
- Highlight of balanced arrow：**off** until points earned path (`next`)

---

## 10. Migration must-haves

1. 完整三个 EquationPool + Level3 exclusions  
2. `isSimplified` 计分门闩  
3. 两态错误反馈（NotBalanced vs NotSimplified）  
4. Show Why 真实可视化  
5. Stars ← bestScore；Timer 可选  
6. Start Over ≠ Reset All  
7. 禁止「字符串答案比对」假 Game
