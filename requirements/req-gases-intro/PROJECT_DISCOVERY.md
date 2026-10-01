# PROJECT_DISCOVERY — Gases Intro

**日期**：2026-09-06  
**本地源码根**：`phet sourses/gases-intro-main/gases-intro-main`  
**证据依赖 worktree**：`phet sourses/gas-properties-for-gases-intro` @ lock SHA  
**Fallback clone**：`phet sourses/gas-properties-for-diffusion` @ `7a52c48`（仅 HTML/version 差 2 commit；Ideal 模型 [已确认] 相同）

---

## 本地版本

| 项 | 值 | 标记 |
|---|---|---|
| package.json name | `gases-intro` | [已确认] |
| package.json version | **1.2.0-dev.0** | [已确认] |
| dependencies.json comment | `# gases-intro 1.1.0-dev.3 Mon Feb 12 2024…` | [已确认] |
| gases-intro SHA (deps) | `e0a327f8fd37eb9dea6bd0badecef983bec8e838` | [已确认] lock；本地树 **无 .git**，无法核对本机 HEAD |
| **gas-properties lock SHA** | **`10c7c08d5866622426ba1969c35465c3269a70df`** | [已确认] |
| analyzed GP SHA | 同 lock（worktree） | [已确认] |
| phetLibs | `gas-properties`, `twixt` | [已确认] |
| supportsSound | true | [已确认] |
| screenNameKeys | `screen.intro`, `screen.laws` | [已确认] |

---

## Screen 数量

### **[已确认：双 Screen]**

`js/gases-intro-main.ts`：

```ts
const screens = [
  new IntroScreen( Tandem.ROOT.createTandem( 'introScreen' ) ),
  new LawsScreen( Tandem.ROOT.createTandem( 'lawsScreen' ) )
];
```

| Order | Class | 字符串名 | 模型 | 相对 Ideal 差异 |
|---|---|---|---|---|
| 0（default） | `IntroScreen` extends `IdealScreen` | Intro | `IdealModel` | **无** Hold Constant 控件 |
| 1 | `LawsScreen` extends `IdealScreen` | Laws | `IdealModel` | **有** Hold Constant 控件 |

- 两屏 **独立** model 实例（各自 `IdealScreen` → `new IdealModel`）
- Reset：各屏 Reset All；无跨屏共享粒子状态
- **禁止**迁入 Gas Properties 的 Explore / Energy / Diffusion 屏

### 启动差异（相对 Gas Properties）[已确认]

1. 若 URL **未**指定 `pressureNoise` → 强制 `pressureNoiseProperty = false`（GP 默认 true）
2. Intro：隐藏 Hold Constant；Laws：显示（= GP Ideal）

### API 命名偏斜 [待确认 / 迁移按语义]

本地 `IntroScreen`/`LawsScreen` 传入 `hasHoldConstantFeature`；lock SHA 的 `IdealScreen` 选项名为 **`hasHoldConstantControls`**。  
`implementation-notes.md` 语义明确：Intro 隐藏 Hold Constant，Laws ≡ Ideal。  
→ 迁移以 **lock GP API + doc 语义** 为准，不盲信本地 GI 选项字段名。

本地 `gases-intro-main.ts` 引用 `GasPropertiesConstants.SIM_OPTIONS`；lock SHA **无**该字段 → 本地 GI 树可能略新于 `dependencies.json`。[待确认]

---

## 仓库形态

Gases Intro 是 **薄壳**（同 Diffusion → gas-properties）：

| 本仓 | 内容 |
|---|---|
| `js/gases-intro-main.ts` | 启动 + 双屏 + pressureNoise 默认 |
| `js/intro/IntroScreen.ts` | Ideal 特化 |
| `js/laws/LawsScreen.ts` | Ideal 特化 |
| `js/gasesIntro.ts` / `GasesIntroStrings.ts` | Namespace / 字符串 |
| `doc/*` | 指向 gas-properties docs |
| `assets/*.png` | marketing / 屏截图 |

**真实模型/视图** 全部在 **gas-properties**：

- `js/ideal/` → IdealScreen / IdealModel / IdealScreenView
- `js/common/model/IdealGasLawModel.ts` 等

---

## Model 根（gas-properties @ 10c7c08）

| 类 | 路径 | 角色 |
|---|---|---|
| `IdealModel` | `js/ideal/model/IdealModel.ts` | 顶层；**仅** extends IdealGasLawModel |
| `IdealGasLawModel` | `js/common/model/IdealGasLawModel.ts` | PV=NkT 编排、HoldConstant、step |
| `IdealGasLawContainer` | …/IdealGasLawContainer.ts | 可移左墙 + 可吹开盖；Ideal：`leftWallDoesWork=false` |
| `BaseContainer` | …/BaseContainer.ts | V = width×height×depth |
| `ParticleSystem` | …/ParticleSystem.ts | Heavy/Light 库存与注入 |
| `HeavyParticle` / `LightParticle` | … | mass 28/4 AMU；radius 125/87.5 pm |
| `TemperatureModel` | … | T=(2/3)⟨KE⟩/k |
| `PressureModel` | … | P=(NkT/V)×SCALE |
| `PressureGauge` | … | 显示采样 + 可选噪声 |
| `CollisionDetector` | … | PP + walls（**非** DiffusionCollisionDetector） |
| `BaseModel` | … | play/pause/speed/MVT/stopwatch |
| `TimeTransform` | … | NORMAL 2.5 ps/s；SLOW 0.3 ps/s |

官方 `doc/model.md`：Ideal/Explore/Energy 使用 Ideal Gas Law；**Diffusion 用 simpler model** — [已确认]

### 「Piston」澄清 [已确认]

源码 **无 piston**。体积由 **可移动左墙（left wall / width handle）** 改变。  
Ideal：拖宽时 **暂停**，松手后 `redistributeParticles`；墙 **不做功**（`leftWallDoesWork=false`）。  
不得自行发明活塞动力学。

---

## 核心物理结论（Phase 0 摘要）

| 量 | 源码定义 | 标记 |
|---|---|---|
| Temperature | `T = (2/3) * averageKE / BOLTZMANN`；空容器 `null` | [已确认] |
| Pressure (model) | `P_kPa = (N*k*T/V) * 1.66E6`；空或未发生墙碰前为 0 | [已确认] |
| Pressure (display) | PressureGauge 每 0.75 ps 刷新；噪声默认 **关**（本 sim） | [已确认] |
| Volume | `width * 8750 * 4000` pm³；width∈[5000,15000]，默认 10000 | [已确认] |
| Heat/Cool | `v *= 1 + heatCoolFactor/800`，factor∈[-1,1] | [已确认] |
| Pump | BicyclePump；每下 **50** 粒子；注入角扇形 π/2；多粒子 Gaussian T | [已确认] |
| Clock | NORMAL 2.5 ps/s；Step=0.2 ps；Ideal **无 Slow UI** | [已确认] |

---

## Assets

| 来源 | 内容 |
|---|---|
| gases-intro `assets/` | 截图 PNG（已拷 `visual-qa/`） |
| gas-properties `images/` | 基本仅 `phetGirlLabCoat`；粒子为 **ShadedSphere 几何** |
| scenery-phet | BicyclePump / HeaterCooler / Gauge / Thermometer 程序绘制 |

禁止 Material Icon 冒充仪器。

---

## KARTOSLAB 上下文

| 项 | 结论 |
|---|---|
| 代码根 | 本仓库 `KartosLab`（非 `c:\workspace\kratos`；该路径不存在） |
| Home | `lib/screens/home_screen.dart`；「热学与气体」已有 Diffusion |
| Diffusion | `lib/diffusion/` — **Ideal Gas Law 路径禁止直接复制**；仅 CollisionDetector 基类算法可对照同源 GP |
| Collision Lab | **不得**复制 |
| common | NineGrid / AppBar 页面级复用；**不**建跨 sim Gas framework |
| Taxonomy | 物理 → 热学与气体 → 新增 Gases Intro（不改一级分类） |

---

## 风险 / 暂停项（本阶段）

| 项 | 状态 |
|---|---|
| 修改 common API / Theme / 一级 taxonomy | 不需要 |
| 跨 sim Gas framework | **禁止**；实现落在 `lib/gases_intro/` |
| P/T/V/Piston/Pump 定义无法确认 | **已确认**（见上；无 piston） |
| gas-properties SHA | worktree 已对齐 lock |
| 本地 GI 与 lock API 偏斜 | 记录为证据偏斜；按 lock + doc 语义迁移 |
| Ideal 无 Slow UI | 不实现 Slow 控件（模型可保留 transform） |

---

## 下一阶段

Phase 1：`SOURCE_ANALYSIS.md`（算法级）  
Phase 2：`DEPENDENCY_PROVENANCE.md`
