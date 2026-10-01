# FINAL-VISUAL-P4-2

> Decay Screen 已确认 Color / Gradient · 2026-08-31  
> 未改 Theme / Chart Intro / NineGrid / Typography / State / disabled 配方 / Full Chart Dialog

截图：`flutter_decay_empty.png` / `flutter_decay_fe69.png`（1280×800 @ DPR 2）  
取样：`../p4_2_screenshot_samples.json`

---

## 0. 对照表（修前 → 目标）

| Component | PhET source | Flutter 修前 | Target | 状态 |
|---|---|---|---|---|
| play background | `screenBackground` WHITE | Theme `#FEF7FF` | `#FFFFFF` | **已修** |
| proton base | `#D14600` | `#D14600` | 同 | 未改 |
| neutron base | `#737373` | `#737373` | 同 | 未改 |
| nucleon gradient | 白→base，中心 −0.4r，半径 1.6r | 同 | 同 | 未改 |
| nucleon stroke | = base，宽 1 | 同 | 同 | 未改 |
| electron cloud | `#0000FF` 径向 0/0.9 | 同配方，叠在 `#FEF7FF` | 同配方，叠在 **白** | 随底色 |
| decay panel | `#F2F2F2` | `#F2F2F2` | 同 | 未改 |
| decay enabled | `#FBB240` | `#FBB240` | 同 | 未改 |
| pointer | `#FF00FF` | `#FF00FF` | 同 | 未改 |
| equation/legend arrow | 白填 / `#0404FF` | 同 | 同 | 未改 |
| reset | ResetAllButton 橙圆 | Material `IconButton` | 不换组件 | [视觉近似：Material] |
| undo | ReturnButton 黄方 | 无独立黄键 | 不换组件 | [视觉近似：Material] |
| checkbox | sun Checkbox | Material Checkbox | 不换组件 | [视觉近似：Material] |
| generator 球 | 同 ParticleNode | 同 | 同 | 未改 |
| labels | 红元素名 / 黑 Stability | 同 | 同 | 未改 |
| disabled decay | sun 灰化 | α=0.35 `#F5DCB4` | — | **[待确认]** 不修 |
| Full Chart Dialog | — | Chart Intro | — | **[待确认]** 本阶段不改 Chart Intro |

---

## 1. 修改项

只改 **Decay play 底**：

- `BanConstants.screenBackgroundValue = 0xFFFFFFFF`
- `BuildANucleusScreen`：embedded 时 `ColoredBox` 铺白；独立 Scaffold `backgroundColor` 白

未改：`NucleusPainter` 渐变、云 stop、面板、启用键、指针、生成器、Theme、其他 sim。

---

## 2–4. 颜色前后

| | PhET | Flutter 原值 | Flutter 新值 |
|---|---|---|---|
| play 底 | `#FFFFFF` | `#FEF7FF` | **`#FFFFFF`**（取样 var=0） |
| AppBar | joist 黑底栏 | `#B45309` | `#B45309`（chrome，未动） |
| 云叠底后中环 | 蓝雾 | `#B5B0FF` 偏紫 | `#ACACFF` / `#ABABFF` **蓝** |

---

## 5. Gradient 参数（未改，已对齐）

| | 值 |
|---|---|
| proton / neutron base | `#D14600` / `#737373` |
| 高光 | WHITE |
| 中心 | −0.4r, −0.4r |
| 半径 | 1.6r |
| 描边 | base，宽 1 |
| 云 | `#0000FF`，stop 0 α=1，stop 0.9 α=0，中心=核 |

不要用高光像素反推 base。

---

## 6. Screenshot sampling（Fe-69 · 逻辑×2）

| 区域 | hex | 类型 |
|---|---|---|
| play 左 / 核左空白 | `#FFFFFF` | **base region** |
| 空核 canvas | `#FFFFFF` | **base region** |
| 云（核右 / 核上） | `#ACACFF` `#D7D7FF` | **gradient + 白底合成** |
| 核中心 | `#CACACA` | **gradient region**（中子高光，不当 `#737373`） |
| Available Decays | `#F2F2F2` | **base region** |
| α 键（禁用） | `#F5DCB4` | 未改 · [待确认] |
| 指针 | `#FF00FF` | **base region** |
| AppBar | `#B45309` | chrome |

抗锯齿边未用来判 base。

---

## 7. mean \|ΔRGB\|

叠图：原版 1024×672 vs Flutter 1280×800；play 去 chrome 后仿射 1024×618。

| 配对 | P4-1 附近 | P4-2 |
|---|---:|---:|
| 全画幅空核 | 47.01 | **46.60** |
| 全画幅 Fe-69 | 49.61 | **49.59** |
| Play Fe-69 | 31.79 | **31.81** |

全画幅略降来自白底对齐；play 均值几乎不变（NineGrid / chrome / 核排布仍主导）。**不是**优化目标。

---

## 8. [源码一致]

- play WHITE；核子 hex + 径向配方；云 `#0000FF` 0/0.9  
- 面板 `#F2F2F2`；启用键 `#FBB240`；指针 `#FF00FF`  
- 元素名红、Stability 黑  

---

## 9. [视觉近似]

- **[视觉近似：Material]** Reset / Undo / Checkbox 未换 scenery 皮肤  
- 生成器箭头无白底 `DoubleArrowButton`  
- 核子高光像素 ≠ base  
- 云边缘近白（stop 0.9），中环才见蓝  

---

## 10. [待确认]

- disabled decay 的 sun 灰化配方（仍 α=0.35）  
- Full Chart Dialog 底（Chart Intro，本阶段不改）  

---

## 11. 测试

- `flutter analyze`：**No issues found**
- BAN：**407/407**
- 640×360 / 1024×768 / 1280×800：`build_a_nucleus_final_viewport_test` 无 overflow

停在 P4-2。未进 P4-3 / P5 / Typography / Geometry。
