# RECONSTRUCTION_REPORT — Energy Forms and Changes

> 2026-09-10 22:35 · Runtime Visual Reconstruction QA  
> **不得宣布完成**

---

## 0. 强制差异表（基于 Flutter Runtime 截图 + 源码）

| Screen | Object | Original | Flutter (runtime) | Difference | Priority | Status |
|---|---|---|---|---|---|---|
| Intro | viewport | 1024×618 | 1024×618 | 对齐 | — | ok |
| Intro | Iron / Brick | 三面纹理 BlockNode | 有透视立方体；纹理偶发未暖缓存时发灰 | ImageCache 暖启动后改善 | P0 | 进行中 |
| Intro | Thermometer storage | 左上 4 支 tip 同点叠放 | storage 可见；4 tip 同 model 点（源码一致） | 待 Original overlay | P1 | 进行中 |
| Intro | HeaterCooler body | scenery-phet Path+slider | 已按 HeaterCoolerFront/Back Path | flame/ice/Faucet **[BLOCKED D]** | P0 | 进行中 |
| Intro | BurnerStand cage | BurnerStandNode 孔洞平行四边形 | 已按 BurnerStandNode.ts 侧+顶开孔 | 待 Original overlay | P1 | 进行中 |
| Intro | Beaker water/oil | BeakerView front/back + meniscus | PerspectiveWater meniscus+玻璃+刻度弧 | 待 Original overlay | P1 | 进行中 |
| Intro | bottom TimeControl | TimeControlNode | Material play/step 等 | 外观不一致 | P1 | open |
| Intro | typography | PhetFont | 测试截图 Ahem→黑块 | **测试伪影**；真机需另验 | P1 | 记录 |
| Systems | Biker+Rider | 完整腿/躯干/车 0.49 | 已可见完整骑手+蓝车架 | 锚点待 Original overlay | P1 | 进行中 |
| Systems | Belt | Belt.ts 双弧闭合 | BeltGeometry 闭合双弧+线宽4 | 待 Original overlay | P1 | 进行中 |
| Systems | Generator | generator.png + spokes -65 | 本地坐标+实测 212×330 | 轮/壳关系待 overlay | P1 | 进行中 |
| Systems | BeakerHeater | 线+coil+BeakerView+温度计 | 固有尺寸 PNG + BeakerPainter + tip 偏移 | 待 Original overlay | P1 | 进行中 |
| Systems | 3 selectors | 44px icons spacing 82 | 图标可见、蓝框选中 | 禁用态/过渡待对 | P1 | 进行中 |
| Systems | connection points | 轮心 model offsets | 与 Belt 共用同一套 centers/radii | 待 Original overlay | P1 | 进行中 |
| Both | Original Runtime | PhET 运行时同态截图 | `visual-qa/runtime/original/` 4 张已登记 | Overlay 已建 | P0 | **UNBLOCKED** |
| Both | Overlay / Diff | 成对叠加 | `overlay/` + `diff/` | 持续几何收敛 | P0 | 进行中 |

---

## 1. Flutter Runtime 截图识别（已确认）

| 文件 | 状态 | 证据 |
|---|---|---|
| `flutter/intro_initial.png` | Intro · 初始 | 脚本 `capture Intro initial`；台面+双块+双炉+双烧杯 |
| `flutter/intro_heater_active.png` | Intro · heater active | `setHeatCoolLevel(...,1)`；可见火焰 |
| `flutter/systems_initial.png` | Systems · 初始 | 默认 Biker→Generator→BeakerHeater；暖缓存后资产完整 |
| `flutter/systems_bike_active.png` | Systems · bike active | `setBikerSpeed` + step；腿帧/轮转 |

生成：`test/energy_forms_and_changes/runtime_screenshot_test.dart`（AssetImage resolve 暖 ImageCache）。

---

## 2. Original Runtime Evidence

**`[BLOCKED：缺少对应原版 runtime screenshot]`**

详见 `visual-qa/runtime/original/ORIGINAL_BLOCKED.md`。

禁止用营销图作最终 Overlay 证据；禁止伪造对比结果。

---

## 3. 本轮已修（源码驱动，非拍脑袋 offset）

1. **Biker**：`Transform.scale`→显式 `width/height = native×0.490`（修布局尺寸错位导致 initial 空白）  
2. **Generator**：PNG 实测 212×330 / spokes 167  
3. **Belt**：错误双弧填充改为两根公切线（避免巨大黑多边形）  
4. **Thermometer idle**：`(100,100)` 米级飞出 → 近 storage 模型坐标  
5. **截图**：正确暖 `ImageCache`（先前 `decodeImageFromList` 无效）  
6. **flame/ice**：已从 scenery-phet 拷入（上轮）

---

## 4. Runtime QA 目录

```
visual-qa/runtime/
  flutter/     ✅ 四态
  original/    ❌ BLOCKED（仅 ORIGINAL_BLOCKED.md）
  overlay/     ❌ 待 Original
  diff/        ✅ 局部 crop / 分析笔记
```

---

## 5. Tests

- 未重复大规模 model 全量（按用户要求）  
- screenshot 4 passed  
- 26 passed 基线仍有效；**≠ 完成**

---

## 6. 硬性验收

- [ ] P0 = 0  
- [ ] Original + Overlay  
- [ ] Interaction / Animation 核对  
- [ ] **未封板**
