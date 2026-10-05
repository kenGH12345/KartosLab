import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/mp_vector2.dart';
import '../mp_constants.dart';
import '../mp_colors.dart';

/// Jmol-style dipole arrow. Source: `DipoleNode.ts`
class DipolePainter {
  static const double referenceMagnitude =
      MpConstants.electronegativityMax - MpConstants.electronegativityMin;
  static const double referenceLength = 135;
  static const Size headSize = Size(12, 20);
  static const Size crossSize = Size(10, 10);
  static const double referenceCrossOffset = 20;
  static const double tailWidth = 4;
  static const double fractionalHeadHeight = 0.4;

  static void paint(
    Canvas canvas, {
    required Offset origin,
    required MpVector2 dipole,
    required Color color,
  }) {
    if (dipole.magnitude < 1e-12) return;

    final desiredLength =
        dipole.magnitude * (referenceLength / referenceMagnitude);
    var adjustedLength = desiredLength;
    var scale = 1.0;
    if (headSize.height > fractionalHeadHeight * desiredLength) {
      adjustedLength = headSize.height / fractionalHeadHeight;
      scale = desiredLength / adjustedLength;
    }
    final crossOffset =
        scale * referenceCrossOffset * adjustedLength / referenceLength;
    final crossWidth =
        scale * crossSize.width * adjustedLength / referenceLength;

    final path = Path()
      ..moveTo(0, -tailWidth / 2)
      ..lineTo(crossOffset, -tailWidth / 2)
      ..lineTo(crossOffset, -crossSize.height / 2)
      ..lineTo(crossOffset + crossWidth, -crossSize.height / 2)
      ..lineTo(crossOffset + crossWidth, -tailWidth / 2)
      ..lineTo(adjustedLength - headSize.height, -tailWidth / 2)
      ..lineTo(adjustedLength - headSize.height, -headSize.width / 2)
      ..lineTo(adjustedLength, 0)
      ..lineTo(adjustedLength - headSize.height, headSize.width / 2)
      ..lineTo(adjustedLength - headSize.height, tailWidth / 2)
      ..lineTo(crossOffset + crossWidth, tailWidth / 2)
      ..lineTo(crossOffset + crossWidth, crossSize.height / 2)
      ..lineTo(crossOffset, crossSize.height / 2)
      ..lineTo(crossOffset, tailWidth / 2)
      ..lineTo(0, tailWidth / 2)
      ..close();

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(dipole.angle);
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  static void paintBondDipole(
    Canvas canvas, {
    required Offset bondCenter,
    required MpVector2 dipole,
    required double bondAngle,
  }) {
    if (dipole.magnitude < 1e-12) return;
    // `BondDipoleNode.ts` — offset perpendicular to bond
    const perpendicularOffset = 55.0;
    final isInPhase = (bondAngle - dipole.angle).abs() < (math.pi / 4);
    final dipoleViewLength =
        dipole.magnitude * (referenceLength / referenceMagnitude);
    final offsetX =
        isInPhase ? (dipoleViewLength / 2) : -(dipoleViewLength / 2);
    final offsetAngle = math.atan(offsetX / perpendicularOffset);
    final tailDistance = perpendicularOffset / math.cos(offsetAngle);
    final tailAngle = bondAngle - (math.pi / 2) - offsetAngle;
    final tail = Offset(
      bondCenter.dx + tailDistance * math.cos(tailAngle),
      bondCenter.dy + tailDistance * math.sin(tailAngle),
    );
    paint(
      canvas,
      origin: tail,
      dipole: dipole,
      color: MpColors.bondDipole,
    );
  }

  static void paintMolecularDipole(
    Canvas canvas, {
    required Offset moleculeCenter,
    required MpVector2 dipole,
  }) =>
      paint(
        canvas,
        origin: moleculeCenter,
        dipole: dipole,
        color: MpColors.molecularDipole,
      );

  /// `DipoleNode.createIcon` — Vector2(0.65, 0), points right.
  /// View size ≈ 44×12 for magnitude 0.65.
  static Size iconSize = const Size(46, 14);

  static void paintIcon(
    Canvas canvas, {
    required Color color,
    Offset origin = const Offset(1, 7),
  }) {
    paint(
      canvas,
      origin: origin,
      dipole: const MpVector2(0.65, 0),
      color: color,
    );
  }
}

/// Pair of translate-hint arrows around an atom (`TranslateArrowsNode.ts`).
class TranslateHintArrowsPainter {
  static void paint(
    Canvas canvas, {
    required Offset atomCenter,
    required Offset moleculeCenter,
    required double atomRadius,
    required Color color,
    double length = 25,
  }) {
    final v = moleculeCenter - atomCenter;
    final angle = math.atan2(v.dy, v.dx) - math.pi / 2;
    canvas.save();
    canvas.translate(atomCenter.dx, atomCenter.dy);
    canvas.rotate(angle);
    final spacing = 2.0;
    _arrow(
      canvas,
      from: Offset(-(atomRadius + spacing), 0),
      to: Offset(-(atomRadius + spacing + length), 0),
      color: color,
    );
    _arrow(
      canvas,
      from: Offset(atomRadius + spacing, 0),
      to: Offset(atomRadius + spacing + length, 0),
      color: color,
    );
    canvas.restore();
  }

  static void _arrow(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Color color,
  }) {
    const headWidth = 30.0;
    const headHeight = 15.0;
    const tailWidth = 15.0;
    final dir = to - from;
    final len = dir.distance;
    if (len < 1e-6) return;
    final unit = dir / len;
    final perp = Offset(-unit.dy, unit.dx);
    final neck = to - unit * headHeight;
    final path = Path()
      ..moveTo(from.dx + perp.dx * tailWidth / 2, from.dy + perp.dy * tailWidth / 2)
      ..lineTo(neck.dx + perp.dx * tailWidth / 2, neck.dy + perp.dy * tailWidth / 2)
      ..lineTo(neck.dx + perp.dx * headWidth / 2, neck.dy + perp.dy * headWidth / 2)
      ..lineTo(to.dx, to.dy)
      ..lineTo(neck.dx - perp.dx * headWidth / 2, neck.dy - perp.dy * headWidth / 2)
      ..lineTo(neck.dx - perp.dx * tailWidth / 2, neck.dy - perp.dy * tailWidth / 2)
      ..lineTo(from.dx - perp.dx * tailWidth / 2, from.dy - perp.dy * tailWidth / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

/// Shaded sphere atom. Approximates `ShadedSphereNode` / MeshLambert for Real.
class AtomPainter {
  static void paint(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required String label,
    bool lambert = false,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    if (lambert) {
      // Three.js MeshPhong on Real Molecules: tight specular, no flat stroke.
      final highlight = Offset(
        center.dx - radius * 0.32,
        center.dy - radius * 0.40,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            highlight,
            radius * 1.4,
            [
              Colors.white,
              Color.lerp(Colors.white, color, 0.22)!,
              color,
              Color.lerp(color, const Color(0xFF1A1A1A), 0.42)!,
            ],
            const [0.0, 0.16, 0.52, 1.0],
          ),
      );
    } else {
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.1,
        colors: [
          Color.lerp(Colors.white, color, 0.15)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()..shader = gradient.createShader(rect),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    if (label.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: _labelColor(color),
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  static Color _labelColor(Color base) {
    final luminance = base.computeLuminance();
    return luminance > 0.55 ? Colors.black : Colors.white;
  }
}

class BondPainter {
  static void paint(
    Canvas canvas, {
    required Offset a,
    required Offset b,
    double width = 12,
  }) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = MpColors.bond
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Jmol / Three.js cylinder between two spheres (Real Molecules).
  static void paintCylinder(
    Canvas canvas, {
    required Offset a,
    required Offset b,
    required double radiusA,
    required double radiusB,
    double cylinderRadius = 8,
  }) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len;
    final uy = dy / len;
    final insetA = radiusA * 0.62;
    final insetB = radiusB * 0.62;
    if (len <= insetA + insetB) return;
    final p0 = Offset(a.dx + ux * insetA, a.dy + uy * insetA);
    final p1 = Offset(b.dx - ux * insetB, b.dy - uy * insetB);
    final mx = (p0.dx + p1.dx) / 2;
    final my = (p0.dy + p1.dy) / 2;
    // Lighting across the tube (perpendicular to bond).
    final px = -uy * cylinderRadius;
    final py = ux * cylinderRadius;
    canvas.drawLine(
      p0,
      p1,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(mx - px, my - py),
          Offset(mx + px, my + py),
          const [
            Color(0xFFFFFFFF),
            Color(0xFFE4E4E4),
            Color(0xFF9A9A9A),
            Color(0xFF6E6E6E),
          ],
          const [0.0, 0.28, 0.72, 1.0],
        )
        ..strokeWidth = cylinderRadius * 2
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke,
    );
  }
}

class PartialChargePainter {
  static void paint(
    Canvas canvas, {
    required Offset atomCenter,
    required double partialCharge,
    required double atomRadius,
  }) {
    if (partialCharge.abs() < 1e-9) return;
    final text = partialCharge > 0 ? 'δ+' : 'δ−';
    final outward = Offset(atomCenter.dx, atomCenter.dy - atomRadius - 8);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Place above atom; for bottom half of screen could flip — keep simple.
    tp.paint(
      canvas,
      Offset(outward.dx - tp.width / 2, outward.dy - tp.height),
    );
  }
}

/// 2D surface cloud: capsule of two atom circles + gradient.
/// Approximates `SurfaceNode` / ESP / density fills.
class Surface2dPainter {
  static void paint(
    Canvas canvas, {
    required Offset a,
    required Offset b,
    required double radius,
    required List<Color> gradientColors,
    required double deltaEN,
  }) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: a, radius: radius))
      ..addOval(Rect.fromCircle(center: b, radius: radius));
    // Expand along bond with union approx via stadium
    final along = b - a;
    final len = along.distance;
    if (len < 1e-6) return;
    final dir = along / len;
    final perp = Offset(-dir.dy, dir.dx) * radius;
    final stadium = Path()
      ..moveTo(a.dx + perp.dx, a.dy + perp.dy)
      ..lineTo(b.dx + perp.dx, b.dy + perp.dy)
      ..arcToPoint(
        Offset(b.dx - perp.dx, b.dy - perp.dy),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(a.dx - perp.dx, a.dy - perp.dy)
      ..arcToPoint(
        Offset(a.dx + perp.dx, a.dy + perp.dy),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..close();

    // Gradient width depends on EN (PhET SURFACE_GRADIENT_WIDTH_MULTIPLIER)
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final gHalf = math.max(
      20.0,
      MpConstants.surfaceGradientWidthMultiplier *
          (2 + deltaEN.abs()) *
          8,
    );
    final g0 = mid - dir * gHalf;
    final g1 = mid + dir * gHalf;
    final shader = LinearGradient(
      begin: Alignment(
        (g0.dx - mid.dx) / gHalf,
        (g0.dy - mid.dy) / gHalf,
      ),
      end: Alignment(
        (g1.dx - mid.dx) / gHalf,
        (g1.dy - mid.dy) / gHalf,
      ),
      colors: gradientColors
          .map((c) => c.withValues(alpha: MpColors.surfaceAlpha))
          .toList(),
    ).createShader(Rect.fromCenter(center: mid, width: gHalf * 2, height: gHalf * 2));

    // Prefer axis-aligned gradient along bond via paint shader from g0→g1
    final paint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors
            .map((c) => c.withValues(alpha: MpColors.surfaceAlpha))
            .toList(),
      ).createShader(Rect.fromPoints(g0, g1));

    canvas.drawPath(stadium, paint..blendMode = BlendMode.srcOver);
    // silence unused
    assert(path.getBounds().width >= 0);
    assert(shader.hashCode != 0 || true);
  }
}

class PlatesPainter {
  /// HBox width of `PlatesNode`: two `PlateNode`s plus [spacing].
  static double hboxWidth(double spacing) =>
      (MpConstants.plateWidth + MpConstants.plateThickness) * 2 + spacing;

  /// Right edge of the positive plate (outer thickness).
  static double rightEdge({
    required double moleculeX,
    required double spacing,
  }) =>
      moleculeX + hboxWidth(spacing) / 2;

  static void paint(
    Canvas canvas, {
    required Offset moleculeCenter,
    required double spacing,
  }) {
    const w = MpConstants.plateWidth;
    const h = MpConstants.plateHeight;
    const t = MpConstants.plateThickness;
    const yOff = MpConstants.platePerspectiveYOffset;
    final nodeW = w + t;
    final total = nodeW * 2 + spacing;
    final left = moleculeCenter.dx - total / 2;
    final top = moleculeCenter.dy - h / 2;

    // Negative plate: `PlateNode` scale(-1, 1) so thickness faces outward.
    canvas.save();
    canvas.translate(left + nodeW, top);
    canvas.scale(-1, 1);
    _positivePlateGeom(canvas);
    canvas.restore();
    _polarityIndicator(
      canvas,
      Offset(left + nodeW / 2, top + yOff / 2 - 40),
      positive: false,
    );

    canvas.save();
    canvas.translate(left + nodeW + spacing, top);
    _positivePlateGeom(canvas);
    canvas.restore();
    _polarityIndicator(
      canvas,
      Offset(left + nodeW + spacing + nodeW / 2, top + yOff / 2 - 40),
      positive: true,
    );
  }

  /// Face + edge of a positive plate, origin at local (0,0). `PlateNode.ts`.
  static void _positivePlateGeom(Canvas canvas) {
    const w = MpConstants.plateWidth;
    const h = MpConstants.plateHeight;
    const t = MpConstants.plateThickness;
    const yOff = MpConstants.platePerspectiveYOffset;
    final face = Path()
      ..moveTo(0, yOff)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, yOff + (h - 2 * yOff))
      ..close();
    final edge = Rect.fromLTWH(w, 0, t, h);
    final fill = Paint()..color = MpColors.plate;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(edge, fill);
    canvas.drawRect(edge, stroke);
    canvas.drawPath(face, fill);
    canvas.drawPath(face, stroke);
  }

  /// `PolarityIndicator.ts` — hollow circle, +/− bars, stem. No text glyphs.
  static void _polarityIndicator(
    Canvas canvas,
    Offset center, {
    required bool positive,
  }) {
    const r = MpConstants.polarityIndicatorRadius;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, stroke);
    canvas.drawLine(
      Offset(center.dx - r * 0.5, center.dy),
      Offset(center.dx + r * 0.5, center.dy),
      stroke,
    );
    if (positive) {
      canvas.drawLine(
        Offset(center.dx, center.dy - r * 0.5),
        Offset(center.dx, center.dy + r * 0.5),
        stroke,
      );
    }
    canvas.drawLine(
      Offset(center.dx, center.dy + r),
      Offset(center.dx, center.dy + 2 * r),
      stroke,
    );
  }
}
