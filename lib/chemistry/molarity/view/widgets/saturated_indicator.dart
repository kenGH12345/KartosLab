import 'package:flutter/material.dart';

/// "Saturated!"（饱和）标签 · 对齐蓝本 SaturatedIndicatorNode。
///
/// [visible] 由上层监听 model 传入（本组件无状态）。
class SaturatedIndicator extends StatelessWidget {
  const SaturatedIndicator({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: const Text(
        'Saturated!',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFFB45309),
        ),
      ),
    );
  }
}
