# 拖拽逻辑完整文档

> 文件：`lib/screens/circuit_screen.dart`
> 核心原则：**当前选中谁就处理谁，焦点互斥**

---

## 状态变量

| 变量 | 类型 | 用途 |
|------|------|------|
| `_dragStartMousePos` | `Offset?` | 拖拽开始时鼠标位置（用来算相对偏移） |
| `_dragStartCompPos` | `Offset?` | 拖拽开始时元件位置（用来算新位置） |
| `_isToolboxDropActive` | `bool` | 工具箱拖拽进行中标志（防止 `_onDragEnd` 误创建导线） |

## `CircuitState` 中的拖拽字段

| 字段 | 类型 | 用途 |
|------|------|------|
| `selectedId` | `String?` | 当前选中对象 ID（元件或导线），**单值 = 自动互斥** |
| `draggingVertexId` | `String?` | 正在拖拽的顶点 ID |
| `dragVertexNewPos` | `Offset?` | 拖拽中顶点的实时位置 |
| `draggingControlPointWireId` | `String?` | 正在拖拽的控制点所属的导线 ID |
| `draggingControlPointIndex` | `int?` | 正在拖拽的控制点索引 |
| `dragPos` | `Offset?` | 拖拽中控制点的实时位置 |
| `creatingWireStartVertexId` | `String?` | 残留状态（应在每次操作后清除） |

---

## 流程图

```
用户按下鼠标（onDragStart）
│
├─ 分支A：已选中非导线元件（电池/电阻等）
│   └─ 直接准备拖拽该元件，跳过顶点/控制点检测 → return
│
└─ 分支B：选中导线 或 没选中任何东西
    │
    ├─ 1. 检测元件（hitTest）→ 命中 → 更新 selectedId 并准备拖拽 → return
    │   ★ 元件排在第一！修复"选中导线后点拖拽元件，顶点抢事件"
    │   ★ 拖拽时 _onComponentTap 不触发，必须在这里完成选中
    ├─ 2. 检测顶点（vertexAt）→ 命中 → 设置 draggingVertexId → return
    ├─ 3. 检测控制点（仅选中导线时）→ 命中 → 设置 draggingControlPoint* → return
    └─ 4. 空白区域 + 有选中 → 准备拖拽选中对象
```

```
用户移动鼠标（onDragMove）
│
├─ draggingControlPointWireId != null → 更新 dragPos（控制点跟随鼠标）
├─ draggingVertexId != null → 更新 dragVertexNewPos（顶点跟随鼠标）
└─ selectedId != null + 偏移量有效 → 计算 dx/dy，移动元件 + 其两个端点顶点
```

```
用户松开鼠标（onDragEnd）
│
├─ _isToolboxDropActive == true → 跳过（工具箱拖拽刚完成）
│
├─ draggingControlPointWireId != null
│   └─ 将控制点新位置写入导线，清除拖拽状态 → return
│
├─ draggingVertexId != null
│   ├─ 查找磁吸目标（40px 内）
│   │   ├─ 有 → _mergeVertices() 合并两个顶点
│   │   └─ 无 → 移动顶点到新位置
│   └─ 清除 _dragStartMousePos / _dragStartCompPos → return
│
└─ 清除 _dragStartMousePos / _dragStartCompPos（元件拖拽结束）
```

---

## 三个核心方法

### `_onDragStart(Offset worldPos)`

**职责**：判断"用户想拖拽什么"，设置对应状态，不移动任何东西。

**检测顺序（分支B）**：
1. **元件**（★ 排第一，因为拖拽时 `_onComponentTap` 不触发，必须在此完成选中）
2. 顶点
3. 控制点（仅选中导线时）
4. 空白区域（有选中则准备拖拽）

**关键设计**：`_onComponentTap` 先执行（设置 `selectedId`），`_onDragStart` 后执行（读取 `selectedId` 决定行为）。所以"先选中电池，再拖拽"时，`selectedId` 已经是电池 ID，分支A 生效。

---

### `_onDragMove(Offset worldPos)`

**职责**：根据当前拖拽状态，实时更新位置。

**三路分支（互斥）**：
1. 拖拽控制点 → 只更新 `dragPos`
2. 拖拽顶点 → 只更新 `dragVertexNewPos`
3. 拖拽元件 → 用相对偏移（`dx/dy`）移动元件 + 其两个端点顶点

**相对偏移算法**：
```dart
dx = worldPos.dx - _dragStartMousePos.dx;
dy = worldPos.dy - _dragStartMousePos.dy;
newCompX = _dragStartCompPos.dx + dx;  // 元件新位置
newCompY = _dragStartCompPos.dy + dy;
// 两个端点顶点同步移动相同 dx/dy
```

---

### `_onDragEnd()`

**职责**：结束拖拽，固化结果，清除中间状态。

**处理顺序**：
1. 守卫：`_isToolboxDropActive`（工具箱拖拽，直接跳过）
2. 控制点拖拽 → 写入导线
3. 顶点拖拽 → 磁吸合并 or 移动顶点
4. 元件拖拽 → 清除偏移记录（位置已在 `_onDragMove` 中实时更新）

---

## 焦点互斥机制

`selectedId` 是 `String?`（单值），所以：
- 选中电池时，`selectedId = "c1"`
- 再点击导线，`selectedId = "w1"`（电池自动取消选中）
- 再点击空白，`selectedId = null`（导线自动取消选中）

**没有额外的"清除之前选中"代码**——单值覆盖本身就是互斥。

---

## 已知 Bug 修复历史

| 版本 | 问题 | 修复 |
|------|------|------|
| Fix7 | 拖拽时元件跳到鼠标位置 | 改用相对偏移（`_dragStartMousePos` / `_dragStartCompPos`） |
| Bug1Fix | 工具箱拖拽后误创建导线 | `_isToolboxDropActive` 标志 + `_onDragEnd` 守卫 |
| T-1 | 手势冲突残留状态 | 每次添加元件/导线时同步清除所有拖拽中间状态 |
| v3 | 选中电池后拖拽，导线端点抢焦点 | 分支A：选中非导线元件时跳过顶点检测 |
| v4 | 选中导线后拖拽元件，顶点抢事件 | ①修复 `isWireSelected` 判断<br>②元件检测提到顶点之前 |
| **v5** | **`copyWith` 的 `??` 陷阱：所有清空操作都无效** | **`CircuitState.copyWith` 改用 sentinel 模式，`null` 能真正清空可空字段** |
