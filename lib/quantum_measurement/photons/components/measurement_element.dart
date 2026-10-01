/// PolarizingBeamSplitterNode — enclosure + diagonal line.
library;

import 'package:flutter/material.dart';

import '../qm_photons_colors.dart';

class PolarizingBeamSplitterNode extends StatelessWidget {
  const PolarizingBeamSplitterNode({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    // Label is drawn below the enclosure without affecting the enclosure's
    // Positioned center (matches source: label under PBS cube).
    return SizedBox(
      width: size.width,
      height: size.height + 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height,
                    color: QmPhotonsColors.splitterEnclosure,
                  ),
                  CustomPaint(
                    size: size,
                    painter: const _DiagonalPainter(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: size.height + 4,
            width: size.width + 40,
            child: const Text(
              'Polarizing\nBeam Splitter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  const _DiagonalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QmPhotonsColors.splitterLine
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// MirrorNode — short diagonal reflector.
class MirrorNode extends StatelessWidget {
  const MirrorNode({super.key, required this.length});

  final double length;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length),
      painter: const _MirrorPainter(),
    );
  }
}

class _MirrorPainter extends CustomPainter {
  const _MirrorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8888AA)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
