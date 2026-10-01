# POST_PHASE11 VISUAL REMEDIATION REPORT

```
POST-PHASE-11 VISUAL REMEDIATION STATUS

Scope:
Spin particle/SG visual + Bloch Sphere layout/functionality
alignment to PhET source (post Phase 11 release gate)

Date:
2026-09-30 19:07

Overall:
PASS (visual remediation closed for Spin + Bloch)
```

---

## 1. Summary

Phase 11 产品门关闭后，按用户原版截图与 PhET 源码，完成 **Spin** 与 **Bloch Sphere** 两屏视觉/交互补齐。不改动 Model 测量语义与 RNG 契约；Reset All 仍走 `KratosResetAllButton`。

| Screen | Verdict | Notes |
|---|---|---|
| Spin | **PASS** | 完整 SGz、箱内粒子隐藏、平滑改道、布局对齐 |
| Bloch Sphere | **PASS** | 原版测量区结构：方程+Basis / Atom 舱 / T 直方图 / 橡皮 / Aqua 控件 |
| Coins / Photons | 先前轮次已修 | 本轮未再改 |

---

## 2. Spin（第三屏）

### 2.1 对照源码

| Item | PhET | Flutter |
|---|---|---|
| SG 装饰曲线 | `SternGerlachNode` cyan Path | `_SgPainter` 恢复上下二次曲线 |
| 粒子进箱 | `entrance → entrance+SG_WIDTH` 后改道 | **箱内不可见**，沿同二次曲线隐式穿箱后出口出现 |
| 速度 | `speed=1` 常量 | 箱外 `1.0`；箱内隐式穿越 `sgTransitSpeed=0.38` |
| Source 标签 | 装置上方 | `Spin-1/2 Source` 移到 body 上方 |
| MD 居中 | `MeasurementDeviceNode.center` | `mdCenterOffsetY=111` |
| MVT origin Y | experimentArea 内容驱动 | `measurementOrigin.y=360` |

### 2.2 关键文件

- `lib/quantum_measurement/spin/components/stern_gerlach_apparatus.dart`
- `lib/quantum_measurement/spin/animation/spin_particle_simulation.dart`
- `lib/quantum_measurement/spin/components/spin_particle_renderer.dart`（`visible`）
- `lib/quantum_measurement/spin/components/spin_source.dart`
- `lib/quantum_measurement/spin/view/spin_scene.dart`
- `lib/quantum_measurement/spin/composer/spin_composer.dart`

### 2.3 视觉判定

- `[原版资源一致]` SGz 黑盒 + 蓝分叉 + 孔 + 标签完整绘制  
- `[布局已对齐]` Source / SG / MD 相对关系对齐原版 Experiment 1  
- `[动态绘制已对齐]` 粒子入口消失 → 出口平滑飞出，无箱心瞬移  

---

## 3. Bloch Sphere（第四屏）

### 3.1 对照源码 / 原版截图

| Item | PhET (`BlochSphereMeasurementArea`) | Flutter（本轮前） | Flutter（本轮后） |
|---|---|---|---|
| 「Measurement」标题 | 无 | 有 | **已移除** |
| 方程 + Basis X/Y/Z | Panel + Aqua | 仅紧凑方程 | **`BlochMeasureEquationPanel`** |
| 数值方程随 Basis | `BlochSphereNumericalEquationNode` | 固定 Z | **系数/下标随 Basis** |
| Atom 舱 | `SystemUnderTestNode` 高舱 | 小扁框 | **`BlochSystemUnderTest` 150×160** |
| ×10 Atoms 栅格 | 3/2/3/2 | 无 | **舱内多球** |
| 直方图 | T 轴 + ket 标签 | 简陋双柱 | **`BlochHistogramPainter` 200×160** |
| Erase | 黄 `EraserButton` | 文字 Erase | **黄橡皮 glyph** |
| Number of Atoms | Aqua + 红球 + ×1/×10 | ChoiceChip | **Aqua + 红球** |
| Spin Measurement Axis | Aqua X/Y/Z | ChoiceChip | **Aqua** |
| Magnetic Field | Atom 下方勾选；强度旁侧 | 底部混排 | **Atom 下勾选 + 旁侧强度面板** |
| Observe / Reprepare / Start | 状态色按钮 | 已有 | 保留 |

### 3.2 关键文件

- `lib/quantum_measurement/bloch_sphere/components/bloch_state_equation.dart`
- `lib/quantum_measurement/bloch_sphere/components/measurement_controls.dart`
- `lib/quantum_measurement/bloch_sphere/view/bloch_scene.dart`
- `lib/quantum_measurement/bloch_sphere/composer/bloch_composer.dart`

### 3.3 视觉判定

- `[布局已对齐]` prep | divider | 测量（方程→球→Atom→B场 / 右栏控件）  
- `[原版资源一致]` 程序化球/红原子/直方图；无 Material Icons 冒充  
- `[动态绘制已对齐]` Observe 塌缩、Erase 清计数、B 场进动路径未改 Model  

---

## 4. Verification

| Check | Result |
|---|---|
| `dart analyze` spin + bloch_sphere | **No issues** |
| `bloch_sphere_model_test` + `bloch_phase6_test` | **33 PASS** |
| Model / RNG / Golden baseline | **未改契约**；Golden PNG 未重录（视觉增量，建议择机刷新） |

---

## 5. Known / Non-blocking

1. Bloch Golden 截图未在本轮重录（布局变更后建议下一轮 golden update）  
2. Photons Fine-tune（若仍有像素级偏差）不在本轮范围  
3. Phase 11 已知非阻塞项（a11y sparse / audio N/A / SVG style）不变  

---

## 6. Closing

```
Spin visual:           PASS
Bloch visual:          PASS
Product status:        READY WITH KNOWN NON-BLOCKING RISKS (unchanged from PHASE 11)
Visual remediation:    CLOSED for Spin + Bloch
```

Report path: `requirements/req-quantum-measurement/POST_PHASE11_VISUAL_REMEDIATION_REPORT.md`
