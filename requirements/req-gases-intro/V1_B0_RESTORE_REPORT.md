# V1 验收报告 — Restore B0 Capability

**日期**：2026-09-06  
**阶段**：V1 完成 · **停止，不进入 V2**  
**改动范围**：仅 `lib/gases_intro/screens/gases_intro_home.dart`、`lib/gases_intro/widgets/gases_intro_shell.dart`  
**Model / Physics / Solver / constants**：**零修改**（model 目录文件时间戳仍为上午构建）

---

## A. B0 功能清单（恢复目标）

| # | 能力 |
|---|---|
| 1 | Intro \| Laws 双屏独立 Model |
| 2 | IdealControlPanel 与 ParticlesAccordion **分离** |
| 3 | Hold Constant（Laws） |
| 4 | Width / Stopwatch / Collision Counter 三个 Checkbox |
| 5 | Particles Fine/Coarse ±1 / ±50，可点尺寸充足 |
| 6 | Bicycle pump 拖动 → `model.pump()`（B0 尺寸 120×230） |
| 7 | Heavy/Light 泵下类型切换 |
| 8 | Heater/Cooler → `setHeatCool`（flame/ice PNG） |
| 9 | 左墙 Handle 拖宽 → begin/setWidth/end |
| 10 | Thermometer / PressureGauge 显示绑定 |
| 11 | Erase（eraser.svg）/ Reset（resetArrow.png） |
| 12 | Play / Pause / Step |
| 13 | Return Lid（盖飞后） |
| 14 | Width 可见时尺寸箭头（painter） |
| 15 | Stopwatch 可见时底栏读数 |
| 16 | Home：`SizedBox(1008×618)` + `FittedBox` 铺满，可操作区按设计尺寸布局 |

---

## B. B1（overflow 重写）曾有的回退

| 回退 | B1 表现 |
|---|---|
| 面板合并 | 单一 ListView 含 Hold+checkbox+Particles |
| Fine/Coarse 缩小 | 28×28 shrinkWrap |
| Pump 缩小 | 100×200 |
| Home | AspectRatio 导致可点区域退化 |
| Accordion | 无折叠块 |

---

## C. 恢复项逐项结果

| # | 项 | 结果 |
|---|---|---|
| 1 | ControlPanel ‖ ParticlesAccordion 分离 | **已恢复** — `IdealControlPanel` + `ParticlesAccordionBox`，间距 15 |
| 2 | Fine/Coarse 尺寸 | **已恢复** — 40×40、icon 22；控件按 `NumberOfParticlesControl` 两行布局 |
| 3 | Pump 120×230 | **已恢复** — 仍绑定 `model.pump()` |
| 4 | Home FittedBox + 1008×618 | **已恢复** |
| 5 | Particles ±1/±50 | **保留且可点** |
| 6 | Heater/Cooler binding | **保留**（未改 instruments 绑定） |
| 7 | 左墙拖动 | **保留** |
| 8 | Hold Constant | **保留**（在 IdealControlPanel） |
| 9 | 三 checkbox | **保留**（未改成普通 Switch） |
| 10 | erase / reset / flame / ice | **保留真实 assets** |

局部 overflow：V1 **允许**（未缩控件）；留给 V5。

---

## D. 仍缺失（相对 PhET · 非 V1 范围）

| 项 | 说明 | 计划阶段 |
|---|---|---|
| 可拖 Stopwatch / CollisionCounter 工具 | 仅 checkbox + 读数 | V3 |
| ParticleTypeRadioButtonGroup 图标 | 仍为色点 | V4 |
| 单位 listbox、OopsDialog、lid 拖 | 无 | V3/V4 |
| 仪器相对容器锚点 | 仍顶栏/侧栏近似 | V2 |
| TimeControl / Reset 外观与定位 | Material + 合并 TimeBar | V2 |
| FineCoarseSpinner 原版外观 | 功能恢复，非像素精修 | V2+ |

---

## E. 是否存在功能回退（相对 B0）

**否。** V1 功能集 ≥ B0；B1 引入的回退已恢复。

---

## F. Model / Physics 是否零修改

**是。**

- 未编辑 `lib/gases_intro/model/**`
- 未改 solvers / 公式 / 常量语义文件（本轮未触碰 `gases_intro_constants.dart`）
- `flutter test test/gases_intro` → **15 passed**

---

## G. 测试结果

```
flutter test test/gases_intro     → 15 passed
flutter analyze lib/gases_intro   → 0 issues
```

---

## 结构（便于 V2–V6）

```
GasesIntroHome
  FittedBox → SizedBox(1008×618) → TabBarView → GasesIntroShell
GasesIntroShell
  Row(
    Expanded(_SimulationViewport),  // instruments / canvas+pump / heater+time
    SizedBox(225, _RightColumn(
      IdealControlPanel,            // 独立
      ParticlesAccordionBox,        // 独立 Accordion
    )),
  )
```

公开 View 类型：`IdealControlPanel`、`ParticlesAccordionBox`、`NumberOfParticlesControl` — 后续可替换为更源码对齐实现而不拆绑 Model。

---

**状态**：`v1_b0_restored` · 等待确认后再开 V2。
