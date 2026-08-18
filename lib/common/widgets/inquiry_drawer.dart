import 'package:flutter/material.dart';

import '../chart/snapshot_chart.dart';
import 'conclusion_panel.dart';
import 'experiment_logger.dart';
import 'inquiry_models.dart';
import 'inquiry_task_panel.dart';
import 'prediction_panel.dart';

/// 右侧探究工作流抽屉：任务卡 + 实验记录器 + 结论归纳。
///
/// 用 `Offstage` 常驻 widget 树（关闭时保持 ExperimentLogger/ConclusionPanel
/// 的内部 State——学生关闭面板再打开，记录与已写结论不丢）。
/// 宽度固定 280（项目允许硬编码控件面板宽度），窄视口下内部纵向滚动。
class InquiryDrawer extends StatefulWidget {
  const InquiryDrawer({
    super.key,
    required this.task,
    required this.columns,
    required this.snapshotProvider,
    this.open = false,
  });

  final InquiryTask? task;
  final List<ColumnDef> columns;
  final SnapshotProvider snapshotProvider;
  final bool open;

  @override
  State<InquiryDrawer> createState() => _InquiryDrawerState();
}

class _InquiryDrawerState extends State<InquiryDrawer> {
  // ExperimentLogger 记录行的镜像（经 onRowsChanged 同步）· 供 SnapshotChart 消费
  List<Map<String, dynamic>> _rows = [];
  int _verifiedCount = 0;
  bool _conclusionSubmitted = false;

  /// 阶段进度：预测（有预测题时按已验证题数点亮）→ 记录（≥1 条）→ 归纳（已提交）。
  /// 返回 [已完成节点数, 总节点数]，用于 [_ProgressBar] 渲染。
  (int, int) get _progress {
    final hasPrediction = widget.task?.predictions.isNotEmpty ?? false;
    final done = [
      !hasPrediction || _verifiedCount >= (widget.task?.predictions.length ?? 0),
      _rows.isNotEmpty,
      _conclusionSubmitted,
    ].where((b) => b).length;
    final total = 1 + (hasPrediction ? 1 : 0) + 1; // 记录 + (预测) + 归纳
    return (done, total);
  }

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
          child: SizedBox(
            width: 280,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressBar(progress: _progress),
                  const SizedBox(height: 8),
                  // 预测题置顶：预测阶段默认展开，进入即可先猜（做中学"猜测→验证"第一步）
                  if (task.predictions.isNotEmpty) ...[
                    PredictionPanel(
                      predictions: task.predictions,
                      onVerifiedChanged: (n) => setState(() => _verifiedCount = n),
                    ),
                    const SizedBox(height: 10),
                  ],
                  InquiryTaskPanel(task: task, compact: true),
                  const SizedBox(height: 10),
                  ExperimentLogger(
                    columns: widget.columns,
                    snapshotProvider: widget.snapshotProvider,
                    compact: true,
                    onRowsChanged: (rows) => setState(() => _rows = rows),
                  ),
                  if (widget.columns.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SnapshotChart(rows: _rows, columns: widget.columns),
                  ],
                  const SizedBox(height: 10),
                  ConclusionPanel(
                    question: task.question,
                    referenceConclusion: task.referenceConclusion,
                    compact: true,
                    onSubmittedChanged: (v) =>
                        setState(() => _conclusionSubmitted = v),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 做中学阶段进度条：猜测 → 记录 → 归纳（按数据自动点亮）。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final (int, int) progress;

  @override
  Widget build(BuildContext context) {
    final (done, total) = progress;
    final labels = <String>[];
    final hasPrediction = total == 3;
    if (hasPrediction) labels.add('猜测');
    labels.add('记录');
    labels.add('归纳');

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _ProgressDot(
            label: labels[i],
            active: i < done,
            done: i < done,
          ),
          if (i != labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                color: i < done - 1
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
              ),
            ),
        ],
      ],
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({
    required this.label,
    required this.active,
    required this.done,
  });

  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF2563EB)
        : active
        ? const Color(0xFF93C5FD)
        : const Color(0xFFCBD5E1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            border: Border.all(color: color, width: done ? 0 : 2),
          ),
          child: done
              ? const Icon(Icons.check, size: 8, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: done ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            fontWeight: done ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
