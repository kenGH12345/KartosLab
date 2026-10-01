# Wave on a String — 交付收口报告

**日期：** 2026-09-22  
**Source：** wave-on-a-string **1.3.0-dev.0**  
**Flutter 包：** `lib/wave_on_a_string/`  
**需求目录：** `requirements/req-wave-on-a-string/`

---

## 最终状态

```text
FINAL STATUS = READY
Home          = PASS
Android       = NOT VERIFIED

P0 = 0
P1 = 0
P2 = accepted / non-blocking
Substituted assets = 0

Wave tests    = 175 PASS
Analyze       = CLEAN
View physics  = 0
Control physics = 0
```

---

## 阶段闭环

| Phase | 内容 | 结果 |
| ----- | ---- | ---- |
| 0 | Source Audit | COMPLETE |
| 1 | Native Dart WoasModel（61 beads / evolve） | COMPLETE |
| 2 | Core View | COMPLETE |
| 3 | Controls | COMPLETE |
| 4 | Dynamic Behavior QA | COMPLETE |
| 5 | Final Visual QA（26 screenshots） | COMPLETE |
| 6 | Lifecycle / Home（物理 → 光学与波动） | COMPLETE |
| 7 | Final Acceptance | **READY** |

---

## 核心数据流（已锁定）

```text
Manual / Oscillate / Pulse
        ↓
     WoasModel
        ↓
     step(dt) → manualStep → evolve()
        ↓
 yLast / yNow / yNext / yDraw
        ↓
     61 beads → Core View
```

- Damping：`β = damping × 0.1`
- Tension：`minDt`（**不是** α）
- Slow：`0.25` · Normal：`1.0`
- **Restart ≠ ResetAll**

---

## Home 接入

```text
KartosLab Home
  → 物理
  → 光学与波动
  → Wave on a String
  → WoasScreen
```

| 项 | 归属 |
| -- | ---- |
| Model owner | `WoasScreenState` |
| Clock owner | `WoasPlayAreaState`（单一 `SimulationClock`） |
| Re-entry | Back → dispose · 再进入 → fresh Model |

---

## READY 后视觉收口（用户反馈）

| 项 | 修复 |
| -- | ---- |
| Manual 扳手 / 箭头 / 首珠对齐 | 按 `WrenchNode`：offset 仅乘 `SCALE_FROM_ORIGINAL`，不再错误复合 image×start scale |
| 蓝色 Restart 按钮 | 按 `RestartUndoButton`：圆角矩形 + 浅蓝 3D + **黑色** undo 箭头（非圆形白箭头） |

橙色 **Reset All** 仍为 L0 `KratosResetAllButton`（未改）。

---

## VERSION_DELTA（accepted）

```text
VD-SOUND · VD-A11Y · VD-PHETIO · VD-LOCALE · VD-BEAD-CACHE · VD-FONT
```

---

## 全仓回归（Phase 7）

```text
flutter test → +2980 ~1 −56
Wave failures = 0
New Wave-caused = 0
Known unrelated = capture/timeout（SoM / Pendulum / Projectile / Gas / Forces）
```

---

## 主要产物路径

```text
lib/wave_on_a_string/
test/wave_on_a_string/
assets/simulations/wave_on_a_string/   # wrench/clamp/rings/windows · Substituted=0

requirements/req-wave-on-a-string/
  PHASE_0_*.md … PHASE_7_*.md
  ASSET_MAP.md
  visual-qa/screenshots/               # 26-state matrix
  meta.yaml · process.txt
  DELIVERY_REPORT.md                   # 本文件
```

---

## 未做 / 不阻断

- Android 真机 / 模拟器验证 → `NOT VERIFIED`
- 完整 Parallel DOM / PhET-iO / 本地 sound assets → VERSION_DELTA
- Accepted P2（slider chrome、ruler ticks、bead cache 微差等）→ 不清零

---

**结论：Wave on a String 可按 KartosLab 正式 READY 交付；Home 已接入；Android 待后续验证。**
