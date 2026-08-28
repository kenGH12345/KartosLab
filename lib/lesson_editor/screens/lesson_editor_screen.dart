import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/controls/kratos_combo_box.dart';
import '../../common/scenario/lesson_manifest.dart';
import '../../common/scenario/lesson_plan.dart';
import '../../common/scenario/lesson_sim_host.dart';
import '../../common/scenario/success_condition.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../canvas/lesson_canvas_view.dart';
import '../canvas/lesson_edge_painter.dart';
import '../conflict/conflict_checker.dart';
import '../conflict/conflict_rules.dart';
import '../models/editable_lesson_model.dart';
import '../panels/advance_editor.dart';
import '../panels/condition_tree_editor.dart';
import '../panels/node_tray.dart';
import '../panels/scene_selector.dart';
import '../validation/lesson_importer.dart';
import '../validation/lesson_saver.dart';
import '../validation/lesson_validator.dart';

/// 剧本编辑器主屏（九宫格 · T1/T2/T3/T4）。
///
/// 布局（80-kratos-sim-checklist L0-4 强制）：
/// - center：编排画布（≥70% · LessonCanvasView）
/// - midLeft：节点库托盘（NodeTray · DragTray 复用）
/// - midRight：属性面板（本阶段占位，后续接 PropertyControlPanel）
/// - topRight：校验/保存按钮（后续接 LessonValidator）
/// - footer：底部工具条（新建/导入/高级 JSON/删除）
class LessonEditorScreen extends StatefulWidget {
  const LessonEditorScreen({super.key});

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  EditableLessonModel _model = const EditableLessonModel();
  String? _selectedNodeId;
  int _nodeSeq = 0;

  /// T5 · 连线拖拽状态：源节点 id + 当前指针位置（null = 未在连线）。
  String? _edgeFromId;
  Offset? _edgePointer;

  /// T18 · 高级 JSON 模式开关（true = 全屏 JSON 编辑，false = 可视化画布）。
  bool _jsonMode = false;

  /// T19 · 冲突规则表（加载失败 → 降级态）。
  ConflictRuleSet _conflictRules = const ConflictRuleSet();

  /// T21 · 当前冲突警告列表（由 model 变化时重新 analyze）。
  List<ConflictWarning> _conflictWarnings = const [];

  @override
  void initState() {
    super.initState();
    _loadConflictRules();
  }

  /// T19/T21 · 加载规则表 + 刷新冲突标注。
  Future<void> _loadConflictRules() async {
    final rules = await ConflictRuleSet.load();
    if (!mounted) return;
    setState(() {
      _conflictRules = rules;
      _conflictWarnings = ConflictChecker.analyze(_model, rules);
    });
  }

  void _setModel(EditableLessonModel m) {
    setState(() {
      _model = m;
      _conflictWarnings = ConflictChecker.analyze(m, _conflictRules);
    });
  }

  /// T4 · 从托盘拖入新节点：生成 id + 默认位置（世界坐标 = 屏幕坐标）。
  ///
  /// 场景节点占位 scenario = {sim: '', scenarioId: ''}：保持 isEnd=false，
  /// 让属性面板可正常编辑 advance（F5 场景选择器未做前用占位引用）。
  /// 占位引用保存时由 LessonValidator 拦截（F5/T11 后续接入）。
  void _onNodeDrop(LessonNodeType type, Offset pos) {
    final id = 'n${++_nodeSeq}';
    final EditableNode node = type == LessonNodeType.end
        ? EditableNode(id: id, title: '课时完成')
        : EditableNode(
            id: id,
            title: '新场景节点',
            scenario: const LessonScenarioRef(sim: '', scenarioId: ''),
            advance: LessonAdvance(type: 'next'),
          );
    _setModel(
      _model.copyWith(
        nodes: [..._model.nodes, node],
        layout: {..._model.layout, id: pos},
      ),
    );
    setState(() => _selectedNodeId = id);
  }

  /// T4 · 拖动节点：增量更新 layout（clamp 画布外为负则允许，后续缩放再处理）。
  void _onNodeMoved(String id, Offset delta) {
    final cur = _model.layout[id] ?? Offset.zero;
    _setModel(
      _model.copyWith(
        layout: {..._model.layout, id: cur + delta},
      ),
    );
  }

  void _onNodeSelected(String id) => setState(() => _selectedNodeId = id);

  // ---------- T5 · 节点连线 ----------

  void _onEdgeDragStart(String fromId) {
    setState(() {
      _edgeFromId = fromId;
      _edgePointer = null;
    });
  }

  void _onEdgeDragUpdate(Offset globalPos) {
    setState(() => _edgePointer = globalPos);
  }

  /// 松开：命中目标节点 → 回写源节点 advance=onCompleted(to)。
  void _onEdgeDragEnd(Offset globalPos) {
    final fromId = _edgeFromId;
    if (fromId == null) return;
    final target = _hitTestNode(globalPos);
    if (target != null && target.id != fromId) {
      // 终点节点不允许作为"源"连线（二元绑定由保存前校验兜底）；
      // 这里只处理源为场景节点的情况（终点无 advance）。
      final fromNode = _model.nodes
          .where((n) => n.id == fromId)
          .firstOrNull;
      if (fromNode != null && !fromNode.isEnd) {
        _setModel(
          _model.updateNode(
            fromId,
            (n) => n.copyWith(
              advance: LessonAdvance(type: 'onCompleted', to: target.id),
            ),
          ),
        );
      }
    }
    setState(() {
      _edgeFromId = null;
      _edgePointer = null;
    });
  }

  /// 指针（画布局部坐标）命中节点卡片矩形（layout 即画布局部坐标）。
  EditableNode? _hitTestNode(Offset localPos) {
    for (final n in _model.nodes) {
      final pos = _model.layout[n.id];
      if (pos == null) continue;
      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        _nodeCardWidth,
        _nodeCardHeight,
      );
      if (rect.contains(localPos)) return n;
    }
    return null;
  }

  static const double _nodeCardWidth = 160;
  static const double _nodeCardHeight = 36;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('剧本编辑器'),
        actions: [
          IconButton(
            tooltip: '校验',
            icon: const Icon(Icons.verified_outlined),
            onPressed: _onValidatePressed,
          ),
          IconButton(
            tooltip: '保存',
            icon: const Icon(Icons.save_outlined),
            onPressed: _onSavePressed,
          ),
        ],
      ),
      body: _jsonMode
          ? _JsonEditorView(
              initialText: const JsonEncoder.withIndent('  ')
                  .convert(_model.toLessonPlanJson()),
              onApply: _applyJson,
              onCancel: () => setState(() => _jsonMode = false),
            )
          : NineGridLayout(
          center: LessonCanvasView(
          nodes: _model.nodes,
          layout: _model.layout,
          edges: _model.edges,
          selectedNodeId: _selectedNodeId,
          conflictEdgeKeys: {
            for (final w in _conflictWarnings)
              if (w.type == 'semantic' && w.fromNodeId != null && w.toNodeId != null)
                '${w.fromNodeId}:${w.toNodeId}',
          },
          // M2（代码评审）：dataFlow 类冲突不对应画布上的一条边（条件树叶子
          // 跨 sim 引用），改为把涉及节点（拥有该条件树的节点 + 被引用节点）
          // 都标记为冲突节点，交给 LessonNodeCard 渲染 ⚠ 角标。
          conflictNodeIds: {
            for (final w in _conflictWarnings)
              if (w.type == 'dataFlow') ...[
                if (w.fromNodeId != null) w.fromNodeId!,
                if (w.toNodeId != null) w.toNodeId!,
              ],
          },
          tempEdge:
              _edgeFromId == null || _edgePointer == null
                  ? null
                  : TempLessonEdge(
                      fromId: _edgeFromId!, pointer: _edgePointer!),
          onNodeDrop: _onNodeDrop,
          onNodeMoved: _onNodeMoved,
          onNodeSelected: _onNodeSelected,
          onEdgeDragStart: _onEdgeDragStart,
          onEdgeDragUpdate: _onEdgeDragUpdate,
          onEdgeDragEnd: _onEdgeDragEnd,
        ),
        midLeft: const NodeTray(),
        midRight: NodePropertyPanel(
          model: _model,
          node: _selectedNodeId == null
              ? null
              : _model.nodes
                  .where((n) => n.id == _selectedNodeId)
                  .firstOrNull,
          nodeIds: [for (final n in _model.nodes) n.id],
          onAdvanceChanged: _onAdvanceChanged,
          onScenarioChanged: _onScenarioChanged,
          onUnlockChanged: _onUnlockChanged,
          onMetaChanged: _onMetaChanged,
          onTitleChanged: _onTitleChanged,
        ),
        footer: _FooterBar(
          onNew: _onNewPressed,
          onImport: _onImportPressed,
          onAdvancedJson: _onAdvancedJsonPressed,
        ),
      ),
    );
  }

  /// T18 · 切换高级 JSON 模式（true：全屏 JSON 编辑视图）。
  void _onAdvancedJsonPressed() {
    setState(() => _jsonMode = !_jsonMode);
  }

  /// T18 · 应用 JSON 文本：解析 → 运行时校验 → 重建模型 → 切回可视化。
  ///
  /// 失败（AC-15）：不切回、提示错误；成功：重建 EditableLessonModel
  /// （保留现有 layout，因为 JSON 文本只含 schema 契约字段）。
  void _applyJson(String text) {
    final Map<String, dynamic> decoded;
    try {
      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('JSON 顶层必须是对象');
      }
      decoded = parsed;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON 解析失败：$e（已停留在高级模式）'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
      return;
    }
    try {
      // 复用运行时完整校验（fail loud → FormatException）
      LessonPlan.fromJson(
        decoded,
        scenarioPlayable: LessonSimHosts.scenarioPlayable(),
      );
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON 校验未通过：$e（已停留在高级模式）'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
      return;
    }
    // 校验通过：重建模型（布局保留；JSON 文本仅 schema 契约字段）
    final model = EditableLessonModel.fromLessonPlanJson(
      decoded,
      layout: _model.layout,
    );
    setState(() {
      _model = model;
      _selectedNodeId = null;
      _edgeFromId = null;
      _edgePointer = null;
      _jsonMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON 已应用并切回可视化')),
    );
  }

  /// F11 · 新建：重置为空模型（保留节点序号递增，避免 id 冲突）。
  void _onNewPressed() {
    setState(() {
      _model = const EditableLessonModel();
      _selectedNodeId = null;
      _edgeFromId = null;
      _edgePointer = null;
    });
  }

  /// F9 · 导入（T17）：列 manifest 剧本 → 选中 → 加载到画布。
  Future<void> _onImportPressed() async {
    final importer = const LessonImporter();
    final List<LessonManifestEntry> entries;
    try {
      entries = await importer.listAvailable();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败：$e'), backgroundColor: const Color(0xFFB91C1C)),
      );
      return;
    }
    if (!mounted) return;
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无已保存的剧本（先编排并保存）')),
      );
      return;
    }
    final picked = await showDialog<LessonManifestEntry>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择要导入的剧本'),
        children: [
          for (final e in entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e),
              child: Text('${e.name}（${e.id} · ${e.sim}）'),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;

    try {
      final model = await importer.importByEntry(picked);
      setState(() {
        _model = model;
        _selectedNodeId = null;
        _edgeFromId = null;
        _edgePointer = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导入剧本「${picked.name}」')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败（校验未通过或 JSON 损坏）：$e'),
            backgroundColor: const Color(0xFFB91C1C)),
      );
    }
  }

  /// T13 · 校验：运行 LessonValidator，结果弹 Dialog。
  void _onValidatePressed() {
    final result = LessonValidator.validate(_model);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result.isValid ? '校验通过' : '校验未通过（${result.errors.length} 项）'),
        content: SizedBox(
          width: 420,
          child: result.isValid
              ? const Text('剧本结构合法，可以保存。')
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final e in result.errors)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $e',
                              style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// T13/T16/T21 · 保存：校验（不通过阻止）→ 冲突警告确认（不阻止）→ 落盘。
  Future<void> _onSavePressed() async {
    final result = LessonValidator.validate(_model);
    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败：${result.errors.length} 项校验错误（点击校验查看详情）'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
      return;
    }
    // T21 · 冲突警告清单（C7 不阻止 · 弹确认框）
    if (_conflictWarnings.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${_conflictWarnings.length} 项冲突警告（可保存）'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final w in _conflictWarnings)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• [${w.label}] ${w.reason}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('仍要保存'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }
    final error = await const LessonSaver().save(_model);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      error == null
          ? const SnackBar(
              content: Text('保存成功：assets/lessons/<id>.json + .layout.json + manifest 已更新'),
            )
          : SnackBar(content: Text('保存失败：$error'), backgroundColor: const Color(0xFFB91C1C)),
    );
  }

  /// T9 · 更新选中节点的 advance（经 EditableLessonModel.updateNode 回写）。
  void _onAdvanceChanged(LessonAdvance? advance) {
    final id = _selectedNodeId;
    if (id == null) return;
    _setModel(
      _model.updateNode(id, (n) => n.copyWith(advance: advance)),
    );
  }

  /// T10 · 更新选中节点的场景引用（经 updateNode 回写）。
  void _onScenarioChanged(LessonScenarioRef? scenario) {
    final id = _selectedNodeId;
    if (id == null) return;
    _setModel(
      _model.updateNode(id, (n) => n.copyWith(scenario: scenario)),
    );
  }

  /// T12 · 更新选中节点的解锁条件（经 updateNode 回写）。
  void _onUnlockChanged(SuccessCondition? unlock) {
    final id = _selectedNodeId;
    if (id == null) return;
    _setModel(
      _model.updateNode(id, (n) => n.copyWith(unlock: unlock)),
    );
  }

  /// T13/B2 · 更新剧本元数据（lessonId/name/version/description/entry）。
  void _onMetaChanged({
    String? lessonId,
    String? name,
    String? version,
    String? description,
    String? entry,
  }) {
    _setModel(
      _model.copyWith(
        lessonId: lessonId ?? _model.lessonId,
        name: name ?? _model.name,
        version: version ?? _model.version,
        description: description ?? _model.description,
        entry: entry ?? _model.entry,
      ),
    );
  }

  /// B1（代码评审）· 更新选中节点的标题（经 updateNode 回写）。
  void _onTitleChanged(String title) {
    final id = _selectedNodeId;
    if (id == null) return;
    _setModel(
      _model.updateNode(id, (n) => n.copyWith(title: title)),
    );
  }
}

/// midRight：节点属性面板（T9/T10/T12/T13 · 元数据 + 场景 + 解锁 + advance）。
class NodePropertyPanel extends StatelessWidget {
  const NodePropertyPanel({
    super.key,
    required this.model,
    required this.node,
    required this.nodeIds,
    required this.onAdvanceChanged,
    required this.onScenarioChanged,
    required this.onUnlockChanged,
    required this.onMetaChanged,
    required this.onTitleChanged,
  });

  final EditableLessonModel model;
  final EditableNode? node;

  /// 画布所有节点 id（advance 目标 / 条件树叶子 nodeId 候选）。
  final List<String> nodeIds;

  final ValueChanged<LessonAdvance?> onAdvanceChanged;
  final ValueChanged<LessonScenarioRef?> onScenarioChanged;
  final ValueChanged<SuccessCondition?> onUnlockChanged;
  final void Function({
    String? lessonId,
    String? name,
    String? version,
    String? description,
    String? entry,
  }) onMetaChanged;

  /// B1（代码评审）· 选中节点标题变更。
  final ValueChanged<String> onTitleChanged;

  /// M2（代码评审）· 节点 id → 所属 sim，供条件树叶子跨 sim 引用判断。
  Map<String, String> get _nodeSims => {
        for (final n in model.nodes)
          if (n.scenario?.sim != null && n.scenario!.sim.isNotEmpty)
            n.id: n.scenario!.sim,
      };

  @override
  Widget build(BuildContext context) {
    final node = this.node;
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 剧本元数据（T13 · 校验前必填 lessonId/name/entry） ----
            const Text('剧本设置',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            _ControlledTextField(
              key: const ValueKey('meta-lessonId'),
              value: model.lessonId,
              labelText: 'lessonId',
              onChanged: (v) => onMetaChanged(lessonId: v),
            ),
            const SizedBox(height: 6),
            _ControlledTextField(
              key: const ValueKey('meta-name'),
              value: model.name,
              labelText: '剧本名称 (name)',
              onChanged: (v) => onMetaChanged(name: v),
            ),
            const SizedBox(height: 6),
            _ControlledTextField(
              key: const ValueKey('meta-version'),
              value: model.version,
              labelText: '版本 (version)',
              onChanged: (v) => onMetaChanged(version: v),
            ),
            const SizedBox(height: 6),
            _ControlledTextField(
              key: const ValueKey('meta-description'),
              value: model.description,
              labelText: '描述 (description)',
              maxLines: 2,
              onChanged: (v) => onMetaChanged(description: v),
            ),
            const SizedBox(height: 6),
            KratosComboBox<String>(
              label: '入口节点 (entry)',
              items: ['', ...nodeIds],
              itemLabels: const ['（未指定）'],
              value: model.entry ?? '',
              width: double.infinity,
              onChanged: (v) => onMetaChanged(entry: v.isEmpty ? null : v),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            if (node == null)
              const Text('属性面板\n\n选中节点后编辑其属性',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
            else ...[
              Text('id: ${node.id}', style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 4),
              _ControlledTextField(
                key: ValueKey('title-${node.id}'),
                value: node.title,
                labelText: '节点标题',
                onChanged: onTitleChanged,
              ),
              const SizedBox(height: 4),
              Text(node.isEnd ? '类型: 终点节点' : '类型: 场景节点',
                  style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
                  if (!node.isEnd) ...[
                    SceneSelector(
                      scenario: node.scenario,
                      onChanged: onScenarioChanged,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(node.unlock == null ? '解锁条件' : '解锁条件（未满足时节点锁定）',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF334155))),
                  const SizedBox(height: 4),
                  ConditionTreeEditor(
                    value: node.unlock,
                    nodeIds: nodeIds,
                    onChanged: onUnlockChanged,
                    nodeSims: _nodeSims,
                    ownerSim: node.scenario?.sim,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  AdvanceEditor(
                    advance: node.advance,
                    nodeIds: nodeIds,
                    selfId: node.id,
                    isEndNode: node.isEnd,
                    onChanged: onAdvanceChanged,
                    nodeSims: _nodeSims,
                    ownerSim: node.scenario?.sim,
                  ),
                ],
              ],
            ),
          ),
    );
  }
}

/// m4（代码评审）· 受控文本输入框：持有 [TextEditingController] 生命周期。
///
/// 此前 NodePropertyPanel 的各 TextField 每次 `build` 都
/// `TextEditingController(text: ...)` 重建 controller（未 dispose）。若用户
/// 输入过程中因其他状态变化（如 `_conflictWarnings` 刷新）触发 `setState`
/// 重建，光标位置/焦点会丢失或跳转。
///
/// 修复：改为受控 StatefulWidget，controller 只在 initState 建一次；
/// - 用户输入时（`value == controller.text`）不打断光标；
/// - 仅当外部来源（切换节点/导入剧本）改变 [value] 与当前文本不一致时，
///   才同步 controller 并把光标收敛到末尾。
/// key 由父级传入（如 `title-<id>`），切换节点时随 key 重建 State。
class _ControlledTextField extends StatefulWidget {
  const _ControlledTextField({
    super.key,
    required this.value,
    required this.labelText,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String value;
  final String labelText;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<_ControlledTextField> createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<_ControlledTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ControlledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 12),
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.labelText,
        labelStyle: const TextStyle(fontSize: 11),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// footer：底部工具条（F11 新建 / F9 导入 · T17 接入；高级 JSON T18 接入）。
class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.onNew,
    required this.onImport,
    required this.onAdvancedJson,
  });

  final VoidCallback onNew;
  final VoidCallback onImport;
  final VoidCallback onAdvancedJson;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B2B3D),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _FooterAction(
            icon: Icons.add_box_outlined,
            label: '新建',
            onTap: onNew,
          ),
          const SizedBox(width: 24),
          _FooterAction(
            icon: Icons.upload_file_outlined,
            label: '导入',
            onTap: onImport,
          ),
          const SizedBox(width: 24),
          _FooterAction(
            icon: Icons.code,
            label: '高级 JSON',
            onTap: onAdvancedJson,
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// 高级 JSON 编辑视图（T18 · F12 · AC-14/AC-15）。
///
/// - 等宽 TextField（`monospace`）承载 JSON 文本（MVP 无语法高亮 · T4）
/// - 格式化：jsonEncode(jsonDecode(text), indent: 2)（缩进统一）
/// - 应用并切回：onApply(text) 解析+校验+重建模型（失败停留提示）
/// - 取消：放弃编辑，切回可视化（不触碰当前模型）
class _JsonEditorView extends StatefulWidget {
  const _JsonEditorView({
    required this.initialText,
    required this.onApply,
    required this.onCancel,
  });

  final String initialText;
  final void Function(String text) onApply;
  final VoidCallback onCancel;

  @override
  State<_JsonEditorView> createState() => _JsonEditorViewState();
}

class _JsonEditorViewState extends State<_JsonEditorView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _format() {
    try {
      final decoded = jsonDecode(_controller.text);
      _controller.text = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法格式化：JSON 解析失败（$e）'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFFE2E8F0),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '在此编辑 lesson JSON…',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
        ),
        Container(
          color: const Color(0xFF0B2B3D),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _FooterAction(
                icon: Icons.auto_fix_high,
                label: '格式化',
                onTap: _format,
              ),
              const SizedBox(width: 24),
              _FooterAction(
                icon: Icons.check_rounded,
                label: '应用并切回',
                onTap: () => widget.onApply(_controller.text),
              ),
              const SizedBox(width: 24),
              _FooterAction(
                icon: Icons.close_rounded,
                label: '取消',
                onTap: widget.onCancel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
