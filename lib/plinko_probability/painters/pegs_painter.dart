import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/galton_board.dart';
import '../plinko_constants.dart';
import '../transform/plinko_mvt.dart';
import 'peg_raster.dart';

/// Peg lattice — `PegsNode.js` (drawImage of pre-baked peg + shadow bitmaps).
class PegsPainter extends CustomPainter {
  PegsPainter({
    required this.board,
    required this.mvt,
    required this.probability,
    this.rotatePegs = false,
  });

  final GaltonBoard board;
  final PlinkoMvt mvt;
  final double probability;
  final bool rotatePegs;

  /// Must match [PegRaster.ensureLoaded] pixelRatio.
  static const bakePixelRatio = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (!PegRaster.isReady) return;

    final n = board.numberOfRows;
    // PegsNode: pegScale = (minRow+1)/(nRows+1); image drawn in layout px × layoutScale.
    final pegScale =
        (PlinkoConstants.rowsMin + 1) / (n + 1) * mvt.layoutScale;

    final pegImg = rotatePegs ? PegRaster.flatPeg! : PegRaster.circlePeg!;
    final shadowImg = PegRaster.shadow!;

    // PhET: pegWidth = pegScale * canvas.width (CSS/layout px of toCanvas).
    // Our bake is at bakePixelRatio device px → divide to recover layout px.
    final pegDrawW = pegScale * (pegImg.width / bakePixelRatio);
    final pegDrawH = pegScale * (pegImg.height / bakePixelRatio);
    final shadowDrawW = pegScale * (shadowImg.width / bakePixelRatio);
    final shadowDrawH = pegScale * (shadowImg.height / bakePixelRatio);

    final pegSpacing = GaltonBoard.getPegSpacing(n);
    final shadowOffset = Offset(
      mvt.modelToViewDeltaX(pegSpacing * 0.08),
      mvt.modelToViewDeltaY(-pegSpacing * 0.24),
    );

    final pegAngle =
        rotatePegs ? -(math.pi / 4) + (probability * math.pi / 2) : 0.0;

    for (final peg in board.visiblePegs) {
      final c = mvt.modelToView(peg.position);
      final shadowPos = c + shadowOffset;

      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
          center: shadowPos,
          width: shadowDrawW,
          height: shadowDrawH,
        ),
        image: shadowImg,
        filterQuality: FilterQuality.high,
      );

      canvas.save();
      canvas.translate(c.dx, c.dy);
      if (rotatePegs) canvas.rotate(pegAngle);
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
          center: Offset.zero,
          width: pegDrawW,
          height: pegDrawH,
        ),
        image: pegImg,
        filterQuality: FilterQuality.high,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PegsPainter oldDelegate) =>
      oldDelegate.board.numberOfRows != board.numberOfRows ||
      oldDelegate.probability != probability ||
      oldDelegate.mvt.viewBoardWidth != mvt.viewBoardWidth ||
      oldDelegate.rotatePegs != rotatePegs;
}
