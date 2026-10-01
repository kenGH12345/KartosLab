# Balancing Chemical Equations — PHASE 0 Source Audit Report

> **req-id**: `req-port-balancing-chemical-equations`  
> **Audit date**: 2026-09-23  
> **Auditor**: PhET → Flutter Native Migration Engineer  
> **Priority**: Local PhET Source → Original Assets → User Screenshots → Official Runtime → Flutter  
> **Gate**: Phase 0 — **PASS**（完整源码审计完成；未写 Flutter UI）

---

## PHASE 0 STATUS: PASS

---

## A. Source Version

| Field | Value |
|-------|-------|
| Package | `balancing-chemical-equations` |
| `package.json` version | **2.2.0-dev.0** |
| `dependencies.json` comment | balancing-chemical-equations **2.1.0-dev.1** (Mon Feb 16 2026) |
| Local SHA (`dependencies.json` → `balancing-chemical-equations.sha`) | `f09cf80cafc30a9c8b00e1b990b65c3fcf2bf910` (branch `main`) |
| Local checkout | NO_GIT（zip 解压树） |
| License | GPL-3.0 |
| Repo | https://github.com/phetsims/balancing-chemical-equations.git |
| Online | https://phet.colorado.edu/sims/html/balancing-chemical-equations/latest/balancing-chemical-equations_all.html |
| Local path | `phet sourses/balancing-chemical-equations-main/balancing-chemical-equations-main` |
| Entry | `js/balancing-chemical-equations-main.ts` |
| `phetLibs` | **nitroglycerin**, **vegas** |
| Features | Sound, Dynamic Locale, Interactive Description, PhET-iO |

### Key dependency SHAs (`dependencies.json`)

| Repo | SHA |
|------|-----|
| nitroglycerin | `ca115ad1233059957fa599a7c249feef1cbfacac` |
| vegas | `6e4726b37f53b3d0fe6ea713787094c69d3beea3` |
| axon | `cafe03f85ec180e5918d69c8846f8f5973a3d4cc` |
| joist | `6e03ced39c6a0411cd67442c021e6e36a2beafae` |
| scenery / scenery-phet / sun / tambo / twixt | 见 `dependencies.json` |

### Local sibling status

| Dependency | Local availability |
|------------|-------------------|
| `nitroglycerin` | **MISSING** from `phet sourses/` — **P0 risk**（MoleculeNode / Element / Atom 全靠它） |
| `vegas` | **MISSING** from `phet sourses/` — GameTimer / LevelSelection / ScoreDisplayStars / RewardNode / GameAudioPlayer |
| `scenery-phet` | Present as `phet sourses/scenery-phet` |

---

## B. Screens

入口确认（source-truth，非截图）：

```25:29:phet sourses/balancing-chemical-equations-main/balancing-chemical-equations-main/js/balancing-chemical-equations-main.ts
  const screens = [
    new IntroScreen( Tandem.ROOT.createTandem( 'introScreen' ) ),
    new EquationsScreen( Tandem.ROOT.createTandem( 'equationsScreen' ) ),
    new GameScreen( Tandem.ROOT.createTandem( 'gameScreen' ) )
  ];
```

`package.json` `screenNameKeys` 同序：Intro → Equations → Game。

| Screen | Source Class | View Class | Model | Status |
|--------|--------------|------------|-------|--------|
| **Intro** | `IntroScreen` | `IntroScreenView` | `IntroModel` | Audited |
| **Equations** | `EquationsScreen` | `EquationsScreenView` | `EquationsModel` | Audited |
| **Game** | `GameScreen` | `GameScreenView` | `GameModel` + `GameLevel`×3 | Audited |

布局常量（全屏共用）：

```text
BCEConstants.LAYOUT_BOUNDS = Bounds2( 0, 0, 768, 504 )
```

背景色（`BCEColors`）：

| Screen | Default |
|--------|---------|
| Intro / Equations | `#d9ebff` |
| Game | `#ffffe4` |

底栏：`HorizontalBarNode` fill `#3376c4`，height `50`。

---

## C. Chemistry Model

### C.1 结构（禁止简化为字符串）

```text
Equation
├── reactants: EquationTerm[]
├── products: EquationTerm[]
├── isBalancedProperty      // Derived
├── isSimplifiedProperty    // Derived
└── hasNonZeroCoefficientProperty

EquationTerm
├── balancedCoefficient: number   // 正整数，配平答案
├── molecule: Molecule
└── coefficientProperty: NumberProperty  // 用户系数（Integer）

Molecule  (nitroglycerin-backed static instances)
├── symbol: string          // RichText，含 <sub>
├── atoms: Atom[]           // Element 序列
└── createNode() → MoleculeNode subclass

AtomCount
├── element
├── reactantsCount
└── productsCount
```

化学式（如 `N₂`、`NH₃`）**不是**裸 String 判断对象，而是：

1. `Molecule` 静态单例（`Molecule.N2`、`Molecule.NH3`…）  
2. `elements: Element[]` → `atoms: Atom[]`  
3. `symbol` 由 `elementsToSymbol` 生成 RichText  

### C.2 Balance 逻辑（核心 · source-truth）

`doc/model.md` + `Equation.ts`：

> An equation is **balanced** when the user coefficient is an integer multiple **N** of the balanced coefficient, **N is the same for all terms**, and **N ≥ 1**.  
> **Balanced and simplified** means balanced and **N = 1**.

实现：

```typescript
const multiplier = reactants[0].coefficient / reactants[0].balancedCoefficient;
every term: coefficient !== 0 && coefficient === multiplier * balancedCoefficient
```

| 例子 | isBalanced | isSimplified |
|------|------------|--------------|
| `2 H₂ + O₂ → 2 H₂O` | ✅ | ✅ |
| `4 H₂ + 2 O₂ → 4 H₂O` | ✅ (N=2) | ❌ |
| `0 H₂ + 0 O₂ → 0 H₂O` | ❌（N=0 禁止） | ❌ |
| 仅元素数相等但非同一倍数 | ❌ | ❌ |

**关键**：Game 的 Check **只奖励 `isSimplified`**，不奖励“仅 balanced”。  
视觉上的 Balance Scales / Bar Charts 用 `AtomCount` 比较左右原子数（与 `isBalanced` 算法不同；coeff=0 时 scales 两侧都是 0 会“看起来水平”，但 equation 仍 unbalanced）。

### C.3 Coefficient

| Item | Source |
|------|--------|
| Type | `NumberProperty` Integer |
| Intro range | `Range(0, 3)` |
| Equations range | `Range(0, 6)` |
| Game range | `Range(0, 7)` |
| Default initial | **1**（`BCEQueryParameters.initialCoefficient`；Preferences 可改 0 或 1） |
| Allow 0 | ✅ |
| Allow negative | ❌ |
| UI | `CoefficientPicker` ← `NumberPicker`（上下箭头；长按 delay 400ms / interval 200ms） |
| View update | Property link → Particles 显隐 / Scales tilt / Bars height / Arrow highlight |
| Animation on coeff change | **无** Tween；即时更新 |
| Sound on coeff change | 无（Game Check 才有 correct/wrong） |

系数改变时：**view 按 coefficient 绘制粒子数量**，不是改 Molecule 数据本身。

### C.4 Intro equations（固定 3 个）

| Label | Balanced form | Factory |
|-------|---------------|---------|
| Make Ammonia（默认） | `1 N₂ + 3 H₂ → 2 NH₃` | `create2Reactants1Product` |
| Separate Water | `2 H₂O → 2 H₂ + 1 O₂` | `create1Reactant2Products` |
| Combust Methane | `1 CH₄ + 2 O₂ → 1 CO₂ + 2 H₂O` | `create2Reactants2Products` |

切换：`EquationRadioButtonGroup` → `equationProperty`。  
**切换不 reset 系数**；每个 `Equation` 保留自己的 `coefficientProperty`。  
`Reset All`：`equationProperty.reset()` + 所有 equation `reset()` + viewProperties reset。

### C.5 Equations datasets（source 顺序）

**ReactionType**: `'synthesis' | 'decomposition' | 'combustion'`（默认 `synthesis`）。

每类独立 `*EquationProperty`，切换 reaction type **保留各类上次选中方程与系数**。

#### Synthesis（默认第 0 项）

| # | Balanced |
|---|----------|
| 0 | `2 C + 1 O₂ → 2 CO` |
| 1 | `2 N₂ + 5 O₂ → 2 N₂O₅` |
| 2 | `4 P + 5 O₂ → 2 P₂O₅` |
| 3 | `1 C₂H₂ + 2 H₂ → 1 C₂H₆` |

#### Decomposition

| # | Balanced |
|---|----------|
| 0 | `1 CH₃OH → 1 CO + 2 H₂` |
| 1 | `2 NO₂ → 2 NO + 1 O₂` |
| 2 | `2 PCl₃ → 2 P + 3 Cl₂` |
| 3 | `2 H₂O₂ → 2 H₂O + 1 O₂` |

#### Combustion

| # | Balanced |
|---|----------|
| 0 | `1 C₂H₄ + 3 O₂ → 2 CO₂ + 2 H₂O` |
| 1 | `1 C₂H₅OH + 3 O₂ → 2 CO₂ + 3 H₂O` |
| 2 | `2 CH₃OH + 3 O₂ → 2 CO₂ + 4 H₂O` |
| 3 | `2 C₂H₂ + 5 O₂ → 4 CO₂ + 2 H₂O` |

无 randomization（用户 ComboBox 选择）。

---

## D. Visualizations

`ViewMode = 'particles' | 'balanceScales' | 'barCharts' | 'none'`（互斥；默认 `particles`）。

### Particles

- `ParticlesNode` + 两侧 `ParticlesAccordionBox`（**AccordionBox**，非 checkbox）  
- Reactants / Products：`expandedProperty` 控制展开；标题 Reactants / Products；展开时标题隐藏（`showTitleWhenExpanded: false`）  
- 橙色减号外观 = AccordionBox expand/collapse 按钮（PhET sun）  
- Molecule：`term.molecule.createNode()`（nitroglycerin MoleculeNode），scale `0.74`  
- 布局：按 term 的 xOffset 列；行高 `(boxHeight) / coefficientsRange.max`；从底向上堆叠  
- coeff 增减：已有节点 `visible` 切换；不够则新建；**不删除**、**无入场动画**  
- 中间箭头：`RightArrowNode`；balanced 且 highlightEnabled → 黄色，否则 `#2e6bb2`

### Balance Scales

- 每种元素一把秤（纵排，`Y_OFFSET=140`，整体 scale 0.85）  
- 左右 = reactantsCount / productsCount（AtomCount）  
- 倾斜：`difference = right - left`；`NUMBER_OF_TILT_ANGLES=6`；超过则 maxAngle  
- 水平当 counts 相等；元素级 balanced 时 beam 高亮黄色（且两侧非 0）  
- 原子堆：三角形堆叠（`ATOMS_IN_PILE_BASE=5`）+ 上方数字  
- **无阻尼动画**——即时 `setRotation`

### Bar Charts

- 每种元素一行：左 reactant bar / 中 equality operator / 右 product bar  
- Bar 高度 = `numberOfAtoms * 5`；>12 显示向上箭头形态  
- 显示数字、元素符号、Atom icon；颜色 = `element.color`  
- 元素顺序 = AtomCount 从左到右首次出现顺序  

### None

- 仅 `viewModeProperty === 'none'` → 隐藏可视化；**不改 model**

---

## E. Game（摘要 · 详见 GAME_LOGIC_AUDIT.md）

| Item | Source |
|------|--------|
| Levels | 3（`GameLevel1/2/3`） |
| Challenges / game | **5**（`CHALLENGES_PER_GAME`；`?playAll` 则全池） |
| Scoring | 第 1 次正确 **2** 分；第 2 次 **1** 分；否则 **0** |
| Win check | **`isSimplified`**（非仅 isBalanced） |
| Attempts max | 2（`ATTEMPTS_RANGE`） |
| Stars | `ScoreDisplayStars`：`numberOfStars=5`，`perfectScore=10`，绑 `bestScoreProperty` |
| Timer | `vegas.GameTimer`；`timerEnabledProperty` 默认 false |
| Show Why | Level1=scales；Level2=随机 scales/barCharts；Level3=barCharts；展示原子守恒可视化 |
| Show Answer | → state `next` → `equation.balance()` 写入最简系数 |
| Feedback panels | Balanced+Simplified / Balanced+NotSimplified / NotBalanced |

Equation pools：Level1=21；Level2=11；Level3=14（含 reverse + exclusionsMap）。

---

## F. Reset Semantics

| Action | Behavior |
|--------|----------|
| **Reset All**（Intro/Equations） | model.reset + viewProperties.reset（方程选择、所有系数、ViewMode、Accordion） |
| **Reset All**（Game level selection） | GameModel.reset（含 bestScore/bestTime、timerEnabled、level→null） |
| **Start Over**（status bar） | `resetToStart` + `level=null` + `levelSelection`；**不**清 bestScore/bestTime |
| **Try Again** | state → `check`；系数保持；attempts 已+1；无加分 |
| **Show Answer** | state → `next`；随后 `balance()` |
| **Next** | 下一题或 `levelCompleted` |
| **Continue**（level complete） | `startOver()` |

禁止全部收成单一 `model.reset()`。

---

## G. Assets

见 `ASSET_MAP.md`。

- Sim 内栅格图几乎只有 `mipmaps/scales.png`（**当前 JS 未引用**；秤为程序绘制）  
- 分子 / 原子 = **nitroglycerin** 程序几何（ShadedSphere 系）  
- Icons：FontAwesome check/times（sherpa）、FaceNode、StarNode、ResetAllButton（scenery-phet）  
- **目标 Substituted = 0**；缺 nitroglycerin 源码时必须先拉取依赖再移植 MoleculeNode

---

## H. Animation

见 `ANIMATION_AUDIT.md`。

Source 几乎**无** coefficient / scale / particle Tween。  
唯一持续 `step(dt)`：完美通关 `BCERewardNode`（vegas RewardNode 粒子雨）。

---

## I. Accessibility / Keyboard

| Area | Source |
|------|--------|
| Intro/Equations keyboard help | `BCEKeyboardHelpContent`：Coefficient（slider keys）+ Choose View（combo）+ Basic Actions |
| Game keyboard help | `BCEGameKeyboardHelpContent`：Coefficient + Basic Actions |
| PDOM | Equation reactants/products headings；View ComboBox accessibleName；focus 在 feedback 按钮 |
| Features | Interactive Description、Dynamic Locale、Alternative Input（release 2.1） |
| Voicing | 无专用 voicing 模块于本 sim |

Flutter 必须保留：系数步进可用键盘语义、View 选择、Game Check/Next 焦点顺序。

---

## J. Known Risks

### P0

1. **`nitroglycerin` 本地缺失** — 全部 MoleculeNode / Element 颜色与几何；无法忠实画粒子则视觉门禁失败。  
2. **`vegas` 本地缺失** — GameTimer、Stars、LevelSelection、Reward、GameAudioPlayer；Game 屏依赖重。

### P1

1. Balance 判定是 **multiplier**，不是单纯元素计数；Game 还要求 **simplified**——易实现成“假配平”。  
2. Level3 exclusionsMap + 随机抽题 + `firstBigMolecule=false`（Level1）——必须原样迁移池逻辑。  
3. Intro Accordion（Reactants/Products）易被误认为橙色 “clear” 按钮。  
4. Show Answer / Show Why 语义不同：Why=可视化解释；Answer=写入最简系数。

### P2

1. `scales.png` 未使用，勿误当作运行时 asset。  
2. PhET-iO / Preferences `initialCoefficient` 全局联动。  
3. Equations Feedback 显示 Balanced + Simplified/NotSimplified；Intro Feedback **仅** Balanced（`isBalanced`）。

### Architecture

- 必须共享 `Equation` / `EquationTerm` / `Molecule` / `AtomCount`；三屏复用可视化。  
- Game 状态机严格：`levelSelection → check ⇄ tryAgain → showAnswer → next → levelCompleted`。

### Visual

- LAYOUT_BOUNDS 768×504；Particles box 尺寸 Intro/Equations/Game 不同。  
- View 互斥（2.0 breaking change）。

### Game logic

- Stars 映 bestScore，非“每题一星硬编码”；完美分 = challenges × 2。

---

## Intro Control Area（§10 确认）

| Control | Type | Role |
|---------|------|------|
| Reactants / Products | **AccordionBox** expand/collapse | 仅 Particles 模式下可见；展开看分子 |
| View | **ComboBox** | particles / balanceScales / barCharts / none |
| Equation radios | `EquationRadioButtonGroup` | 底栏三反应 |
| Reset All | scenery-phet `ResetAllButton` | → Flutter `KratosResetAllButton` |

---

## Typography（source）

| Role | Font |
|------|------|
| Equation / CoefficientPicker | `PhetFont(32)` |
| View label | `PhetFont(22)` bold |
| View combo icons / None text | `PhetFont(18)` |
| Accordion title | `PhetFont(18)` bold |
| Feedback text | `PhetFont(18)` |
| Game points | `PhetFont(24)` bold |
| Level select title | `PhetFont(36)` |
| Level button label | `PhetFont(14)` bold |
| Status bar | `PhetFont(14)` white |
| Scale counts | `PhetFont(18)` |
| Bar number / symbol | `PhetFont(18)` / `PhetFont(24)` |

禁止默认 Material Typography。

---

## Phase Plan Gates（后续）

| Phase | Scope | Gate |
|-------|-------|------|
| **1** | Chemistry model：Molecule / Equation / Term / AtomCount / isBalanced / isSimplified | 单元测试覆盖 model.md 全部例子；含 N=2 与 N=0 |
| **2** | Intro screen | 三方程、系数、四 View、Accordion、Reset、Feedback |
| **3** | Equations screen | ReactionType + 12 方程 ComboBox + Feedback（含 simplified） |
| **4** | Game | 状态机、池、计分、Stars、Timer、Show Why/Answer、Reward |
| **5** | Visual reconstruction | ASSET_MAP Substituted=0；三视口截图对齐 |
| **6** | Behavior acceptance | 行为矩阵 vs source |
| **7** | Regression | 模型/游戏随机种子回归 |
| **8** | Home 入口 | 分类接入，不改无关 Home |
| **9** | Final visual / release | 全屏 QA |

---

## Architecture Proposal（仅提案，Phase 0 不建代码）

见 `MODEL_ARCHITECTURE.md`。

```text
lib/balancing_chemical_equations/
  model/          # Equation, EquationTerm, Molecule, AtomCount, ViewMode
  data/           # Intro / Equations / Game pools
  game/           # GameModel, GameLevel, GameState, EquationPool*
  views/          # Particles, Scales, BarCharts, EquationNode, CoefficientPicker
  screens/        # Intro / Equations / Game
  widgets/        # Feedback, LevelSelection, StatusBar
```

---

*Phase 0 结束。等待下一阶段指令。禁止宣布 READY。*
