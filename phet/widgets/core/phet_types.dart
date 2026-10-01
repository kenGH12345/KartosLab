/// Core type definitions for the PhET component library.
///
/// These types provide a simulation-agnostic foundation used across
/// physics, chemistry, and math simulations.
library;

import 'dart:math';
import 'package:flutter/material.dart' show Offset, Size, Rect, Color;

/// A 2D vector with standard vector operations.
class PhetVector {
  final double dx;
  final double dy;

  const PhetVector(this.dx, this.dy);
  const PhetVector.zero() : dx = 0, dy = 0;

  // ── Factory constructors ──
  factory PhetVector.fromOffset(Offset o) => PhetVector(o.dx, o.dy);
  factory PhetVector.fromAngle(double angle, double magnitude) =>
      PhetVector(magnitude * cos(angle), magnitude * sin(angle));

  // ── Conversions ──
  Offset toOffset() => Offset(dx, dy);

  // ── Operations ──
  PhetVector operator +(PhetVector o) => PhetVector(dx + o.dx, dy + o.dy);
  PhetVector operator -(PhetVector o) => PhetVector(dx - o.dx, dy - o.dy);
  PhetVector operator *(double s) => PhetVector(dx * s, dy * s);
  PhetVector operator -() => PhetVector(-dx, -dy);

  // ── Properties ──
  double get magnitude => sqrt(dx * dx + dy * dy);
  double get angle => atan2(dy, dx);
  double get magnitudeSquared => dx * dx + dy * dy;

  PhetVector normalized() {
    final m = magnitude;
    if (m < 1e-12) return const PhetVector.zero();
    return PhetVector(dx / m, dy / m);
  }

  double dot(PhetVector o) => dx * o.dx + dy * o.dy;
  double cross(PhetVector o) => dx * o.dy - dy * o.dx;

  @override
  String toString() => 'PhetVector(${dx.toStringAsFixed(2)}, ${dy.toStringAsFixed(2)})';
}

/// A numeric range [min, max].
class PhetRange {
  final double min;
  final double max;
  const PhetRange(this.min, this.max);
  const PhetRange.unit() : min = 0, max = 1;

  double get span => max - min;
  double clamp(double v) => v.clamp(min, max);
  double lerp(double t) => min + (max - min) * t.clamp(0.0, 1.0);
  double normalize(double v) => ((v - min) / (max - min)).clamp(0.0, 1.0);
  bool contains(double v) => v >= min && v <= max;
}

/// An integer range [min, max].
class PhetIntRange {
  final int min;
  final int max;
  const PhetIntRange(this.min, this.max);
  int clamp(int v) => v.clamp(min, max);
  bool contains(int v) => v >= min && v <= max;
}

/// A bounds rectangle in world or screen coordinates.
class PhetBounds {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const PhetBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory PhetBounds.fromRect(Rect r) =>
      PhetBounds(left: r.left, top: r.top, right: r.right, bottom: r.bottom);

  factory PhetBounds.fromSize(Size s) =>
      PhetBounds(left: 0, top: 0, right: s.width, bottom: s.height);

  double get width => right - left;
  double get height => bottom - top;
  Offset get center => Offset((left + right) / 2, (top + bottom) / 2);

  Rect toRect() => Rect.fromLTRB(left, top, right, bottom);

  bool contains(Offset p) =>
      p.dx >= left && p.dx <= right && p.dy >= top && p.dy <= bottom;

  Offset clamp(Offset p) => Offset(
        p.dx.clamp(left, right),
        p.dy.clamp(top, bottom),
      );
}

/// A transform combining position, rotation, and scale.
class PhetTransform {
  final Offset position;
  final double rotation;
  final double scale;

  const PhetTransform({
    this.position = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
  });

  PhetTransform copyWith({Offset? position, double? rotation, double? scale}) =>
      PhetTransform(
        position: position ?? this.position,
        rotation: rotation ?? this.rotation,
        scale: scale ?? this.scale,
      );
}

/// A color preset for PhET simulations.
class PhetColor {
  // ── Primary palette ──
  static const Color phetBlue = Color(0xff1a237e);
  static const Color phetLightBlue = Color(0xff4fc3f7);
  static const Color phetAccent = Color(0xffe65100);
  static const Color phetGreen = Color(0xff2e7d32);
  static const Color phetRed = Color(0xffcc2222);
  static const Color phetYellow = Color(0xfff9a825);

  // ── Panel colors ──
  static const Color panelBg = Color(0xfff0f4f8);
  static const Color panelBgDark = Color(0xff0d2255);
  static const Color panelBorder = Color(0xffbdbdbd);
  static const Color canvasBg = Color(0xff000000);

  // ── Field colors ──
  static const Color fieldArrowHead = Color(0xffcc2222);
  static const Color fieldArrowTail = Color(0xffcccccc);

  // ── Compass colors ──
  static const Color compassNeedleNorth = Color(0xffee3333);
  static const Color compassNeedleSouth = Color(0xffaaaaaa);

  // ── Electron color ──
  static const Color electron = Color(0xff42a5f5);
}
