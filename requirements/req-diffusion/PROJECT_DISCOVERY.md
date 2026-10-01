# PROJECT_DISCOVERY — Diffusion

**日期**：2026-09-06  
**本地源码根**：`phet sourses/diffusion-main/diffusion-main`  
**证据依赖 clone**：`phet sourses/gas-properties-for-diffusion` @ lock SHA

---

## 本地版本

| 项 | 值 | 标记 |
|---|---|---|
| package.json name | `diffusion` | [已确认] |
| package.json version | **1.2.0-dev.0** | [已确认] |
| dependencies.json comment | `# diffusion 1.1.0-dev.3 Mon Feb 12 2024…` | [已确认] |
| diffusion SHA (deps) | `5ebcdc0c3cc1bed439592b50e1277817ba0723c7` | [已确认] |
| **gas-properties lock SHA** | **`7a52c48ab2892644dc8afb426b523d47d621a56d`** | [已确认] 迁移取证必须对齐 |
| phetLibs | `gas-properties`, `twixt` | [已确认] |
| supportsSound | true | [已确认] |

---

## Screen 数量

### **[已确认：单 Screen]**

`js/diffusion-main.ts`：

```ts
const screens = [
  new DiffusionScreen( Tandem.ROOT.createTandem( 'diffusionScreen' ) )
];
```

- Screen 名：Diffusion（来自 gas-properties `GasPropertiesStrings.screen.diffusion`）
- Order：唯一
- Default：该屏
- Model：`DiffusionModel`（gas-properties）
- View：`DiffusionScreenView`
- **禁止**迁入 Ideal / Explore / Energy 等其他 Gas Properties 屏

---

## 仓库形态

Diffusion 仓库是 **薄壳**（同 Waves Intro → WI）：

| 本仓 | 内容 |
|---|---|
| `js/diffusion-main.ts` | 启动 + 单屏 |
| `js/diffusion.ts` | Namespace |
| `js/DiffusionStrings.ts` | 字符串 |
| `doc/*` | 指向 gas-properties docs |
| `assets/*.png` | 截图 |

**真实模型/视图** 全部在 **gas-properties** `js/diffusion/` + shared `js/common/`（非 IdealGasLaw 路径）。

---

## Model 根（gas-properties @ 7a52c48）

| 类 | 路径 | 角色 |
|---|---|---|
| `DiffusionModel` | `js/diffusion/model/DiffusionModel.ts` | 顶层；extends **BaseModel**（非 IdealGasLaw） |
| `DiffusionContainer` | …/DiffusionContainer.ts | 固定宽 + 可拆 divider |
| `DiffusionSettings` | …/DiffusionSettings.ts | 左/右：N、mass、radius、T₀ |
| `DiffusionParticle1/2` | … | 两种粒子（cyan / red） |
| `DiffusionCollisionDetector` | … | extends common `CollisionDetector` + divider |
| `DiffusionData` | … | 左右 N₁/N₂/⟨T⟩ |
| `ParticleFlowRate` | … | 流量矢量模型 |
| `BaseModel` | `js/common/model/BaseModel.ts` | play/pause/speed/MVT/stopwatch |
| `CollisionDetector` | `js/common/model/CollisionDetector.ts` | PP + wall；**非** Collision Lab |
| `TimeTransform` | … | NORMAL 2.5 ps/s；SLOW 0.3 ps/s |

官方 `doc/model.md`：**Diffusion 使用 simpler model，不涉及 Ideal Gas Law** — [已确认]

---

## Assets

| 来源 | 内容 |
|---|---|
| diffusion `assets/` | marketing 截图 PNG |
| gas-properties | 粒子多为 Canvas 几何着色（`ParticlesNode` / Sprite）；无单独 heavy/light PNG 必需 |
| 截图 reference | 已拷 `visual-qa/reference_default.png` |

---

## KARTOSLAB 上下文

| 项 | 结论 |
|---|---|
| Home | `lib/screens/home_screen.dart`；尚无 Diffusion |
| Collision Lab | `lib/collision_lab/solver/collision_engine.dart` — **不得直接复制**；GP CollisionDetector 是独立语义 |
| common | `NineGridLayout`、`simulation_clock` 可页面级复用；**不**建跨 sim physics framework |
| Taxonomy | 物理下新增子组「热学与气体」承载 Diffusion（不改一级 物理/化学） |

---

## 风险 / 暂停项（本阶段）

| 项 | 状态 |
|---|---|
| 修改 common API | 不需要 |
| 修改一级 Home taxonomy | 不需要 |
| 引入跨 sim Collision framework | **禁止**；sim-local 实现 GP 算法 |
| gas-properties 源码本地缺失 | **已解决**：clone @ lock SHA |
| Ideal Gas Law 误迁 | **禁止** |

---

## 下一阶段

Phase 1：完整 SOURCE_ANALYSIS + DIFFUSION_PHYSICS_VALIDATION（算法级）。
