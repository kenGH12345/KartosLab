# 实机问题 #1–#16 收口报告

**状态：** 清单内 16 条均已关闭（用户按条实机确认后进入下一项）  
**日期：** 2026-10-04 → 2026-10-05  
**范围：** Home 已接入、面向用户的 PhET Flutter 移植页；不覆盖尚未列入本清单的其他 sim  
**原则：** 原版 asset / Scenery 几何优先（规则 85）；Reset All 一律 `KratosResetAllButton`（规则 86）；逐条修改、不并行开下一项；避免整包冷启动撑爆内存

---

## 1. 结论

这 16 条是一次**实机观感 / 交互**专项，不是新 sim 立项。每条都对照原版 PhET 源码或官方资源改 Flutter，用户在真机上看过后再关项。

**重点标记：** 清单里明确要求重点跟踪的是 **#13 构建原子核**。后续把差距较大的 **#7 开普勒、#9 Waves Intro、#11 Gases Intro、#12 Gas Properties** 也按重点处理。上述标记均已在用户确认后去掉。收口时**没有仍挂重点标记的项目**。

未纳入本清单、未在本轮开工的内容（例如笔记功能）保持现状，代码未写死笔记入口。

---

## 2. 逐条结果

| # | Sim | 原问题 | 处理要点 | 关闭 |
|---|---|---|---|---|
| 1 | Forces and Motion · Net Force | 小人应拉**绳结**，与原版一致 | `Puller` 按 `standOffsetX` / `dragOffsetX` 锚定 knot；姿势随是否拉动切换；占用同一 knot 会挤走同队小人 | 已关 |
| 2 | Masses and Springs · Basics | 秤砣要用原版图 | 使用原版 mass / hanger 资源，禁止 Material 替代 | 已关 |
| 3 | Projectile Motion | 大炮高度调整卡顿 | 高度拖动手感连续化，去掉台阶感 | 已关 |
| 4 | Density | 方块要用原版贴图 | 原版材料 JPEG / 纹理走 `CuboidPainter`，不重画「差不多」的块 | 已关 |
| 5 | Capacitor Lab · Basics | 改线路要**拖动 + 点击**都能切 | `switch_gesture_layer`：触点 tap 切换，刀片 pan 拖动；二者可同指针路径共存 | 已关 |
| 6 | Ohm's Law | 电阻图画不全 | 按 `WireBox` 电阻几何与透视完整绘制，对齐原版可视范围 | 已关 |
| 7 | Kepler’s Laws | 与原版差距大，需先解析再改 | 轨道 / 扫面积 / 周期 / 矢量 / 时间控件按原版 ScreenView 重对齐；用户确认后去掉重点标记 | 已关 |
| 8 | Gravity and Orbits | Moon 轨迹应与地球不同色，可用原版紫 | `GaoBody.pathColor`：Moon 轨迹紫色，地球仍用地球色 | 已关 |
| 9 | Waves Intro | 观感差；切页 / 点击卡 | 布局与控件对齐原版；切 tab 避免整树闪白；用户确认后去掉重点标记（用户曾说「不用改了」后只收卡顿） | 已关 |
| 10 | Wave on a String | 蓝色还原钮难看 | `WoasRestartButton`：scenery-phet `RestartUndoButton` 浅蓝立体钮，不用 Material refresh | 已关 |
| 11 | Gases Intro | 控件非原版、功能不全 | 仪器 / 播放区 / 时间控件对齐 scenery-phet；用户确认后去掉重点标记 | 已关 |
| 12 | Gas Properties | 应与 Gases Intro **共用**控件族 | Ideal 家族壳层、拖拽、时间控件与 Intro 同源思路；用户确认后去掉重点标记 | 已关 |
| 13 | 构建原子核 | 比例不对、缺图；**重点标记** | Decay 等屏 FittedBox / 锚点对齐原版；缺图补原版 asset（剪刀等走 PNG）；用户确认比例接近后关项 | 已关 |
| 14 | 同位素与原子质量 | 秤上文字被挡；Mix 拖球；黄橡皮 | 读数叠在原子**前面**；Mix 拖球扩大命中并走 Listener 包裹（对齐 Build an Atom）；橡皮 = `BUTTON_YELLOW` + 原版 `eraser.svg` | 已关 |
| 15 | 搭建分子 | 原子要点进画布；要用原版原子 | 无原子 PNG（nitroglycerin `AtomNode` = `ShadedSphereNode`）；按下离碗、**松在画布才入 play**；点击回碗；Your Molecules 刷新钮 = `RefreshButton` + `syncShape`，橙色立体矩形，禁用 Material `Icons.refresh` | 已关 |
| 16 | Molecule Polarity | 拖动卡；E 场极板被面板挡 | 角度指数阻尼（指针设目标、60fps 跟随，松手 5° snap）；极板按 `PlateNode`：左负右正、外侧厚度、空心 +/−，中心对齐分子，右板在 View 面板左侧 | 已关 |

---

## 3. 本轮特别对齐的原版语义

| 主题 | 原版依据 | Flutter |
|---|---|---|
| BAM 桶拖拽 | 拖到 play，不是 tap 生成 | `startDragFromBucket` 不立刻 `addAtomToPlay`；`containsGlobal` 才落下 |
| BAM 刷新 | `CollectionAreaNode` `RefreshButton`（`Color.ORANGE`，`syncShape`，iconHeight 20） | `_BamCollectionRefreshButton` |
| MP 极板 | `PlatesNode` + `PlateNode` + `PolarityIndicator`（无 PNG） | `PlatesPainter` 几何重建 |
| MP 旋转 | 拖时跟手、量化在松手 | `angleDragLambda` + 时钟平滑 |
| CLB 开关 | ConnectionNode 点击 + 刀片拖动 | 同一层 tap / pan |
| Reset All | scenery-phet 橙球 | 各屏 `KratosResetAllButton`（本轮未再引入 Material refresh 冒充 Reset All） |

---

## 4. 测试与验证

- 各条在改动后跑过相关 **widget / model** 测试（例如 BAM `bam_bucket_drag_test`：点桶不生成、拖入画布才入场；MP `molecule_polarity` 全套含极板右缘 < View 面板）。
- **真机**由用户按条确认；模拟器截图不能替代本清单的关闭条件。
- 内存：按条加载对应 sim，避免一次拉起整个 Home 全目录。

---

## 5. 明确不做 / 仍开放

- **笔记功能**：本轮不接线、不写死占位 API。
- **本清单外的 sim**：未审计、未改。
- **#9**：中途按用户指示停止「大改对齐」，只收切页卡顿后再关项。
- Git：**未因本清单自动 commit / push**（需你另行要求）。

---

## 6. 主要代码落点（便于复查）

| # | 代表路径 |
|---|---|
| 1 | `lib/forces/screens/net_force_screen.dart` · `model/net_force_model.dart` |
| 2 | `lib/masses_and_springs_basics/` |
| 3 | `lib/projectile_motion/` |
| 4 | `lib/density/view/painters/cuboid_painter.dart` |
| 5 | `lib/capacitor_lab_basics/common/widgets/switch_gesture_layer.dart` |
| 6 | `lib/ohms_law/view/wire_box.dart` |
| 7 | `lib/astronomy/keplers_laws/` |
| 8 | `lib/astronomy/gravity_and_orbits/model/gao_body.dart` · `painters/path_painter.dart` |
| 9 | `lib/waves_intro/` |
| 10 | `lib/wave_on_a_string/view/controls/woas_time_controls.dart` |
| 11 | `lib/gases_intro/` |
| 12 | `lib/gas_properties/` |
| 13 | `lib/chemistry/build_a_nucleus/` |
| 14 | `lib/chemistry/isotopes_and_atomic_mass/` |
| 15 | `lib/chemistry/build_a_molecule/` |
| 16 | `lib/chemistry/molecule_polarity/` |

原始用户清单备份：`_tmp_issues.txt`。

---

## 7. 一句话给后续

用户可见的这 16 个实机缺陷已按原版交互与资源关完；若再开新一轮，应另列清单，不要假设本报告覆盖整个 KartosLab 仓库。
