import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 沉淀粒子 painter：在烧杯底部区域随机分布方形粒子。
///
/// 分布确定性：同 [seed] + 同 [particleCount] → 相同布局（测试稳定 · 拖拽不抖动）。
/// 粒子数 = model `numberOfParticles`（≤ particlesPerMole×沉淀量）。
class PrecipitatePainter extends CustomPainter {
  const PrecipitatePainter({
    required this.particleCount,
    required this.color,
    required this.particleSize,
    this.seed = 42,
  });

  final int particleCount;
  final Color color;
  final double particleSize;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (particleCount <= 0) return;
    final rng = math.Random(seed);
    final paint = Paint()..color = color;
    final half = particleSize / 2;

    // 分布区域：烧杯底部（高度 25% 内）· 左右各留粒子半径边距
    final areaTop = size.height * 0.75;
    for (var i = 0; i < particleCount; i++) {
      final x = half + rng.nextDouble() * (size.width - particleSize);
      // 越靠底部粒子越密（椭圆堆叠效果近似）
      final t = rng.nextDouble();
      final y = areaTop + t * t * (size.height - areaTop - particleSize);
      canvas.drawRect(Rect.fromLTWH(x, y, particleSize, particleSize), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PrecipitatePainter old) =>
      old.particleCount != particleCount ||
      old.color != color ||
      old.particleSize != particleSize ||
      old.seed != seed;
}
