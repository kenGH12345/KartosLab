# PHASE 0 REPORT — Membrane Transport Source Archaeology

## PHASE 0 STATUS

**Scope:** 完整解析本地 PhET Membrane Transport 源码结构、Screens、Model、Assets、随机性、Reset、功能清单；产出 SOURCE_MAP / FUNCTION_MAP / NUMERICAL_MODEL / RESET_SEMANTICS / VISUAL_ASSET_AUDIT / RISK_REGISTER / COMPONENT_MAP stub / LAYOUT_SPEC stub。未写 Flutter UI / 未拷贝 assets。

---

| Gate | Result |
|------|--------|
| Source Audit | **PASS** |
| Model（考古） | **PASS**（实现 NOT STARTED） |
| Views（考古） | **PASS** |
| Layout Archaeology | **NOT STARTED**（仅常量种子） |
| Layout Spec | **STUB** |
| Composer | **NOT STARTED** |
| Assets（清单） | **PASS**（拷贝 PENDING） |
| Function Map | **PASS** |
| Behavior | **NOT STARTED** |
| Responsive | **NOT STARTED** |
| Hitbox | **NOT STARTED** |
| Lifecycle | **NOT STARTED** |
| Performance | **NOT STARTED** |
| Memory | **NOT STARTED** |
| Golden | **0 / N** |
| Golden Determinism | **NOT STARTED** |
| Tests | Previous: 0 · Added: 0 · Final: 0 |
| Analyze | N/A |
| P0 | 0（代码未写；风险见 RISK_REGISTER） |
| P1 | 0 |
| P2 | 0 |
| Android Runtime | **NOT VERIFIED** |
| Home | **NOT STARTED** |
| **Status** | **NOT READY** |

---

## Key Findings

1. **4 Screens**，每屏 **独立** `MembraneTransportModel(featureSet)` — 禁止 singleton。  
2. **FeatureSet** 控制溶质/蛋白/电压/配体，而非 Screen 子类化。  
3. Observation **534×400**；模型宽 **200**；膜 y∈[-10,10]。  
4. 粒子/蛋白/细胞：**原版 SVG**；磷脂：**程序 Canvas**。  
5. 随机：`dotRandom` + 梯度偏置 0.1 / 0.9；气体近平衡 P=0.90。  
6. Reset All ≠ Eraser；Ligands **reset 不销毁实例**。  
7. **无**时间 Step 按钮；Speed 仅 Normal/Slow。  
8. Audio 27 MP3；a11y/键盘体系完整（后续分期实现，不可伪造快捷键）。  

## Artifacts

```
requirements/req-membrane-transport/
  meta.yaml
  process.txt
  SOURCE_MAP.md
  FUNCTION_MAP.md
  NUMERICAL_MODEL.md
  RESET_SEMANTICS.md
  VISUAL_ASSET_AUDIT.md
  RISK_REGISTER.md
  COMPONENT_MAP.md
  LAYOUT_SPEC.md          (stub)
  visual-qa/screen*_ref.png
  PHASE_0_REPORT.md
```

## Next

**PHASE 1** — 完成 Layout Archaeology（LAYOUT_SPEC PASS）+ 蛋白状态机深挖补全 NUMERICAL_MODEL。  
然后 **PHASE 2** — Core Model（无 UI）+ seeded RNG + 单测。
