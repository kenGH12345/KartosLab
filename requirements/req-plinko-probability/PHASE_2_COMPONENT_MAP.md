# PHASE 2 — Component Map · Plinko Probability

> 先组件、后组装。包根：`lib/plinko_probability/`

---

## 1. Directory Layout

```
lib/plinko_probability/
├── plinko_probability.dart          # export barrel
├── plinko_constants.dart
├── plinko_colors.dart
├── plinko_strings.dart
├── plinko_assets.dart
├── model/
│   ├── ball_phase.dart
│   ├── peg.dart
│   ├── galton_board.dart
│   ├── ball.dart                    # common Ball
│   ├── intro_ball.dart
│   ├── lab_ball.dart
│   ├── histogram.dart
│   ├── plinko_common_model.dart
│   ├── intro_model.dart
│   ├── lab_model.dart
│   └── plinko_random.dart           # seedable RNG (dotRandom 等价)
├── controller/
│   ├── intro_controller.dart
│   └── lab_controller.dart          # binds SimulationClock
├── transform/
│   └── plinko_mvt.dart              # single scene transform
├── painters/
│   ├── board_painter.dart
│   ├── pegs_painter.dart
│   ├── balls_painter.dart
│   ├── hopper_painter.dart
│   ├── histogram_painter.dart
│   ├── cylinders_painter.dart
│   └── trajectory_path_painter.dart
├── widgets/
│   ├── intro_play_panel.dart
│   ├── lab_play_panel.dart
│   ├── peg_controls.dart
│   ├── hopper_mode_control.dart
│   ├── histogram_mode_control.dart
│   ├── number_balls_display.dart
│   ├── statistics_accordion_box.dart
│   ├── eraser_button.dart
│   ├── sound_toggle_button.dart
│   ├── plinko_play_button.dart
│   ├── plinko_pause_button.dart
│   └── out_of_balls_dialog.dart
└── screens/
    ├── plinko_probability_home.dart # KratosTabbedScreen（独立运行）
    ├── intro_screen.dart
    └── lab_screen.dart

test/plinko_probability/
├── model/
│   ├── ball_path_test.dart
│   ├── galton_board_test.dart
│   ├── histogram_stats_test.dart
│   ├── binomial_test.dart
│   ├── intro_model_test.dart
│   └── lab_model_test.dart
└── …
```

---

## 2. Component Ownership

| Component | Layer | Source of truth | Notes |
|---|---|---|---|
| **GaltonBoard** | Model | `GaltonBoard.js` | peg positions / visibility / spacing |
| **Peg** | Model (data) | peg object in GaltonBoard | row, col, position, isVisible |
| **Ball** | Model | `Ball.js` | pegHistory + phases + updatePosition |
| **IntroBall** | Model | `IntroBall.js` | cylinder stacking offsets |
| **LabBall** | Model | `LabBall.js` | histogram landing offset |
| **BallManager** | = Model.balls list | CommonModel.balls | **不**另建并行粒子系统；由 Intro/LabModel 管理 |
| **Histogram** | Model | `Histogram.js` | bins + sample stats |
| **ProbabilityModel** | LabModel methods | `getBinomial*` | theoretical only |
| **DistributionModel** | Histogram + LabModel | normalized sample vs binomial | 两数组 |
| **BoardTransform / PlinkoMvt** | Transform | CommonView MVT | **单一** scene scale |
| **BoardPainter** | View | `Board.js` | triangle board |
| **PegsPainter** | View | `PegsNode.js` | Canvas pegs + shadow |
| **BallsPainter** | View | BallsNode + shaded sphere | 复用 `paintShadedSphere` |
| **HopperPainter** | View | `Hopper.js` | trapezoid funnel |
| **HistogramPainter** | View | `HistogramNode.js` | bars + Ideal |
| **CylindersPainter** | View | Cylinders*Node | Intro only |
| **TrajectoryPathPainter** | View | `TrajectoryPath.js` | Lab path mode |
| **IntroPlayPanel** | Widget | IntroPlayPanel | Play + ×1/×10/×100 |
| **LabPlayPanel** | Widget | LabPlayPanel | Play/Pause + one/continuous |
| **PegControls** | Widget | PegControls | Rows + p sliders → **KratosSlider** |
| **HopperModeControl** | Widget | HopperModeControl | ball/path/none → **KratosRadioGroup** |
| **HistogramModeControl** | Widget | + original PNG icons | counter/cylinder/fraction |
| **StatisticsAccordionBox** | Widget | StatisticsAccordionBox | N, x̄, s, μ, σ, Ideal |
| **NumberBallsDisplay** | Widget | NumberBallsDisplay | Intro N= |
| **EraserButton** | Widget | scenery-phet EraserButton 风格 | erase |
| **SoundToggle** | Widget | SoundToggleButton 风格 | mute |
| **Reset** | Widget | **KratosResetAllButton** L0 | radius 按源码 scale |
| **Play/Pause** | Widget | PlayButton/PauseButton | 新建；禁 Material Icons |
| **SimulationClock** | L0 | `lib/common/simulation_clock.dart` | Controller attach |
| **KratosTabbedScreen** | L0 | home shell | Intro+Lab tabs |

---

## 3. Data Chain（强制）

```
User Controls
  → IntroModel / LabModel state
  → Ball spawn (queue or continuous)
  → Ball constructor: Bernoulli path precompute
  → step(dt): phase + parabolic interpolation
  → peg hit emitter → sound
  → EXITED → Histogram.addBallToHistogram
  → Lab: theoretical binomial (Ideal)
  → Painters / Readouts
```

禁止：

- 视觉路径 ≠ Model.position
- 直方图 ≠ histogram.visibleBinCount
- Ideal 条 ≠ getNormalizedBinomialDistribution()

---

## 4. Reuse Decision Summary

| Need | Decision |
|---|---|
| Clock | Reuse SimulationClock |
| Tabs / Reset | Reuse KratosTabbedScreen / KratosResetAllButton |
| Sliders / Radio | Reuse KratosSlider / KratosRadioGroup |
| Play/Pause look | **New** Plinko buttons（参考 SoM） |
| Histogram chart | **New** painter（算法自 Histogram.js） |
| Ball sphere | Reuse paintShadedSphere |
| MVT | **New** PlinkoMvt |
| RNG | **New** PlinkoRandom（可种子，测分布） |
| Visual QA | Reuse tool/ Playwright + diff_visual_qa.py |

---

## 5. Build Order（M3→M4）

1. Constants / Colors / Random / BallPhase / Peg / GaltonBoard  
2. Ball + IntroBall + LabBall + unit tests（路径、相位）  
3. Histogram + Lab binomial + stats tests  
4. IntroModel / LabModel + clock binding tests  
5. PlinkoMvt + Board/Pegs/Balls painters  
6. Hopper / Histogram / Cylinders / Trajectory painters  
7. Controls widgets  
8. IntroScreen / LabScreen 组装  
9. PlinkoProbabilityHome（独立）  
10. Major Geometry → Visual QA → Browser QA → Statistical Validation → Final Gate  
11. **然后** Home 接入 + 全项目回归

---

## 6. Test Plan（最小集）

| Test | Assert |
|---|---|
| `galton_board_test` | spacing、peg 坐标、可见行数 |
| `ball_path_test` | 固定 seed：binIndex 分布；方向计数 ≈ Bernoulli |
| `ball_motion_test` | phase 转移；FALLING 抛物线公式点 |
| `histogram_stats_test` | 递推 mean/stddev 与手算一致 |
| `binomial_test` | μ/σ/`n choose k`/归一化 max=1 |
| `intro_model_test` | 队列、150ms、erase、cap=100 |
| `lab_model_test` | isPlaying 创建、path 瞬时落地、改 p erase |
| `reset_test` | Reset All 全字段默认 |

命令：

```bash
flutter test test/plinko_probability
flutter analyze
```
