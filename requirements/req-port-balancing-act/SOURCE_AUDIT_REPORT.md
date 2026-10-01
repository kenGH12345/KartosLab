# Balancing Act — Phase 0 Source Audit Report

> **req-id**: `req-port-balancing-act`  
> **Audit date**: 2026-09-23  
> **Auditor**: KartosLab Flutter migration agent  
> **Priority order**: Local PhET source → original assets → user screenshots → online sim → speculation  
> **Gate**: Phase 0 — **PASS**（完整审计完成；未写 Flutter UI；未改 Home）

---

## 1. Version

| Field | Value |
|-------|-------|
| Package name | `balancing-act` |
| `package.json` version | **1.4.0-dev.2** |
| `dependencies.json` comment | balancing-act 1.4.0-dev.2 Sun Aug 03 2025 |
| Local tree SHA (`dependencies.json` → `balancing-act.sha`) | `b468e7d73dafcd093839b28a792b49ff090329bf` |
| License | GPL-3.0 |
| Repo | https://github.com/phetsims/balancing-act.git |
| Online sim | https://phet.colorado.edu/sims/html/balancing-act/latest/balancing-act_all.html |
| Local path | `phet sourses/balancing-act-main/balancing-act-main` |
| Entry | `js/balancing-act-main.ts` |
| Screens | **3**：Intro → Balance Lab → Game（phet-io 下 Game 被剔除 → 2） |

### Key dependency SHAs (`dependencies.json`)

| Repo | SHA | Role |
|------|-----|------|
| axon | `b5fafbb935011645259e381f2558328f351885df` | Properties / stepTimer |
| joist | `80c46204f0d12a2049bcff9a5fb31ed9be4a7e8f` | Sim / Screen / ScreenView |
| scenery | `d98a2072c73d1160fc8b571dcf37fbe1381630ed` | Node tree / DragListener |
| scenery-phet | `747d8a7e2c1805d419cc13fbd572d1bc1684e9a4` | ResetAllButton, OutsideBackgroundNode, RulerNode, … |
| sun | `0fbc99271370918f672a1f47586c037755e629fd` | Panel, Checkbox, Radio, Carousel, ABSwitch |
| vegas | `6646e11d684ed727b9b2e5ae80fbb7351c596143` | Game framework + GameAudioPlayer |
| twixt | `8e7b76db00f358dffc7fa90e05c753f7a5a8f09c` | Declared; **js/ 未直接 import** |
| tambo | `3c70d073671562f6e083a62c0066bd3abc6c025e` | soundManager（UI category level=0） |
| phetcommon | `e111988335c8c99d523735b5a58a9933a6fb4f37` | ModelViewTransform2 |
| dot / kite | (in deps) | Vector2 / Shape |

---

## 2. Screens

**Confirmed exclusively from source** — `js/balancing-act-main.ts` L23–28:

```typescript
const sim = new Sim( balancingActTitleStringProperty, [
  new BAIntroScreen( tandem.createTandem( 'introScreen' ) ),
  new BalanceLabScreen( tandem.createTandem( 'balanceLabScreen' ) ),
  ...( Tandem.PHET_IO_ENABLED ? [] : [ new BalanceGameScreen( tandem.createTandem( 'gameScreen' ) ) ] )
], { ... } );
```

`package.json` `screenNameKeys`：`intro` / `balanceLab` / `game`  
英文标签（`balancing-act-strings_en.json`）：**Intro** / **Balance Lab** / **Game**

| # | Screen | Source Class | Model | View | Purpose |
|---|--------|--------------|-------|------|---------|
| 1 | **Intro**（默认） | `BAIntroScreen` | `BAIntroModel` → `BalanceModel` | `BAIntroView` → `BasicBalanceScreenView` | 固定 2×灭火器(5kg)+垃圾桶(10kg)；拖放到 plank |
| 2 | **Balance Lab** | `BalanceLabScreen` | `BalanceLabModel` → `BalanceModel` | `BalanceLabScreenView` | Carousel 创建砖块/人物/神秘物；放不上回 toolbox 动画 |
| 3 | **Game** | `BalanceGameScreen` | `BalanceGameModel`（独立，不继承 BalanceModel） | `BalanceGameView` | 4 关 × 6 题；Balance Me / Mass Deduction / Tilt Prediction |

**默认进入**：数组第一项 → Intro。

---

## 3. Project structure

```
balancing-act-main/
├── js/
│   ├── balancing-act-main.ts          # entry
│   ├── balancingAct.ts / BalancingActImages.ts / BalancingActStrings.ts
│   ├── intro/                         # BAIntroScreen + model + view
│   ├── balancelab/                    # BalanceLabScreen + creators + MassCarousel consumers
│   ├── game/                          # BalanceGameScreen + challenges + StartGameLevelNode
│   └── common/
│       ├── BASharedConstants.ts
│       ├── model/                     # BalanceModel, Plank, Mass, Fulcrum, …
│       │   └── masses/                # 全部具体质量类
│       └── view/                      # BasicBalanceScreenView, PlankNode, …
├── images/                            # SVG/PNG 原版 assets（objects + 区域人物）
├── mipmaps/                           # 仅 license.json（无图像）
├── assets/                            # 设计源 .ai + 截图 + 支柱图标 SVG（运行时未 import 支柱 SVG）
├── dependencies.json / package.json
└── balancing-act-strings_en.json
```

**无** `*_tests.ts` / `tests/` 目录。

---

## 4. Layout / Viewport / MVT

| Constant | Value | Source |
|----------|-------|--------|
| `LAYOUT_BOUNDS` | **768 × 504** | `BASharedConstants.ts` L17 |
| Intro/Lab MVT | `createSinglePointScaleInvertedYMapping( ZERO, (width×0.375, height×0.79), **105** )` | `BasicBalanceScreenView.ts` L107–111 |
| Game MVT | 同 API，offset `(width×0.45, height×0.86)`, scale **115** | `BalanceGameView.ts` L101–104 |
| Model origin | 地面、支点正下方中心 `(0,0)`；Y 向上（model）→ view 倒置 | 注释 + MVT |
| Reset All scale | `0.96` | `BASharedConstants.RESET_ALL_BUTTON_SCALE` |

Joist `ScreenView` + `layoutBounds` → **固定设计视口 + 等比缩放适配**（FittedNode 语义由 joist 提供）。

---

## 5. Model summary

详见 `MODEL_ARCHITECTURE.md` / `PHYSICS_AUDIT.md`。

核心实体：
- **Fulcrum**（固定 A-frame，不可拖动）
- **Plank**（4.5 m × 0.05 m，75 kg；绕 pivot 旋转）
- **LevelSupportColumn** ×2（±1.625 m；DOUBLE_COLUMNS 时锁水平）
- **Mass** 层级（ImageMass / BrickStack / MysteryMass / HumanMass）
- **ColumnState**：`DOUBLE_COLUMNS` | `SINGLE_COLUMN` | `NO_COLUMNS`

---

## 6. Physics summary（关键反直觉点）

| Topic | Source truth |
|-------|--------------|
| 显示重力 | `MassForceVector`: \(F_y = m \times (-9.8)\) — **仅用于力矢量显示** |
| 动力学力矩 | **不含 g**：`τ_masses = Σ(pivotX − x_i·m_i)`；plank 自矩 `(pivotX−bottomCenterX)×75` |
| 平衡判定 | `isBalanced`: `\|Σ m·d_surface\| < 1e-6`（`COMPARISON_TOLERANCE`） |
| 角速度积分 | `ω += α`（**无 ×dt**）；`θ += ω·dt`；每步 `ω *= 0.91` |
| 吸附 | **离散** snap，间距 **0.25 m**，17 槽去掉中心 → 最多 16 可用位 |

---

## 7. Interaction / Controls summary

详见 `INTERACTION_AUDIT.md`。

- 拖拽：`MassDragHandler`（`DragListener`）→ 松手后各 Screen 决定落点
- Intro/Lab：`ColumnOnOffController`（`ABSwitch`）DOUBLE ↔ NO
- Show：Mass Labels / Forces / Level（checkboxes）
- Position：None / Rulers / Marks（radio）
- Lab：`MassCarousel`（Bricks / People / Mystery）
- Reset：`scenery-phet/ResetAllButton`
- Game：选关、Check/Next/TryAgain/ShowAnswer、TimerToggle、Vegas 计分

---

## 8. Assets / Audio / Animation / Tests

| Domain | Report | Verdict |
|--------|--------|---------|
| Assets | `ASSET_MAP.md` | 运行时 images 齐全；mipmaps 空；支柱图标为程序绘制（assets SVG 未用） |
| Audio | `AUDIO_AUDIT.md` | 无本地音效文件；Game 用 vegas GameAudioPlayer；UI sound level=0 |
| Animation | `ANIMATION_AUDIT.md` | Plank 物理旋转 + Mass 回 toolbox 线性动画；twixt 未直接使用 |
| Tests | `SOURCE_TEST_AUDIT.md` | **0 tests** in checkout |

---

## 9. Source Truth Matrix

| Domain | Source Truth | Evidence |
|--------|--------------|----------|
| Screen | 3 screens; default Intro | `balancing-act-main.ts` |
| Model | BalanceModel + BalanceGameModel | `common/model/`, `game/model/` |
| Physics | Plank.step / torque / damping | `Plank.ts` |
| Balance | `isBalanced` + COMPARISON_TOLERANCE 1e-6 | `Plank.ts`, `BASharedConstants.ts` |
| Mass | 具体 kg 见 PHYSICS_AUDIT 表 | `common/model/masses/*` |
| Drag | MassDragHandler + Plank.addMassToSurface | `MassDragHandler.ts`, `Plank.ts` |
| Pivot | 固定 Fulcrum；用户不可拖 | `Fulcrum.ts`, `BalanceModel.ts` |
| Reset | ResetAllButton → view.reset → model.reset | `BasicBalanceScreenView.ts` |
| Animation | Plank 动力学 + Mass.initiateAnimation | `Plank.ts`, `Mass.ts` |
| Audio | vegas GameAudioPlayer；无本地 mp3 | `BalanceGameView.ts`, entry L40 |
| Assets | images/ SVG/PNG | `images/` |
| Layout | 768×504 | `BASharedConstants.ts` |
| MVT | scale 105 (Intro/Lab) / 115 (Game) | BasicBalance / BalanceGameView |

---

## 10. P0 / P1 / P2

### P0（阻断）— **0**
无。核心 model/physics/screens/assets 均可从本地源码完整解析。

### P1（影响迁移）— **2**
1. **Game 强依赖 vegas**：选关、计分、Face、GameAudioPlayer、LevelCompletedNode — Flutter 需自建对等层。
2. **源码无测试**：物理积分 quirks（ω 无 dt、力矩无 g、运算符优先级）必须靠手工对照源码写 Flutter 测试，无 PhET 单元测试可移植。

### P2（非阻断）— **4**
1. `twixt` 声明但未直接使用 — 可忽略。
2. `mipmaps/` 空 — 无影响。
3. 区域人物 SVG（africa/asia/…）— 需区域策略，MVP 可用默认区。
4. GameAudioPlayer 音资源在 vegas/tambo — 需后续 vendor 或静默降级。

### OPEN QUESTIONS
1. `getTorqueDueToMasses` 运算符优先级写法是否为有意设计（`pivotX - x*m` vs `(pivotX-x)*m`）— **以源码字面为准复刻**，不“修正”。
2. `ω += α` 无 dt — 帧率敏感；Flutter 需决定是否严格复刻或固定步长对齐观感（记为实现决策，非 Phase 0 阻塞）。

---

## 11. Phase 0 Gate

```
PHASE 0 STATUS: PASS

核心 Model: 已理解
核心 Physics: 已理解
所有 Screen: 已识别（3）
主要 Interaction: 已识别
Reset: 已识别
Animation: 已识别
Assets: 已 mapping
Dependencies: 已 mapping
Source tests: 已审计（0）
截图: 已 cross-reference
P0: 0

Flutter UI: NOT STARTED
Home: NOT TOUCHED
```

**禁止进入 Phase 1，直到用户明确下达下一阶段指令。**
