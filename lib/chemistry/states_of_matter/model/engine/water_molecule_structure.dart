import 'dart:math' as math;

import '../../som_constants.dart';

/// Water molecule geometry / inertia — PhET WaterMoleculeStructure.
class WaterMoleculeStructure {
  WaterMoleculeStructure._();

  static final _Data _data = _Data._compute();

  static List<double> get moleculeStructureX => _data.structureX;
  static List<double> get moleculeStructureY => _data.structureY;
  static double get rotationalInertia => _data.rotationalInertia;
}

class _Data {
  _Data(this.structureX, this.structureY, this.rotationalInertia);

  final List<double> structureX;
  final List<double> structureY;
  final double rotationalInertia;

  factory _Data._compute() {
    final structureX = <double>[0, 0, 0];
    final structureY = <double>[0, 0, 0];

    structureX[0] = 0;
    structureY[0] = 0;
    structureX[1] = SomConstants.distanceFromOxygenToHydrogen;
    structureY[1] = 0;
    structureX[2] = SomConstants.distanceFromOxygenToHydrogen *
        math.cos(SomConstants.thetaHoh);
    structureY[2] = SomConstants.distanceFromOxygenToHydrogen *
        math.sin(SomConstants.thetaHoh);

    final xcm0 = (structureX[0] +
            0.25 * structureX[1] +
            0.25 * structureX[2]) /
        1.5;
    final ycm0 = (structureY[0] +
            0.25 * structureY[1] +
            0.25 * structureY[2]) /
        1.5;
    for (var i = 0; i < 3; i++) {
      structureX[i] -= xcm0;
      structureY[i] -= ycm0;
    }

    final inertia = (math.pow(structureX[0], 2) + math.pow(structureY[0], 2)) +
        0.25 *
            (math.pow(structureX[1], 2) + math.pow(structureY[1], 2)) +
        0.25 *
            (math.pow(structureX[2], 2) + math.pow(structureY[2], 2));

    return _Data(structureX, structureY, inertia.toDouble());
  }
}
