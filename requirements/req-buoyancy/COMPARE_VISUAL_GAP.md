# Compare 屏 · 原版 vs 移植版差距清单

> 源码：`BuoyancyCompareScreenView.ts` / `BuoyancyCompareModel.ts` / `BuoyancyScreenView.ts`  
> 对照截图：用户原版 vs Flutter `01_compare.png`（2026-10-01）  
> 判定标准：布局锚点 + 功能行为与源码一致（非「看起来差不多」）

## 锚点布局（源码）

| 模块 | 源码锚点 | 移植现状 |
|---|---|---|
| `blocksPanel` | AlignBox right/top | 有，但与 Mass 滑条错误合并 |
| `blocksValuePanel` | 右侧 VBox（pool 右上角下方） | 缺失独立面板 |
| `densityComparisonAccordionBox` | 右侧 VBox | 缺失 |
| `percentSubmergedAccordionBox` | 右侧 VBox | 缺失 |
| `displayOptionsPanel` (Forces) | AlignBox left/bottom | 缺失 |
| `fluidPanel` | AlignBox center/bottom | 缺失 |
| `resetAllButton` | AlignBox right/bottom | 有 |
| `poolScaleHeightControl` | pool 右缘 model→view | 缺失 |
| 液位读数 `levelVolume` | pool 左缘红三角 + L | 缺失 |
| 底栏 Joist navbar | 底部 | 现为顶部 tab（harness） |

## 场景内容

| 内容 | 源码 | 移植现状 |
|---|---|---|
| Cuboid 1A/1B + 材质贴图 | CuboidView + MaterialView | 贴图已加载；标签/色标缺失 |
| Mass Values 读数 | MassLabelNode | 缺失 |
| 陆地秤 Scale (-0.70) | `BuoyancyCompareModel` | 缺失 |
| 池内 PoolScale | `Pool(usePoolScale:true)` | 缺失 |
| 力箭头 Gravity/Buoyancy/Contact | ForceDiagramNode + DisplayProperties | 模型有力；UI 未接 |
| Depth Lines | supportsDepthLines | 缺失 |
| 草地/土层/水池 | Ground*/PoolMesh | 已基本对齐；块体与土层 z 序仍有裁切感 |

## 功能绑定

| 功能 | 期望 | 现状 |
|---|---|---|
| Same Mass / Volume / Density | `blockSetProperty` | 有 |
| Mass/Volume/Density NumberControl | 独立 `BlocksValuePanel` | 滑条挤在 Blocks 里 |
| Fluid 下拉 simple 列表 | FluidSelectionPanel | 无 |
| Vector Zoom ± | level 0..7 | 无 |
| Density / % Submerged 手风琴 | AccordionBox | 无 |
| 池液位拖动 | PoolScaleHeightControl | 无 |

## 本轮已落地（2026-10-01）

- [x] 完整控件树骨架：Blocks / Mass(Value) / Forces / Fluid / Density+%Submerged Accordion / Reset
- [x] DisplayProperties 接线（力箭头开关、Mass Values、Depth Lines、Vector Zoom）
- [x] 1A/1B 色标 + 质量标签；液位 L 读数 + 池侧高度滑杆
- [x] 陆地秤 / 池内秤 **视觉占位**（读数固定 0.0 N；物理称重未接）
- [ ] 秤的真实测力 / PoolScale.heightProperty 物理
- [ ] Joist 底栏（属壳层）
- [ ] 贴图光照与原版 THREE Lambert 完全一致

## 本轮对齐优先级

1. **P0** ~~完整控件树 + DisplayProperties~~ ✅  
2. **P0** ~~质量标签 + 色标；力箭头~~ ✅  
3. **P1** 陆地秤 + 池内秤 **物理测力**（视觉已占位）  
4. **P1** 块体与地面深度排序细化  
5. **P2** Joist 底栏（属 Home/壳层）
