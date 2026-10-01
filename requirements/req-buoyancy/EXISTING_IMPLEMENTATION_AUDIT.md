# Existing KartosLab Implementation Audit

搜索 `lib/` 的 buoyancy、density、fluid、Archimedes。没有 `lib/buoyancy`。没有 `requirements/req-buoyancy`（本文件创建之前）。Home 未改。

| Location | What it is | Decision |
| --- | --- | --- |
| `lib/density/**` | 已完成的 Density 模拟，`req-density` status done。对应 `density_all.html`，不是 Buoyancy | REFERENCE ONLY |
| `lib/density/solver/buoyancy_world.dart` | Density 用的重力+浮力+接触+指针弹簧。注释写 pointer spring-damper，`pointerStiffness = 180`。PhET Buoyancy 的拖拽是 p2 `RevoluteConstraint`，maxForce 2500 | REFERENCE ONLY。禁止当 Buoyancy 真源。禁止为了省事直接搬过来 |
| `lib/density/density_constants.dart` `density_colors.dart` `density_mvt.dart` | 从 common 抄过的常量、颜色、屏障 | ADAPT 只在逐项对照本次 common 源码之后。数值冲突时以本次 `density-buoyancy-common-main` 为准 |
| `lib/density/view/painters/pool_painter.dart` `cuboid_painter.dart` | Density 的 2D/伪 3D 绘制。Buoyancy 视图是 THREE + 不同相机 lookAt `(0, -0.18, 0)` | REFERENCE ONLY |
| `requirements/req-density/**` | Density 的 screen map 明确写了“不机械套用 Buoyancy 的流体切换 / 力矢量 / 船瓶” | IGNORE 作为 Buoyancy 规格 |
| Under Pressure（`lib` 中 `UnderPressureHome`，`req-port-under-pressure`） | 流体压强，另一模拟 | IGNORE |
| Home 分组「密度与浮力」 | 现有卡片是「密度」和 Under Pressure | IGNORE until Home phase。PHASE 0 不添加卡片 |
| `phet sourses/density-buoyancy-common-main` | 本次 Buoyancy 的共享真源，也被 Density 用过。SHA 是 `0c835c64`，不是 buoyancy lockfile 的 `0295f8f6` | 这是源码，不是 Flutter 实现。不要再克隆第二份 common |
| `phet sourses/buoyancy-main` | 本次壳仓库 | 真源壳 |

## Shared domain decision

KartosLab 没有一份已经正确的 “density / buoyancy shared Flutter model”。`BuoyancyWorld` 是 Density 的近似。

结论：**parallel migration**。Buoyancy 按本地 PhET 源码新建领域模型。以后若要和 Density 共用池几何或材质表，只能抽取双方都与源码一致的常量，不能把旧 solver 的弹簧系数、粘滞 `8.0` 带进 Buoyancy。

Density 的 `req-density` 约束“不修改其它已完成 simulation”仍然有效。Buoyancy 的 PHASE 1+ 不得改 `lib/density` 来凑浮力。
