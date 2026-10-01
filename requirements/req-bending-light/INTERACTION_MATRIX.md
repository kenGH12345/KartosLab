# INTERACTION_MATRIX.md · Bending Light

> 闭环要求：User Input → Handler → Model Property → Physics Update → View Update  
> Status 列：Phase 0 全部为 **TODO**（尚未实现 Flutter）  
> 审计日期：2026-09-18

---

## Global Patterns

| Pattern | Gesture | Original Behavior | Model / View | Flutter Handler | Status |
|---|---|---|---|---|---|
| DragListener | drag | 写 position/angle Property | 各 Node | `onPanUpdate` → model | TODO |
| ForwardingListener | toolbox icon drag | enable 工具 → 转发 press 到 play-area node | toolbox | ToolboxController | TODO |
| Toolbox put-back | drop overlapping toolbox | `enabledProperty=false` | Intro/MT tools | same | TODO |
| Prism delete | drop center in toolbox | `removePrism` + dispose | PrismsModel | same | TODO |
| Occlusion bump | release near right panels | 向左推开 | view helper | layout helper | TODO |
| PressListener | — | **未使用** | — | — | N/A |
| Keyboard / a11y hotkeys | — | **本 sim 无专用** | — | P2 later | TODO |

---

## Intro Screen

| Element | Gesture | Original Behavior | Model Property | Flutter Handler | Status |
|---|---|---|---|---|---|
| Laser power button | tap | 开关光束 | `laser.onProperty` | `LaserNode.onPowerTap` | TODO |
| Laser body | drag | 绕 pivot 旋转；限制第二象限 π/2…π；Wave 时 ≤ `MAX_ANGLE_IN_WAVE_MODE` | `emissionPointProperty` / `setAngle` | `LaserNode.onRotateDrag` | TODO |
| Rotation drag handles | *(cue only)* | 悬停/拖时显示弧箭头 | view-local show flags | paint only | TODO |
| Top Medium ComboBox | select | Air/Water/Glass/MysteryA/B/Custom | `topMediumProperty` | `MediumControlPanel` | TODO |
| Bottom Medium ComboBox | select | 同上；默认 Water | `bottomMediumProperty` | same | TODO |
| IOR slider | drag | Custom n ∈ [~1.000293, 1.6]；刻度 Air/Water/Glass | `mediumIndexProperty` → medium | slider | TODO |
| IOR ± / readout | tap | 步进 10^-2 | same | arrow buttons | TODO |
| Mystery A/B | via ComboBox | 固定 n；隐藏滑块与数值 | Substance mystery | panel | TODO |
| Ray / Wave radio | tap | 切换渲染；Wave 显示 TimeControl | `laserViewProperty` | `LaserTypeAquaRadio` | TODO |
| Normal checkbox | check | 显示竖直虚线法线 | `showNormalProperty` | checkbox | TODO |
| Protractor (toolbox) | drag out | 启用并放到指针处；scale icon 0.24 → play 0.8 | view `showProtractorProperty` | toolbox forward | TODO |
| Protractor (play) | drag / drop toolbox | 移动；放回则隐藏 | same | drag + put-back | TODO |
| Intensity meter (toolbox) | drag out | enable；首次 body+probe 同移 | `intensityMeter.enabledProperty` | toolbox | TODO |
| Intensity body | drag | 移 body；可 put-back | `bodyPositionProperty` | drag | TODO |
| Intensity probe | drag | 独立移动探头 | `sensorPositionProperty` | drag | TODO |
| TimeControl | tap | 仅 WAVE 可见；play/pause/step/speed | `isPlayingProperty`, `speedProperty` | TimeControl | TODO |
| Reset All | tap | 全 model + UI tools reset | multi | `KratosResetAllButton` r=19 | TODO |
| Screen nav | tap icons | 切到 Prisms / More Tools | joist | home shell | TODO |

**Intro 不含**：Wavelength 滑块、Angles 复选、激光平移旋钮、棱镜。

---

## More Tools Screen

（继承 Intro 交互，以下为差异 / 增量）

| Element | Gesture | Original Behavior | Model Property | Flutter Handler | Status |
|---|---|---|---|---|---|
| Bottom medium default | — | 默认 **Glass**（非 Water） | `bottomMediumProperty` | model ctor | TODO |
| IOR decimals | ± | **3** 位小数 | panel ctor | panel | TODO |
| Angles checkbox | check | 显示入射/反射/折射角弧与读数 | `showAnglesProperty` | checkbox + `AngleNode` | TODO |
| Wavelength slider | drag | 设置 λ（nm→m）；光谱条 | `wavelengthProperty` | `WavelengthControl` | TODO |
| Wavelength ± | tap | ±1 nm | same | arrows | TODO |
| Velocity sensor | drag out / body | enable；显示速度；put-back | `velocitySensor.*` | `VelocitySensorNode` | TODO |
| Wave sensor (Time) | drag out | 双探头 + 图表 body | `waveSensor.enabledProperty` | `WaveSensorNode` | TODO |
| Wave probe 1/2 | drag | 首次同移，之后独立 | `probe1/2.positionProperty` | probes | TODO |
| TimeControl visibility | — | WAVE **或** waveSensor.enabled | derived | visibility bind | TODO |
| horizontalPlayAreaOffset | — | `false`（与 Intro 不同） | model flag | layout | TODO |

---

## Prisms Screen

| Element | Gesture | Original Behavior | Model Property | Flutter Handler | Status |
|---|---|---|---|---|---|
| Laser power | tap | on/off | `laser.onProperty` | LaserNode | TODO |
| Laser body translate | drag | 平移；dragBounds；遮挡左推 | `laser.translate` / emission | LaserNode | TODO |
| Laser knob (`knob.png`) | drag | 绕 pivot **360°** 旋转 | `setAngle` | knob drag | TODO |
| Translation handles | cue | 悬停显示绿箭头 | view flags | paint | TODO |
| Rotation handles | cue | 旋转时显示 | view flags | paint | TODO |
| Environment ComboBox | select | 环境介质；**无** IOR 数值框 | `environmentMediumProperty` | MediumControlPanel | TODO |
| Environment IOR slider | drag | 调环境 n | same | slider | TODO |
| Objects ComboBox | select | 所有棱镜材料 | `prismMediumProperty` | toolbox panel | TODO |
| Objects IOR slider | drag | 调棱镜 n | same | slider | TODO |
| Laser type radio 1× | tap | 单色单束 | `colorMode=SINGLE`, `manyRays=1` | `LaserTypeRadio` | TODO |
| Laser type radio 5× | tap | 单色多束 | `manyRays≈5` | same | TODO |
| Laser type radio white | tap | 白光；禁用波长滑块 | `colorMode=WHITE` | same | TODO |
| Wavelength control | drag/± | 单色时可用 | `wavelengthProperty` | WavelengthControl | TODO |
| Prism toolbox icons | drag | copy prototype → `addPrism`；每类最多 6 | `prisms` | PrismToolbox | TODO |
| Prism body | drag | 平移；中心回 toolbox → 删除 | `prism.positionProperty` | PrismNode | TODO |
| Prism knob | drag | 旋转；**不能**经旋钮删除 | `prism.rotate` | PrismNode | TODO |
| Reflections checkbox | check | 显示非 TIR 反射 | `showReflectionsProperty` | checkbox | TODO |
| Normal checkbox | check | 交点法线 | `showNormalsProperty` | checkbox | TODO |
| Protractor checkbox | check | 显示可旋转量角器（无 put-back） | `showProtractorProperty` | checkbox | TODO |
| Protractor drag | drag | 移动；bump left | view position | drag | TODO |
| Reset All | tap | 清空棱镜 + 复位 | model.reset | KratosResetAll r=19 | TODO |

**Prisms 不含**：Ray/Wave、Intensity/Velocity/Wave sensors、上下双介质面板。

---

## Interaction Count Summary

| Screen | Interactive elements (approx.) |
|---|---|
| Intro | ~18 |
| More Tools | ~18 Intro + ~8 extra ≈ **26** |
| Prisms | ~22 |
| **Total unique rows in matrices** | **≈ 55+**（含 cue/非手势行） |

---

## Closed-Loop Verification Checklist（后续 Phase）

对每个 Status=DONE 的元素必须验证：

1. 手势触发  
2. Model Property 变化（单元测试或 debug）  
3. Physics 重算（射线列表更新）  
4. View 重绘（非静态截图）  
5. Reset 恢复默认  

“能拖动”≠完成。

---

*INTERACTION_MATRIX · req-bending-light · Phase 0*
