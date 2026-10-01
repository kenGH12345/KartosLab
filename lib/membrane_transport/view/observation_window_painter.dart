import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../layout/membrane_transport_layout.dart';
import '../membrane_transport_constants.dart';
import '../model/membrane_transport_model.dart';
import '../model/mt_random.dart';
import '../model/particle.dart';
import '../model/solute_type.dart';
import '../model/transport_protein_type.dart';
import 'protein_image_cache.dart';

/// Observation window renderer — phospholipids + proteins + particles + charges.
class ObservationWindowPainter extends CustomPainter {
  ObservationWindowPainter({
    required this.model,
    required this.phospholipids,
    this.particleImages = const {},
    this.animateLipids = true,
    this.showSlotIndicators = false,
    this.highlightedSlotIndex,
  });

  final MembraneTransportModel model;
  final List<Phospholipid> phospholipids;
  final Map<ParticleType, ui.Image> particleImages;
  final bool animateLipids;
  final bool showSlotIndicators;
  final int? highlightedSlotIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final obs = Rect.fromLTWH(0, 0, size.width, size.height);
    const corner = Radius.circular(
      MembraneTransportLayoutPrimitives.observationCornerRadius,
    );
    final clipRRect = RRect.fromRectAndRadius(obs, corner);

    // PhET ObservationWindow clipNode.clipArea — clip contents, then draw frame.
    canvas.save();
    canvas.clipRRect(clipRRect);

    final midY = size.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, midY),
      Paint()..color = MembraneTransportColors.observationOutside,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, midY, size.width, size.height),
      Paint()..color = MembraneTransportColors.observationInside,
    );

    if (model.chargesVisible) {
      _drawCharges(canvas, size);
    }

    final tailPaint = Paint()
      ..color = MembraneTransportColors.phospholipidTail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (final p in phospholipids) {
      p.drawTails(canvas, tailPaint, size);
    }

    final headPaint = Paint()..color = MembraneTransportColors.phospholipidHead;
    final headStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    for (final p in phospholipids) {
      p.drawHead(canvas, headPaint, headStroke, size);
    }

    if (showSlotIndicators) {
      _drawSlotIndicators(canvas, size);
    }

    for (final slot in model.membraneSlots) {
      final protein = slot.transportProtein;
      if (protein != null) {
        _drawProtein(canvas, size, protein.type, protein.state, slot.position);
      }
    }

    for (final s in model.solutes) {
      _drawParticle(canvas, size, s);
    }
    if (model.areLigandsAdded) {
      for (final lig in model.ligands) {
        _drawParticle(canvas, size, lig);
      }
    }

    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(obs.deflate(1), corner),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawSlotIndicators(Canvas canvas, Size size) {
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    final sy = size.height / MembraneTransportLayoutPrimitives.obsHeight;
    final slots = model.membraneSlots;
    for (var i = 0; i < slots.length; i++) {
      final local = MembraneTransportLayoutSpec.modelToObservationView(
        slots[i].position,
        0,
      );
      final c = Offset(local.dx * sx, local.dy * sy);
      final rect = Rect.fromCenter(
        center: c,
        width: 65 * sx,
        height: 105 * sy,
      );
      final highlighted = highlightedSlotIndex == i;
      final fill = Paint()
        ..color = highlighted
            ? const Color.fromRGBO(0, 0, 0, 0.5)
            : const Color.fromRGBO(255, 255, 255, 0.7);
      final stroke = Paint()
        ..color = highlighted ? Colors.white : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round;
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      canvas.drawRRect(rrect, fill);
      // dashed feel via path effect approximation: solid OK for MVP
      canvas.drawRRect(rrect, stroke);
    }
  }

  void _drawCharges(Canvas canvas, Size size) {
    final potential = model.membranePotential.toDouble();
    final numberOfCharges =
        (18 * potential.abs() / 70).round().clamp(1, 40);
    const margin = 5.0;
    final membraneW = MembraneTransportConstants.modelWidth;
    final separation = numberOfCharges <= 1
        ? 0.0
        : (membraneW - margin * 2) / (numberOfCharges - 1);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const radius = 2.0;

    for (var i = 0; i < numberOfCharges; i++) {
      final mx =
          MembraneTransportConstants.membraneMinX + margin + i * separation;
      final outsideSign = potential < 0 ? '+' : '-';
      final insideSign = potential < 0 ? '-' : '+';
      _drawSign(canvas, size, outsideSign, mx, 17, paint, radius);
      _drawSign(canvas, size, insideSign, mx, -17, paint, radius);
    }
  }

  void _drawSign(
    Canvas canvas,
    Size size,
    String sign,
    double mx,
    double my,
    Paint paint,
    double radius,
  ) {
    final c = _modelToView(mx, my, size);
    if (sign == '+') {
      canvas.drawLine(
        Offset(c.dx, c.dy - radius),
        Offset(c.dx, c.dy + radius),
        paint,
      );
    }
    canvas.drawLine(
      Offset(c.dx - radius, c.dy),
      Offset(c.dx + radius, c.dy),
      paint,
    );
  }

  Offset _modelToView(double mx, double my, Size size) {
    final view = MembraneTransportLayoutSpec.modelToObservationView(mx, my);
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    final sy = size.height / MembraneTransportLayoutPrimitives.obsHeight;
    return Offset(view.dx * sx, view.dy * sy);
  }

  void _drawProtein(
    Canvas canvas,
    Size size,
    TransportProteinType type,
    String state,
    double modelX,
  ) {
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    final sy = size.height / MembraneTransportLayoutPrimitives.obsHeight;
    final viewW = MembraneTransportConstants.transportProteinWidth *
        MembraneTransportLayoutPrimitives.mvtScale *
        sx;
    // Artwork is 650×900 by design
    final viewH = viewW * (900 / 650) * (sy / sx);
    final center = _modelToView(modelX, 0, size);
    final dst = Rect.fromCenter(
      center: center,
      width: viewW,
      height: viewH,
    );

    final img = ProteinImageCache.forType(type, state: state);
    if (img != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(img, src, dst, Paint());
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(dst, const Radius.circular(4)),
        Paint()..color = const Color(0xFF8D6E63),
      );
    }
  }

  void _drawParticle(Canvas canvas, Size size, MtParticle particle) {
    final view = MembraneTransportLayoutSpec.modelToObservationView(
      particle.position.x,
      particle.position.y,
    );
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    final sy = size.height / MembraneTransportLayoutPrimitives.obsHeight;
    final cx = view.dx * sx;
    final cy = view.dy * sy;

    final img = particleImages[particle.type];
    final dim = particle.dimension;
    final w = dim.width * MembraneTransportLayoutPrimitives.mvtScale * sx;
    final h = dim.height * MembraneTransportLayoutPrimitives.mvtScale * sy;

    if (img != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      final dst = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
      final paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, particle.opacity);
      canvas.drawImageRect(img, src, dst, paint);
    } else {
      final color = _fallbackColor(particle.type)
          .withValues(alpha: particle.opacity.clamp(0.0, 1.0));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        Paint()..color = color,
      );
    }

    if (particle.timeSinceCrossedMembrane < 0.4 &&
        model.crossingHighlightsEnabled) {
      canvas.drawCircle(
        Offset(cx, cy),
        math.max(w, h) * 0.7,
        Paint()
          ..color =
              MembraneTransportColors.crossingHighlight.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  Color _fallbackColor(ParticleType t) {
    switch (t) {
      case ParticleType.oxygen:
        return const Color(0xFFFF0000);
      case ParticleType.carbonDioxide:
        return const Color(0xFF737373);
      case ParticleType.sodiumIon:
        return const Color(0xFFFF5500);
      case ParticleType.potassiumIon:
        return const Color(0xFF009BC2);
      case ParticleType.glucose:
        return const Color.fromRGBO(106, 42, 211, 1);
      case ParticleType.atp:
        return const Color.fromRGBO(59, 147, 74, 1);
      case ParticleType.adp:
        return const Color.fromRGBO(59, 147, 74, 0.7);
      case ParticleType.phosphate:
        return const Color.fromRGBO(123, 104, 238, 1);
      case ParticleType.triangleLigand:
        return const Color(0xFFFFD54F);
      case ParticleType.starLigand:
        return const Color(0xFF81D4FA);
    }
  }

  @override
  bool shouldRepaint(covariant ObservationWindowPainter oldDelegate) => true;
}

/// Procedural phospholipid — PhET `Phospholipid.ts`.
class Phospholipid {
  Phospholipid({
    required this.side,
    required this.anchorX,
    required MtRandom random,
  }) {
    final anchorY = side == PhospholipidSide.inner ? -headY : headY;
    final left = anchorX - tailOffset / 2;
    final right = anchorX + tailOffset / 2;
    final spacing = anchorY / 6.6;
    _tails = [
      _TailState(left, anchorY, _createCps(left, anchorY, spacing, random)),
      _TailState(right, anchorY, _createCps(right, anchorY, spacing, random)),
    ];
    _randomizeInitial(random);
  }

  static const double headRadius = 1.3;
  static const double tailOffset = 1.2;
  static const double headWindow = 0.2;
  static const double tailWindow = 0.3;
  static const double controlStep = 0.2;
  static const double friction = 0.99;
  static final double headY =
      MembraneTransportConstants.membraneMaxY - headRadius;

  final PhospholipidSide side;
  final double anchorX;
  double headOffsetX = 0;
  double headVx = 0;
  late final List<_TailState> _tails;

  static List<_ControlPoint> _createCps(
    double ax,
    double ay,
    double spacing,
    MtRandom random,
  ) {
    return List.generate(6, (i) {
      final stagger = random.nextDoubleBetween(0.9, 1.1);
      return _ControlPoint(ax, ay - spacing * (i + 1) * stagger);
    });
  }

  void _randomizeInitial(MtRandom random) {
    headOffsetX = (random.nextDouble() + random.nextDouble() - 1) * headWindow;
    for (final t in _tails) {
      for (final cp in t.controlPoints) {
        cp.x = t.anchorX +
            (random.nextDouble() + random.nextDouble() - 1) * tailWindow;
        cp.vx = 0;
      }
    }
  }

  void step(double dt, MtRandom random) {
    headVx = headVx * friction +
        (random.nextDouble() * 2 - 1) * 0.5 * controlStep * dt;
    headOffsetX += headVx;
    if (headOffsetX < -headWindow) {
      headOffsetX = -headWindow;
      headVx = 0;
    } else if (headOffsetX > headWindow) {
      headOffsetX = headWindow;
      headVx = 0;
    }

    for (final t in _tails) {
      final minX = t.anchorX - tailWindow;
      final maxX = t.anchorX + tailWindow;
      for (final cp in t.controlPoints) {
        cp.vx = cp.vx * friction +
            (random.nextDouble() * 2 - 1) * controlStep * dt;
        cp.x += cp.vx;
        if (cp.x < minX) {
          cp.x = minX;
          cp.vx = 0;
        } else if (cp.x > maxX) {
          cp.x = maxX;
          cp.vx = 0;
        }
      }
    }
  }

  Offset _toView(double mx, double my, Size size) {
    final v = MembraneTransportLayoutSpec.modelToObservationView(mx, my);
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    final sy = size.height / MembraneTransportLayoutPrimitives.obsHeight;
    return Offset(v.dx * sx, v.dy * sy);
  }

  double _radiusView(Size size) {
    final sx = size.width / MembraneTransportLayoutPrimitives.obsWidth;
    return headRadius * MembraneTransportLayoutPrimitives.mvtScale * sx;
  }

  void drawHead(Canvas canvas, Paint fill, Paint stroke, Size size) {
    final y = side == PhospholipidSide.outer ? headY : -headY;
    final c = _toView(anchorX + headOffsetX, y, size);
    final r = _radiusView(size);
    canvas.drawCircle(c, r, fill);
    canvas.drawCircle(c, r, stroke);
  }

  void drawTails(Canvas canvas, Paint paint, Size size) {
    for (final t in _tails) {
      final path = Path();
      final start = _toView(t.anchorX + headOffsetX, t.anchorY, size);
      path.moveTo(start.dx, start.dy);
      final cps = t.controlPoints;
      Offset pt(int i) => _toView(cps[i].x + headOffsetX, cps[i].y, size);
      final p0 = pt(0);
      final p1 = pt(1);
      final p2 = pt(2);
      path.cubicTo(p0.dx, p0.dy, p1.dx, p1.dy, p2.dx, p2.dy);
      final p3 = pt(3);
      final p4 = pt(4);
      final p5 = pt(5);
      path.cubicTo(p3.dx, p3.dy, p4.dx, p4.dy, p5.dx, p5.dy);
      canvas.drawPath(path, paint);
    }
  }

  static List<Phospholipid> createAll(MtRandom random) {
    final list = <Phospholipid>[];
    const a = headRadius * 2;
    final count = (MembraneTransportConstants.modelWidth / a).floor() + 2;
    for (var i = 0; i < count; i++) {
      final x = -MembraneTransportConstants.modelWidth / 2 + i * a;
      list.add(Phospholipid(
        side: PhospholipidSide.inner,
        anchorX: x,
        random: random,
      ));
      list.add(Phospholipid(
        side: PhospholipidSide.outer,
        anchorX: x,
        random: random,
      ));
    }
    return random.shuffle(list);
  }
}

enum PhospholipidSide { outer, inner }

class _TailState {
  _TailState(this.anchorX, this.anchorY, this.controlPoints);
  final double anchorX;
  final double anchorY;
  final List<_ControlPoint> controlPoints;
}

class _ControlPoint {
  _ControlPoint(this.x, this.y);
  double x;
  double y;
  double vx = 0;
}
