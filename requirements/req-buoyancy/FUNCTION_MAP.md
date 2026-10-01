# Function Map

证据列是本地文件。动画列只记录源码里真正存在的时间演化。没有源码的 ease/bounce 写成 NONE。

| Screen | Feature | User Action | Model | View | Animation | Reset | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| All | 进入模拟 | 启动 | `simLauncher.launch` → `new Sim([5 screens])` → `sim.start()` | 第一屏 Compare | NONE | n/a | `buoyancy-main.ts` | AUDITED |
| All | 步进 | 时间流逝 | `DensityBuoyancyModel.step(dt)` → `engine.step(dt)` → 每个 mass.step | 读插值后的矩阵与液面 | 物理时间，不是 AnimationController | n/a | `DensityBuoyancyModel.ts` `step` | AUDITED |
| All | 重力 | 自动 | `F_g = (0, -m * g)` 在 postStep 施加 | 箭头可选 | 物理 | gravity reset | 同文件 postStep | AUDITED |
| All | 浮力 | 物体与液面相交 | `F_b = (0, ρ_fluid * V_sub * (g + a_extra))` | 箭头可选 | 物理 | 力插值 reset | 同文件 | AUDITED |
| All | 粘滞 | 浸没时 | 与速度反向，上限 `m * v / dt` | 无独立箭头 | 物理阻尼 | n/a | 同文件 | AUDITED |
| All | 接触 | 与地面、池壁、其他物体 | p2 contact，restitution 0 | 只画接触力的 y | 物理 | n/a | `PhysicsEngine.ts` | AUDITED |
| All | 抓取 | pointer down 在质量上 | `startDrag`：y+=0.0001，RevoluteConstraint maxForce 2500 | 手型光标。射线选物体 | 约束力，物理继续 | userControlled reset | `Mass.ts`，`BackgroundEventTargetListener` | AUDITED |
| All | 拖动 | pointer move | `updateDrag` 改 constraint pivot | 物体被约束拉向指针 | 物理 | n/a | `PhysicsEngine.updatePointerConstraint` | AUDITED |
| All | 松开 | pointer up | `endDrag` 移除约束 | 物体按当前速度继续 | 物理沉降 | n/a | `Mass.endDrag` | AUDITED |
| All | 液位 | 物体进入池 | `updateFluid` → basin 体积 → `computeY` | `FluidMesh` + 左侧升数 | 液面瞬时水平，无波浪动画 | pool.reset | `Pool.ts`，`Basin` | AUDITED |
| All | 力显示 | 勾选 Gravity / Buoyancy / Contact | `DisplayProperties` 布尔 | `ForceDiagramNode`，`tip = -F * vectorZoom * 20` | NONE | displayProperties.reset | `ForceDiagramNode.ts:130` | AUDITED |
| All | 矢量缩放 | Vector Zoom −/+ | `vectorZoomLevelProperty` 0..7，scale = 0.5^(8-level) 待 PHASE 1 复核循环 | 箭头变长 | NONE | zoom level 回 4 | `DisplayProperties.ts` | AUDITED |
| All | 质量读数 | Mass Values | `massValuesVisibleProperty` | 物体旁 kg | NONE | 各屏默认不同 | `DisplayProperties` | AUDITED |
| All | Reset All | 按钮 | `model.reset()` + `displayProperties.reset()` | 物体回初始位姿 | NONE | 见 RESET_SEMANTICS | `DensityBuoyancyScreenView.ts:305` | AUDITED |
| Compare | 模式 | Same Mass / Volume / Density | `blockSetProperty` | 显示对应的两块，隐藏其余 | NONE | 回 Same Mass | `BlockSet`，`BlocksPanel` | AUDITED |
| Compare | 共用滑条 | 拖 Mass 或 Volume 或 Density | `massProperty` / `volumeProperty` / `densityProperty` 写到两块 custom 密度或尺寸 | 块尺寸与沉浮改变 | 随后物理沉降 | 滑条 reset | `CompareBlockSetModel.ts` | AUDITED |
| Compare | 换液体 | Combo | `fluidMaterialProperty` | 液体颜色 | 浮力下一步就变 | 回水 | `FluidSelectionPanel`，type `simple` | AUDITED |
| Explore | 一块/两块 | 图标 radio | `modeProperty` → blockB.visible | B 出现 | NONE | One Block | `BuoyancyExploreModel.ts` | AUDITED |
| Explore | 材料 | Combo | `materialProperty` | 纹理或纯色 | 质量由 ρV 立即重算，然后物理 | A wood，B aluminum | `MaterialMassVolumeControlNode` | AUDITED |
| Explore | 质量/体积 | 滑条 | 固定密度：改一个，另一个由 ρ=m/V 跟随。custom：密度派生 | 立方体边长变 | 物理 | 初始质量 2 kg 与 13.5 kg | `Mass.ts` multilink，`Cube.createWithMass` | AUDITED |
| Explore | 流体密度 | 命名液体或滑条 | custom 密度 500–15000 | 颜色随密度变亮/变暗 | 物理 | 水 | `FluidDensityPanel` | AUDITED |
| Lab | 重力 | Combo / 滑条 | `gravityProperty` 1.6 / 9.8 / 24.8 / 19.6 / custom 0.1–25 | 重力箭头、秤读数、浮力一起变 | 物理 | Earth | `Gravity.ts`，`BuoyancyLabModel` | AUDITED |
| Lab | 排开液体 | 勾选或默认展开的折叠盒 | `fluidDisplacedVolumeProperty = percent/100 * V * 1000` 升 | 量筒图与牛顿读数 | 跟随浮力 | 随块 reset | `BuoyancyLabModel.ts:68`，`doc/model.md` | AUDITED |
| Lab | 力默认开 | 进入屏 | `forcesInitiallyDisplayed: true`，质量读数 false | 箭头可见 | NONE | 回到该默认 | `BuoyancyLabScreenView.ts:43` | AUDITED |
| Shapes | 形状 | Combo | `shapeNameProperty` 切换缓存的 Mass，底边 y 对齐 | 对应 View | NONE | Block | `BuoyancyShapeModel.ts` | AUDITED |
| Shapes | 尺寸 | Height，Width & Depth | 比例 → 各形状 `getSizeFromRatios` | 网格尺度 | 体积变，质量变，然后物理 | 0.25 / 0.75 | `BuoyancyShapesModel.createMass` | AUDITED |
| Shapes | 说明 | Info | 无模型变化 | `ShapesInfoDialog` | NONE | n/a | `BuoyancyShapesScreenView.ts` | AUDITED |
| Applications | 场景 | bottle / boat radio | `applicationModeProperty` 改可见性，并按 ±秤体积改池体积 | 面板切换 | NONE | bottle | `BuoyancyApplicationsModel.ts:121` | AUDITED |
| Applications | 瓶内材料 / 空气 | Combo + Air Volume | Bottle 质量与排水覆盖 `getUpdatedMassValue` / `getUpdatedSubmergedVolume` | 瓶姿态 | 物理 | bottle.reset | `Bottle.ts`，Applications model override | AUDITED |
| Applications | 船舱进水 | 块放入船或船下沉 | 船 basin；溢出加回池；拖出池则舱水回到池 | 船内液面 | `FILL_EMPTY_MULTIPLIER = 0.3` 用于排空速度 | boat.reset | `BuoyancyApplicationsModel.ts` 常量与 `updateFluid` override | AUDITED |
| Applications | 重新浮起 | 船场景小按钮 | `resetBoatAndBlockPosition` | 船和块回初始位置，舱水清空 | NONE | 不是 Reset All | 同文件 `:150` | AUDITED |

## 正常实验路径（来自控件，不是截图推测）

Compare：选 Same Mass / Volume / Density → 调唯一滑条 → 换液体 → 把块拖进池 → 看沉浮与可选力 → 用地面秤称重 → Reset。

Explore：选材料 → 调质量和体积 → 可选第二块 → 调流体或 mystery 液体 → 拖入池 → 打开密度与浸没百分比 → Reset。

Lab：打开力（默认已开）→ 改流体密度与重力 → 看排开体积 = 浮力 / (ρ g) 的视图 → 浸没百分比 → Reset。

Shapes：选形状与材料 → 调高度和宽深 → 看体积与沉浮 → 可选第二块 → Reset。

Applications：瓶子装不同材料和空气体积；或切到船，把块放进船，观察舱水与溢出 → 沉了用 re-float → Reset All 回瓶子。

## 禁止的未来实现

用户拖动物体时，Flutter 不能把位置直接设成指针落点并跳过约束力。松开后必须继续 `step`，直到接触和浮力平衡。沉浮不能用 `AnimationController` 伪造。
