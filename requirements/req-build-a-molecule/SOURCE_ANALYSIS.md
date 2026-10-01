# SOURCE_ANALYSIS · Build a Molecule

> 本地源：`1.1.0-dev.2` · SHA `9f605a7f…`  
> 格式：功能 → 源文件 → 类/方法 → 算法 → Flutter 迁移结论

---

## 1. 启动与 Screen

| 功能 | Source | Class/Method | 结论 | 标记 |
|---|---|---|---|---|
| Sim 入口 | `js/build-a-molecule-main.ts` | `Sim([Single, Multiple, Playground], {webgl:true})` | Flutter：`KratosTabbedScreen` 三 Tab，顺序一致 | `[已确认]` |
| Single | `single/SingleScreen.ts` + `SingleModel.ts` | 固定 3 kit + 5 box×1 | 硬编码移植首套；后续 collection 随机生成 | `[已确认]` |
| Multiple | `multiple/*` | `isMultipleCollection:true`；box capacity>1 | 同左 | `[已确认]` |
| Playground | `playground/*` | 无 collection panel | 仅 kit + play area + 命名/3D | `[已确认]` |

---

## 2. Molecule Data Schema

### 2.1 CompleteMolecule（命名分子）

**解析**：`CompleteMolecule.fromSerial2` / `fromString`

| 字段 | 含义 | Flutter |
|---|---|---|
| commonName | PubChem/覆盖名 | `String commonName` |
| molecularFormula | 公式字符串 | `String formula` |
| cid | PubChem CID | `int cid` |
| format | `full`/`2d`/`3d` | enum + has2d/has3d |
| atoms | PubChemAtom(+coords) | `BamAtom` + optional 2d/3d |
| bonds | PubChemBond(+order) | `BamBond` + `order` |

**样本 water**：`collectionMoleculesData.ts` L35。

### 2.2 structuresData（允许拓扑）

**解析**：`MoleculeStructure.fromSerial2Basic`  
无名称；用于 `MoleculeList.addAllowedStructure` → `allowedStructureFormulaMap[histogramHash] → StrippedMolecule[]`。

### 2.3 加载策略

| 阶段 | 方法 | Flutter |
|---|---|---|
| 启动 | `initialList.loadInitialData()` 仅 collection | 同步加载 collection JSON |
| 主数据 | `getMainInstance()` → other + structures | isolate 或启动时异步；bonding 前必须就绪 |

---

## 3. Structure Matching

| 步骤 | Source | 算法 | Flutter | 标记 |
|---|---|---|---|---|
| 有效性 | `MoleculeStructure.isValid` | 无环/连通；H 不连 >1 | 原样移植 | `[已确认]` |
| 允许搭建 | `MoleculeList.isAllowedStructure` | strip H → histogram hash → `StrippedMolecule.isHydrogenSubmolecule`；≤2 纯 H 例外 | 必须移植 structures 集 | `[已确认]` |
| 命名匹配 | `findMatchingCompleteMolecule` | `completeMolecules.find(m => user.isEquivalent(m))` | StructureResolver | `[已确认]` |
| 同构 | `isEquivalent` + `checkEquivalency` | 直方图相等 + 递归邻居置换同构 | **禁止**仅比 formula | `[已确认]` |
| Collection drop | `CollectionBox.willAllowMoleculeDrop` | `moleculeType.isEquivalent` && not full | CollectionModel | `[已确认]` |

**StrippedMolecule**：去掉氢后的骨架，用于 structures 加速匹配（含氢子图扩展）。

---

## 4. Bond / Drag Interaction（Kit）

| 行为 | Source | 细节 | 标记 |
|---|---|---|---|
| 拖出 bucket | `Kit` / `BAMBucket` | Atom2 从 bucket → play molecule（可单原子） | `[已确认]` |
| 自动成键 | `attemptToBondMolecule` | 最近 Lewis 开口；距离≤100 或重叠；`canBond` | `[已确认]` |
| canBond | `Kit.canBond` | 不同分子 + `isAllowedStructure(合并结构)` + 在 play bounds | `[已确认]` |
| 几何对齐 | `BondingOption.idealPosition` | `posA + dir*(rA+rB)` | `[已确认]` |
| 方向 | `LewisDotModel` + `Direction` N/S/E/W | 每原子最多 4 向 | `[已确认]` |
| 断键 | `breakBond` + 剪刀 UI | 无效化 Lewis + 拆 molecule map | `[已确认]` |
| 回桶 | `recycleMolecule` / atom invalidate | 清键 → bucket | `[已确认]` |
| Refill | `RefillButton` | play 区全回桶，恢复数量 | `[已确认]` |

**关键**：成键合法性由 **structures 数据集** 门控，不是开放价态表。

---

## 5. Collection / Next Collection

| 功能 | Source | 算法 | 标记 |
|---|---|---|---|
| Box | `CollectionBox.ts` | type + capacity + quantity | `[已确认]` |
| 满箱音效 | vegas `GameAudioPlayer` | Flutter：可选 audioplayers / 静默 | `[推测]` 可降级 |
| All filled | `AllFilledDialog` | “You completed…” + Next | `[已确认]` |
| 生成下一套 | `BAMModel.generateKitCollection` | 随机 goal∈COLLECTION_BOX_MOLECULES；容量 1..3（Multiple）；按公式拼 kit buckets | `[已确认]` |
| 前后切换 | `hasPrevious/Next` + `switchTo*` | 保留已生成 collections 列表直至 Reset | `[已确认]` |
| Reset | `BAMModel.reset` | 仅留 firstCollection | `[已确认]` |

**无** level/stars/timer/checkAnswer 独立 Game 管线。

---

## 6. Formula / Name

| 功能 | Source | Flutter |
|---|---|---|
| Display name | `getDisplayName`：strings 驼峰 key，否则 English commonName | 加载 `build-a-molecule-strings_en.json` |
| Formula 显示 | `getGeneralFormulaFragment` 等（MoleculeStructure） | 模型派生，Widget 只读 |
| 模式串 | `moleculeNamePattern`、`collection*Pattern` | 字符串插值移植 |

---

## 7. 3D

| 路径 | Source | Flutter 策略 | 标记 |
|---|---|---|---|
| WebGL Dialog | `Molecule3DDialog` + THREE | **不**引入全局 3D 引擎 | `[有意差异]` |
| Canvas 投影 | `Molecule3DNode`：xyz×75，拖拽旋转，球着色 | CustomPainter 移植 | `[已确认]` 默认 |
| WebGL 警告 | `WarningDialog` | 若不做 WebGL 可不弹；或信息条说明用 2.5D | `[待确认]` 文案 |
| Space/BallStick | Dialog `ViewStyle` | Canvas 两模式 | `[已确认]` |

---

## 8. Reset / Lifecycle

| 动作 | 行为 | 标记 |
|---|---|---|
| Refill | 原子回桶，collection **保留** | `[已确认]` doc |
| Reset Collection | 回桶 + 清 boxes | `[已确认]` |
| Reset All | `BAMModel.reset` | `[已确认]` |
| 切 Screen | 各 Screen 独立 Model | `[已确认]` |
| 回 Home | dispose（对齐 BAN） | `[推测]` 工程惯例 |

---

## 9. 依赖缺口

| 依赖 | 用途 | 处理 |
|---|---|---|
| nitroglycerin Element | 色/半径/权重 | `_ref_Element.ts` 已取证 → Dart `BamElement` |
| nitroglycerin *Node | 伪 3D 分子图标 | Canvas 自绘 / 数据坐标 |
| mobius+THREE | WebGL Dialog | 跳过；Canvas 替代 |
| vegas | 正确音 | 可选 |

---

## 10. Flutter 迁移结论（总）

1. 把三份数据 **原样** 转为 `assets/data/build_a_molecule/*.json`。  
2. Dart 移植：`MoleculeStructure` / `StrippedMolecule` / `MoleculeList` / `Kit` / `LewisDot` / `CollectionBox` / `BAMModel`。  
3. UI：NineGrid + kit carousel + play + collection panel。  
4. 3D Dialog：Canvas 2.5D。  
5. 测试优先：matching、allowed structure、collection、reset——不是“Widget 出现”。
