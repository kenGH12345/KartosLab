# PHASE 2 — Model + Physics Report · Projectile Motion

## 实现文件

| 文件 | 对应源码 |
|---|---|
| `lib/projectile_motion/pm_constants.dart` | ProjectileMotionConstants.ts + CannonNode/Target/DataProbe 常量 |
| `lib/projectile_motion/pm_strings.dart` | projectile-motion-strings_en.json |
| `lib/projectile_motion/model/data_point.dart` | DataPoint.ts |
| `lib/projectile_motion/model/trajectory.dart` | Trajectory.ts（积分/阻力/落地/apex/vx 保护逐行对照） |
| `lib/projectile_motion/model/projectile_object_type.dart` | ProjectileObjectType.ts（10 预设 + clone 防跨屏污染） |
| `lib/projectile_motion/model/target.dart` | Target.ts（3/2/1 星） |
| `lib/projectile_motion/model/measuring_tape.dart` | ProjectileMotionMeasuringTape.ts |
| `lib/projectile_motion/model/data_probe.dart` | DataProbe.ts（可读点规则 + 传感半径 0.2m/zoom） |
| `lib/projectile_motion/model/projectile_motion_model.dart` | ProjectileMotionModel.ts（accumulator 恒定 dt、fire/erase/limit/reset、NASA 空气密度） |
| `lib/projectile_motion/model/screen_models.dart` | Intro/Vectors/Drag/LabModel（默认值为源码值） |
| `lib/projectile_motion/controller/projectile_motion_controller.dart` | SimulationClock 桥接 + ViewProperties（含 VectorsDisplayEnumeration 语义） |
| `lib/projectile_motion/transform/pm_transform.dart` | ModelViewTransform2 invertedY，origin (70,510)，30px/m×zoom |

## 关键实现决策

1. **恒定 dt = 0.012s accumulator**（等价 EventTimer(ConstantEventModel(1000/12))），慢放墙钟 ×0.33 —— 不用解析公式。
2. **发射点 (0, cannonHeight)**，炮管 4m 仅用于视图（Trajectory:168 / CannonNode:48）。
3. **无 Projectile 类**：`PmTrajectory.currentPoint` 即抛体当前状态，轨迹与抛体天然同步（满足 §12 约束）。
4. 物体类型 `clone()` 工厂：Lab 屏编辑会写回类型（LabModel:53-62），静态预设必须每次实例化隔离。
5. `numberOfMovingProjectiles` 由轨迹列表重算（单一事实来源），发射后即时更新。
6. Lab `syncEditsToObjectType` + `resetObjectTypes()` hook 对应 LabModel reset 语义。

## 测试证据

`test/projectile_motion/projectile_motion_physics_test.dart`：**17/17 PASS**（2026-09-14）

覆盖：PHY-1..9（含真空解析锚点 1% 容差：range≈11.30m / t≈3.614s / apex≈16.01m）、二次阻力单调减程、NASA 密度（海平面≈1.225）、落地精确截断、apex 插值、vx 反号保护、目标星级、SEM-1..3、FIRE-1/2/4、四屏默认值、accumulator 慢放、暂停不步进。

## 偏差记录

- Stats 屏不迁移（原版默认入口未挂入）。
- PhET-iO / Tandem 无对应物，省略。
- `getRandomizedValue` σ 仅 Stats 使用，不迁移。
