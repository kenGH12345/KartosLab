# ANIMATION_AUDIT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **日期**: 2026-09-23  
> **原则**: Flutter 保持流畅，但**禁止**添加 source 没有的装饰性动画。

---

## 1. Search results

在 `js/` 内检索 `Animation` / `Tween` / `twixt` / `ease` / `animate`：

| Match | Meaning |
|-------|---------|
| `GameScreenView.step(dt)` | 仅转发到 `BCERewardNode.step` |
| Coefficient / Particles / Scales / Bars | **无** Tween — Property 即时更新 |
| BalanceScaleNode rotation | 即时 `setRotation(angle)`，无阻尼 |
| RightArrowNode color | 即时 fill 切换 |
| AccordionBox | sun Accordion 自带 expand/collapse（PhET 标准，非本 sim 自定义 Tween） |
| NumberPicker long-press | timerDelay 400ms / timerInterval 200ms（连续步进，非补间动画） |

本 sim **未**依赖 `twixt` 做 UI 动画。

---

## 2. Animation inventory

| Animation | Trigger | Duration | Source | Flutter guidance |
|-----------|---------|----------|--------|------------------|
| Particle show/hide | coefficient ↑↓ | **instant** | `ParticlesAccordionBox.updateMoleculeNodes` | Instant visibility / add child；**no** fade/scale pop |
| Scale tilt | atom count Δ | **instant** | `BalanceScaleNode.updateNode` | Instant Transform rotation |
| Scale beam highlight | element balanced | **instant** | `BalanceBeamNode.setHighlighted` | Instant color |
| Bar height reshape | atom count Δ | **instant** | `BarNode` shape rebuild | Instant |
| Arrow balanced color | `isBalanced` | **instant** | `RightArrowNode.updateHighlight` | Instant |
| Accordion expand/collapse | Reactants/Products button | PhET Accordion default | `sun/AccordionBox` | Match sun Accordion timing if L0 has it；else brief standard expand — **do not** invent bounce |
| Face smile/frown | balanced feedback | instant swap | `FaceNode.smile/frown` | Instant |
| Feedback panel appear | Check result | appear（无自定义 tween） | `GameFeedbackNode.visible` | Show/hide；no custom bounce |
| Coefficient long-press repeat | hold NumberPicker | 400ms then every 200ms | `CoefficientPicker` | Same delays |
| **Reward rain** | Perfect score / `?showReward` | continuous `step(dt)` | `BCERewardNode` ← `vegas.RewardNode` | Port RewardNode motion；150 random nodes |
| LevelCompleted dialog | level end | vegas layout | `BCELevelCompletedNode` | Static panel + Continue |
| Reset All press | user tap | scenery-phet ResetAll | `KratosResetAllButton` | L0 elasticOut rebound（项目规则） |

---

## 3. Explicit non-animations（不要加）

| Temptation | Source reality |
|------------|----------------|
| Molecules flying in when coeff increases | Only visibility / new node at rest position |
| Scale spring / damping | Instant discrete tilt levels (6 steps) |
| Bar grow tween | Instant height |
| Screen transition between Intro/Equations/Game | Joist Screen default only |
| Game challenge cross-fade | Instant swap EquationNode |
| Show Why slide-in | Instant toggle visibility |

---

## 4. Sound（非动画，但同步触发）

| Event | Audio |
|-------|-------|
| Check correct (simplified) | `GameAudioPlayer.correctAnswer()` |
| Check incorrect | `wrongAnswer()` |
| Level complete perfect | `gameOverPerfectScore()` |
| Level complete imperfect | `gameOverImperfectScore()` |
| Coefficient change | none |
| Show Why | none |

---

## 5. Phase 5 / 6 checklist

- [ ] Particle updates: no fade  
- [ ] Scales: discrete tilt matching `NUMBER_OF_TILT_ANGLES=6` formula  
- [ ] Reward only on perfect（or debug flag）  
- [ ] Reset All uses L0 rebound only  
- [ ] No hero “chemistry sparkle” extras
