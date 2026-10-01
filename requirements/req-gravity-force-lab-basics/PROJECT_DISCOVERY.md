# PROJECT_DISCOVERY — Gravity Force Lab: Basics

## 本地版本 [已确认]

| 字段 | 值 |
|---|---|
| package.json version | **`1.2.0-dev.0`** |
| dependencies.json comment | `1.1.0-dev.41 Tue Aug 24 2021` |
| local sha | `244ba556b1b781a86ad34a58a1c0ab5eb4434b8a` |
| 本地路径 | `phet sourses/gravity-force-lab-basics-main/gravity-force-lab-basics-main` |
| 策略 | **不以官网 latest 替换本地 basics** |

## Screen [已确认：单 Screen]

| 项 | 值 | 证据 |
|---|---|---|
| count | **1** | `gravity-force-lab-basics-main.js`：`[ new Screen(...) ]` |
| title | Gravity Force Lab: Basics | strings |
| Model | `GFLBModel` | |
| View | `GFLBScreenView` | layoutBounds **768×464** |
| Background | `#ffffc2` | GFLBConstants |

## 依赖库

| Lib | 本地？ | 用法 |
|---|---|---|
| inverse-square-law-common | **无本地克隆** | ISLCModel / ISLCObject / ForceArrow / Puller |
| gravity-force-lab | **无本地克隆** | Mass.calculateRadius |
| 算法来源 | GitHub raw（与 doc 一致）| 记录在 SOURCE_ANALYSIS；不阻塞 |

## 默认状态摘要 [已确认]

| 项 | 值 |
|---|---|
| m1 / m2 | 2e9 / 4e9 kg |
| x1 / x2 | −2000 / +2000 m（中心距 4000 m = 4 km） |
| Constant Size | **false** |
| Distance visible | **true** |
| Force Values | **true** |
| Density | 1.5 kg/m³ |
| Constant radius | calculateRadius(1e9, 1.5) |
| G | 6.67430e-11 |
| 默认 F | ≈ 33.37 N → 显示 33.4 N |

## KARTOSLAB

| 项 | 决策 |
|---|---|
| 代码落点 | `lib/gravity_force_lab_basics/` |
| Home | 物理 → 力学 |
| 不迁移 | 完整版 `gravity-force-lab` |

## 暂停检查

无需暂停：引力公式、单位、Constant Size、箭头缩放均已从源码确认。
