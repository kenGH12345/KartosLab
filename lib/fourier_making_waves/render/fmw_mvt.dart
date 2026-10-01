import 'dart:ui';

/// Model-view transform: map math (x,y) range → [Offset] in a chart rect.
///
/// Y is inverted (math up → screen up within [chartRect]).
class FmwMvt {
  const FmwMvt({
    required this.chartRect,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  final Rect chartRect;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  double get _xSpan => xMax - xMin;
  double get _ySpan => yMax - yMin;

  Offset modelToView(double x, double y) {
    final nx = _xSpan == 0 ? 0.5 : (x - xMin) / _xSpan;
    final ny = _ySpan == 0 ? 0.5 : (y - yMin) / _ySpan;
    return Offset(
      chartRect.left + nx * chartRect.width,
      chartRect.bottom - ny * chartRect.height,
    );
  }

  /// View delta for a positive model Δx (calipers measured width).
  double modelToViewDeltaX(double modelDeltaX) {
    if (_xSpan == 0) return 0;
    return modelDeltaX / _xSpan * chartRect.width;
  }

  (double, double) viewToModel(Offset p) {
    final nx =
        chartRect.width == 0 ? 0.5 : (p.dx - chartRect.left) / chartRect.width;
    final ny = chartRect.height == 0
        ? 0.5
        : (chartRect.bottom - p.dy) / chartRect.height;
    return (xMin + nx * _xSpan, yMin + ny * _ySpan);
  }

  /// Factory for the standard PhET chart rectangle size.
  factory FmwMvt.forChart({
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
    double width = 645,
    double height = 123,
  }) {
    return FmwMvt(
      chartRect: Rect.fromLTWH(0, 0, width, height),
      xMin: xMin,
      xMax: xMax,
      yMin: yMin,
      yMax: yMax,
    );
  }
}
