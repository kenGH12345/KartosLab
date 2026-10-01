# PROJECT_DISCOVERY · Build a Molecule

> req: `req-build-a-molecule`  
> 日期: 2026-09-04  
> 标记约定: `[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论摘要

1. **[已确认]** 本地版本 `1.1.0-dev.2`（`package.json` + `build-a-molecule_en.html` + `dependencies.json`）。本地 SHA：`9f605a7f540bcc145e56bedc285344362acb9bee`。**不以官网 latest 替换**。
2. **[已确认]** **3 个 Screen**，顺序：`Single` → `Multiple` → `Playground`（`js/build-a-molecule-main.ts`）。默认首屏 Single。
3. **[已确认]** **无独立 Game Screen**。`vegas` 仅用于 `CollectionBox` 满箱时 `GameAudioPlayer.correctAnswer()`。
4. **[已确认]** 合法结构来自预生成数据集：`structuresData`（允许子图）+ `collectionMoleculesData` + `otherMoleculesData`（CompleteMolecule）。**禁止**用“价态合法即合法”替代。
5. **[已确认]** 键合时 `Kit.canBond` → `MoleculeList.isAllowedStructure`（structures 子图匹配），不是开放化学引擎。
6. **[已确认]** 分子识别：`MoleculeStructure.isEquivalent`（元素直方图 + 图同构），**不是** `formula == "H2O"`。
7. **[已确认]** Collection：`CollectionBox(moleculeType, capacity)` + `willAllowMoleculeDrop` 用 `isEquivalent`。Next Collection：`BAMModel.generateKitCollection`（`dotRandom`）。
8. **[已确认]** 3D：Dialog 用 `mobius/ThreeNode` + `three-r104`（WebGL）；另有 `Molecule3DNode` **Canvas 2D 投影**。KartosLab **无** flutter_gl / WebGL 依赖。
9. **[已确认]** Flutter 侧尚无 `lib/chemistry/build_a_molecule/`；化学仅有 molarity / build_a_nucleus。
10. **[待确认→可自动推进]** 3D 策略：默认采用 **Canvas 2.5D 投影**（移植 Molecule3DNode / PubChem xyz），**不**引入全局 3D framework → **不触发暂停**。WebGL 级 Dialog 记为 `[有意差异]`。

---

## 1. 本地版本记录

| 项 | 值 | 标记 |
|---|---|---|
| package.name | `build-a-molecule` | `[已确认]` |
| version | `1.1.0-dev.2` | `[已确认]` |
| dependencies.json 时间戳 | Thu Aug 07 2025 09:19:46 MDT | `[已确认]` |
| build-a-molecule sha | `9f605a7f540bcc145e56bedc285344362acb9bee` | `[已确认]` |
| nitroglycerin sha | `10252a4a2cd368478358aa2e37fb23c2219a53fd` | `[已确认]`（本地**未**克隆该 repo） |
| mobius / vegas / three | phetLibs + preload `three-r104.js` | `[已确认]` |
| 本地路径 | `phet sourses/build-a-molecule-main/build-a-molecule-main` | `[已确认]` |

---

## 2. KartosLab 工程半

| 项 | 证据 | 标记 |
|---|---|---|
| 包名 | `kratos`（pubspec） | `[已确认]` |
| Home | `lib/screens/home_screen.dart`：化学 → 溶液与浓度 / 原子核 | `[已确认]` |
| 已有化学 sim | `molarity/`、`build_a_nucleus/` | `[已确认]` |
| BAM Flutter 实现 | **不存在** | `[已确认]` |
| NineGrid | `lib/common/widgets/nine_grid_layout.dart` | `[已确认]` |
| 可复用 | `KratosTabbedScreen`、`DragDropWorkspace`、`celebration_dialog` | `[已确认]` |
| 3D 依赖 | pubspec **无** flutter_gl / cube / webview | `[已确认]` |
| 渲染惯例 | CustomPainter + Canvas 2D | `[已确认]` |
| 未接线原型 | `phet/widgets/chemistry/molecules/` — **不作为**生产基线 | `[已确认]` |
| 需求模板 | 对齐 `req-collision-lab` meta/process | `[已确认]` |
| 建议落点 | `lib/chemistry/build_a_molecule/`；Home：化学 → 新子组「分子搭建」 | `[推测]` |

---

## 3. Screens

| # | Screen | Model | View | Collection | 标记 |
|---|---|---|---|---|---|
| 0 | Single | `SingleModel` | `MoleculeCollectingScreenView(model, true)` | 是；每箱 capacity=1；固定首套 kit/boxes | `[已确认]` |
| 1 | Multiple | `MultipleModel` | `MoleculeCollectingScreenView(model, …)` | 是；capacity>1；`isMultipleCollection: true` | `[已确认]` |
| 2 | Playground | `PlaygroundModel` | `BAMScreenView` | **否**（`CollectionLayout(false)`） | `[已确认]` |

入口：`js/build-a-molecule-main.ts` 数组顺序即导航顺序。`Sim(..., { webgl: true })`。

### Single 首套 Collection（固定）`[已确认]`

Kits：
1. H×2, O×1  
2. H×2, O×2  
3. C×1, O×2, N×2  

Boxes（各 capacity 1）：H2O, O2, H2, CO2, N2。

### Multiple 首套 `[已确认]`

Boxes：CO2×2, O2×2, H2×4, NH3×2。

### Playground 元素 kit（无 collection）`[已确认]`

实现 notes + `PlaygroundModel`：H, O, C, N, Cl, F, B, Si, S, P, Br。  
`BAMConstants.SUPPORTED_ELEMENTS` 另含 **I**；Playground kits **未**放碘桶 → 碘主要在数据/匹配层 `[已确认]`。

---

## 4. Molecule Data 文件

| 文件 | 行数(约) | 角色 | 标记 |
|---|---|---|---|
| `collectionMoleculesData.ts` | 37 行文件 / **26** 条 | 首屏 collection 所需 CompleteMolecule（含名称） | `[已确认]` |
| `otherMoleculesData.ts` | ~9342 | 其余可命名 CompleteMolecule | `[已确认]` |
| `structuresData.ts` | ~29894 | **允许的结构子图**（无名称；用于 `isAllowedStructure`） | `[已确认]` |

加载：`MoleculeList.loadInitialData` → collection；`loadMainData` → other + structures。

### CompleteMolecule serial2 schema `[已确认]`

示例（water，`doc/implementation-notes.md` + 数据行）：

```
water|H2O|962|full|3|2|O 2.5369 -0.155 0 0 0|H ... ,0-1|H ... ,0-1
```

字段：`commonName|formula|cid|format(full|2d|3d)|…atoms/bonds payload`

Atom（full）：`Symbol x2d y2d x3d y3d z3d`  
Bond：`index-order`（1-based 邻接序列化；order=1/2/3）

### structuresData schema `[已确认]`

`atomCount|bondCount|Atom0|Atom1,bondTargets|...`（`MoleculeStructure.fromSerial2Basic`）  
例：`'3|2|O|H,0|H,0'` ≈ 水骨架（无 H 坐标名，纯拓扑）。

---

## 5. Structure Matching / Bond Rules

| 问题 | 答案 | 标记 |
|---|---|---|
| 什么是合法 molecule structure？ | 在 `allowedStructureFormulaMap` 中与某 stripped structure 氢子图匹配；或仅 1–2 个 H；且 `isValid()` | `[已确认]` |
| atom composition | `ElementHistogram` / atoms[].element | `[已确认]` |
| atom identity | Element.symbol（nitroglycerin Element） | `[已确认]` |
| bond 表示 | play：`Bond(a,b)` 无 order；catalog：`PubChemBond` 有 order | `[已确认]` |
| 连接 | LewisDot 四向 N/S/E/W；吸附距离 `Kit.bondDistanceThreshold=100` | `[已确认]` |
| stereochemistry | 匹配用图同构，**不**区分立体异构手性判据 | `[已确认]`（算法层） |
| formula | CompleteMolecule.molecularFormula / Hill 等派生 | `[已确认]` |
| name | commonName + strings 驼峰映射 `getDisplayName` | `[已确认]` |
| collection vs other | collection 子集先加载；二者皆 CompleteMolecule | `[已确认]` |
| 用户可构建 | kit 原子 + structures 允许 + 识别为 complete 可入箱 | `[已确认]` |
| 仅信息数据 | otherMolecules 大量用于命名/3D；structures 无显示名 | `[已确认]` |
| 预生成 3D | PubChem x3d/y3d/z3d 在 full/3d 条目中 | `[已确认]` |

**识别路径**：用户分子 → `findMatchingCompleteMolecule` → `isEquivalent`（直方图 + `checkEquivalency` 同构）。

**禁止替代**：`if (formula == "H2O")` — 源码**不是**这样做。

---

## 6. Collection / “Game”

| 能力 | 行为 | 标记 |
|---|---|---|
| Goal | `CollectionBox.moleculeType: CompleteMolecule` + `capacity` | `[已确认]` |
| Drop 判定 | `moleculeType.isEquivalent(structure) && quantity < capacity` | `[已确认]` |
| Progress | `quantityProperty` | `[已确认]` |
| Full | `quantity === capacity` → 音效 | `[已确认]` |
| Next Collection | 全部满 → `AllFilledDialog` → `regenerateCallback` → `generateKitCollection` | `[已确认]` |
| Random | `dotRandom` 从 `COLLECTION_BOX_MOLECULES`（~26 种）抽 goal；kit 原子按目标分子配方生成 | `[已确认]` |
| Reset | `BAMModel.reset`：回第一 collection，清其余 | `[已确认]` |
| 独立关卡/星级/计时 Game | **不存在** | `[已确认]` |

---

## 7. 3D / Interaction

| 组件 | 技术 | 标记 |
|---|---|---|
| `Molecule3DDialog` | THREE.js WebGL；Space Fill / Ball-Stick；quaternion 旋转；Play/Pause | `[已确认]` |
| `Molecule3DNode` | **Canvas 2D** 投影 PubChem 3D 坐标 ×75 | `[已确认]` |
| `WarningDialog` | WebGL 不可用时警告（字符串 `warning`） | `[已确认]` |
| Play area 原子 | 2D Lewis 布局 + 共价半径；伪 3D 图标用 nitroglycerin `*Node` | `[已确认]` |
| 剪刀断键 | `images/scissors*.png` + cursor | `[已确认]` |

Flutter 默认方案：Dialog 用 **Canvas 投影**（Molecule3DNode 语义）→ `[有意差异：无 WebGL]`，避免新全局 3D 依赖。

---

## 8. 元素颜色 / 半径

来源：nitroglycerin `Element.ts`（本地缺失；CDN 取证 → `requirements/req-build-a-molecule/_ref_Element.ts`）。

| Symbol | covalentRadius (pm) | color | 标记 |
|---|---|---|---|
| H | 37 | `#ffffff` | `[已确认]`（外部依赖源） |
| C | 77 | `rgb(178,178,178)` | 同上 |
| O | 73 | `PhetColorScheme.RED_COLORBLIND` = `rgb(255,85,0)` | 同上 |
| N | 75 | `#0000ff` | 同上 |
| F | 72 | `rgb(245,255,36)` | 同上 |
| Cl | 100 | `rgb(136,242,21)` | 同上 |
| Br | 114 | `rgb(190,30,20)` | 同上 |
| I | 133 | `#940094` | 同上 |
| B | 85 | `rgb(255,170,119)` | 同上 |
| Si | 118 | `rgb(240,200,160)` | 同上 |
| P | 110 | `rgb(255,154,0)` | 同上 |
| S | 103 | `rgb(212,181,59)` | 同上 |

---

## 9. Assets / Strings

### 本地 assets `[已确认]`

- `assets/build-a-molecule-screenshot*.png`（已复制到 `visual-qa/ref/`）
- `images/scissors*.png`、`splitBlue.png`、cursor 变体
- **无**独立分子 PNG 库（分子多为几何/数据驱动）

### Strings `[已确认]`

`build-a-molecule-strings_en.json`：**53** keys（分子名 + collection 模板 + 元素名 + title.* + warning + threeD…）。

---

## 10. Layout / Lifecycle 常数 `[已确认]`

`BAMConstants`：
- 背景 play area `rgb(198,226,246)`
- collection bg `rgb(238,238,238)`
- MVT scale `0.27 * 1.2`，inverted Y，中心映射
- `VIEW_PADDING = 18`

Reset：Refill（回桶）≠ Reset Collection（清箱+回桶）≠ Sim Reset All（BAMModel.reset）。

Home ↔ Sim：对齐 BAN — 无 AutomaticKeepAlive；返回 dispose。

---

## 11. 风险与阻塞

| 项 | 状态 |
|---|---|
| Molecule schema | `[已确认]` — 不阻塞 |
| Matching 规则 | `[已确认]` — 不阻塞 |
| Collection 规则 | `[已确认]` — 不阻塞 |
| 缺少本地 nitroglycerin | 已用外部 Element.ts 取证落盘 — **不阻塞** |
| 引入全局 3D framework | **不采用** → 不暂停 |
| 大数据集体积（structures ~30k / other ~9k） | 实现时转 JSON asset — 工程量风险，非架构暂停 |

---

## 12. 下一阶段

→ Phase 1：`SOURCE_ANALYSIS.md` + `DATA_MAPPING.md`  
→ Phase 2：`visual-qa/BASELINE.md`（用 ref 截图；标缺少本机 runtime 截图）  
→ Phase 3：`ARCHITECTURE_PLAN.md`  
→ Phase 4+：模型与数据迁移实现

*Phase 0 完成。无暂停条件触发。*
