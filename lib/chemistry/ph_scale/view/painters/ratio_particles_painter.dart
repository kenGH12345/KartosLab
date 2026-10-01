import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/beaker.dart';
import '../../model/ph_chemistry.dart';
import '../../model/ph_scale_colors.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/ratio_particle_counts.dart';

/// Ratio view — PhET `RatioNode.ts` / `ParticlesCanvas`.
///
/// Flat circles for **H₃O⁺** and **OH⁻** only (no H₂O dots), clipped to
/// solution volume. Counts come from [RatioParticleCounts], not Avogadro.
class RatioParticlesLayer extends StatefulWidget {
  const RatioParticlesLayer({
    super.key,
    required this.beaker,
    required this.pH,
    required this.totalVolume,
    this.visible = true,
  });

  final Beaker beaker;
  final PhValue pH;
  final double totalVolume;
  final bool visible;

  @override
  State<RatioParticlesLayer> createState() => _RatioParticlesLayerState();
}

class _RatioParticlesLayerState extends State<RatioParticlesLayer> {
  static const double _radius = 3;
  static const double _majorityAlpha = 0.55;
  static const double _minorityAlpha = 1.0;

  final List<Offset> _h3o = [];
  final List<Offset> _oh = [];
  int _lastH3o = -1;
  int _lastOh = -1;
  final math.Random _rng = math.Random(42);

  @override
  void didUpdateWidget(covariant RatioParticlesLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCounts();
  }

  @override
  void initState() {
    super.initState();
    _syncCounts();
  }

  void _syncCounts() {
    if (!widget.visible) return;
    final counts = RatioParticleCounts.displayCounts(widget.pH);
    if (counts.h3o == _lastH3o && counts.oh == _lastOh) return;
    _lastH3o = counts.h3o;
    _lastOh = counts.oh;
    _h3o
      ..clear()
      ..addAll(_randomPoints(counts.h3o));
    _oh
      ..clear()
      ..addAll(_randomPoints(counts.oh));
  }

  Iterable<Offset> _randomPoints(int n) sync* {
    final b = widget.beaker.bounds;
    final minX = b.left.ceil();
    final maxX = b.right.floor();
    final minY = b.top.ceil();
    final maxY = b.bottom.floor();
    for (var i = 0; i < n; i++) {
      final x = minX + _rng.nextInt(math.max(1, maxX - minX + 1));
      final y = minY + _rng.nextInt(math.max(1, maxY - minY + 1));
      yield Offset(x.toDouble(), y.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    _syncCounts();

    return CustomPaint(
      size: PhScaleConstants.layoutBounds,
      painter: _RatioPainter(
        beaker: widget.beaker,
        totalVolume: widget.totalVolume,
        h3o: List.unmodifiable(_h3o),
        oh: List.unmodifiable(_oh),
        radius: _radius,
        majorityAlpha: _majorityAlpha,
        minorityAlpha: _minorityAlpha,
      ),
    );
  }
}

class _RatioPainter extends CustomPainter {
  _RatioPainter({
    required this.beaker,
    required this.totalVolume,
    required this.h3o,
    required this.oh,
    required this.radius,
    required this.majorityAlpha,
    required this.minorityAlpha,
  });

  final Beaker beaker;
  final double totalVolume;
  final List<Offset> h3o;
  final List<Offset> oh;
  final double radius;
  final double majorityAlpha;
  final double minorityAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalVolume <= 0) return;

    final height = beaker.size.height * (totalVolume / beaker.volume);
    final clip = Rect.fromLTWH(
      beaker.left,
      beaker.position.dy - height,
      beaker.size.width,
      height,
    );
    canvas.save();
    canvas.clipRect(clip);

    final h3oMajority = h3o.length > oh.length;
    if (h3oMajority) {
      _drawSpecies(
        canvas,
        h3o,
        PhScaleColors.h3oParticles.withValues(alpha: majorityAlpha),
        PhScaleColors.h3oParticlesStroke,
      );
      _drawSpecies(
        canvas,
        oh,
        PhScaleColors.ohParticles.withValues(alpha: minorityAlpha),
        PhScaleColors.ohParticlesStroke,
      );
    } else {
      _drawSpecies(
        canvas,
        oh,
        PhScaleColors.ohParticles.withValues(alpha: majorityAlpha),
        PhScaleColors.ohParticlesStroke,
      );
      _drawSpecies(
        canvas,
        h3o,
        PhScaleColors.h3oParticles.withValues(alpha: minorityAlpha),
        PhScaleColors.h3oParticlesStroke,
      );
    }
    canvas.restore();
  }

  void _drawSpecies(
    Canvas canvas,
    List<Offset> pts,
    Color fill,
    Color stroke,
  ) {
    final fillP = Paint()..color = fill;
    final strokeP = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final p in pts) {
      canvas.drawCircle(p, radius, fillP);
      canvas.drawCircle(p, radius, strokeP);
    }
  }

  @override
  bool shouldRepaint(covariant _RatioPainter oldDelegate) =>
      oldDelegate.totalVolume != totalVolume ||
      oldDelegate.h3o != h3o ||
      oldDelegate.oh != oh ||
      oldDelegate.beaker != beaker;
}
