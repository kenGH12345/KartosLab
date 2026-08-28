# How-To：在随 setState 频繁重建的场景使用受控 TextField

> 来源: `req-drag-lesson-editor` · m4 修复（受控 `_ControlledTextField`）+ 先例 `_RouteRow`（process.txt T9）| 创建时间: 2026-08-28
> 经验单一源: `requirements/req-drag-lesson-editor/notes.md` §8 经验 4（"有先例仍复发" → 沉淀为项目级 checklist）。

## 适用场景

Flutter 表单输入框（`TextField` / `TextFormField`）**随父级 `setState` 频繁重建**时——例如属性面板在输入过程中因其他状态（如冲突检测刷新、连带联动）触发 rebuild。

**反模式（会丢焦点/光标跳位）**：在 `build()` 里 `TextEditingController(text: ...)` 每次重建 controller。表现为用户输入时光标跳到末尾或焦点丢失，且 controller 未 dispose 泄漏。

> 本项目已两次踩此坑：`_RouteRow`（T9 阶段先例已改）与 `NodePropertyPanel` 的 5 处 TextField（m4 复发）。凡命中"适用场景"必须用受控写法，不要在 build 里造 controller。

## 通用模式：受控 StatefulWidget

```
┌─ _ControlledTextField extends StatefulWidget
│    ├─ 外部传入 value（当前值） + onChanged 回调 + key（挂在外层）
│    └─ State:
│         ├─ initState        建一次 controller（text: widget.value）
│         ├─ didUpdateWidget  仅当外部 value 与当前文本不一致才 controller.text = value
│         │                   （切换节点/导入等外部来源变化）并把光标收敛到末尾；
│         │                   用户输入时（value == text）不打断光标
│         └─ dispose          controller.dispose()
└─ 用户输入 → onChanged(text) → 父级 model 更新（value 下一帧回流，但 == text 故不打断）
```

关键点：
1. **`initState` 建一次**：`_controller = TextEditingController(text: widget.value)`。
2. **`didUpdateWidget` 只在外部 value 真变时同步**：
   ```dart
   @override
   void didUpdateWidget(covariant _ControlledTextField old) {
     super.didUpdateWidget(old);
     if (widget.value != _controller.text) {          // 外部来源变化（切换节点/导入）
       _controller.text = widget.value;
       _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
     }
     // value == text（用户自己刚输入回流的值）→ 不动，光标不跳
   }
   ```
3. **`dispose` 释放** controller，避免泄漏。
4. **key 挂在外层 widget**：测试 `enterText(find.byKey(...))` 会向下查找后代 `EditableText`，外层挂 key 兼容。

参考实现：`lib/lesson_editor/screens/lesson_editor_screen.dart` 的 `_ControlledTextField`（5 处 meta/title TextField 复用）。

## 验证清单（交互类 AC 至少 widget 级断言）

> 来源: 同需求经验 5——首轮 3 Blocker 中 2 个（title/version+description 不可编辑）正是缺"字段可编辑→回调触发→模型更新"widget 断言的直接后果。

新增/改动可编辑字段后，widget 测试至少覆盖：

- [ ] **可编辑→回调→模型更新**：`enterText` 后断言 `onChanged` 触发且模型字段更新（不要只靠手动运行）。
- [ ] **外部 rebuild 不丢光标**：外部 `setState` rebuild（value 未变）后断言光标 offset 保持不变（老实现会重建 controller 使光标跳末尾）。参考 `test/lesson_editor/node_property_panel_test.dart` "m4 · 外部 rebuild 保持光标位置"。
- [ ] **外部 value 变化才同步**：切换数据源（如切换选中节点）后断言输入框显示新值。

## 跨引用

- UI 渲染框架（状态上提原则）: [../frontend/ui-framework.md](../frontend/ui-framework.md)
- 状态管理与不可变模式: [../frontend/drag-drop-workspace.md](../frontend/drag-drop-workspace.md)「状态管理与不可变模式」节
- 剧本编辑器模块登记: [../systems/module-index.md](../systems/module-index.md)「剧本编辑器模块」
