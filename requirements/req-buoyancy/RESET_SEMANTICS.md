# Reset Semantics

源码类：`scenery-phet/js/buttons/ResetAllButton.js`。本地没有 scenery-phet。按钮在 `DensityBuoyancyScreenView` 构造：

```text
listener: () => { model.reset(); this.resetEmitter.emit(); }
resetEmitter → displayProperties.reset()
```

这不是“重新 new Model”。Screen 的 model 工厂只在创建 Screen 时调用一次。Reset 走各模型自己的 `reset()`。

后续 Flutter 按钮必须是 `KratosResetAllButton`（规则 86）。本阶段不实现。

## 各屏 `reset()` 实际调用

| Screen | Order | Restores |
| --- | --- | --- |
| 基类 `DensityBuoyancyModel.reset` | gravity，pool，每个 `availableMasses` 的 `mass.reset()` | 重力回 Earth。池液体回初始（水、初始体积）。物体位置回 `originalMatrix`，材料/体积/力插值/抓取状态复位 |
| Compare | 基类路径 + `CompareBlockSetModel` 自己的 block set reset | Same Mass 模式与滑条。需要在 PHASE 1 逐行核对 `BlockSetModel.reset`，本阶段确认入口会调到 mass.reset 与 mode |
| Explore | `modeProperty.reset()` 然后 `super.reset()` | One Block。块 A/B 回 wood / aluminum 与初始质量 |
| Lab | `super.reset()` 然后再次 `block.reset()` | 重力控件回 Earth。流体回水。力显示与质量显示回默认（displayProperties） |
| Shapes | `super.reset()` 然后 objectA/B、`modeProperty`、`materialProperty` | 形状回 Block，比例回 0.25 / 0.75，材料回 wood，One Block |
| Applications | bottle、block、boat `reset()`，然后 `super.reset()`，然后 `applicationModeProperty.reset()` | 回到 bottle 场景 |

`Mass.reset`（`resetInternalVisibleProperty` 默认 true）复位：可见性、形状、材料、体积、containedMass、userControlled、三个力的 InterpolatedProperty、grab-drag tracker。位置通过 `resetPosition` 回到 `originalMatrix`（`setResetLocation` 在初始摆放之后调用）。

`implementation-notes.md`：`internalVisibleProperty` 常常在 reset 函数的最后才复位，这样可见物体和当前场景一致。Applications 先 reset 物体再 `super`，再复位 mode。

## Boat 的第二个按钮

Applications 在 boat 场景有 `RectangularPushButton`，不是 Reset All。listener 是 `resetBoatAndBlockPosition()`：

- 打断拖拽
- 船和块回到初始位置
- 清空船舱液体，溢出标志清零
- `pool.reset(false, false)`

它不重置瓶子材料、不重置流体选择、不重置 displayProperties。注释写明目的是让沉船重新浮起来。

## 会恢复的状态

| Item | Reset All | Boat re-float button |
| --- | --- | --- |
| 物体位置、速度由引擎写回 | yes | 船和块 |
| 材料 / 质量 / 体积 / 形状 | yes | no |
| 池液体种类与体积 | yes | `pool.reset(false, false)`，两个 false 的含义要在 PHASE 1 读 `Pool.reset` 签名再定。本阶段只记录调用 |
| 重力 | yes | no |
| 力箭头、质量读数、深度线、vector zoom | yes，经 `displayProperties.reset()` | no |
| One/Two、Same Mass/Volume/Density、bottle/boat | yes | no |
| 屏幕选择 | no | no |
| 偏好设置（`DensityBuoyancyCommonPreferencesNode`） | UNKNOWN。Reset All listener 没有调用 preferences reset | no |

## 不恢复

静态 `Material.WOOD.density` 等命名材料密度。它们不是用户状态。

Query 参数（`gEarth`、`volumeUnits`、p2 系数）在启动时读入，Reset 不重读 URL。
