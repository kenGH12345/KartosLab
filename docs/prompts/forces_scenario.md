# Forces Scenario JSON Generation Prompt

You are a **forces experiment designer** for the kratos force & motion simulation module. Generate valid JSON scenario files that define educational physics experiments involving 1D Newtonian mechanics.

## Model Overview

The forces module uses a **1D Newtonian simulation engine** (`ForcesSimulation`) shared by all experiment modes:

| Parameter | Type | Range | Description |
|---|---|---|---|
| `mass` | number | > 0 | Object mass in kg |
| `position` | number | any | 1D position in meters |
| `velocity` | number | ±40 max | Current speed in m/s |
| `appliedForce` | number | -500~500 | External pushing force in N |
| `frictionCoeff` | number | 0~0.5 | Surface friction coefficient |

## Experiment Modes

| mode | Screen | Key Mechanics |
|---|---|---|
| `netForce` | NetForceScreen | Tug-of-war: 8 pullers (left/right, 50N/100N/150N), drag onto rope knots, cart moves toward stronger side |
| `motion` | MotionScreen | No friction: stack objects (up to 3), apply force via slider, observe speed |
| `friction` | MotionScreen | With friction: same as motion but with surface friction; static vs kinetic friction model |
| `acceleration` | MotionScreen | With accelerometer UI: same as friction but shows real-time acceleration gauge |

## Few-Shot Examples

### Example 1: Free Motion (motion mode)

```json
{
  "scenarioId": "motion-explore",
  "name": "力与运动探索",
  "description": "无摩擦平面 · 堆叠不同质量的箱子，施加推力观察速度变化",
  "version": "1.0",
  "mode": "motion",
  "initialParams": {"mass": 10, "position": 0, "velocity": 0, "appliedForce": 100, "frictionCoeff": 0},
  "objects": [
    {"id": "box_10", "label": "小箱 (10kg)", "mass": 10, "icon": "inventory_2"},
    {"id": "box_20", "label": "中箱 (20kg)", "mass": 20, "icon": "inventory_2"},
    {"id": "box_50", "label": "大箱 (50kg)", "mass": 50, "icon": "warehouse"},
    {"id": "crate_100", "label": "货箱 (100kg)", "mass": 100, "icon": "cases"}
  ],
  "successCriteria": [
    {"id": "sc-1", "type": "speedReached", "description": "使物体加速到 10 m/s", "params": {"minSpeed": 10}}
  ],
  "hints": [
    {"trigger": "speed < 2", "message": "试试增加施加力（滑块向右推）"},
    {"trigger": "always", "message": "增加质量会让加速度变小——验证 F=ma！"}
  ]
}
```

### Example 2: Tug of War (netForce mode)

```json
{
  "scenarioId": "netforce-tug",
  "name": "拔河比赛",
  "description": "合力实验 · 左右各 4 名拉绳者，拖拽到绳结上参与拔河",
  "version": "1.0",
  "mode": "netForce",
  "gameRules": {"gameLength": 400, "cartStep": 0.003},
  "pullers": [
    {"id": "sl0", "force": 50, "side": "left", "color": "FF3B82F6"},
    {"id": "ml", "force": 100, "side": "left", "color": "FF3B82F6"},
    {"id": "ll", "force": 150, "side": "left", "color": "FF3B82F6"},
    {"id": "sr0", "force": 50, "side": "right", "color": "FFEF4444"},
    {"id": "mr", "force": 100, "side": "right", "color": "FFEF4444"},
    {"id": "lr", "force": 150, "side": "right", "color": "FFEF4444"}
  ],
  "successCriteria": [
    {"id": "sc-1", "type": "gameWon", "description": "一方获胜（小车越过边界）", "params": {}}
  ],
  "hints": [
    {"trigger": "always", "message": "拖拽拉绳者到绳结上参与拔河，点击开始按钮开始比赛"}
  ]
}
```

### Example 3: Friction Surface (friction mode)

```json
{
  "scenarioId": "friction-demo",
  "name": "摩擦力演示",
  "description": "有摩擦表面 · 比较静摩擦与动摩擦的差异",
  "version": "1.0",
  "mode": "friction",
  "initialParams": {"mass": 50, "position": 0, "velocity": 0, "appliedForce": 150, "frictionCoeff": 0.3},
  "objects": [
    {"id": "box_20", "label": "中箱 (20kg)", "mass": 20, "icon": "inventory_2"},
    {"id": "box_50", "label": "大箱 (50kg)", "mass": 50, "icon": "warehouse"}
  ],
  "successCriteria": [
    {"id": "sc-1", "type": "speedReached", "description": "在有摩擦的情况下使物体加速到 5 m/s", "params": {"minSpeed": 5}}
  ],
  "hints": [
    {"trigger": "speed < 0.5", "message": "静摩擦力在抵抗！增大施加力直到超过 μs·mg"},
    {"trigger": "always", "message": "静摩擦 > 动摩擦：物体需要更大的初始力才能开始滑动"}
  ]
}
```

## Objective Criterion Types

| type | params | Description |
|---|---|---|
| `speedReached` | `minSpeed` (number) | Object reaches target speed |
| `forceBalanced` | `tolerance` (number) | Net force within tolerance of 0 |
| `positionReached` | `minPosition` (number) | Object reaches target position |
| `gameWon` | (none) | NetForce: cart crosses boundary |

## Constraint Types

| type | params | Description |
|---|---|---|
| `maxSpeed` | `maxSpeed` (number) | Speed ceiling |
| `maxObjects` | `maxObjects` (number) | Max stackable objects |
| `forceRange` | `min/max` (number) | Allowed force range |

## Output Format

Generate **only valid JSON** (no markdown code fences). Must conform to `schemas/forces_scenario.schema.json`.

## Validation Checklist

- [ ] `mode` is one of: netForce, motion, friction, acceleration
- [ ] `scenarioId` is unique across all scenarios
- [ ] netForce mode: `pullers` array present with at least 2 entries
- [ ] motion/friction/acceleration mode: `objects` array present for stacking
- [ ] `initialParams.frictionCoeff` in 0~0.5 range
- [ ] `initialParams.mass` > 0
- [ ] JSON valid, no BOM
