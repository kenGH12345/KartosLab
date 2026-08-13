# 决策 & 踩坑 & 知识沉淀 — req-ui-interaction-polish

> 由 req-closer 收尾时整理（2026-08-11）。记录本需求从 intake 到验收的决策与踩坑，供后续需求（尤其"操作面板推广"）参考。

## 一、决策记录（带依据）

| 决策 | 选择 | 依据 |
|------|------|------|
| 操作面板统一位置 | 底部横排 · molarity 试点 | 用户 S1：molarity 试点验收通过后推广 9 屏（独立迭代）。避免一次性大改造成回归面失控 |
| overflow 存桩处理 | 合并入本需求 AC-6 | 用户 S2：HomeScreen 已重写，原 130x139 Column overflow 病灶大概率已随重写消除，只需验证 |
| 窄视口降级方案 | FittedBox scaleDown | AC-5.4 要求 320px 功能可达；允许折叠/缩放作为降级（风险 R1 缓解） |
| 评审 Major | 本轮全部修复不放行 | 用户 verdict（18:10）：Major-1/2/3 小而明确，修后恢复测试覆盖，避免债务累积 |

## 二、踩坑经验（坑 + 解决方案）

### 坑 1：CanvasProjection 与 SceneProjection 投影原点不一致 → 拖放错位
- **现象**：canvas 投影 origin 0.55H vs scene 投影 origin 0.5H，缩放后拖放元件错位、点不中。
- **根因**：`_onComponentDrop` 转换硬编码 `zoom:1`，而渲染/命中用 `zoom: _state.zoom`（0.6~2.0 可调）。
- **解决**：`_onComponentDrop` 用当前 `_state.zoom` 构造 SceneProjection（Major-1，circuit_screen.dart:179-183）。
- **提示**：涉及投影/命中坐标换算时，**缩放系数必须从组件内部状态读取**，不可用默认值硬编码。

### 坑 2：GestureDetector 含 onDoubleTap 时 onTapUp 延迟
- **现象**：测试 tap 后立即断言失败。
- **根因**：onDoubleTap 使 GestureDetector 等待双击判定，onTapUp 触发延迟。
- **解决**：测试 tap 后 pump 350ms 等待。

### 坑 3：footer 高度未从 centerH 扣除 → 边格被压近 0
- **现象**：molarity 固定高度合计占 maxHeight ~99.7%（0.837+0.16），320×480 下边格各 ~0.6px，控件不可见。
- **解决**：`centerH = (maxHeight - footerH) * side`（Major-2，nine_grid_layout.dart:91-97）。
- **提示**：布局中新增横向占用块时，**必须从主体容器高度中显式扣除**，否则按比例分配会挤压到不可用；footer 默认 null 不波及其他屏。

### 坑 4：SingleChildScrollView 包裹 Expanded → 布局崩溃 → 全局 hit test 失败
- **现象**：optics 屏返回键失效，实为布局崩溃导致整个屏 hit test 全局失败。
- **根因**：Expanded 在无界约束（滚动视图内）下崩溃。
- **解决**：移除 midRight 的 SingleChildScrollView 包裹（optics_screen.dart:202）。

### 坑 5：测试名实不符（tap 退化为存在性断言）
- **现象**：place 测试改 tap 后退化为托盘存在性断言，放置回归覆盖被移除。
- **解决**：Major-3 改为"拖放成功"验证（DropCanvas 内元件存在 + 无异常），恢复启用 place/select；delete/toggle/rotate 仍 skip。

## 三、对后续需求的提示

1. **操作面板推广迭代**：molarity 已沉淀模板（NineGridLayout.footer + ConcentrationBarPainter horizontal），后续 9 屏迁移直接复用；但 **circuit 顶部行布局空间不足**（~51px 放不下 compact Slider ~60px）是独立问题，需先评估顶部行布局方案。
2. **新增布局组件注意**：任何按比例分配高度的布局，新加横向/底部占用块时都要从主体扣除高度（见坑 3）。
3. **投影缩放**：凡涉及拖放/命中的 sim，缩放系数从组件状态读取（见坑 1）。
4. **测试断言**：含 onDoubleTap 的控件，交互测试需 pump 等待双击判定（见坑 2）。

## 四、实证债务 / 遗留

- **skip 测试**：circuit delete/toggle/rotate 3 个选中工具条测试 skip（设计空间限制非 bug），待顶部行布局方案独立评估后启用。
- **Minor-1~5**：见 `spec/最终需求.md §5`，均已登记，非阻塞。
- **Minor-3 缺 1920 视口测试**：molarity AC-5.5 当前仅 1600×900 覆盖，1920×1080 待补。
