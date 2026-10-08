/// Shared visual primitives used by Classical / Quantum scenes (not a GenericCoinScene).
library;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/qm_typography.dart';
import '../../common/qm_visual.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class CoinsDashedDivider extends StatelessWidget {
  const CoinsDashedDivider({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return QmExperimentDividingLine(height: height);
  }
}

class StartMeasurementButton extends StatelessWidget {
  const StartMeasurementButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QuantumMeasurementColors.startMeasurementButton,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 72,
          height: 48,
          child: CustomPaint(painter: _ForwardArrowPainter()),
        ),
      ),
    );
  }
}

class _ForwardArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(size.width * 0.22, cy - 8)
      ..lineTo(size.width * 0.22, cy + 8)
      ..lineTo(size.width * 0.55, cy + 3)
      ..lineTo(size.width * 0.55, cy + 10)
      ..lineTo(size.width * 0.78, cy)
      ..lineTo(size.width * 0.55, cy - 10)
      ..lineTo(size.width * 0.55, cy - 3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NewCoinButton extends StatelessWidget {
  const NewCoinButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QuantumMeasurementColors.newCoinButton,
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(QmStrings.newCoin, style: TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}

class CoinsSectionTitle extends StatelessWidget {
  const CoinsSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: QmTypography.boldHeader.copyWith(
        decoration: TextDecoration.underline,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class CoinTestBoxFrame extends StatelessWidget {
  const CoinTestBoxFrame({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.borderWidth = 8,
  });

  final double width;
  final double height;
  final Widget child;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: QuantumMeasurementColors.testBoxRectangleStroke,
          width: borderWidth,
        ),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
