/// Multi-coin test box -?individual coins (10/100) or 100×100 canvas (10000).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/system_type.dart';
import '../../layout/qm_coins_layout_spec.dart';
import '../../qm_assets.dart';
import '../rendering/coin_render_mode.dart';
import '../rendering/coins_10k_painter.dart';

class MultiCoinDisplay extends StatelessWidget {
  const MultiCoinDisplay({
    super.key,
    required this.systemType,
    required this.measuredValues,
    required this.count,
    required this.revealed,
    this.size = QmCoinsLayoutSpec.multiCoinTestBoxSize,
  });

  final SystemType systemType;
  final List<String> measuredValues;
  final int count;
  final bool revealed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mode = coinRenderModeForCount(count);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: QuantumMeasurementColors.testBoxRectangleStroke,
          width: 2,
        ),
        gradient: revealed
            ? null
            : const LinearGradient(
                colors: [
                  QuantumMeasurementColors.testBoxGradientStart,
                  QuantumMeasurementColors.testBoxGradientEnd,
                ],
              ),
        color: revealed ? Colors.white : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: mode == CoinRenderMode.pixelCanvas
          ? CustomPaint(
              painter: Coins10kPainter(
                measuredValues: measuredValues,
                count: count,
                revealed: revealed,
                systemType: systemType,
                sideLength: const QmCoinsLayoutSpec().pixelGridSideLength,
              ),
              size: Size(size, size),
            )
          : _IndividualCoinsGrid(
              systemType: systemType,
              measuredValues: measuredValues,
              count: count,
              revealed: revealed,
              boxSize: size,
            ),
    );
  }
}

/// Deterministic grid positions for 10 / 100 coins.
Offset coinPositionForIndex({
  required int index,
  required int count,
  required double boxSize,
}) {
  final cols = count <= 10 ? 5 : 10;
  final rows = (count / cols).ceil().clamp(1, count);
  final cellW = boxSize / cols;
  final cellH = boxSize / rows;
  final col = index % cols;
  final row = index ~/ cols;
  return Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
}

class _IndividualCoinsGrid extends StatelessWidget {
  const _IndividualCoinsGrid({
    required this.systemType,
    required this.measuredValues,
    required this.count,
    required this.revealed,
    required this.boxSize,
  });

  final SystemType systemType;
  final List<String> measuredValues;
  final int count;
  final bool revealed;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    final cols = count <= 10 ? 5 : 10;
    final cell = boxSize / cols;
    final radius = (cell * 0.35).clamp(3.0, 10.0);

    return Stack(
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final center = coinPositionForIndex(
                index: i,
                count: count,
                boxSize: boxSize,
              );
              return Positioned(
                left: center.dx - radius,
                top: center.dy - radius,
                child: _MiniCoinCell(
                  radius: radius,
                  revealed: revealed,
                  value: revealed ? measuredValues[i] : 'hidden',
                  systemType: systemType,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MiniCoinCell extends StatelessWidget {
  const _MiniCoinCell({
    required this.radius,
    required this.revealed,
    required this.value,
    required this.systemType,
  });

  final double radius;
  final bool revealed;
  final String value;
  final SystemType systemType;

  @override
  Widget build(BuildContext context) {
    if (!revealed || value == 'hidden') {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QuantumMeasurementColors.maskedFill,
          border: Border.all(color: QuantumMeasurementColors.coinStroke),
        ),
      );
    }

    if (systemType == SystemType.quantum) {
      final isUp = value == 'up';
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUp
              ? QuantumMeasurementColors.upFill
              : QuantumMeasurementColors.downFill,
          border: Border.all(color: QuantumMeasurementColors.coinStroke),
        ),
        child: CustomPaint(
          painter: _MiniArrowPainter(
            up: isUp,
            color: isUp
                ? QuantumMeasurementColors.upColor
                : QuantumMeasurementColors.downColor,
          ),
        ),
      );
    }

    final isHeads = value == 'heads';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: QuantumMeasurementColors.headsFill,
        border: Border.all(color: QuantumMeasurementColors.coinStroke),
      ),
      child: Padding(
        padding: EdgeInsets.all(radius * 0.2),
        child: SvgPicture.asset(
          isHeads ? QmAssets.classicalCoinHeads : QmAssets.classicalCoinTails,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _MiniArrowPainter extends CustomPainter {
  const _MiniArrowPainter({required this.up, required this.color});

  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height * 0.55;
    final headH = h * 0.35;
    final headW = size.width * 0.45;
    final tailW = size.width * 0.14;
    final path = Path();
    if (up) {
      final tipY = cy - h / 2;
      final baseY = cy + h / 2;
      final neckY = tipY + headH;
      path
        ..moveTo(cx, tipY)
        ..lineTo(cx + headW / 2, neckY)
        ..lineTo(cx + tailW / 2, neckY)
        ..lineTo(cx + tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, neckY)
        ..lineTo(cx - headW / 2, neckY)
        ..close();
    } else {
      final tipY = cy + h / 2;
      final baseY = cy - h / 2;
      final neckY = tipY - headH;
      path
        ..moveTo(cx, tipY)
        ..lineTo(cx + headW / 2, neckY)
        ..lineTo(cx + tailW / 2, neckY)
        ..lineTo(cx + tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, neckY)
        ..lineTo(cx - headW / 2, neckY)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniArrowPainter old) =>
      old.up != up || old.color != color;
}
