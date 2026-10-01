import 'dart:ui';

/// Layout primitives for QWI — geometry only (no Widgets / Model).
///
/// Spec: `requirements/req-quantum-wave-interference/LAYOUT_SPEC.md`
enum QwiAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Spacing tokens S0–S7 from LAYOUT_SPEC §12.
abstract final class QwiSpacing {
  static const double s0 = 2;
  static const double s1 = 4;
  static const double s2 = 6;
  static const double s3 = 8;
  static const double s4 = 10;
  static const double s5 = 15;
  static const double s6 = 20;
  static const double s7 = 40;

  /// Primary vertical stack gap (detector → controls → graph).
  static const double stack = s3;

  /// Root screen margins.
  static const double margin = s5;

  /// Detector → snapshot column.
  static const double snapshotGap = s2;
}

/// Immutable axis-aligned box in design space (768×504).
class QwiRect {
  const QwiRect(this.left, this.top, this.width, this.height);

  factory QwiRect.fromLTWH(double l, double t, double w, double h) => QwiRect(l, t, w, h);

  factory QwiRect.fromFlutter(Rect r) => QwiRect(r.left, r.top, r.width, r.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  Rect get asRect => Rect.fromLTWH(left, top, width, height);

  QwiRect normalize(Size canvas) => QwiRect(
        left / canvas.width,
        top / canvas.height,
        width / canvas.width,
        height / canvas.height,
      );
}
