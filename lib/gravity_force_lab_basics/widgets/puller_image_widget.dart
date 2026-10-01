import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../gflb_constants.dart';

/// Puller sprite attached to a mass (PhET `ISLCPullerNode`).
///
/// Hand / rope overlap matches `ISLCPullerNode.js`
/// (`right = -ropeLength + 0.1 * width`, `bottom = 42`).
class PullerImageWidget extends StatelessWidget {
  const PullerImageWidget({
    super.key,
    required this.frameIndex,
    required this.massCenter,
    required this.massRadiusView,
    required this.flipHorizontal,
  });

  /// 0..30 → figurePull_1..31.png
  final int frameIndex;
  final Offset massCenter;
  final double massRadiusView;
  final bool flipHorizontal;

  static const double intrinsicWidth = 134;
  static const double intrinsicHeight = 151;
  static const double imageBottomLocal = 42;
  static const double handOverlapFactor = 0.1;

  static String assetPath(int frameIndex) {
    final n = (frameIndex + 1).clamp(1, GflbConstants.pullerFrameCount);
    return '${GflbConstants.pullerAssetDir}/figurePull_$n.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPath(frameIndex);
    final ropeLen = GflbConstants.pullerRopeLength;
    final scale = GflbConstants.pullerImageScale;
    final w = intrinsicWidth * scale;
    final h = intrinsicHeight * scale;
    final handOverlap = handOverlapFactor * w;

    final edgeX = flipHorizontal
        ? massCenter.dx + massRadiusView
        : massCenter.dx - massRadiusView;
    final ropeFarX =
        flipHorizontal ? edgeX + ropeLen : edgeX - ropeLen;

    final double imageLeft;
    if (flipHorizontal) {
      imageLeft = ropeFarX - handOverlap;
    } else {
      final imageRight = ropeFarX + handOverlap;
      imageLeft = imageRight - w;
    }
    final imageTop = massCenter.dy + imageBottomLocal - h;

    Widget image = Image.asset(
      path,
      width: w,
      height: h,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: w,
        height: h,
        child: const ColoredBox(color: Color(0x33888888)),
      ),
    );

    if (flipHorizontal) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: image,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: const Size(
            GflbConstants.layoutWidth,
            GflbConstants.layoutHeight,
          ),
          painter: _RopePainter(
            from: Offset(edgeX, massCenter.dy),
            to: Offset(ropeFarX, massCenter.dy),
          ),
        ),
        Positioned(
          left: imageLeft,
          top: imageTop,
          child: image,
        ),
      ],
    );
  }
}

class _RopePainter extends CustomPainter {
  _RopePainter({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GflbColors.rope
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant _RopePainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}
