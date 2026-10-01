# DEPENDENCY_PROVENANCE — Gases Intro

| Dependency | Lock SHA (`dependencies.json`) | Analyzed SHA | Migration SHA | Status |
|---|---|---|---|---|
| **gas-properties** | `10c7c08d5866622426ba1969c35465c3269a70df` | worktree `gas-properties-for-gases-intro` 同左 | 同左 | **A** — Ideal/IdealGasLaw 全部取证自此 |
| gases-intro (self) | `e0a327f8fd37eb9dea6bd0badecef983bec8e838` | 本地 1.2.0-dev.0 树（无 .git） | 启动壳 + 双屏特化 | 薄壳；选项字段名见下 |
| scenery-phet | `b491faff4bed411f7a1576961e47245f593f96cb` | 未单独 checkout | BicyclePump / HeaterCooler / Gauge / Thermometer 几何参考 | 不强制锁 UI 像素 |
| twixt | `0f3b8ac8e973c12bd9b9ce30e1e583bb1bf4cd84` | — | 动画（泵/加热器） | 按需近似 |
| axon / dot | lock 内 | Property / Random / LinearFunction 模式 | Dart 等价 | — |
| tambo | lock 内 | 本轮未迁音频 | [待实现] 音效 | — |
| phet-core / joist / sun / scenery | lock 内 | 框架 | 不迁 | — |

## SHA 比对（gas-properties）

| Clone | SHA | vs lock |
|---|---|---|
| `gas-properties-for-diffusion`（Diffusion 用） | `7a52c48a…` | lock **领先** 2 commit |
| Diff `7a52c48..10c7c08` | `09173b44` version bump + `10c7c08` HTML bump | **仅** `package.json` + `gas-properties_en.html` |
| Ideal 模型文件 | 无 diff | [已确认] 语义一致 |

→ 允许用 Diffusion 同目录源码作对照，但 **迁移权威** 为 lock worktree。

## 不使用

- Collision Lab 源码 / Flutter `collision_lab`
- Diffusion Flutter 模型（不同顶层：`DiffusionModel` ≠ `IdealGasLawModel`）
- Gas Properties Explore / Energy 屏专属行为（`leftWallDoesWork=true`、初始 T 控件、直方图等）
- 官网 latest / GitHub main HEAD（除非 SHA 相同）

## 本地 gases-intro vs lock 偏斜

| 现象 | 处理 |
|---|---|
| `hasHoldConstantFeature` vs `hasHoldConstantControls` | 按 lock IdealScreen + `implementation-notes.md` 语义 |
| 引用 `GasPropertiesConstants.SIM_OPTIONS`（lock 无） | 忽略；用 Joist/Sim 默认等价即可 |
| package 1.2.0-dev.0 vs deps comment 1.1.0-dev.3 | 记录；物理以 GP lock 为准 |

**判定**：核心物理/Ideal 取证 **A**（lock 对齐）。
