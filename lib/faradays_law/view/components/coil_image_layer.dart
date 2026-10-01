import 'package:flutter/material.dart';

import '../../faradays_law_assets.dart';
import '../../faradays_law_constants.dart';

enum CoilKind { fourLoop, twoLoop }

/// Coil back or front mipmap layer — `CoilNode.js`.
class CoilImageLayer extends StatelessWidget {
  const CoilImageLayer({
    super.key,
    required this.kind,
    required this.front,
    required this.coilCenter,
    this.visible = true,
  });

  final CoilKind kind;
  final bool front;
  final Offset coilCenter;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final asset = switch ((kind, front)) {
      (CoilKind.fourLoop, true) => FaradaysLawAssets.fourLoopFront,
      (CoilKind.fourLoop, false) => FaradaysLawAssets.fourLoopBack,
      (CoilKind.twoLoop, true) => FaradaysLawAssets.twoLoopFront,
      (CoilKind.twoLoop, false) => FaradaysLawAssets.twoLoopBack,
    };

    final intrinsic = kind == CoilKind.fourLoop
        ? const Size(420, 468)
        : const Size(318, 468);
    final displayW = intrinsic.width * FaradaysLawConstants.coilImageScale;
    final displayH = intrinsic.height * FaradaysLawConstants.coilImageScale;

    var xOffset = FaradaysLawConstants.coilXOffset;
    if (kind == CoilKind.twoLoop) {
      xOffset += FaradaysLawConstants.coilTwoOffset;
    }
    final imageCenter = coilCenter + Offset(xOffset, 0);

    return Positioned(
      left: imageCenter.dx - displayW / 2,
      top: imageCenter.dy - displayH / 2,
      width: displayW,
      height: displayH,
      child: Image.asset(
        asset,
        width: displayW,
        height: displayH,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}
