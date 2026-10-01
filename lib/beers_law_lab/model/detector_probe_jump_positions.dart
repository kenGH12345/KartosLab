import 'dart:ui';

import 'cuvette.dart';
import 'detector.dart';
import 'jump_position.dart';
import 'light.dart';

/// PhET `DetectorProbeJumpPositions` — spatial landmarks (a11y strings later).
List<JumpPosition> buildDetectorProbeJumpPositions({
  required Cuvette cuvette,
  required Light light,
  required Detector detector,
}) {
  final probe = detector.probePosition;
  return [
    JumpPosition(
      id: 'betweenLightAndCuvette',
      position: Offset(cuvette.position.dx - 0.5, light.position.dy),
    ),
    JumpPosition(
      id: 'centeredInCuvette',
      position: Offset(cuvette.centerX, light.position.dy),
    ),
    JumpPosition(
      id: 'rightOfCuvette',
      position: Offset(probe.dx, light.position.dy),
    ),
    JumpPosition(
      id: 'outsideLightPath',
      position: Offset(
        probe.dx,
        light.position.dy + detector.sensorDiameter + 0.15,
      ),
    ),
  ];
}
