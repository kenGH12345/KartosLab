import 'dart:ui' show Offset;

import 'package:kratos/faradays_law/model/faradays_law_model.dart';

/// Shared trajectory helpers for Phase 4 dynamic QA.
List<Offset> approachCoilTrajectory({int steps = 8}) {
  const start = Offset(620, 310);
  const end = Offset(448, 310);
  return List.generate(steps + 1, (i) {
    final t = i / steps;
    return Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );
  });
}

/// Runs [positions] with fixed [dt], syncing B at first point without EMF.
void runTrajectory(
  FaradaysLawModel model,
  List<Offset> positions, {
  double dt = 1 / 60,
}) {
  assert(positions.isNotEmpty);
  model.setMagnetPositionForTest(positions.first);
  model.bottomCoil.reset();
  model.topCoil.reset();
  for (var i = 1; i < positions.length; i++) {
    model.setMagnetPositionForTest(positions[i]);
    model.step(dt);
  }
}
