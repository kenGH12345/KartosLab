# DEPENDENCY_PROVENANCE — Waves Intro

**审计日期**：2026-09-05  
**本地 sim**：`phet sourses/waves-intro-main/waves-intro-main`  
**原则**：不因官网 / GitHub main 更新而替换本地源码；`dependencies.json` 为 lock 证据；不自行 checkout 覆盖迁移树。

---

## 1. waves-intro 本体

| 项 | 值 | 标记 |
|---|---|---|
| `package.json` version | **`1.2.0-dev.0`** | [已确认] |
| `dependencies.json` comment | `# waves-intro 1.1.0-dev.25 Tue Nov 03 2020` | [已确认] |
| `dependencies.json` → `waves-intro.sha` | `f962e2ea7e1730b804c5e28486949927d078d90f` | [已确认] |
| 本地 `.git` | **无**（zip 展开树） | [已确认] |
| 本地 analyzed SHA | 无法 `git rev-parse` | [待确认：无本地 commit] |
| migration-used | 本地树文件（`waves-intro-main.ts` 等） | [已确认] |

**判定**：package **1.2.0-dev.0** 与 lock 注释 **1.1.0-dev.25** 不同步 → **[已确认：lock 过时]**。入口仍为 3×`MediumScreen`，与当前 `js/waves-intro-main.ts` 一致。

---

## 2. 依赖对照表

| Dependency | dependencies.json SHA | local analyzed SHA | migration-used SHA / 来源 | status |
|---|---|---|---|---|
| **wave-interference** | `31ebfd71800f065c2da3bc8d402cb65eafe65932` | clone HEAD `5443da094116592a549b45eb362a90600a87e4f5` | 迁移常量/Scene 逻辑取自 **`5443da0`** 读源 | **mismatch** · 见 §3 |
| **scenery-phet** | `0b6b199d3f618467633b788db04c8fcf20aa4170` | 本地 clone `6035eb49939c9a703b074e4b66b3422a96d18b06` | Lattice 移植自本地 **`6035eb4:js/Lattice.ts`** | **mismatch** · 见 §4 |
| tambo | `21ccfaf503af6fc0f67cc7dc79200fbb4b508607` | **无本地 clone** | 未迁音效 | [待确认] 仅 lock |
| twixt | `e7aa3c2fcc624d1ca40180e8c088e69a7ddd13b8` | 无 | 未直接移植 | [已确认] lock only |
| griddle | `9bcdd895300e65e45520904a30258bd00c977ee6` | 无 | 未直接移植 | [已确认] lock only |
| bamboo | *不在 dependencies.json* | — | `package.json` phetLibs 含 bamboo | **[已确认：lock 缺条目]** |
| axon / joist / scenery / sun / … | 见 `dependencies.json` | 无独立分析 clone | 未逐仓迁移 | [已确认] lock only |

---

## 3. wave-interference mismatch 判定

| 对比 | 结果 |
|---|---|
| Lock `31ebfd7`（2020 JS） vs 分析 `5443da0`（2026 TS） | **SHA 不同** |
| `EVENT_RATE` / `initialAmplitude:8` / water·sound·light `waveSpeed`·`timeScaleFactor`·`waveAreaWidth`·`frequencyRange` | **一致**（抽样对照 WavesModel） |
| 点源：`-sin(ωt+φ)·A·1.2` | **一致** |
| Lattice **位置** | Lock：**WI 内** `js/common/model/Lattice.js`；现代：移至 scenery-phet |
| Lattice **公式** `c=0.5`，`value = 2m1 − m2 + c²·∇²`，吸收边 | Lock Lattice.js 与现代 Lattice.ts **一致** |

### 分类结论（Wave Model 核心）

**A. 只是分析 clone 版本不同，但最终代码已按正确 dependency 语义取证（核心 FDTD / λ / 点源）**

- 标记：**[已确认] A（核心波）**
- **不修改**已验证的 FDTD / lattice / `c=0.5` / `λ=v/f` / continuous / pulse 实现。
- **不**自行把 clone 换成 `31ebfd7` 覆盖工作树。

### 分类结论（P0+ 功能取证）

WaterDrop / 工具等后续取证：**优先以 lock SHA `31ebfd7` 文件为准**（`WaterScene.js` / `WaterDrop.js` / `WaveMeterNode.js` 等）。

- 若与 `5443da0` 行为分歧 → 以 **`31ebfd7`** 为 Waves Intro lock 事实来源。
- 标记：**[迁移风险：P0+ 须用 lock SHA 再取证]**（非“已用错误 FDTD”）

---

## 4. scenery-phet / Lattice 判定

| 项 | 结果 |
|---|---|
| Lock `0b6b199` 树内是否存在 `Lattice` | **否**（该 SHA 无 Lattice 文件） |
| Lock 时代 Lattice 归属 | **[已确认]** `wave-interference@31ebfd7` → `js/common/model/Lattice.js` |
| 迁移读的 `scenery-phet@6035eb4` Lattice.ts | 公式与 lock WI Lattice.js **同构** |

### 分类

**A（FDTD）**：表面 SHA mismatch，但算法证据链 = lock WI Lattice.js ≡ 已移植 Dart。

**非 B**：没有证据表明 Flutter 使用了另一套 `c` 或另一套步进式。

---

## 5. migration-used 摘要（代码注释与常量）

| 模块 | 实际依据 |
|---|---|
| `lib/waves_intro/model/lattice.dart` | scenery-phet Lattice.ts（≡ WI Lattice.js@31ebfd7） |
| `waves_intro_constants.dart` | WI WavesModel / Constants（5443da0 读源，与 31ebfd7 抽样一致） |
| `wave_scene.dart` 点源/脉冲 | Scene（5443da0 ≡ 31ebfd7 核心式） |
| WaterDrop 水龙头 | **尚未按 WaterScene 实现** → gap，非错误 FDTD |

---

## 6. 总判定（是否改 Wave Model）

| 问题 | 答案 |
|---|---|
| 是否因 mismatch 改 FDTD / λ / pulse / continuous？ | **否** |
| mismatch 性质 | **分析 clone 新于 lock；核心波语义对齐 lock** → **A** |
| 无法确认项 | waves-intro 本地无 git SHA；bamboo 缺 lock；tambo 未克隆 |
| 总体 | **[已确认] 核心波 A** · **[迁移风险] P0+ 应用 31ebfd7 取证** · 非 **B（错误 FDTD）** |

---

## 7. 后续 Functional Gap Closure 证据优先级

1. **waves-intro 本地**（屏入口）  
2. **`wave-interference@31ebfd71800f065c2da3bc8d402cb65eafe65932`**（lock）  
3. `5443da0` 仅作对照  
4. scenery-phet：工具类（MeasuringTape/Stopwatch）按 lock 引用路径再核 SHA  

**禁止**为对齐 SHA 自动 `git checkout` 替换依赖目录。
