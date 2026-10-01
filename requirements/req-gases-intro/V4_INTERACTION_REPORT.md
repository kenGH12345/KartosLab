# V4 验收报告 — Interaction / Component Behavior Reconstruction

**日期**：2026-09-06  
**阶段**：V4 完成 · **停止，不进入 V5**  
**Model / Physics / Solver**：**零修改**（View：`ViewInteractionState` + instrument widgets）

---

## A. 新增/修复组件

| 组件 | 动作 |
|---|---|
| `ParticleTypeRadioButtonGroup` | 新建 — Rectangular radio + 粒子图标（非色点） |
| Pressure / Temperature **Units ComboBoxDisplay** | 新建 — PopupMenu 切换 atm↔kPa、K↔°C |
| `ParticlesAccordionBox` | 修复 — `particlesExpanded` 默认 **false**；左侧 expand 按钮（AccordionBox 语义） |
| Lid handle drag | 新建 — 水平拖改 `lidWidth` / 开口（非活塞） |
| `GasPropertiesOopsDialog` | 新建 — phetGirlLabCoat + 英文字符串 + OK |
| Hold Constant 入口 | 修复 — 经 `requestHoldConstant` 触发 Oops |

---

## B. Source → Flutter mapping

| Source Node | Flutter | 状态 |
|---|---|---|
| `ParticleTypeRadioButtonGroup` | `ParticleTypeRadioButtonGroup` | [行为一致] |
| `PressureDisplay` ComboBoxDisplay | `_UnitsCombo` on gauge | [行为一致] |
| `TemperatureDisplay` ComboBoxDisplay | `_UnitsCombo` on thermometer | [行为一致] |
| `ParticlesAccordionBox` / AccordionBox | `ParticlesAccordionBox` + `viewState.particlesExpanded` | [行为一致] |
| `LidNode` + `LidDragListener` | lid hit + `setLidWidthFromOpeningLeft` | [行为一致] |
| Left-wall `HandleNode` | 既有 left-wall drag | [行为一致]（非活塞） |
| `GasPropertiesOopsDialog` | `GasPropertiesOopsDialog` + asset | [行为一致] 文案；icon [源码一致] |
| Model `oopsEmitters` | View 从 hold/N/T 推断 | [有意差异] 无 Emitter API |

---

## C. Interaction mapping

| Interaction | Flow |
|---|---|
| Particle type | Tap radio → `model.setParticleType` → pump color / inject type |
| Pressure units | Popup → `viewState.pressureUnits` → label 格式（针仍用 kPa） |
| Temperature units | Popup → `viewState.temperatureUnits` → label（柱仍用 K） |
| Accordion | Expand button → `particlesExpanded` → show/hide Fine/Coarse |
| Lid drag | Pointer → openingLeft model X → `container.lidWidth` → rebuild |
| Wall resize | 既有 begin/setWidth/end |
| Oops | Hold 拒绝 / max-T 清空 / pressureV 越界 → modal → OK dismiss |

---

## D. State binding

| State | Owner | Reset |
|---|---|---|
| particleType | Model | model.reset → heavy |
| pressureUnits / temperatureUnits | ViewInteractionState | atmospheres / kelvin |
| particlesExpanded | ViewInteractionState | **false**（源码默认） |
| lidWidth | Container（公共字段） | model.reset |
| pendingOopsMessage | ViewInteractionState | cleared |
| Stopwatch / CC | ToolsController | V3 既有 |

---

## E. Reset behavior

`_resetAll` → `model.reset()` + `tools.reset()` + `viewState.reset()`  
→ 单位、accordion、oops、粒子类型、盖宽、工具位均回源码默认。

---

## F. V1/V2/V3 regression

| 层 | 结果 |
|---|---|
| V1 泵/墙/热/Hold/checkbox/±1±50/assets | **保留** |
| V2 Anchor Stack / MVT | **未推翻** |
| V3 Stopwatch / CollisionCounter 拖动 | **保留** |
| 功能回退 | **无** |

---

## G. 测试结果

```
flutter test test/gases_intro  → 18 passed
flutter analyze lib/gases_intro → 0 issues
```

---

## H. 当前视觉问题

| 项 | 状态 |
|---|---|
| Radio / ComboBox / Oops 非 scenery 像素级 | [有意差异] — **非** [视觉已对齐] |
| Lid grip 几何 vs LidNode HandleNode | [待确认] |
| Gauge+combo / Thermo+combo 锚点微调 | [待确认] |

---

## I. 当前剩余功能问题

| 项 | 状态 |
|---|---|
| Oops 依赖 View 推断而非 model.oopsEmitters | [有意差异]（Model 冻结） |
| Lid 飞出动画（blow off spin） | [待实现] |
| ComboBox listboxParent 置顶层 | [有意差异] PopupMenu |
| V5 responsive / overflow | [待实现] |

---

**状态**：`v4_interaction_restored` · 等待确认后再开 V5。
