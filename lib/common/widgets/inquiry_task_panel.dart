import 'package:flutter/material.dart';

import 'inquiry_models.dart';

/// 探究任务卡：展示 scenario 的探究问题与分步指引。
///
/// 只读展示 · 可折叠/展开（内部用 ExpansionTile）。
/// `task == null` 时不渲染任何内容（向后兼容：无 inquiryTask 的 scenario 不受影响）。
class InquiryTaskPanel extends StatelessWidget {
  const InquiryTaskPanel({super.key, required this.task, this.compact = false});

  final InquiryTask? task;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = task;
    if (t == null) return const SizedBox.shrink();
    final textSize = compact ? 11.0 : 13.0;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFEFF6FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFBFDBFE)),
      ),
      child: ExpansionTile(
        // 探究任务默认展开，确保学生第一时间看到任务内容
        initiallyExpanded: true,
        tilePadding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 2),
        childrenPadding: EdgeInsets.fromLTRB(compact ? 8 : 12, 0, compact ? 8 : 12, 8),
        leading: const Icon(Icons.science_outlined, size: 18, color: Color(0xFF2563EB)),
        title: Text('探究任务', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w800, color: const Color(0xFF1E3A8A))),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(t.question,
                style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A), height: 1.4)),
          ),
          if (t.steps.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final (i, step) in t.steps.indexed) _StepTile(index: i + 1, step: step, compact: compact),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.step, required this.compact});

  final int index;
  final InquiryStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textSize = compact ? 10.5 : 12.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child:           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: compact ? 9 : 11,
                backgroundColor: const Color(0xFF2563EB),
                child: Text('$index', style: TextStyle(fontSize: compact ? 9 : 11, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.instruction,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: textSize, color: const Color(0xFF334155), height: 1.35)),
                    if (step.hint != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_outlined, size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(step.hint!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: textSize - 1.5, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
