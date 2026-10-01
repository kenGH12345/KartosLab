# notes

- `doc/model.md` 摩擦方程不完整。实现以 `Pendulum.js` `frictionTerm` 为准（线性 + ω|ω| 二次）。
- Earth g 用 9.8（PhysicalConstants.GRAVITY_ON_EARTH），不是文档 9.81。
- JS `angle % TWO_PI` 必须用 Dart `remainder`，不能用 `%`。
- 1.007 时间偏置保留。
- 尺子/周期迹/秒表不上抽 L0（与 MASB shared-abstraction 一致）。
