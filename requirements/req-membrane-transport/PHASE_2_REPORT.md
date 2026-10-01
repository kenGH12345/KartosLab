# PHASE 2 REPORT — Core Model

## PHASE 2 STATUS

**Scope:** 实现可注入 seeded RNG 的核心 Model（无 UI）：FeatureSet、粒子 RandomWalk/PassiveDiffusion、槽位、8 类蛋白状态机子集、Reset/Eraser、梯度偏置；单元测试覆盖。

---

| Gate | Result |
|------|--------|
| Source Audit | PASS |
| Model | **PASS** (core) |
| Views | NOT STARTED |
| Layout Spec | PASS (Phase 1) |
| Composer | NOT STARTED |
| Assets | PENDING COPY |
| Function (model subset) | **PASS** |
| Behavior (UI path) | NOT STARTED |
| Tests | **17 PASS** |
| Analyze | pending full package |
| P0 | 0 |
| P1 | 0 |
| P2 | 见下 |
| Android | NOT VERIFIED |
| Home | NOT STARTED |
| **Status** | **NOT READY** |

---

## Delivered Code

```
lib/membrane_transport/
  membrane_transport_constants.dart
  membrane_transport_feature_set.dart
  model/
    mt_random.dart          # SeededMtRandom / SystemMtRandom
    mt_vec2.dart
    solute_type.dart
    transport_protein_type.dart
    particle.dart
    particle_mode.dart      # RandomWalk / PassiveDiffusion / Waiting* / LigandBound / MovingThrough
    slot.dart
    membrane_transport_model.dart
    proteins/
      transport_protein.dart
      leakage_channel.dart
      voltage_gated_channel.dart
      ligand_gated_channel.dart
      sodium_potassium_pump.dart
      sodium_glucose_cotransporter.dart
      create_transport_protein.dart

test/membrane_transport/membrane_transport_model_test.dart  # 17 tests
```

---

## Test Coverage

| Area | Result |
|------|--------|
| FeatureSet / independent models | PASS |
| add / clear / reset semantics | PASS |
| time NOT reset; ligands retained | PASS |
| Gradient bias / near-eq | PASS |
| Seeded determinism | PASS |
| O₂ passive crossing | PASS |
| Pause freezes motion | PASS |
| Voltage gate −50 / +30 + 0.25s delay | PASS |
| Ligand bind/open/unbind FSM | PASS |
| Na/K pump ATP → ADP+Pi | PASS |
| Slot positions / capture radius=40 | PASS |

Correction vs Phase 0/1 note: **CAPTURE_RADIUS = 40**（非 20）；`height/2*4 = 20/2*4 = 40`。NUMERICAL_MODEL 已更正。

---

## P2 / Known Gaps (acceptable for Phase 2)

1. MoveTo* 中间动画模式简化为直接 Waiting / MovingThrough（捕获后瞬移口部）  
2. Cotransporter 全循环未单测（状态机已实现）  
3. Phospholipid / Canvas / Sounds / a11y 未做  
4. `MovingThrough` 尚未完整对齐 DirectionalMovementMode 的 slot 事件细节  
5. Glucose metabolism preference 仅钩子，未接 Preferences UI  

---

## Next

**PHASE 3 — Primary Screen = Simple Diffusion**

1. 拷贝原版 SVG（溶质 + cell + icons）  
2. `MembraneTransportLayoutComposer` + Observation Canvas（磷脂程序绘制 + 粒子 Image）  
3. SolutesPanel / SoluteControl / Time / Eraser / Graph / `KratosResetAllButton`  
4. 接入真实 Model；Golden 初态  

**禁止**同时开四个 Screen；先做 Simple Diffusion。
