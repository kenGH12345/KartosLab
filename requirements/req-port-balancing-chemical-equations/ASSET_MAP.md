# ASSET_MAP — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **目标**: Substituted = **0**  
> **日期**: 2026-09-23

## 使用优先级

```text
原 PhET Asset → 原 SVG/PNG/Mipmap → 原 Scenery geometry → Flutter Canvas 等价重建 → 最后才自行绘制
```

---

## 1. Sim 内栅格 / Mipmap

| Source Asset | Purpose | Used in runtime JS? | Flutter Target | Reuse | Notes |
|--------------|---------|---------------------|----------------|-------|-------|
| `mipmaps/scales.png` (+ `scales_png.ts`) | 历史秤图（300×163 等 mip levels） | **NO** — 无 import | （保留于 assets，不冒充运行时） | N/A | Balance Scales 为 `BalanceScaleNode` 程序绘制；**禁止**用此 PNG 当交互秤 |
| `assets/balancing-chemical-equations-screenshot*.png` | 文档 / 商店截图 | NO | QA 参考 only | YES (ref) | 非运行时 |

---

## 2. 程序几何（必须 Canvas / CustomPainter 等价，非 Material Icon）

| Source | Purpose | Flutter Target | Reuse |
|--------|---------|----------------|-------|
| `nitroglycerin/js/nodes/*Node.js`（CNode, H2Node, NH3Node, O2Node…） | 分子 3D 球棍布局 | `MoleculePainter` / per-molecule painters | **YES** — 几何/比例从 nitroglycerin 源复制 |
| `nitroglycerin/js/Element.js` | 元素符号与颜色 | `Element` data class | YES |
| `nitroglycerin/js/nodes/AtomNode.js` + `ShadedSphereNode` | 原子球 | `AtomSpherePainter` | YES |
| `BalanceFulcrumNode` / `BalanceBeamNode` | 秤座 / 横梁 | CustomPainter | YES |
| `BarNode` Shape | 柱状图矩形 / 超限箭头 | CustomPainter | YES |
| `RightArrowNode` ← `ArrowNode` | 反应箭头 | CustomPainter | YES |
| `ViewComboBox` icons | Particles/Scales/Charts 图标 | 与 source 同构绘制 | YES |
| Screen icons（Intro/Equations/Game） | Home 屏图标 | 同构绘制 | YES |

### Molecule 静态表（`Molecule.ts`）— Flutter 必须全集

`C, Cl2, C2H2, C2H4, C2H5Cl, C2H5OH, C2H6, CH2O, CH3OH, CH4, CO, CO2, CS2, F2, H2, H2O, H2O2, H2S, HF, HCl, N2, N2O, N2O5, NH3, NO, NO2, O2, OF2, P, P4, P2O5, PH3, PCl3, PCl5, PF3, S, SO2, SO3`

---

## 3. 共享 UI 组件（L0 / scenery-phet / vegas）

| Source | Purpose | Flutter Target | Reuse |
|--------|---------|----------------|-------|
| `scenery-phet/ResetAllButton` | Reset All | **`KratosResetAllButton`** | YES (L0) |
| `scenery-phet/FaceNode` | 笑/哭脸反馈 | Face painter（对齐 FACE_NODE_OPTIONS） | YES |
| `scenery-phet/StarNode` | Reward L3 | Star painter | YES |
| `scenery-phet/TimerToggleButton` | Timer on/off | 对齐 PhET TimerToggle（非 Material alarm） | YES |
| `vegas/ScoreDisplayStars` | Level 按钮星级 | Stars score display | YES |
| `vegas/LevelSelectionButtonGroup` | Level 1–3 按钮 | Level selection UI | YES |
| `vegas/RewardNode` | 通关粒子雨 | Reward animation | YES |
| `vegas/GameAudioPlayer` | correct/wrong/gameOver | Sound assets from tambo/vegas 惯例 | YES |
| `sun/AccordionBox` | Reactants/Products | Accordion（展开按钮外观对齐） | YES |
| `sun/NumberPicker` / `CoefficientPicker` | 系数步进 | Coefficient stepper | YES |
| `sun/ComboBox` | View / Equation 选择 | ComboBox | YES |
| `sherpa/fontawesome-5/checkSolidShape` | ✓ | Path 复刻（非 Icons.check） | YES |
| `sherpa/fontawesome-5/timesSolidShape` | ✗ | Path 复刻（非 Icons.close） | YES |

---

## 4. 颜色常量（`BCEColors` / 硬编码）

| Token | Value | Use |
|-------|-------|-----|
| Intro/Equations bg | `#d9ebff` | Screen background |
| Game bg | `#ffffe4` | Screen background |
| Bottom bar | `#3376c4` | HorizontalBarNode |
| BOX_COLOR | `white` | Particle boxes |
| UNBALANCED_COLOR | `rgb(46,107,178)` | Arrow / unbalanced |
| BALANCED_HIGHLIGHT_COLOR | `yellow` | Arrow / beam highlight |
| CHECK_MARK_FILL | `rgb(0,180,0)` | Balanced check |
| Feedback panel fill | `#c1d8fe` | GameFeedbackPanel |
| Level button base | `#d9ebff` | LevelSelection |
| Check/Next button | `yellow` | Game push buttons |
| Why button | `#d9d9d9` | Show Why toggle |
| Status bar | `rgb(49,117,202)` | BCEFiniteStatusBar |
| ATOM_STROKE | black, lineWidth 0.5 | Atoms |

元素颜色来自 **nitroglycerin `Element`**，禁止自拟色板。

---

## 5. Layout / Scale 常量

| Constant | Value | Where |
|----------|-------|-------|
| LAYOUT_BOUNDS | 768 × 504 | All screens |
| PARTICLES_SCALE_FACTOR | 0.74 | Molecules & atoms |
| Intro BOX_SIZE | 285 × 145 | ParticlesAccordionBox |
| Equations BOX_SIZE | 285 × 260 | ParticlesAccordionBox |
| Game BOX_SIZE | 285 × 340 | ParticlesAccordionBox |
| Intro/Eq BOX_X_SPACING | 110 | HorizontalAligner |
| Game BOX_X_SPACING | 140 | HorizontalAligner |
| Arrow length | 70 | RightArrowNode |
| Balance scales node scale | 0.85 | BalanceScalesNode |
| Show Why viz scale | 0.65 | NotBalancedPanel |
| ResetAllButton scale (Intro) | 0.8 | IntroScreenView |

---

## 6. Substituted Assets 追踪

| ID | Asset | Status | Justification |
|----|-------|--------|---------------|
| — | — | **Substituted = 0** | 尚未实现 Flutter；Phase 0 无替代 |

### Blockers for Substituted=0 at implement time

1. 本地缺少 `nitroglycerin` 仓库 → 必须 clone `dependencies.json` SHA 后再移植 MoleculeNode。  
2. 禁止用 `Icons.refresh` / Material chemistry icons 冒充 Reset / 分子。  
3. `scales.png` 不得当作运行时秤贴图（source 未用）。

---

## 7. Flutter 建议资源目录

```text
assets/simulations/balancing_chemical_equations/
  # 仅当确有可复用 PNG；当前 sim 几乎无运行时图
  # 分子几何 → 代码 painters，不放假图
```

依赖包建议镜像：

```text
docs/... 或 vendor notes:
  nitroglycerin@ca115ad1...
  vegas@6e4726b3...
```
