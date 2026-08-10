import 'package:flutter/material.dart';

import '../chart/snapshot_chart.dart';
import 'conclusion_panel.dart';
import 'experiment_logger.dart';
import 'inquiry_models.dart';
import 'inquiry_task_panel.dart';

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
