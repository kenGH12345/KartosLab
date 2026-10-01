import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/john_travoltage_model.dart';
import '../model/jt_vec2.dart';
import 'jt_view_geometry.dart';
import 'jt_view_layout.dart';

/// One mapped electron for painting — stable [id] matches Model [Electron.id].
class ElectronViewSample {
  const ElectronViewSample({required this.id, required this.screenPosition});

  final int id;
  final JtVec2 screenPosition;
}

/// Sync Model electrons → screen samples (call once per model notification).
///
/// Mutates each electron's history exactly like PhET `ElectronNode` on position
/// update — must not be called from [build] more than once per logical update.
List<ElectronViewSample> syncElectronViewSamples(JohnTravoltageModel model) {
  return [
    for (final e in model.electrons)
      ElectronViewSample(
        id: e.id,
        screenPosition: ElectronScreenMapper.mapScreenPosition(
          electron: e,
          leg: model.leg,
          arm: model.arm,
        ),
      ),
  ];
}

/// Electron layer — PhET `ElectronLayerNode` + `ElectronNode` mapping.
///
/// Draws 1:1 from [samples]; does not read/mutate Model during paint.
class ElectronLayerNode extends StatelessWidget {
  const ElectronLayerNode({
    super.key,
    required this.samples,
  });

  final List<ElectronViewSample> samples;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(
          JtViewLayout.layoutWidth,
          JtViewLayout.layoutHeight,
        ),
        painter: _ElectronLayerPainter(samples: samples),
      ),
    );
  }
}

class _ElectronLayerPainter extends CustomPainter {
  _ElectronLayerPainter({required this.samples});

  final List<ElectronViewSample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    const r = JtViewLayout.electronChargeRadius;
    const charge = ElectronChargePainter(radius: r);
    for (final s in samples) {
      final p = s.screenPosition;
      canvas.save();
      canvas.translate(p.x - r, p.y - r);
      charge.paint(canvas, const Size(r * 2, r * 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ElectronLayerPainter oldDelegate) {
    if (oldDelegate.samples.length != samples.length) return true;
    for (var i = 0; i < samples.length; i++) {
      final a = oldDelegate.samples[i];
      final b = samples[i];
      if (a.id != b.id || a.screenPosition != b.screenPosition) return true;
    }
    return false;
  }
}

/// Spark overlay — PhET `SparkNode.js`.
class SparkNode extends StatelessWidget {
  const SparkNode({
    super.key,
    required this.model,
    required this.points,
  });

  final JohnTravoltageModel model;
  final List<JtVec2> points;

  @override
  Widget build(BuildContext context) {
    if (!model.sparkVisible || points.isEmpty) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(
          JtViewLayout.layoutWidth,
          JtViewLayout.layoutHeight,
        ),
        painter: _SparkPainter(points: points),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.points});

  final List<JtVec2> points;

  @override
  void paint(Canvas canvas, Size size) {
    final path = SparkPathBuilder.toFlutterPath(points);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = JtViewLayout.sparkWhiteWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = JtViewLayout.sparkBlueWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.points != points;
}

/// Rebuild spark zigzag when spark is visible (called each model step).
List<JtVec2> rebuildSparkPoints(JohnTravoltageModel model, math.Random random) {
  if (!model.sparkVisible) return const [];
  return SparkPathBuilder.build(
    finger: model.fingerPosition,
    knob: model.doorknobPosition,
    random: random,
    numSegments: JtViewLayout.sparkSegmentCount,
  );
}
