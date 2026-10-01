# Balancing Act — Interaction Audit

> Phase 0 · Source-only · 2026-09-23

---

## 1. Interaction matrix

| Interaction | Input | Model Change | View Change | Constraint |
|-------------|-------|--------------|-------------|------------|
| Drag mass | Pointer down/move | `userControlled=true`；position = viewToModel + offset | mass node follows pointer | 无 view 边界钳制（DragHandler） |
| Pick up from plank | userControlled→true | `removeMassFromSurface` | mass 离开 plank；θ 可能变化（若 NO_COLUMNS） | — |
| Drop on plank | Pointer up | `addMassToSurface` if above + open snap | snap 到 0.25 m 格点；onPlank | 中心槽禁用；占用槽拒绝 |
| Drop miss (Intro) | Pointer up | y→0 若在可见区；否则 position reset | 回地面或初位 | `BAIntroView` |
| Drop miss (Lab) | Pointer up | `removeMassAnimated` | 飞回 toolbox 并缩小 | `Mass.initiateAnimation` |
| Drop miss (Game) | Pointer up | position → (3,0) | mass 回初始 | `BalanceGameModel` |
| Column toggle | ABSwitch | `columnState` DOUBLE↔NO | 柱显隐；θ 强制 0 | Intro/Lab only |
| Show Mass Labels | Checkbox | viewProperty | kg 文字显隐 | 默认 true |
| Show Forces | Checkbox | viewProperty | 力矢量箭头 | 默认 false |
| Show Level | Checkbox | viewProperty | 气泡水平仪 | 默认 false |
| Position None/Rulers/Marks | Radio | `positionMarkerStateProperty` | 尺子 / 刻度标记 | 默认 NONE |
| Lab create mass | Drag from Carousel creator | `addMass` + press drag | 新 mass 出现 | Creator forwarding listener |
| Lab carousel page | Carousel arrows | — | Bricks / People / Mystery | sun/Carousel |
| Reset All (Intro/Lab) | ResetAllButton | model.reset + viewProperties.reset | 全清 | interrupt drag first |
| Game select level | LevelSelectionButton | levelProperty；生成 challenges | 进入挑战 | 4 levels |
| Game Check | TextPushButton | 评分 / gameState | Face / feedback | challenge-type dependent |
| Game Next / Try Again / Show Answer | TextPushButton | challengeIndex / reveal | UI 切换 | Vegas 流程 |
| Game timer toggle | TimerToggleButton | timerEnabledProperty | 时钟图标 on/off | 选关页 |
| Game Reset (level select) | ResetAllButton | gameModel.reset | 分数/时间清零 | StartGameLevelNode |

---

## 2. Mass drag pipeline

**Handler**: `js/common/view/MassDragHandler.ts` extends `scenery/DragListener`

| Phase | Behavior | Lines |
|-------|----------|-------|
| options | `allowTouchSnag: true` | L25 |
| start | `userControlled=true`；`dragOffset = mass.pos − viewToModel(pointer)` | L27–31 |
| drag | `position = viewToModel(pointer) + dragOffset` | L34–37 |
| end | 多指修复后 `userControlled=false` | L39–47 |

挂接：`ImageMassNode` / `BrickStackNode`。

**落点不在 DragHandler**，在 Screen/Model：
1. `userControlled` → false 触发监听
2. `Plank.addMassToSurface(mass)`：
   - 条件：`isPointAbovePlank(middle)` 且 `getOpenMassDroppedPosition ≠ null`
   - snap 间距 0.25 m；去掉中心；占用 `<0.025 m`
3. 失败 → 各 Screen 分支（见上表）

拖拽中高亮：`Plank.step` 更新 `activeDropPositions` → `PlankNode` 白高亮。

---

## 3. Snap / position limits

| Item | Value |
|------|-------|
| Mode | **discrete snap** |
| Spacing | 0.25 m |
| Slot count generated | 17 |
| Usable after removing center | 16 |
| Max \|distance from center\| | 2.0 m |
| Continuous slide on plank? | **No** |
| Leave plank? | Yes — 拖起即 remove |
| Pivot moveable? | **No** |

---

## 4. Controls inventory (source widgets)

| UI | Widget class | Screen |
|----|--------------|--------|
| Show checkboxes | `sun/VerticalCheckboxGroup` | Intro, Lab |
| Position radios | `sun/VerticalAquaRadioButtonGroup` | Intro, Lab, Game |
| Column switch | `sun/ABSwitch` in `ColumnOnOffController` | Intro, Lab |
| Mass kit | `MassCarousel` extends `sun/Carousel` | Lab |
| Reset All | `scenery-phet/ResetAllButton` | Intro, Lab, Game select |
| Level select | `vegas/LevelSelectionButtonGroup` | Game |
| Stars | `vegas/ScoreDisplayStars` | Game |
| Timer | `scenery-phet/TimerToggleButton` | Game select |
| Status bar | `vegas/FiniteStatusBar` | Game play |
| Game buttons | `sun/TextPushButton` | Game |
| Mass entry | `MassValueEntryNode` (HSlider + ArrowButton) | Game mass deduction |
| Tilt prediction | `TiltPredictionSelectorNode` | Game |

---

## 5. Reset All — full chain

### Intro / Lab (`BasicBalanceScreenView.reset`)
1. `interruptDragHandlerEmitter.emit()`
2. `model.reset()`
3. 重置全部 `viewProperties`（labels / forces / level / position）

子类：
- Intro：mass 回初位 → plank 清空 → columns DOUBLE
- Lab：清空所有动态 mass + `massCarousel.reset()`

### Game select (`StartGameLevelNode` → `BalanceGameView`)
- `gameModel.reset()`：timer、level、challengeIndex、score、gameState、columnState、elapsedTime、bestScores、bestTimes
- `positionMarkerStateProperty.reset()`

---

## 6. Pause / Play

**无** Intro/Lab 暂停按钮。  
物理随 joist 帧 `step(dt)` 持续运行。  
Game 有挑战状态机，但不是全局 pause。
