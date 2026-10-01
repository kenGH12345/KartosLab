import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/model/track.dart';
import 'package:kratos/energy_skate_park/model/premade_tracks.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

/// Track preset icon — SceneSelectionRadioButtonGroup.ts rasterized TrackNode.
class TrackSceneIcon extends StatelessWidget {
  const TrackSceneIcon({super.key, required this.scene, this.size = 44});

  final TrackScene scene;
  final double size;

  Track _iconTrack() {
    switch (scene) {
      case TrackScene.parabola:
        return PremadeTracks.createParabola(physical: false);
      case TrackScene.ramp:
        return PremadeTracks.createTrack(
          PremadeTracks.createRampControlPoints(),
          physical: false,
        );
      case TrackScene.doubleWell:
        return PremadeTracks.createDoubleWell(physical: false);
      case TrackScene.loop:
        return PremadeTracks.createLoop(physical: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.85),
      painter: _TrackSceneIconPainter(track: _iconTrack()),
    );
  }
}

class _TrackSceneIconPainter extends CustomPainter {
  _TrackSceneIconPainter({required this.track});

  final Track track;

  @override
  void paint(Canvas canvas, Size size) {
    const samples = 40;
    final pts = <Offset>[];
    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      final u = track.minPoint + (track.maxPoint - track.minPoint) * t;
      final p = track.getPoint(u);
      pts.add(Offset(p.x, -p.y));
    }
    if (pts.isEmpty) return;

    double minX = pts.first.dx, maxX = pts.first.dx;
    double minY = pts.first.dy, maxY = pts.first.dy;
    for (final p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    const pad = 4.0;
    final w = (maxX - minX).clamp(0.001, double.infinity);
    final h = (maxY - minY).clamp(0.001, double.infinity);
    final sx = (size.width - pad * 2) / w;
    final sy = (size.height - pad * 2) / h;
    final s = sx < sy ? sx : sy;

    Offset map(Offset p) => Offset(
          pad + (p.dx - minX) * s,
          size.height - pad - (p.dy - minY) * s,
        );

    final path = Path()..moveTo(map(pts.first).dx, map(pts.first).dy);
    for (var i = 1; i < pts.length; i++) {
      final m = map(pts[i]);
      path.lineTo(m.dx, m.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = EspColors.roadFill
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = EspColors.roadLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackSceneIconPainter old) => old.track != track;
}
