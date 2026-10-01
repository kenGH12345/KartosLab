/// BlochSphereNode projection — mirrors `js/common/view/BlochSphereNode.ts`.
library;

import 'dart:math' as math;
import 'dart:ui';

/// Source constants from BlochSphereNode.ts
const blochSphereRadius = 100.0;
const equatorInclinationDegrees = 10.0;
const xAxisOffsetDegrees = 20.0;
const axesLineWidth = 0.4;
const labelsOffset = 5.0;

class BlochProjection {
  BlochProjection({
    this.radius = blochSphereRadius,
    this.equatorInclinationRadians = equatorInclinationDegrees * math.pi / 180,
    this.xAxisOffsetRadians = xAxisOffsetDegrees * math.pi / 180,
  });

  final double radius;
  final double equatorInclinationRadians;
  final double xAxisOffsetRadians;

  double get equatorSemiMajor => radius;
  double get equatorSemiMinor => math.sin(equatorInclinationRadians) * equatorSemiMajor;

  /// Equator ring point (azimuth in Bloch φ convention).
  Offset pointOnTheEquator(double azimuth, [double? xOffset]) {
    final off = xOffset ?? xAxisOffsetRadians;
    return Offset(
      equatorSemiMajor * math.sin(azimuth + off),
      equatorSemiMajor * math.cos(azimuth + off) * math.sin(equatorInclinationRadians),
    );
  }

  /// Full sphere surface point from (φ, θ).
  /// Source:
  ///   x = R sin(φ+off) sin(θ)
  ///   y = R (−cos(θ) + cos(φ+off) sin(incl) sin(θ))
  Offset pointOnTheSphere(double azimuth, double polar, [double? xOffset]) {
    final off = xOffset ?? xAxisOffsetRadians;
    final x = equatorSemiMajor * math.sin(azimuth + off) * math.sin(polar);
    final y = equatorSemiMajor *
        (-math.cos(polar) +
            math.cos(azimuth + off) *
                math.sin(equatorInclinationRadians) *
                math.sin(polar));
    return Offset(x, y);
  }

  Offset stateVectorTip({required double polar, required double azimuthal}) =>
      pointOnTheSphere(azimuthal, polar);

  Offset get plusX => pointOnTheEquator(0);
  Offset get minusX => pointOnTheEquator(math.pi);
  Offset get plusY => pointOnTheEquator(math.pi / 2);
  Offset get minusY => pointOnTheEquator(-math.pi / 2);
  Offset get plusZ => Offset(0, -radius);
  Offset get minusZ => Offset(0, radius);
}

class BlochViewGeometry {
  const BlochViewGeometry({
    required this.center,
    required this.radius,
    required this.vectorTip,
    required this.plusX,
    required this.minusX,
    required this.plusY,
    required this.minusY,
    required this.plusZ,
    required this.minusZ,
    required this.equatorSemiMajor,
    required this.equatorSemiMinor,
  });

  final Offset center;
  final double radius;
  final Offset vectorTip;
  final Offset plusX, minusX, plusY, minusY, plusZ, minusZ;
  final double equatorSemiMajor;
  final double equatorSemiMinor;

  factory BlochViewGeometry.fromState({
    required Offset center,
    required double polar,
    required double azimuthal,
    BlochProjection? projection,
    double scale = 1.0,
  }) {
    final p = projection ?? BlochProjection(radius: blochSphereRadius * scale);
    final tipLocal = p.stateVectorTip(polar: polar, azimuthal: azimuthal);
    Offset map(Offset o) => center + o;
    return BlochViewGeometry(
      center: center,
      radius: p.radius,
      vectorTip: map(tipLocal),
      plusX: map(p.plusX),
      minusX: map(p.minusX),
      plusY: map(p.plusY),
      minusY: map(p.minusY),
      plusZ: map(p.plusZ),
      minusZ: map(p.minusZ),
      equatorSemiMajor: p.equatorSemiMajor,
      equatorSemiMinor: p.equatorSemiMinor,
    );
  }
}
