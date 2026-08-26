import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'inquiry_flow.dart';

/// 阶段卡片：五阶段状态机的统一视觉载体（IXD Spec v1.0 §3）。
///
/// 三态视觉规范（§3.2）：
/// - Locked：灰底 · 折叠 84px · 点击抖动 + 上层弹 SnackBar
/// - Active：白底 · 蓝边框 2px + 外发光 · 蓝点脉冲 · 内容完全展开
/// - Completed：绿底 · 折叠显示摘要 · 点击 Header 展开只读回顾
///
/// 展开/折叠动画 300ms easeInOutCubic（§8.1）；锁定抖动 300ms 弹性曲线。
class InquiryStageCard extends StatefulWidget {
  const InquiryStageCard({
    super.key,
    required this.stage,
    required this.status,
    required this.content,
    this.summary = '',
    this.lockedHint = '',
    this.reviewContent,
    this.reviewExpanded = false,
    this.onToggleReview,
  });

  final InquiryStage stage;
  final StageStatus status;

  /// Active 态的内容区。
  final Widget content;

  /// Completed 态折叠时 Footer 显示的一行摘要（如「3/3 正确」）。
  final String summary;

  /// Locked 态 Footer 显示的解锁提示。
  final String lockedHint;

  /// Completed 态展开回顾的只读内容；null 时回顾 [content]。
  final Widget? reviewContent;

  /// Completed 回顾是否展开（父级持有，点击 Header 回调切换）。
  final bool reviewExpanded;

  final VoidCallback? onToggleReview;

  @override
  State<InquiryStageCard> createState() => _InquiryStageCardState();
}

class _InquiryStageCardState extends State<InquiryStageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _onTap() {
    switch (widget.status) {
      case StageStatus.locked:
        // 抖动 + 由上层 SnackBar 提示（§3.2 Locked 交互）
        _shake.forward(from: 0);
        break;
      case StageStatus.completed:
        widget.onToggleReview?.call();
        break;
      case StageStatus.active:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final isLocked = status == StageStatus.locked;
    final isCompleted = status == StageStatus.completed;
    final expanded = status == StageStatus.active ||
        (isCompleted && widget.reviewExpanded);

    final (bg, border, titleColor) = switch (status) {
      StageStatus.locked => (
          Colors.grey.shade100,
          BorderSide(color: Colors.grey.shade300, width: 1),
          Colors.grey.shade500,
        ),
      StageStatus.active => (
          Colors.white,
          const BorderSide(color: Color(0xFF2196F3), width: 2),
          const Color(0xFF1976D2),
        ),
      StageStatus.completed => (
          Colors.green.shade50,
          const BorderSide(color: Color(0xFF4CAF50), width: 1),
          const Color(0xFF2E7D32),
        ),
    };

    // 回顾态展示 reviewContent（只读由下方固定的 IgnorePointer 层负责）。
    // 关键：不可按状态增删 IgnorePointer 包裹层——element 树结构变化会销毁
    // 子树 State，回顾将丢失学生作答（CON-007 实证：曾显示「N 题未验证」）。
    final body = isCompleted && widget.reviewContent != null
        ? widget.reviewContent!
        : widget.content;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        // 左右抖动 3 次 · 幅度 4px（§8.1）
        final t = _shake.value;
        final dx = t == 0 ? 0.0 : 4 * _sin01(t * 3) * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.fromBorderSide(border),
          boxShadow: status == StageStatus.active
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header 是唯一的展开/折叠触发区（§3.2）——若整卡可点，
              // Completed 回顾时点击内容区会误折叠卡片
              InkWell(
                onTap: status == StageStatus.active ? null : _onTap,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: _buildHeader(titleColor, status),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                // maintainState：折叠时内容 State 保留（CON-007 session 级持久化，
                // 展开/折叠不丢已验证预测与已写结论）；Locked 态无内容可保留。
                child: isLocked
                    ? const SizedBox(width: double.infinity)
                    : Visibility(
                        visible: expanded,
                        maintainState: true,
                        maintainAnimation: true,
                        child: IgnorePointer(
                          // 回顾态只读（§2.2 Completed 交互权限）
                          ignoring: isCompleted,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                            child: body,
                          ),
                        ),
                      ),
              ),
              // Locked 态整卡都是提示区（内容为空）→ Footer 也可点触发抖动
              isLocked
                  ? InkWell(onTap: _onTap, child: _buildFooter(status))
                  : _buildFooter(status),
            ],
          ),
        ),
      ),
    );
  }

  /// sin(2πt)（驱动左右往复抖动）。
  double _sin01(double t) => math.sin(t * 2 * math.pi);

  Widget _buildHeader(Color titleColor, StageStatus status) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (status == StageStatus.locked)
            Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade500)
          else if (status == StageStatus.active)
            const _PulseDot()
          else
            const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.stage.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          if (status == StageStatus.completed)
            Icon(
              widget.reviewExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 18,
              color: const Color(0xFF2E7D32).withAlpha(150),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(StageStatus status) {
    final text = switch (status) {
      StageStatus.locked => widget.lockedHint,
      StageStatus.active => null,
      StageStatus.completed => widget.summary,
    };
    if (text == null) return const SizedBox.shrink();
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withAlpha(15), width: 0.5),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          color: status == StageStatus.locked
              ? Colors.grey.shade500
              : const Color(0xFF2E7D32).withAlpha(180),
        ),
      ),
    );
  }
}

/// Active 阶段蓝点脉冲（§3.2：radio_button_checked 16px · 2s 循环呼吸）。
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
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
        // scale 1.0 → 1.1 → 1.0（§8.2 脉冲呼吸）
        final t = _ctrl.value;
        final scale = 1 + 0.1 * math.sin(t * 2 * math.pi).abs();
        return Transform.scale(
          scale: scale,
          child: const Icon(
            Icons.radio_button_checked,
            size: 16,
            color: Color(0xFF2196F3),
          ),
        );
      },
    );
  }
}
