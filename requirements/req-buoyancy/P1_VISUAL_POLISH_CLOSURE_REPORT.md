# Buoyancy · P1 Visual Polish Closure Report

**日期**：2026-10-01  
**范围**：Compare / Explore / Lab / Shapes / Applications 视觉与布局收尾  
**状态**：**CLOSED**（用户确认可 report）

---

## 摘要

本轮关闭四项阻塞级视觉问题：池外轨道、Lab 烧杯、Shapes 手风琴裁切、Applications 瓶/船全黑。五屏控件树与 Home 注册此前已对齐；本报告仅覆盖本轮 polish。

---

## 交付项

| # | 问题 | 处理 | 证据 / 落点 |
|---|---|---|---|
| 1 | PoolScaleHeightControl 像在池内 | 锚点改为 `pool.maxX + MARGIN_SMALL`，Y 对齐池底前缘；五屏共用 `BuoyancyPoolScaleHeightLayout` | `buoyancy_pool_scale_height_control.dart`；对照 `BuoyancyScreenView.positionScaleHeightControl` |
| 2 | Lab 缺 Fluid Displaced 烧杯 | `BuoyancyFluidDisplacedPanel`：BeakerNode 等价绘制 + 原版 `fluid_displaced_scale_icon.png` + 体积/重力实时读数 | `buoyancy_fluid_displaced_panel.dart`；asset `assets/buoyancy/images/fluid_displaced_scale_icon.png` |
| 3 | Shapes 右侧 Object Density / % Submerged 展开看不见 | 去掉 `maxHeight: 0.72` 裁切，改为 `top`→`bottom+56` 可滚动区；展开 `ensureVisible`；密度改 `kg/L` | `buoyancy_shapes_screen.dart` |
| 4 | Applications 瓶/船全黑 | 瓶保持**横躺**（Bottle.ts 沿 X）；半透明灰塑料 + 红 `A` 标；船铝灰实体色；双面光照；网格按 `geometry.height` 预缩放 | `procedural_meshes.dart` / `scene_from_world.dart` / `buoyancy_scene_painter.dart` |

---

## 视觉判定（本轮）

| 项 | 判定 |
|---|---|
| 池外轨道 | `[布局已对齐]` — 锚点与原版 `maxX + MARGIN_SMALL` 一致 |
| Lab 烧杯 | `[原版资源一致]` 图标；`[动态绘制已对齐]` 烧杯/刻度/秤读数结构 |
| Shapes 手风琴 | `[布局已对齐]` — 展开内容可滚动可见 |
| Applications 瓶 | `[布局已对齐]` 横躺；`[动态绘制已对齐]` 半透明塑料（非黑影）。未接原版 clip-plane / Phong 多层材质 |
| Applications 船 | `[动态绘制已对齐]` 铝灰实体色。未接完整金属贴图 UV |

---

## 未做 / 已知非阻塞

- 瓶：无 `BottleView` 上下裁剪半透 + 独立红盖几何 + 内液面 Phong
- 船：无完整 JPEG UV / cabin 水位折射级渲染
- Fluid Displaced / % Submerged 等 overlay 仍依赖局部 ticker 或交互刷新（烧杯已自带 ticker）

---

## 关键文件（本轮）

- `lib/buoyancy/shared/widgets/buoyancy_pool_scale_height_control.dart`
- `lib/buoyancy/shared/widgets/buoyancy_fluid_displaced_panel.dart`
- `lib/buoyancy/{compare,explore,lab,shapes,applications}/view/*_screen.dart`
- `lib/buoyancy/rendering/mesh/procedural_meshes.dart`
- `lib/buoyancy/rendering/primitives/{scene_from_world,buoyancy_scene_painter}.dart`
- `lib/buoyancy/rendering/texture/buoyancy_texture_asset.dart`
- `lib/buoyancy/applications/composer/applications_composer.dart`
- `assets/buoyancy/images/fluid_displaced_scale_icon.png`
- `requirements/req-buoyancy/LAB_SHAPES_APPS_VISUAL_GAP.md`

---

## 结论

**P1 Visual Polish：CLOSED。**  
用户验收点（池外轨道、Lab 烧杯、Shapes 展开可读、Applications 瓶横躺非黑）已落地；剩余为渲染保真度增强，不阻塞本轮收尾。
