import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/model/alpha_particle.dart';
import 'package:kratos/rutherford_scattering/model/rs_base_model.dart';
import 'package:kratos/rutherford_scattering/model/rs_geometry.dart';
import 'package:kratos/rutherford_scattering/rs_assets.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/transform/rs_transform.dart';

/// Particle draw style from PhET ParticleSpaceNode.
enum RsParticleStyle {
  /// Magenta dot (atomic scale).
  particle,

  /// 2p+2n cluster (nuclear / plum pudding).
  nucleus,
}

/// Observation-window content modes.
enum RsObservationMode {
  atomicAtoms,
  nuclearCluster,
  plumPudding,
}

/// Electron positions in 1912×1700 plumPudding.png space
/// (PhET PlumPuddingAtomNode.ts ELECTRON_POSITIONS).
const List<Offset> kPlumPuddingElectronPositions = [
  Offset(1185, 217), Offset(1385, 247), Offset(1015, 272), Offset(894, 284),
  Offset(1065, 367), Offset(1248, 372), Offset(686, 384), Offset(1443, 395),
  Offset(885, 413), Offset(1131, 430), Offset(1350, 438), Offset(615, 476),
  Offset(1146, 522), Offset(748, 538), Offset(1350, 548), Offset(1519, 549),
  Offset(452, 551), Offset(943, 555), Offset(631, 597), Offset(1248, 613),
  Offset(819, 634), Offset(446, 648), Offset(723, 654), Offset(948, 667),
  Offset(1381, 676), Offset(1093, 695), Offset(1573, 697), Offset(544, 700),
  Offset(344, 730), Offset(1265, 734), Offset(465, 752), Offset(710, 752),
  Offset(1165, 754), Offset(1450, 772), Offset(1094, 784), Offset(610, 796),
  Offset(1294, 813), Offset(919, 838), Offset(477, 852), Offset(769, 872),
  Offset(285, 876), Offset(1019, 876), Offset(1427, 904), Offset(1150, 938),
  Offset(1627, 938), Offset(402, 950), Offset(823, 984), Offset(1349, 984),
  Offset(1035, 997), Offset(515, 1013), Offset(665, 1022), Offset(1494, 1063),
  Offset(594, 1080), Offset(1198, 1080), Offset(1681, 1084), Offset(969, 1099),
  Offset(793, 1105), Offset(1410, 1126), Offset(419, 1134), Offset(1561, 1154),
  Offset(473, 1213), Offset(1300, 1230), Offset(650, 1234), Offset(847, 1252),
  Offset(1093, 1253), Offset(535, 1296), Offset(1460, 1297), Offset(919, 1304),
  Offset(448, 1313), Offset(1119, 1317), Offset(723, 1330), Offset(1227, 1363),
  Offset(860, 1426), Offset(1346, 1430), Offset(1019, 1434), Offset(1115, 1488),
  Offset(935, 1496), Offset(1223, 1502),
];

class RsObservationPainter extends CustomPainter {
  RsObservationPainter({
    required this.model,
    required this.transform,
    required this.mode,
    required this.particleStyle,
    this.plumPuddingImage,
    this.revision = 0,
  });

  final RsBaseModel model;
  final RsTransform transform;
  final RsObservationMode mode;
  final RsParticleStyle particleStyle;
  final ui.Image? plumPuddingImage;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    final clip = transform.viewBounds.deflate(RsConstants.spaceBuffer);
    canvas.save();
    canvas.clipRect(clip);

    switch (mode) {
      case RsObservationMode.atomicAtoms:
        _paintAtomicAtoms(canvas);
      case RsObservationMode.nuclearCluster:
        _paintNuclearCluster(canvas);
      case RsObservationMode.plumPudding:
        _paintPlumPudding(canvas);
    }

    for (final p in model.particles) {
      if (model.showTraces) {
        _paintTrace(canvas, p);
      }
      _paintAlpha(canvas, p);
    }

    canvas.restore();

    // Border
    final border = Paint()
      ..color = RsColors.spaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(transform.viewBounds, border);
  }

  void _paintAtomicAtoms(Canvas canvas) {
    final atoms = model.getVisibleSpace().atoms;
    for (final atom in atoms) {
      final c = transform.modelToView(atom.position);
      for (var i = RsConstants.energyLevels; i > 0; i--) {
        final r = _bohrRadius(i);
        final paint = Paint()
          ..color = RsColors.energyLevel
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        _drawDashedCircle(canvas, c, r, paint);
      }
      canvas.drawCircle(
        c,
        RsConstants.nucleusRadius,
        Paint()..color = RsColors.nucleus,
      );
    }
  }

  double _bohrRadius(int index) {
    var radius = 0.0;
    for (var i = 1; i <= index; i++) {
      radius += RsConstants.ionizationEnergy / (i * i);
    }
    return radius * RsConstants.radiusScale;
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dash = 5.0;
    const gap = 5.0;
    final circumference = 2 * math.pi * radius;
    final n = (circumference / (dash + gap)).floor();
    if (n <= 0) return;
    final step = 2 * math.pi / n;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a0 = i * step;
      final a1 = a0 + step * (dash / (dash + gap));
      path.moveTo(
        center.dx + radius * math.cos(a0),
        center.dy + radius * math.sin(a0),
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        a0,
        a1 - a0,
        false,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _paintNuclearCluster(Canvas canvas) {
    final center = transform.modelToView(const RsVec2(0, 0));
    final protons = model.protonCount;
    final neutrons = model.neutronCount;
    final rng = math.Random(protons * 1000 + neutrons);
    final maxR = transform.viewBounds.shortestSide * 0.22;
    final nucleons = <({Offset o, bool proton})>[];
    for (var i = 0; i < protons; i++) {
      nucleons.add((o: _randomInDisk(rng, maxR), proton: true));
    }
    for (var i = 0; i < neutrons; i++) {
      nucleons.add((o: _randomInDisk(rng, maxR), proton: false));
    }
    // Draw neutrons first so protons sit on top a bit.
    for (final n in nucleons.where((e) => !e.proton)) {
      _drawNucleon(canvas, center + n.o, false);
    }
    for (final n in nucleons.where((e) => e.proton)) {
      _drawNucleon(canvas, center + n.o, true);
    }
  }

  Offset _randomInDisk(math.Random rng, double maxR) {
    final a = rng.nextDouble() * 2 * math.pi;
    final r = maxR * math.sqrt(rng.nextDouble());
    return Offset(r * math.cos(a), r * math.sin(a));
  }

  void _paintPlumPudding(Canvas canvas) {
    final img = plumPuddingImage;
    final bounds = transform.viewBounds;
    final scale = math.min(bounds.width, bounds.height) /
            math.max(RsAssets.plumPuddingWidth, RsAssets.plumPuddingHeight) +
        0.0005;
    final dw = RsAssets.plumPuddingWidth * scale;
    final dh = RsAssets.plumPuddingHeight * scale;
    final left = bounds.center.dx - dw / 2;
    final top = bounds.center.dy - dh / 2;

    if (img != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(left, top, dw, dh),
        image: img,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
      );
    } else {
      canvas.drawOval(
        Rect.fromLTWH(left, top, dw, dh),
        Paint()..color = const Color(0xFF8B4513).withValues(alpha: 0.5),
      );
    }

    final eR = RsConstants.electronRadius;
    for (final p in kPlumPuddingElectronPositions) {
      final c = Offset(left + p.dx * scale, top + p.dy * scale);
      _drawElectron(canvas, c, eR);
    }
  }

  void _paintTrace(Canvas canvas, AlphaParticle particle) {
    final pts = particle.positions;
    if (pts.length < 2) return;

    if (particleStyle == RsParticleStyle.particle) {
      // Fade last N segments (atomic style).
      final start = math.max(0, pts.length - RsConstants.fadeoutSegments - 1);
      for (var i = start; i < pts.length - 1; i++) {
        final t = (i - start) / RsConstants.fadeoutSegments;
        final paint = Paint()
          ..color = RsColors.particleAlpha.withValues(alpha: 0.15 + 0.85 * t)
          ..strokeWidth = RsConstants.particleTraceWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          transform.modelToView(pts[i]),
          transform.modelToView(pts[i + 1]),
          paint,
        );
      }
    } else {
      final path = Path();
      final first = transform.modelToView(pts.first);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < pts.length; i++) {
        final o = transform.modelToView(pts[i]);
        path.lineTo(o.dx, o.dy);
      }
      final color = mode == RsObservationMode.plumPudding
          ? RsColors.plumPuddingTrace
          : RsColors.particleAlpha;
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = RsConstants.particleTraceWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintAlpha(Canvas canvas, AlphaParticle particle) {
    final c = transform.modelToView(particle.position);
    if (particleStyle == RsParticleStyle.particle) {
      canvas.drawCircle(
        c,
        RsConstants.particleRadius,
        Paint()..color = RsColors.particleAlpha,
      );
    } else {
      // Compact 2p+2n cluster
      const d = 3.2;
      _drawNucleon(canvas, c + const Offset(-d, -d), true);
      _drawNucleon(canvas, c + const Offset(d, -d), true);
      _drawNucleon(canvas, c + const Offset(-d, d), false);
      _drawNucleon(canvas, c + const Offset(d, d), false);
    }
  }

  void _drawElectron(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        c.translate(-r * 0.35, -r * 0.35),
        r * 1.2,
        [RsColors.specularHighlight, RsColors.electron],
        [0.0, 1.0],
      );
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = RsConstants.electronLineWidth,
    );
  }

  void _drawNucleon(Canvas canvas, Offset c, bool proton) {
    final color = proton ? RsColors.proton : RsColors.neutron;
    final r = proton ? RsConstants.protonRadius : RsConstants.neutronRadius;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        c.translate(-r * 0.35, -r * 0.35),
        r * 1.2,
        [RsColors.specularHighlight, color],
        [0.0, 1.0],
      );
    canvas.drawCircle(c, r, paint);
  }

  @override
  bool shouldRepaint(covariant RsObservationPainter oldDelegate) {
    return oldDelegate.revision != revision ||
        oldDelegate.mode != mode ||
        oldDelegate.particleStyle != particleStyle ||
        oldDelegate.plumPuddingImage != plumPuddingImage ||
        oldDelegate.model.showTraces != model.showTraces ||
        oldDelegate.model.protonCount != model.protonCount ||
        oldDelegate.model.neutronCount != model.neutronCount;
  }
}
