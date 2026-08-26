import 'package:flutter/material.dart';

import '../chart/snapshot_chart.dart';
import 'celebration_dialog.dart';
import 'conclusion_panel.dart';
import 'experiment_logger.dart';
import 'inquiry_flow.dart';
import 'inquiry_models.dart';
import 'inquiry_progress_bar.dart';
import 'inquiry_stage_card.dart';
import 'inquiry_task_panel.dart';
import 'prediction_panel.dart';

/// 右侧探究工作流抽屉：五阶段状态机（IXD Spec v1.0）。
///
/// 阶段：猜测 → 任务 → 操作 → 记录 → 归纳，一次一阶段渐进解锁；
/// 进度条可点击导航；Completed 阶段可展开只读回顾。
///
/// 用 `Offstage` 常驻 widget 树（关闭时保持各面板内部 State——学生关闭
/// 面板再打开，记录与已写结论不丢，CON-007）。
/// 宽度固定 280（项目允许硬编码控件面板宽度）。
class InquiryDrawer extends StatefulWidget {
  const InquiryDrawer({
    super.key,
    required this.task,
    required this.columns,
    required this.snapshotProvider,
    this.open = false,
    this.mode = InquiryMode.guided,
    this.onPredictionResult,
  });

  final InquiryTask? task;
  final List<ColumnDef> columns;
  final SnapshotProvider snapshotProvider;

  /// Drawer 是否展开。
  final bool open;

  /// 探究模式（§7.3）：guided 强引导（默认）| free 自由探索。
  final InquiryMode mode;

  /// 可选转发（T-P1-07 · 剧本模式专用）：PredictionPanel.onResultChanged
  /// 的 (verified, correct) 原样外发——现有内部消费（_correctPredictions /
  /// _flow.setVerifiedCount）不受影响；不传 = 现行为逐字节等价（AC-41/AC-R3）。
  /// 签名对齐 prediction_panel.dart:31 onResultChanged 模式。
  final void Function(int verified, int correct)? onPredictionResult;

  @override
  State<InquiryDrawer> createState() => _InquiryDrawerState();
}

class _InquiryDrawerState extends State<InquiryDrawer> {
  late final InquiryFlowController _flow;

  /// 实验记录行（受控状态源 · 供 ExperimentLogger/SnapshotChart 消费）。
  final List<Map<String, dynamic>> _rows = [];

  /// 各阶段卡片 GlobalKey（自动滚动定位用）。
  final Map<InquiryStage, GlobalKey> _cardKeys = {
    for (final s in InquiryStage.values) s: GlobalKey(),
  };

  /// Completed 阶段回顾展开态。
  final Set<InquiryStage> _reviewExpanded = {};

  InquiryStage? _lastFocus;
  bool _celebrated = false;

  /// 预测题答对数（Completed 摘要「答对 X/N」· 由 PredictionPanel 回调）。
  int _correctPredictions = 0;

  static const _maxRows = 20;

  @override
  void initState() {
    super.initState();
    _flow = InquiryFlowController(
      hasPredictions: _hasPredictions,
      totalPredictions: widget.task?.predictions.length ?? 0,
      mode: widget.mode,
    );
    _flow.addListener(_onFlowChanged);
  }

  bool get _hasPredictions =>
      widget.task?.predictions.isNotEmpty ?? false;

  @override
  void didUpdateWidget(InquiryDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 场景切换：全部探究状态重置（§7.1-8）。
    // 注：InquiryTask 未实现 ==，此处依赖引用相等——各 sim 均传
    // `scenario.inquiryTask`（scenario 缓存持有，引用稳定），换场景才会变。
    if (oldWidget.task != widget.task) {
      _rows.clear();
      _reviewExpanded.clear();
      _celebrated = false;
      _lastFocus = null;
      _correctPredictions = 0;
      _flow.reset(
        hasPredictions: _hasPredictions,
        totalPredictions: widget.task?.predictions.length ?? 0,
      );
    }
    if (oldWidget.mode != widget.mode) _flow.setMode(widget.mode);
  }

  @override
  void dispose() {
    _flow.removeListener(_onFlowChanged);
    _flow.dispose();
    super.dispose();
  }

  void _onFlowChanged() {
    if (!mounted) return;
    setState(() {});
    final focus = _flow.currentStage;
    if (_lastFocus != focus && widget.open) {
      _lastFocus = focus;
      _scrollToStage(focus);
    }
    // CON-006：全部完成 → 庆祝（只触发一次）
    if (_flow.completed && !_celebrated) {
      _celebrated = true;
      _celebrate();
    }
  }

  void _scrollToStage(InquiryStage stage) {
    final key = _cardKeys[stage];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
      );
    });
  }

  void _celebrate() {
    showCelebrationDialog(
      context,
      title: '探究闭环完成！',
      subtitle: '猜测 → 任务 → 操作 → 记录 → 归纳，全部完成',
      primaryLabel: '回顾实验',
      emoji: '🎉',
    );
  }

  // ---------- 记录操作（operation 与 logging 卡共用） ----------

  void _recordRow() {
    if (_rows.length >= _maxRows) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('记录已满（最多 20 条），请删除最早记录',
                style: TextStyle(fontSize: 12)),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    final snapshot = widget.snapshotProvider();
    setState(() => _rows.insert(0, {'ts': _now(), ...snapshot}));
    _flow.setLogRowCount(_rows.length);
  }

  String _now() {
    final t = DateTime.now();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}:${p(t.second)}';
  }

  void _deleteRowAt(int index) {
    if (index < 0 || index >= _rows.length) return;
    setState(() => _rows.removeAt(index));
    _flow.setLogRowCount(_rows.length);
  }

  void _clearRows() {
    if (_rows.isEmpty) return;
    setState(() => _rows.clear());
    _flow.setLogRowCount(0);
  }

  // ---------- 进度条导航 ----------

  void _onStageTap(InquiryStage stage) {
    final status = _flow.statusOf(stage);
    if (status == StageStatus.locked) {
      // §5.4：节点不可提前进入 → Snackbar 提示前一阶段
      _showLockedHint(stage);
      return;
    }
    _flow.focusOn(stage);
    if (status == StageStatus.completed) {
      setState(() => _reviewExpanded.add(stage));
    }
    _scrollToStage(stage);
  }

  void _showLockedHint(InquiryStage stage) {
    final prev = _previousStageName(stage);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('请先完成$prev', style: const TextStyle(fontSize: 12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _previousStageName(InquiryStage stage) {
    final visible = InquiryStage.values.where(_flow.stageVisible).toList();
    final idx = visible.indexOf(stage);
    return idx <= 0 ? '上一阶段' : '「${visible[idx - 1].title}」阶段';
  }

  // ---------- 阶段卡片组装 ----------

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    if (task == null) return const SizedBox.shrink();
    return Offstage(
      offstage: !widget.open,
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: const Color(0xFFF8FAFC).withAlpha(248),
          elevation: 4,
          // 高度 ≤ 视口 80%：进度条常驻顶部 + 卡片滚动；同时避免全高面板
          // 遮挡九宫格 topRight 的探究入口按钮（保持可关闭）
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SizedBox(
              width: 280,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InquiryProgressBar(
                        controller: _flow, onStageTap: _onStageTap),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          for (final stage in InquiryStage.values)
                            if (_flow.stageVisible(stage))
                              Padding(
                                key: _cardKeys[stage],
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildStageCard(stage),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageCard(InquiryStage stage) {
    final status = _flow.statusOf(stage);
    return InquiryStageCard(
      stage: stage,
      status: status,
      content: _stageContent(stage),
      reviewContent: _stageReview(stage),
      summary: _stageSummary(stage),
      lockedHint: _lockedHint(stage),
      reviewExpanded: _reviewExpanded.contains(stage),
      onToggleReview: () =>
          setState(() => _toggleSet(_reviewExpanded, stage)),
    );
  }

  void _toggleSet(Set<InquiryStage> set, InquiryStage stage) {
    if (!set.remove(stage)) set.add(stage);
  }

  /// Locked 卡片的 Footer 提示（§3.2：请先完成"X"阶段以解锁）。
  String _lockedHint(InquiryStage stage) {
    switch (stage) {
      case InquiryStage.prediction:
        return '验证全部猜测后解锁';
      case InquiryStage.task:
        return '请先完成「先猜一猜」以解锁';
      case InquiryStage.operation:
        return '请先完成「探究任务」以解锁';
      case InquiryStage.logging:
        return '记录数据后解锁';
      case InquiryStage.conclusion:
        return '请先记录实验数据以解锁';
    }
  }

  /// Completed 卡片的 Footer 摘要。
  String _stageSummary(InquiryStage stage) {
    switch (stage) {
      case InquiryStage.prediction:
        final total = widget.task?.predictions.length ?? 0;
        return '答对 $_correctPredictions/$total 题 · 点击展开回顾';
      case InquiryStage.task:
        final steps = widget.task?.steps.length ?? 0;
        return '已确认 · $steps 个步骤';
      case InquiryStage.operation:
        return '已记录 ${_flow.logRowCount} 组数据';
      case InquiryStage.logging:
        return '共 ${_flow.logRowCount} 组记录';
      case InquiryStage.conclusion:
        return '已提交结论 · 探究闭环完成';
    }
  }

  // ---------- 各阶段 Active 内容 ----------

  Widget _stageContent(InquiryStage stage) {
    final task = widget.task!;
    switch (stage) {
      case InquiryStage.prediction:
        // key 与 review 模式一致：active→completed 回顾切换时复用 State
        // （已验证的预测选择不丢）
        return PredictionPanel(
          key: ValueKey('prediction-${task.hashCode}'),
          predictions: task.predictions,
          onResultChanged: (verified, correct) {
            _correctPredictions = correct;
            _flow.setVerifiedCount(verified);
            // T-P1-07：可选转发（剧本模式）——现有内部消费不受影响
            widget.onPredictionResult?.call(verified, correct);
          },
        );
      case InquiryStage.task:
        return InquiryTaskPanel(
          task: task,
          compact: true,
          confirmed: _flow.taskConfirmed,
          onConfirm: () => _flow.setTaskConfirmed(true),
        );
      case InquiryStage.operation:
        return _buildOperationContent(task);
      case InquiryStage.logging:
        return _buildLoggingContent();
      case InquiryStage.conclusion:
        return ConclusionPanel(
          key: ValueKey('conclusion-${task.hashCode}'),
          question: task.question,
          referenceConclusion: task.referenceConclusion,
          compact: true,
          onSubmittedChanged: _flow.setConclusionSubmitted,
        );
    }
  }

  /// 操作阶段内容（§4.3.2）：操作指引 + 记录按钮。
  Widget _buildOperationContent(InquiryTask task) {
    final enabled =
        _flow.taskConfirmed || _flow.mode == InquiryMode.free;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mouse_outlined,
                size: 14, color: Color(0xFF1976D2)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '在画布上调节参数，观察现象变化',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        if (task.steps.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '任务要点：${task.steps.map((s) => s.instruction).join('；')}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10, color: Colors.grey.shade500, height: 1.4),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '提示：调整参数后，点击下方按钮记录当前实验数据！',
          style: TextStyle(fontSize: 10, color: Colors.amber.shade800),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: enabled ? _recordRow : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('记录本次实验', style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '当前已记录 ${_rows.length} 组数据',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  /// 记录阶段内容（§4.4.2）：表格 + 图表（受控模式）。
  Widget _buildLoggingContent() {
    final enabled =
        _flow.taskConfirmed || _flow.mode == InquiryMode.free;
    return Column(
      children: [
        ExperimentLogger(
          columns: widget.columns,
          snapshotProvider: widget.snapshotProvider,
          compact: true,
          maxRows: _maxRows,
          rows: _rows,
          onRecord: _recordRow,
          onDeleteAt: _deleteRowAt,
          onClear: _clearRows,
          enabled: enabled,
        ),
        if (widget.columns.isNotEmpty) ...[
          const SizedBox(height: 8),
          SnapshotChart(rows: _rows, columns: widget.columns),
        ],
        if (_flow.logRowCount >= 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              // §4.4.3：主动进入归纳阶段
              onPressed: () => _onStageTap(InquiryStage.conclusion),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('去写结论', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ],
    );
  }

  // ---------- Completed 回顾内容（只读） ----------

  Widget _stageReview(InquiryStage stage) {
    final task = widget.task!;
    switch (stage) {
      case InquiryStage.prediction:
        // key 与 active 模式一致 → 回顾展开时复用 State（显示真实判定结果）
        return PredictionPanel(
          key: ValueKey('prediction-${task.hashCode}'),
          predictions: task.predictions,
          review: true,
        );
      case InquiryStage.task:
        return InquiryTaskPanel(task: task, compact: true);
      case InquiryStage.operation:
        return _buildOperationContent(task);
      case InquiryStage.logging:
        return _buildLoggingContent();
      case InquiryStage.conclusion:
        // key 与 active 模式一致 → 回顾展示已提交结论与参考结论
        return ConclusionPanel(
          key: ValueKey('conclusion-${task.hashCode}'),
          question: task.question,
          referenceConclusion: task.referenceConclusion,
          compact: true,
        );
    }
  }
}
