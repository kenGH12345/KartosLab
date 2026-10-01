# Migration Plan · Density

> 仅在 Phase 1 用户确认后执行。每 vibe-loop ≤ 30 min，analyze + 单测 + 可视。

## 0. 与 prompt 候选路径的差异（必须遵守本工程）

| Prompt 候选 | 本工程事实 | 决定 |
|---|---|---|
| `lib/src/simlab/density/` | 无 simlab；模块在 `lib/forces` `lib/chemistry/molarity` `lib/astronomy/...` | **`lib/density/`** |
| `/simlab/:simId` | `MaterialApp(home: HomeScreen)` + `Navigator.push` | Home → 物理 → 新分组「密度与浮力」→ Density |
| 自建 MaterialApp | 禁止 | 只加入口卡片 |

[来源: docs/knowledge/kratos/architecture/app-entry.md:7-12]  
[来源: docs/knowledge/kratos/architecture/design-patterns.md:9-47]

## 1. 推荐目录（实现时按需建，禁止一次铺满空文件）

```
lib/density/
  density_strings.dart
  density_colors.dart
  density_constants.dart
  model/          # 不可变 State、Material、MysterySet、CompareMode
  solver/         # DensityRelation, CompareConstraint, BuoyancyWorld
  controller/     # DensityController (ChangeNotifier)
  render/         # World↔Screen MVT, RenderData
  view/screens/   # home + 三屏
  view/painters/  # pool, cuboid, scale, number_line
  view/widgets/   # panels, table, mode radios
  config/         # scenario JSON + manager
assets/density/images/
test/density/
schemas/density_scenario.schema.json
```

## 2. L0 复用 vs 新建

**复用**：NineGridLayout, KratosTabBar, KratosSlider, KratosComboBox, KratosRadioGroup, KratosNumberField, PropertyControlPanel, ScenarioManagerBase。

**本 sim 新建（L2）**：CuboidPainter, PoolPainter, DensityNumberLine, DensityTable, MysterySet 数据, CompareConstraint, BuoyancyWorld, 指针约束拖拽。

**不上抽**（第 1 用户）。

## 3. Loop 顺序

1. Material 表 + `DensityRelation` 单测（ρ=m/V、范围、零体积防护）  
2. Intro/Compare/Mystery 不可变 State + Reset  
3. CompareConstraint 单测（三模式 × 四块）  
4. MysterySets 单测（含 11340 ≠ 11342）  
5. World MVT + 空池 Canvas（LayoutBuilder）  
6. Cuboid 渲染（先纯色，再贴图）  
7. Intro 控件接线 + 材料联动  
8. 拖拽 + 最小浮力/接触 step  
9. Compare UI  
10. Mystery + Table + Random  
11. NineGrid 三屏 + Home 入口  
12. Semantics、Reset、Preferences 体积单位  
13. Widget tests + analyze  

## 4. 风险

| 风险 | 证据 | 缓解 |
|---|---|---|
| p2.js 手感难 1:1 | PhysicsEngine + query 十余参数 | 验收沉浮对错 + 不穿透地面 + 抓取跟手；不追求子步级轨迹 |
| THREE PBR | MaterialView + jpg.ts | 先等距立方体贴 col 贴图 |
| 缺 common 曾阻塞 | 与 MSS 缺 solar-system-common 同类 | 已 clone |
| Windows ExcludeSemantics | `lib/main.dart:26-28` | 用户拍板是否改全局 |
| 连续 Ticker | `model.step(dt)` | 页面 dispose 停 ticker；禁止叠加 |
| Compare 标签随模式变化 | cubesData tag 重映射 | 配置驱动，勿写死 A=黄 |

## 5. 测试最低集

- `density = mass/volume`：正常 / 0 体积拒绝 / 负值拒绝 / 极大  
- 六种 Intro 材料默认 ρ、A/B 初值  
- Same Mass/Volume/Density 四块  
- Mystery Set1/2/3 逐字段；Random：5 块、体积∈[1,10]L、密度∈材料表  
- Table 13 行排序  
- Widget：三屏打开、材料切换、Reset、Table 展开  
- Drag：down/move/up 改 position 不改 volume  

## 6. 完成后再进入的 Close

code-reviewer（L0 + NineGrid）→ closer → knowledge-maintainer。
