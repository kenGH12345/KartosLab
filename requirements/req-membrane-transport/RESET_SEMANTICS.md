# Membrane Transport · RESET_SEMANTICS

> PHASE 0 · 以源码为准  
> 证据：`MembraneTransportModel.reset/clearSolutes`, `MembraneTransportScreenView` ResetAll / Eraser

---

## 1. 两个不同动作（禁止混淆）

| 动作 | UI | 调用链 | 范围 |
|------|-----|--------|------|
| **Reset All** | 橙色 ResetAllButton | `model.reset()` + `view.reset()` | 模型属性 + 溶质 + 槽位蛋白 + 视图子组件 |
| **Erase Solutes** | EraserButton | `model.clearSolutes()` **only** | 仅清除溶质及相关蛋白内溶质；**保留**蛋白、电压、配体开关、速度等 |

---

## 2. model.reset()

```ts
reset(): void {
  this.resetEmitter.emit();
  this.updateSoluteCounts();
  this.clearDescriptionEventQueue();
}
```

### resetEmitter 监听（已确认）

| 目标 | 行为 |
|------|------|
| `soluteProperty` | → `'oxygen'` |
| `timeSpeedProperty` | → NORMAL |
| `isPlayingProperty` | → **true**（继续播放） |
| `chargesVisibleProperty` | → 默认（facilitatedDiffusion=true，其它 false） |
| `membranePotentialProperty` | → **-70** |
| `areLigandsAddedProperty` | → **false** |
| `ligandInteractionCueVisibleProperty` | → true |
| `crossingHighlightsEnabledProperty` | → true |
| `crossingSoundsEnabledProperty` | → true |
| `solutes` | **`length = 0`** |
| `membraneSlots` | 每个 `slot.reset()` → 移除蛋白 |
| `hasSodiumGlucoseCotransporterProperty` | reset |

### 明确不重置

| 项 | 说明 |
|----|------|
| `ligands` 数组 | **不清空**；配体实例常驻；仅通过 `areLigandsAddedProperty` 隐藏/失活 |
| Preferences（animateLipids / glucoseMetabolism / stereo） | 全局 Preferences，非 screen model reset |
| `model.time` | **不归零** — 源码仅有 `this.time += dt`，reset 路径无 `time = 0` `[已确认]` |

---

## 3. model.clearSolutes()（Eraser）

```ts
clearSolutes(): void {
  // 每个已填充蛋白 clearSolutes(slot)
  this.solutes.length = 0;
  this.updateSoluteCounts();
  this.clearDescriptionEventQueue();
}
```

**保留**：槽位蛋白、膜电位、配体开关、播放状态、选中溶质、checkbox、速度。  
Eraser `enabledProperty` = `hasAnySolutesProperty`。

---

## 4. view.reset()

`resetEmitter` 触发：

- `MembraneTransportDescriber.reset`
- `observationWindow.reset`
- `soluteConcentrationsAccordionBox.reset`（含展开状态等）
- `transportProteinPanel?.reset`
- `transportProteinToolboxGrabCueNode?.reset`

Reset All 按钮：

```ts
listener: () => {
  model.reset();
  this.reset();
}
```

---

## 5. Flutter 实现清单

| ID | 语义 | 必须 |
|----|------|------|
| R1 | Reset All = model + view 全量 | 是 |
| R2 | Eraser ≠ Reset All | 是 |
| R3 | Reset 后 isPlaying=true | 是 |
| R4 | Reset 后溶质空、槽位空、电位−70、溶质选 O₂ | 是 |
| R5 | Ligands 实例保留；开关回 false | 是 |
| R6 | Preferences 不随 Reset All | 是 |
| R7 | UI：`KratosResetAllButton`（工程规则 86） | 是 |

---

## 6. 测试用例（计划）

1. 加粒子 + 放蛋白 + 改电压 → Reset All → 全回默认  
2. 同上 → Eraser → 粒子空但蛋白与电压仍在  
3. Add Ligands → Reset → ligands 隐藏但数组长度仍为 14（7+7）  
4. Pause → Reset → 恢复 Playing  
5. Reset 后 descriptionEventQueue / flux 空
