# Chart Intro Periodic Table 数据与定位分析

> 需求：`req-build-a-nucleus` · Phase 2G-1  
> 日期：2026-08-31  
> 范围：只建数据 / 定位模型 + 纯 Dart 测试；不画最终 Widget / Painter  
> 诚实标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论先行

1. Chart Intro 右上角是 shred **`PeriodicTableNode` + `SymbolNode`**，包在 `PeriodicTableAndIsotopeSymbol`（`sun.Panel`）。[已确认 `PeriodicTableAndIsotopeSymbol.ts`]
2. 表是 **7 行 × 18 列主表，90 格**。镧系（Z=58–71）与锕系（Z=90–103）**不单独成行、不出现在格子里**。[已确认 `PeriodicTableNode.ts`]
3. 不是「只画 Z=1–10」。整张主表都画；Chart Intro 质子上限 10，所以**游戏中只能点亮 H–Ne**。[已确认 `CHART_MAX_*` + 造格循环]
4. **不可交互**：`interactiveMax: 0`。点击 / 悬停 / 键盘都不会改 p/n。[已确认]
5. 高亮只看 **`protonCountProperty`**。Z=0 不高亮。核素不存在（如 2p0n）仍高亮 He。[已确认]
6. 符号来自 shred `AtomNameUtils.getSymbol`。本工程只复用已有 `ElementInfo`（`nuclide_table.json`），**不经 `NuclideRepository` 存在性查询**。[已确认]
7. 本阶段无 Painter / 无最终 Widget / 无 Controller 点击 API。

---

## 1. 原版 Periodic Table 结构

### 1.1 装配

```
ChartIntroScreenView
  PeriodicTableAndIsotopeSymbol(particleAtom)
    Panel
      Rectangle(0,0,150,100)          // empirically determined
        SymbolNode(protonCount, massNumber)  scale 0.15
        PeriodicTableNode(protonCountProperty, { interactiveMax: 0, ... })
          scale 0.75
```

[已确认 `PeriodicTableAndIsotopeSymbol.ts` L19–46]

符号叠在表「上方空洞」：`centerX = (7.5/18)*table.width`（对准第 8 列中心），`periodicTable.top = symbol.bottom - height/7*2.5`。[已确认]

本阶段 **不实现 SymbolNode**。只记录它与表同面板、读同一 `protonCount`。

### 1.2 是否完整周期表

| 问 | 答 | 标记 |
|---|---|---|
| 是否 IUPAC 全 118 + f 区两行？ | **否**。无镧系/锕系独立行 | [已确认] 源码注释 *“not shown in the sim”* |
| 主表是否画到 Og？ | **是**。Z=1–57、72–89、104–118 | [已确认] 跳格后造满 90 格 |
| Chart Intro 是否裁成 Ne 以内？ | **否**。仍画全主表 | [已确认] 未传裁剪；只 `interactiveMax: 0` |
| 本屏能点亮几个元素？ | **Z=1–10（H–Ne）**；Z=0 无高亮 | [已确认] 壳层上限 10 |

### 1.3 行列定义

`POPULATED_CELLS`：行 = 周期 1–7（下标 0–6）；列 = 0–17（IUPAC 1–18）。

| 行 | 有格的列 | 元素（跳 f 区后） |
|---|---|---|
| 0 | 0, 17 | H, He |
| 1 | 0,1,12–17 | Li–Ne |
| 2 | 0,1,12–17 | Na–Ar |
| 3 | 0–17 | K–Kr |
| 4 | 0–17 | Rb–Xe |
| 5 | 0–17 | Cs, Ba, La, Hf–Rn |
| 6 | 0–17 | Fr, Ra, Ac, Rf–Og |

[已确认 `PeriodicTableNode.ts` L39–47 + L121–175]

单元格平移：`Vector2(column * cellDimension, row * cellDimension)`，默认 `cellDimension = 25`。[已确认] 像素留给 2G-2。

---

## 2. 数据来源

| 数据 | 原版 | 本工程 | 共用？ |
|---|---|---|---|
| 格子行列 | shred `POPULATED_CELLS` + 造格跳 Z | `PeriodicTableLayout` | **布局常量对抄** |
| 符号 / 英文名 | `AtomNameUtils.getSymbol/getName` | 已有 `ElementInfo`（同一 AtomNameUtils 抽出） | **单一事实：elements[]** |
| 核素是否存在 | **周期表不用** | **禁止** `NuclideRepository.doesExist` | 不共用 |
| 高亮 | `particleAtom.protonCountProperty` | `ChartIntroState.protonCount` | 计数同源 |
| 选中/禁用色 | `BANColors.*PeriodicTable*` | 本阶段不进模型 | 2G-2 |

**不要**把 `NuclideRepository` 当周期表数据源。核素表 ≠ 周期表布局。

---

## 3. 元素定位模型

三套编号（shred 注释，[已确认]）：

1. `protonCount` / Z：1–118  
2. `elementIndex`：主表格子 0–89（忽略镧/锕）  
3. `(column, row)`：网格坐标  

造格时 Z 递增，遇 58→72、90→104。[已确认]

本工程：`PeriodicTableSeat { atomicNumber, column, row }`，90 条不可变列表。不把 Widget offset 写进业务。

---

## 4. current element 映射

```
ChartIntroState.protonCount
  → periodicTableHighlightZ   // 0 → null，否则 = protonCount
  → PeriodicTableReading.highlightedAtomicNumber
  → 对应格子（若该 Z 在主表上）
```

| 状态 | 高亮 | 标记 |
|---|---|---|
| 0p0n | 无 | [已确认] `if (protonCount !== 0)` |
| 1p0n H-1 | H | [已确认] |
| 2p0n 不存在 | **仍 He** | [已确认] 只听质子数 |
| Reset → 0p0n | 无 | [已确认] atom clear |
| Z=58（本屏到不了） | shred 会错映到 Hf 的 index | [已确认 公式] 本屏 Z≤10，无影响 |

Fe（Z=26）在表上，Chart Intro **永远点不亮**（加不到 26p）。[已确认]

---

## 5. 交互

Chart Intro 调用：

```ts
new PeriodicTableNode(protonCountProperty, { interactiveMax: 0, ... })
```

[已确认 `PeriodicTableAndIsotopeSymbol.ts` L24–26]

| 输入 | Chart Intro | 依据 |
|---|---|---|
| click | **无**。`interactiveMax===0` → 不把 `protonCountProperty` 传给 cell → 无 `FireListener`，`cursor=null` | [已确认 `PeriodicTableCell.ts` L88–126] |
| 改 p/n | **否** | 同上 |
| hover | **无**业务 hover（无 tooltip、无 hover 变色） | [已确认] cell 无 Pointer hover |
| tooltip | **无** | [已确认] |
| keyboard | **无**。箭头导航只在 `interactiveMax > 0` | [已确认 `PeriodicTableNode.ts`] |
| touch | 同 click：未接线 | [已确认] |
| focus / PDOM | 非交互时 cell `accessibleVisible: false`，不高亮 focus | [已确认] |

**不要**因为核素图不可点就「猜」周期表也不可点——这里是 **`interactiveMax: 0` 单独取证**。

Build an Atom 等 sim 会把 `interactiveMax` 设成正数，点击会 `protonCountProperty.value = atomicNumber`。Chart Intro **没有**这条路。[已确认]

因此：**纯展示**。无 Controller 点击 API。无 controller 测试。

### disabled

`interactiveMax: 0` 时每格 `fill = disabledCellColor`。  
Chart Intro 覆盖：`disabledPeriodicTableCellColorProperty` 默认 **白**（shred 默认 `#EEEEEE`）。  
选中：填/描边黑，标签白，`strokeHighlightWidth: 1`。[已确认 `BANColors.ts` + ctor options]

颜色进 2G-2，不进本阶段数据对象。

---

## 6. 状态关系

```
ChartIntroState
  protonCount          唯一高亮输入
  elementSymbol/Name   已有，给元素名条 / SymbolNode（后期）
  nuclideExists        周期表不用
  periodicTableHighlightZ   本阶段新增派生，不查表

PeriodicTableLayout     座位常量
PeriodicTableReading    座位 + ElementInfo 符号 + 高亮 Z
```

Reset：只清壳层 → `protonCount=0` → 高亮空。周期表无独立 reset。[已确认]

---

## 7. Flutter 数据模型（已落地）

| 类型 | 文件 | 职责 |
|---|---|---|
| `PeriodicTableSeat` | `chart_intro/model/periodic_table_layout.dart` | Z + 列 + 行 |
| `PeriodicTableLayout` | 同上 | `POPULATED_CELLS`、跳 Z、90 座、高亮规则 |
| `PeriodicTableCellData` / `PeriodicTableReading` | `periodic_table_reading.dart` | 只读快照；`from(protonCount, elements)` |
| `ChartIntroState.periodicTableHighlightZ` | `chart_intro_state.dart` | 0→null |

**未做：** Painter、Widget、点击、SymbolNode、改 Decay、改核素图。

---

## 8. 测试计划

文件：`test/chemistry/build_a_nucleus/chart_intro/periodic_table_layout_test.dart`

| 用例 | 期望 |
|---|---|
| 90 格 / 7 行 | 镧锕 Z 无座；La/Hf、Ac/Rf 有座 |
| H | (col 0, row 0) |
| He | (17, 0) |
| C | (13, 1) |
| Fe | (7, 3) |
| Ne | (17, 1)，Z=10 = Chart 上限 |
| Og | (17, 6) |
| 符号 | 来自 `ElementInfo`，H/He/C/Fe/Ne/Og |
| 0p | 无高亮 |
| 2p0n 不存在 | 仍高亮 He |
| Reset | 高亮清除 |

无 click controller 测试。

---

## 9. [已确认]

- `interactiveMax: 0` → 不可点、不改 p/n  
- 主表 90 格；镧/锕不画  
- 高亮 = `protonCount`，0 则无；不看核素存在  
- 符号 = `AtomNameUtils` / 本工程 `ElementInfo`  
- Chart Intro 上限 Ne；表仍画到 Og  
- 无 tooltip / 无业务 hover  
- Reset 只通过质子数归零  
- 面板 `scale(0.75)`、符号 `scale(0.15)`、占位矩形 150×100  

## 10. [推测]

- 150×100 矩形是经验裁剪框，不是格子逻辑尺寸  
- NineGrid `topRight` 将放大/缩小整面板，不改行列模型  

## 11. [待确认]

- SymbolNode 与周期表叠层的像素对齐（2G-2 对原版截图）  
- 白底 disabled 在白 Panel 上是否几乎「无底色只留字」——视觉阶段核对  

## 12. 理论工时

| 阶段 | 理论 |
|---|---|
| 2G-1 本阶段（分析 + 布局数据 + 测试） | **2.5–3.5 h** |
| 2G-2 绘制 + SymbolNode + NineGrid 接入 | 3–5 h（另立项） |

---

## 13. 下一阶段建议

**2G-2：** 用 `PeriodicTableReading` 画格子 + 高亮；同面板接 `SymbolNode` 等价物；放进 `ChartIntroScreen` `topRight`。  
仍不要做 Zoom / Focused / Equation / Full Chart Dialog。
