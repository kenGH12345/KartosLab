import 'package:flutter/material.dart';

import '../../constants/qwi_constants.dart';
import '../../domain/display_slit_layout.dart';
import '../../domain/slit_configuration.dart';
import 'qwi_colors.dart';

/// PhET `DoubleSlitNode` + distance span + drag arrow (HI/SP).
class QwiDoubleSlitBarrier extends StatelessWidget {
  const QwiDoubleSlitBarrier({
    super.key,
    required this.waveSize,
    required this.barrierFraction,
    required this.slitSeparation,
    required this.slitSeparationMin,
    required this.slitSeparationMax,
    required this.config,
    required this.regionWidthMeters,
    required this.onBarrierFractionChanged,
    this.topDetectorHits = 0,
    this.bottomDetectorHits = 0,
  });

  final Size waveSize;
  final double barrierFraction;
  final double slitSeparation;
  final double slitSeparationMin;
  final double slitSeparationMax;
  final SlitConfiguration config;
  final double regionWidthMeters;
  final ValueChanged<double> onBarrierFractionChanged;
  final int topDetectorHits;
  final int bottomDetectorHits;

  static const double barrierViewWidth = 12;
  static const double arrowWidth = 40;
  /// Span / arrow sit near the bottom edge of the wave (original 5.00 μm chrome).
  static const double spanInsetFromBottom = 18;
  static const double arrowInsetFromBottom = 8;
  static const Color barrierFill = Color(0xFF939393);

  /// Tiny extra hit area only — chrome is drawn inside the wave.
  static const double belowWaveExtent = 4;

  @override
  Widget build(BuildContext context) {
    if (!config.hasBarrier) {
      return const SizedBox.shrink();
    }

    final layout = DisplaySlitLayout.compute(
      slitSeparation: slitSeparation,
      slitSeparationMin: slitSeparationMin,
      slitSeparationMax: slitSeparationMax,
      regionHeight: waveSize.height,
    );
    // Display slit width in wave-pixel coords (canonical 22 @ 385).
    final slitW = DisplaySlitLayout.displaySlitWidthPx *
        (waveSize.height / QwiConstants.waveRegionHeight);
    final frac = barrierFraction.clamp(
      QwiConstants.barrierPositionFractionMin,
      QwiConstants.barrierPositionFractionMax,
    );
    final barrierX = frac * waveSize.width - barrierViewWidth / 2;
    final centerY = waveSize.height / 2;
    final topSlitCy = centerY - layout.displaySlitSeparation / 2;
    final bottomSlitCy = centerY + layout.displaySlitSeparation / 2;
    final topBarrierBottom = topSlitCy - slitW / 2;
    final centralTop = topSlitCy + slitW / 2;
    final centralBottom = bottomSlitCy - slitW / 2;
    final bottomBarrierTop = bottomSlitCy + slitW / 2;

    final spanY = waveSize.height - spanInsetFromBottom;
    final arrowY = waveSize.height - arrowInsetFromBottom;
    final barrierCenterX = barrierX + barrierViewWidth / 2;

    final distanceLabel = _formatScreenDistance(
      regionWidthMeters: regionWidthMeters,
      barrierFraction: frac,
    );

    void applyDrag(double dx) {
      final delta = dx / waveSize.width;
      onBarrierFractionChanged(
        (frac + delta).clamp(
          QwiConstants.barrierPositionFractionMin,
          QwiConstants.barrierPositionFractionMax,
        ),
      );
    }

    return SizedBox(
      width: waveSize.width,
      height: waveSize.height + belowWaveExtent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: barrierX - 4,
            top: 0,
            width: barrierViewWidth + 8,
            height: waveSize.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => applyDrag(d.delta.dx),
              child: CustomPaint(
                key: const Key('qwi_double_slit_barrier'),
                painter: _BarrierColumnPainter(
                  barrierX: 4,
                  barrierW: barrierViewWidth,
                  topBarrierBottom: topBarrierBottom.clamp(0.0, waveSize.height),
                  centralTop: centralTop,
                  centralBottom: centralBottom,
                  bottomBarrierTop: bottomBarrierTop.clamp(0.0, waveSize.height),
                  waveH: waveSize.height,
                  topCovered: config.isTopSlitCovered,
                  bottomCovered: config.isBottomSlitCovered,
                  topDetector: config.hasDetectorOnTop,
                  bottomDetector: config.hasDetectorOnBottom,
                  slitW: slitW,
                ),
              ),
            ),
          ),
          // Detector count badges
          if (config.hasDetectorOnTop)
            _countBadge(
              left: barrierX + barrierViewWidth + 4,
              top: topBarrierBottom - 18,
              count: topDetectorHits,
              keyName: 'qwi_slit_det_top_count',
            ),
          if (config.hasDetectorOnBottom)
            _countBadge(
              left: barrierX + barrierViewWidth + 4,
              top: centralBottom + slitW + 2,
              count: bottomDetectorHits,
              keyName: 'qwi_slit_det_bottom_count',
            ),
          // Distance span
          CustomPaint(
            size: Size(waveSize.width, waveSize.height + belowWaveExtent),
            painter: _DistanceSpanPainter(
              leftX: barrierCenterX,
              rightX: waveSize.width,
              y: spanY,
              label: distanceLabel,
            ),
          ),
          // Green double-headed arrow
          Positioned(
            left: barrierCenterX - arrowWidth / 2,
            top: arrowY - 10,
            width: arrowWidth,
            height: 20,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) => applyDrag(d.delta.dx),
              child: CustomPaint(
                key: const Key('qwi_barrier_drag_arrow'),
                painter: const _DoubleHeadArrowPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _countBadge({
    required double left,
    required double top,
    required int count,
    required String keyName,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        key: Key(keyName),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: QwiColors.detectorOverlayFill,
          border: Border.all(color: QwiColors.detectorOverlayStroke),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '$count',
          style: const TextStyle(fontFamily: 'Arial', fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }

  /// PhET `formatFrontFacingScreenDistance` (µm / nm).
  static String _formatScreenDistance({
    required double regionWidthMeters,
    required double barrierFraction,
  }) {
    final useNm = regionWidthMeters < 1e-6;
    final multiplier = regionWidthMeters / QwiConstants.waveRegionWidth * (useNm ? 1e9 : 1e6);
    final pixels = (1 - barrierFraction) * QwiConstants.waveRegionWidth;
    final value = pixels * multiplier;
    final unit = useNm ? 'nm' : 'µm';
    return '${value.toStringAsFixed(2)} $unit';
  }
}

class _BarrierColumnPainter extends CustomPainter {
  _BarrierColumnPainter({
    required this.barrierX,
    required this.barrierW,
    required this.topBarrierBottom,
    required this.centralTop,
    required this.centralBottom,
    required this.bottomBarrierTop,
    required this.waveH,
    required this.topCovered,
    required this.bottomCovered,
    required this.topDetector,
    required this.bottomDetector,
    required this.slitW,
  });

  final double barrierX;
  final double barrierW;
  final double topBarrierBottom;
  final double centralTop;
  final double centralBottom;
  final double bottomBarrierTop;
  final double waveH;
  final bool topCovered;
  final bool bottomCovered;
  final bool topDetector;
  final bool bottomDetector;
  final double slitW;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = QwiDoubleSlitBarrier.barrierFill;
    final cover = Paint()..color = QwiColors.slitCoverFill;
    final detFill = Paint()..color = QwiColors.detectorOverlayFill.withValues(alpha: 0.4);
    final detStroke = Paint()
      ..color = QwiColors.detectorOverlayStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    void bar(double top, double bottom) {
      final h = (bottom - top).clamp(0.0, waveH);
      if (h <= 0) return;
      canvas.drawRect(Rect.fromLTWH(barrierX, top, barrierW, h), fill);
    }

    bar(0, topBarrierBottom);
    bar(centralTop, centralBottom);
    bar(bottomBarrierTop, waveH);

    if (topCovered) {
      canvas.drawRect(Rect.fromLTWH(barrierX, topBarrierBottom, barrierW, slitW), cover);
    }
    if (bottomCovered) {
      canvas.drawRect(Rect.fromLTWH(barrierX, centralBottom, barrierW, slitW), cover);
    }

    void detector(double slitTop) {
      final r = Rect.fromLTWH(barrierX, slitTop, barrierW, slitW);
      canvas.drawRect(r, detFill);
      canvas.drawRect(r, detStroke);
    }

    if (topDetector) detector(topBarrierBottom);
    if (bottomDetector) detector(centralBottom);
  }

  @override
  bool shouldRepaint(covariant _BarrierColumnPainter old) =>
      old.barrierX != barrierX ||
      old.topBarrierBottom != topBarrierBottom ||
      old.centralTop != centralTop ||
      old.centralBottom != centralBottom ||
      old.bottomBarrierTop != bottomBarrierTop ||
      old.topCovered != topCovered ||
      old.bottomCovered != bottomCovered ||
      old.topDetector != topDetector ||
      old.bottomDetector != bottomDetector ||
      old.slitW != slitW;
}

class _DistanceSpanPainter extends CustomPainter {
  _DistanceSpanPainter({
    required this.leftX,
    required this.rightX,
    required this.y,
    required this.label,
  });

  final double leftX;
  final double rightX;
  final double y;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(Offset(leftX, y), Offset(rightX, y), stroke);
    const tick = 4.0;
    canvas.drawLine(Offset(leftX, y - tick), Offset(leftX, y + tick), stroke);
    canvas.drawLine(Offset(rightX, y - tick), Offset(rightX, y + tick), stroke);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontFamily: 'Arial', fontSize: 12, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: (rightX - leftX - 16).clamp(8.0, 200.0));
    tp.paint(canvas, Offset((leftX + rightX) / 2 - tp.width / 2, y + tick + 1));
  }

  @override
  bool shouldRepaint(covariant _DistanceSpanPainter old) =>
      old.leftX != leftX || old.rightX != rightX || old.y != y || old.label != label;
}

class _DoubleHeadArrowPainter extends CustomPainter {
  const _DoubleHeadArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final fill = Paint()..color = const Color(0xFF74AD67);
    final path = Path()
      // left head
      ..moveTo(0, cy)
      ..lineTo(10, cy - 7)
      ..lineTo(10, cy - 3)
      ..lineTo(size.width - 10, cy - 3)
      ..lineTo(size.width - 10, cy - 7)
      ..lineTo(size.width, cy)
      ..lineTo(size.width - 10, cy + 7)
      ..lineTo(size.width - 10, cy + 3)
      ..lineTo(10, cy + 3)
      ..lineTo(10, cy + 7)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3D6B35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
