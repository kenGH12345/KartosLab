import 'package:flutter/material.dart';

import 'inquiry_models.dart';
import 'inquiry_task_panel.dart';
import 'prediction_panel.dart';

/// 实验说明 + 操作指引（通用引导组件 · 所有 sim 共用的"说明/指引"界面）。
///
/// 设计意图：解决"进入 sim 不知道要干嘛"的共性问题——
/// - 常驻一行展示 `description`（回答"这是什么实验"）
/// - 点击弹出完整说明 + 分步操作指引（复用 [InquiryTaskPanel] 的 question/steps/hint）
/// - `description` 为空但 `task` 非空时，退化为"查看操作指引"按钮
///
/// 放置位置：NineGridLayout 的空边格（topCenter / topRight / bottomCenter 等）。
/// 每个 sim 最多一个实例；`description` 与 `task` 均无内容时不渲染。
class ExperimentIntroPanel extends StatelessWidget {
  const ExperimentIntroPanel({
    super.key,
    required this.description,
    this.task,
    this.title = '实验说明',
    this.titleIcon = Icons.menu_book_outlined,
    this.color = const Color(0xFF1177AA),
  });

  /// 场景说明文案（scenario.description · 可空串）。
  final String description;

  /// 探究任务（InquiryTask? · 提供 question + steps 操作指引）。
  final InquiryTask? task;

  /// 弹窗标题（默认"实验说明"）。
  final String title;

  /// 头部图标。
  final IconData titleIcon;

  /// 主题色（各 sim 传自己的 accent 色）。
  final Color color;

  bool get _hasContent => description.isNotEmpty || task != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        // FittedBox scaleDown：centerAreaRatio>0.7 时边格变窄（如电路 0.85 → 62px），
        // Row 内容（icon+text）整体缩放避免溢出（本组件无 Slider，FittedBox 安全）
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Material(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showDialog(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(titleIcon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        description.isNotEmpty ? description : '查看操作指引',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_full_rounded, size: 14, color: color),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(titleIcon, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF073B54),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ],
                if (task != null) ...[
                  const SizedBox(height: 12),
                  InquiryTaskPanel(task: task, compact: true),
                ],
                if (task?.predictions.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  PredictionPanel(predictions: task!.predictions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
