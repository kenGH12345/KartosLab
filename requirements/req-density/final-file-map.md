# Density Final File Map

> Loop 11 · 2026-09-02 · `lib/density/` + `assets/density/` + `test/density/`

## lib/density/

| 文件 | 用途 | 层 | 核心 | 测试 |
|---|---|---|---|---|
| `density_constants.dart` | 物理/单位常量 | Data | ✓ | indirect |
| `density_colors.dart` | PhET 色板 ARGB | Data | ✓ | — |
| `density_strings.dart` | 英文字符串 + About | Data | ✓ | widget |
| **model/** | | | | |
| `density_block.dart` | 立方体实体（materialId/volume/pos/vel） | Model | ✓ | ✓ |
| `density_material.dart` | 材料表 + mysteryTableMaterials | Model | ✓ | ✓ |
| `density_vec.dart` | 2D 向量 | Model | ✓ | ✓ |
| `intro_state.dart` | Intro 屏状态 | Model | ✓ | ✓ |
| `compare_state.dart` | Compare 三 set 预分配 | Model | ✓ | ✓ |
| `mystery_state.dart` | Mystery set/table/labels | Model | ✓ | ✓ |
| **solver/** | | | | |
| `density_relation.dart` | mass/volume/density SSOT | Solver | ✓ | ✓ |
| `compare_constraint.dart` | Same Mass/Volume/Density 数据 | Solver | ✓ | ✓ |
| `mass_layout.dart` | 块初始摆放 | Solver | ✓ | partial |
| `buoyancy_world.dart` | 重力/浮力/碰撞/指针弹簧 | Solver | ✓ | ✓ |
| **controller/** | | | | |
| `density_controller.dart` | 交互/tick/renderData | Controller | ✓ | partial |
| **interaction/** | | | | |
| `pointer_drag.dart` | 命中/抓取偏移 | Interaction | ✓ | partial |
| **data/** | | | | |
| `mystery_sets.dart` | Set1/2/3/Random + DensityTable | Data | ✓ | ✓ |
| `density_texture_cache.dart` | JPEG 预加载/缓存/dispose | Data | ✓ | widget |
| **render/** | | | | |
| `density_mvt.dart` | World↔Screen + 池边界 | Render | ✓ | ✓ |
| `density_render_data.dart` | Painter DTO | Render | ✓ | ✓ |
| **view/** | | | | |
| `screens/density_home.dart` | Ticker + Tab 入口 | View | ✓ | widget |
| `screens/introduction_screen.dart` | Intro NineGrid | View | ✓ | widget |
| `screens/compare_screen.dart` | Compare NineGrid | View | ✓ | widget |
| `screens/mystery_screen.dart` | Mystery Stack+Table overlay | View | ✓ | widget |
| `canvas/density_canvas.dart` | 画布 + Semantics | View | ✓ | widget |
| `controls/intro_block_panel.dart` | Intro 材料/质量/体积 | View | ✓ | widget |
| `widgets/density_number_line.dart` | Intro 密度数轴 | View | ✓ | — |
| `dialogs/density_table_panel.dart` | 13 行 Accordion 表 | View | ✓ | widget |
| `dialogs/density_about_dialog.dart` | GPL/PhET 署名 | View | ✓ | — |
| `painters/pool_painter.dart` | 天空/地面/池 | Painter | ✓ | mvt |
| `painters/cuboid_painter.dart` | 立方体+贴图+标签 | Painter | ✓ | mvt |
| `painters/scale_painter.dart` | 秤 + 场景合成 | Painter | ✓ | mvt |

## assets/density/

| 文件 | 用途 | 核心 |
|---|---|---|
| `NOTICE.md` | GPL/PhET/CC0 声明 | ✓ |
| `images/materials/*.jpg` | 9 张 Intro col 贴图 | ✓ |

## test/density/

| 文件 | 覆盖 |
|---|---|
| `density_relation_test.dart` | SSOT / 材料 / Custom |
| `compare_mystery_test.dart` | Compare 三模式 + Mystery + Table |
| `stacked_drag_test.dart` | Loop 9 堆叠拖拽 |
| `stacked_drag_y_oscillation_test.dart` | Loop 10 Y 稳定 |
| `runtime_acceptance_test.dart` | Loop 8 验收 + viewport |
| `density_widget_test.dart` | 交互/Home/Table |
| `density_mvt_test.dart` | MVT + painter 不 mutate |

## 工具

| 文件 | 用途 | 保留 |
|---|---|---|
| `tool/extract_density_textures.py` | 从 PhET `*_jpg.ts` 提取 JPEG | ✓ 长期 |

## 架构结论

- **职责清晰**：Model 无 UI；Solver 纯关系函数 + BuoyancyWorld 物理（⚠️ 引用 `DensityMvt` 边界常量）
- **SSOT**：`DensityBlock.volume` + `materialId/customDensity` → `DensityRelation.massOf/densityOf`
- **Painter 不 mutate Model**：有回归测试
- **无散落 `if (set==1)` 于 Painter**
