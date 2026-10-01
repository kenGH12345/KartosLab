import 'dart:ui';

import 'cuvette.dart';
import 'jump_position.dart';
import 'light.dart';
import 'ruler.dart';

/// PhET `RulerJumpPositions` — spatial landmarks.
List<JumpPosition> buildRulerJumpPositions({
  required Cuvette cuvette,
  required Light light,
  required Ruler ruler,
}) {
  return [
    JumpPosition(
      id: 'measuringCuvetteWidth',
      position: Offset(
        cuvette.position.dx,
        cuvette.position.dy + cuvette.height,
      ),
    ),
    JumpPosition(
      id: 'measuringOpticalPath',
      position: Offset(
        cuvette.position.dx,
        light.position.dy + light.lensDiameter / 2,
      ),
    ),
    JumpPosition(
      id: 'notMeasuring',
      position: ruler.position,
    ),
  ];
}
