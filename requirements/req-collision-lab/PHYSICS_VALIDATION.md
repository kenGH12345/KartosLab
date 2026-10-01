# PHYSICS_VALIDATION · Collision Lab

> 日期：2026-09-03  
> 本地源码：`1.2.0-dev.0`  
> 测试：`test/collision_lab/physics_test.dart` → **12 passed**

---

## 守恒量策略（对照源码）

| 场景 | 动量 | 动能 | 角动量 | 标记 |
|---|---|---|---|---|
| 球-球 e=100% | 守恒 | 守恒 | — | **[物理一致]** |
| 球-球 e&lt;100% | 守恒 | 不守恒 | — | **[源码一致]** |
| 球-边 reflecting | **不守恒**（外力） | 随 e | — | **[源码一致]** · 测试断言动量变化 |
| Explore1D e=0 分组 | 组内共速 | 损失 | — | **[物理一致]** |
| Inelastic STICK | COM 速度守恒 | 损失 | L→ω | **[物理一致]** · cluster≠null ∧ ω≠0 |
| Inelastic SLIP | 走基类 e=0 法向 | 损失 | 无 cluster | **[源码一致]** |

---

## 公式抽检

| 项 | 结果 |
|---|---|
| `handleBallToBallCollision` vs PhET 法向公式 | ✅ 单测逐分量 |
| `calculateBallRadius` 球体密度 | ✅ m/V ≈ 35 |
| Constant radius 0.15 | ✅ |
| 负步进 elapsed≥0 | ✅ |
| Restart vs Reset | ✅ |
| Grid snap 0.1 / 1D y=0 | ✅ |

---

## 未覆盖（记录）

- 同时多碰撞同时间戳分支（引擎支持，无专项单测）
- cluster-to-border 完整 bisection 数值精度
- Intro Δp opacity 时间线端到端 UI 测试
- Paths lifetime 裁剪单测

均不阻塞交付；属增强项。
