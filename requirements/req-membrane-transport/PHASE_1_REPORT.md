# PHASE 1 REPORT — Layout Archaeology + Protein FSM

## PHASE 1 STATUS

**Scope:** 完成 Layout Archaeology（DESIGN 768×504 公式、Root Regions、MVT、相对约束）；深挖 8 类运输蛋白状态机并写入 NUMERICAL_MODEL §6。未写 Flutter UI。

---

| Gate | Result |
|------|--------|
| Source Audit | PASS (Phase 0) |
| Model（考古+蛋白 FSM） | **PASS** |
| Views（考古） | PASS |
| Layout Archaeology | **PASS** |
| Layout Spec | **PASS** |
| Composer | **NOT STARTED** |
| Assets | PASS inventory / copy PENDING |
| Function | PASS map / impl NOT STARTED |
| Behavior | NOT STARTED |
| Responsive | SPEC READY（Uniform Scale） |
| Hitbox | SPEC NOTES READY |
| Lifecycle | NOT STARTED |
| Performance | NOT STARTED |
| Memory | NOT STARTED |
| Golden | 0 / N |
| Golden Determinism | NOT STARTED |
| Tests | 0 |
| Analyze | N/A |
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| Android Runtime | NOT VERIFIED |
| Home | NOT STARTED |
| **Status** | **NOT READY** |

---

## Deliverables

| File | Change |
|------|--------|
| `LAYOUT_SPEC.md` | Stub → **完整 PASS**（公式/比率/Z-order/分屏变体） |
| `NUMERICAL_MODEL.md` §6 | 蛋白 FSM 全表（Leakage / Voltage / Ligand / Pump / Cotransporter） |
| `PHASE_1_REPORT.md` | 本报告 |
| `meta.yaml` / `process.txt` | 阶段推进 |

---

## Layout Highlights

- Design：**768×504**；Observation：**534×400 @ (117, 8)**  
- MVT scale **2.67**；膜中心 screen **(384, 208)**  
- Slots X：`[-84,-56,-28,0,28,56,84]`  
- Composer 公式见 LAYOUT_SPEC §6  

## Protein Highlights

- Voltage：−70 双关；−50 仅 Na 开；+30 仅 K 开；延迟 **0.25s**  
- Ligand：5s 重绑冷却；15s 结合；0.5s 构象延迟  
- Pump：3 Na out / 2 K in + ATP 水解  
- Cotransporter：需外侧 Na 更高；2 Na + 1 glucose 向内  

## Next

**PHASE 2 — Core Model**（无 UI）：

1. Seeded RNG  
2. `MembraneTransportModel` + Particle FSM + FeatureSet  
3. Protein state machines  
4. Unit tests（梯度偏置、reset≠eraser、电压门延迟、泵循环）  

然后 PHASE 3 — Primary Screen（建议 **Simple Diffusion**）+ LayoutComposer + 原版 assets。
