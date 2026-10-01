# Locked Runtime Acceptance — Energy Forms and Changes

> 2026-09-10 · Original Runtime UNBLOCKED  
> 证据：`visual-qa/runtime/original/` 四张 + 本地 PhET 源码

## 1. Systems Active = 连续视觉链（不可拆开验收）

原版 Systems Active 证明本 Sim **不是**「物体 + 能量值」拼盘，而是：

```text
骑车 → 曲柄 → Belt → Generator wheel → Generator → 管路 → Heater → Water → Steam / Thermometer
```

### 硬性判定

| 条件 | 判定 |
|---|---|
| 各动画「看起来各自在动」但曲柄/后轮/Belt/发电机轮角不同步 | **行为不一致** |
| Belt 与两轮心/半径不是同一套几何 | **P0 几何失败** |
| Generator→管路→BeakerHeater 连接断裂或多余无源码 Path | **P0** |
| 有骑车但水温/蒸汽/温度计无联动 | **行为不一致** |
| Energy Symbols 路径与机械→电→热链脱节 | **P1/行为** |

Flutter `systems_bike_active` 截图场景必须以 **Biker → Generator → BeakerHeater** 跑通该链（热端：水/蒸汽/温度计）。  
Original `systems_bike_active.png`（alt3）为 **灯泡** 变体，用于骑手/Belt/轮几何对照；热端几何对照 `systems_initial` 烧杯链。

## 2. Intro Link Heaters ≠ 只加两团火

Original `intro_heater_active.png`（Link Heaters）要求**整场景状态**：

| 对象 | 要求 |
|---|---|
| Link Heaters checkbox | 勾选 |
| 两个 Heater slider | 同步至 Heat |
| 两团 flame | 同时出现（资产仍可 `[BLOCKED D]` 像素级） |
| Water + Olive Oil | 均在 cage/heater 上 |
| 温度计 | 吸附于液体内（非仅 storage） |
| 蒸汽 / 液体 / 温度柱 | 随加热变化 |
| Iron / Brick | 与原版同布局（本张为左侧台面） |

> Agent 若只实现 checkbox UI + 双火焰、忽略吸附温度计/液体/蒸汽/双炉同步 → **未完成**。

「砖块入水」等交互态可作为额外 AC；本张 Original 主布局为砖块在左。

## 3. 推进顺序（锁死）

```text
Systems Belt / 连接几何
→ BeakerHeater（管+杯+温度计+蒸汽）
→ Intro HeaterCooler / Beaker
→ 两个 Active 状态截图
→ Overlay
```

## 4. Overlay 目录

```text
visual-qa/runtime/{original,flutter,overlay,diff}/
```
