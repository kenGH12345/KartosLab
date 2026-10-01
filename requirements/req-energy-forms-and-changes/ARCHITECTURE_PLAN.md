# Architecture Plan — Energy Forms and Changes

> Phase 3 · 2026-09-10  
> 依据：PROJECT_DISCOVERY + SOURCE_ANALYSIS + KARTOSLAB 惯例  
> **无高风险架构决策需人工确认** → 自动继续 Phase 4

---

## PHASE: 3 — Architecture Design
## STATUS: DONE

---

## 1. Target directory

```
lib/energy_forms_and_changes/
├── efac_constants.dart
├── efac_colors.dart
├── efac_strings.dart
├── common/
│   ├── model/          # EnergyType, EnergyChunk, Beaker, Burner, HeatTransfer…
│   ├── render/         # 共享 RenderData 片段
│   ├── painters/       # EnergyChunkPainter, BeakerPainter, SkyPainter…
│   ├── widgets/        # Time controls (PhET-like), energy checkbox
│   └── transform/      # EfacMvt (scale inverted-Y)
├── intro/
│   ├── model/          # EfacIntroModel + Block, Air, sensors…
│   ├── controller/     # IntroController (clock + drag bridge)
│   ├── render/
│   ├── painters/
│   ├── widgets/
│   └── screens/        # IntroScreenBody
├── systems/
│   ├── model/          # SystemsModel + sources/converters/users/carousel
│   ├── controller/
│   ├── render/
│   ├── painters/
│   ├── widgets/
│   └── screens/
└── screens/
    └── energy_forms_and_changes_home.dart  # KratosTabbedScreen

assets/energy_forms_and_changes/   # 从 images/*_png.ts 解码的 PNG
test/energy_forms_and_changes/
```

**不**机械复制其他 sim；按 PhET `common/intro/systems` 三分。

---

## 2. Data boundary（强制）

```
Model (SSOT: temperatures, energies, positions, carousel selection, chunk lists)
        ↓ 纯函数 / step(dt)
Derived state (contact maps, energy balance, litProportion…)
        ↓
RenderData (immutable snapshot：几何、颜色、asset keys、chunk 屏幕坐标)
        ↓
Painter / Widget（只读 RenderData；手势 → Controller → Model）
```

- Widget **不**算热交换  
- Painter **不**持有可变业务状态  
- Controller：SimulationClock、手势→model API、notify

---

## 3. Screen shell

| 层 | 选择 | 理由 |
|---|---|---|
| Home | `EnergyFormsAndChangesHome` | 对齐 energy_skate_park |
| Tabs | `KratosTabbedScreen` Intro \| Systems | 双独立 Model |
| Page layout | `NineGridLayout` center = play area | checklist L0-4 |
| Internal | Stack + MVT + Positioned | 用户提示 §6 |

两屏 **各自** `ChangeNotifier` Model + Controller；切换 Tab 不共享状态（对齐 PhET）。

---

## 4. Model 分包

### common/model（优先实现）

`EnergyType`, `EnergyChunk`, `EnergyChunkDistributor`, `Beaker`/`BeakerType`, `Burner`, `ModelElement`, `UserMovableModelElement`, `RectangularThermalMovableModelElement`, `ThermalContactArea`, `HorizontalSurface`, `HeatTransferConstants`, `EnergyContainerCategory`, `TemperatureSensor`（精简 PhET-iO）

### intro/model

`EfacIntroModel`, `Air`, `Block`/`BlockType`, `BeakerContainer`, `EnergyBalanceTracker`, `StickyTemperatureSensor`, `efacPositionConstrainer`

### systems/model

`SystemsModel`, `Energy`, `EnergySystemElement` (+Source/Converter/User), `EnergySystemElementCarousel`, `EnergyChunkPathMover`, 各元件类, `Belt`, `Cloud`, `WaterDrop`

---

## 5. Clock

- `SimulationClock(fps: 60)`  
- Intro：`timeScale = isFastForward ? 4 : 1`；`maxDT` clamp 0.1 在 controller  
- Systems：carousel 动画在 pause 时仍需 tick → **Controller 始终 tick carousel；仅 playing 时 stepModel**（对齐源码）

---

## 6. Assets 策略

1. 脚本解码全部 `images/*_png.ts` → `assets/energy_forms_and_changes/*.png`  
2. `pubspec.yaml` 注册目录  
3. scenery-phet（HeaterCooler / Faucet）：Phase 5 按几何/行为源码等价实现，标记 `[待确认]` 直至对齐  
4. 禁止 Material Icon 冒充 energy chunk / carousel icons

---

## 7. Tests 计划

| 层 | 覆盖 |
|---|---|
| Unit | EnergyType, ENERGY_PER_CHUNK 公式, HeatTransfer, Intro step 边界, Systems pipeline gating, carousel select/reset |
| Interaction | drag constrain, heater level, checkbox, carousel radio |
| Lifecycle | home open/reset/reopen 双 Model 独立 |
| Visual | Phase 5+ 截图（非本阶段） |

---

## 8. 分期落地（Vibe 顺序）

| Step | 内容 |
|---|---|
| 4a | constants/strings/colors + asset extract + EnergyType/Chunk/HeatTransfer + ENERGY_PER_CHUNK 单测 |
| 4b | Intro thermal core (Burner/Block/Beaker/Air/IntroModel.step) |
| 4c | Systems pipeline skeleton + carousel + 默认三元件 step |
| 5 | 双屏静态壳 + MVT + 主要 painter/assets |
| 6 | 拖拽/控件/reset |
| 7 | EC wander/path、蒸汽、帧动画、carousel tween |
| 8–11 | Screen 集成、Visual QA、Home、收尾 |

---

## 9. 有意差异（预登记）

| 项 | 说明 |
|---|---|
| PhET nav / logo | KARTOSLAB AppBar + Tab；不复刻 PhET chrome |
| PhET-iO / tandem | 不移植 |
| Query parameters | MVP 固定默认元素（iron,brick,water,oliveOil + 2 burners） |
| TimeControl 外观 | 自绘对齐 scenery-phet，不直接用 L0 Material `TimeControlBar` 冒充 |

---

## 10. Phase 报告框

1. Completed：目录、数据边界、壳层、分期  
2. Files：`ARCHITECTURE_PLAN.md`  
3. Evidence：对齐源码结构 + 工程范例  
4–6. N/A  
7. Blocked：无（无需人工架构决策）  
8. Limitations：scenery-phet 外部控件等价实现风险  
9. Next：Phase 4 Model/State

---

*Phase 3 完成 → 自动进入 Phase 4*
