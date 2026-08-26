import 'package:flutter/material.dart';

import 'inquiry_flow.dart';

/// 探究进度条：Drawer 顶部常驻，兼具进度指示与导航（IXD Spec v1.0 §5）。
///
/// - Completed 节点：实心绿圆 + 白勾，点击滚动回顾
/// - Active 节点：实心蓝圆 + 脉冲，点击滚动定位
/// - Locked 节点：空心灰圆，点击抖动 + SnackBar 提示
/// - 无预测题时猜测节点隐藏（§5.5 动态节点数）
class InquiryProgressBar extends StatelessWidget {
  const InquiryProgressBar({
    super.key,
    required this.controller,
    this.onStageTap,
  });

  final InquiryFlowController controller;

  /// 节点点击回调（导航逻辑由 Drawer 层处理：滚动/提示）。
  final ValueChanged<InquiryStage>? onStageTap;

  @override
  Widget build(BuildContext context) {
    final visible = InquiryStage.values.where(controller.stageVisible).toList();
    final (done, total) = controller.progress;
    final current = controller.currentStage;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text('探究进度',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade700)),
              const Spacer(),
              Text(
                controller.mode == InquiryMode.free ? '自由模式' : '$done/$total 已完成',
                style: TextStyle(
                    fontSize: 10,
                    color: done == total
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                Expanded(child: _Node(
                  stage: visible[i],
                  status: controller.statusOf(visible[i]),
                  isCurrent: visible[i] == current,
                  onTap: () => onStageTap?.call(visible[i]),
                )),
                if (i != visible.length - 1)
                  Expanded(
                    child: _Connector(
                      // 左侧连线绿 = 该节点已完成（§5.3 连接线上色规则）
                      filled: i < visible.length - 1 &&
                          controller.statusOf(visible[i]) ==
                              StageStatus.completed,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.stage,
    required this.status,
    required this.isCurrent,
    this.onTap,
  });

  final InquiryStage stage;
  final StageStatus status;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = status == StageStatus.completed;
    final active = status == StageStatus.active;
    return Tooltip(
      message: '${stage.title}·${done ? '已完成' : active ? '进行中' : '未解锁'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active && isCurrent)
                const _ActiveDot()
              else if (done)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                  child:
                      const Icon(Icons.check, size: 10, color: Colors.white),
                )
              else if (active)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2196F3),
                  ),
                  child: const Icon(Icons.play_arrow,
                      size: 10, color: Colors.white),
                )
              else
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                _shortLabel(stage),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: done || active ? FontWeight.w700 : FontWeight.w400,
                  color: done
                      ? const Color(0xFF2E7D32)
                      : active
                          ? const Color(0xFF1976D2)
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 节点短标签（§5.1 示意图：猜/任/操/记/归）。
  String _shortLabel(InquiryStage stage) => switch (stage) {
        InquiryStage.prediction => '猜',
        InquiryStage.task => '任',
        InquiryStage.operation => '操',
        InquiryStage.logging => '记',
        InquiryStage.conclusion => '归',
      };
}

/// 当前焦点节点的脉冲圆点（§5.3 Active：实心蓝圆 + 脉冲）。
class _ActiveDot extends StatefulWidget {
  const _ActiveDot();

  @override
  State<_ActiveDot> createState() => _ActiveDotState();
}

class _ActiveDotState extends State<_ActiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final scale =
            1 + 0.15 * (1 - (2 * _ctrl.value - 1).abs()); // 1.0→1.15→1.0
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2196F3),
            ),
            child: const Icon(Icons.play_arrow,
                size: 10, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: filled ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0),
    );
  }
}
