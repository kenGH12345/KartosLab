import 'dart:ui' show Offset;

import 'magnet.dart';
import 'magnetic_field.dart';

/// PhET `Coil.js` — pickup coil with calibrated B and EMF = N·ΔB/dt.
class Coil {
  Coil({
    required this.position,
    required this.numberOfSpirals,
    required Magnet magnet,
  }) : _magnet = magnet {
    updateMagneticField();
    previousMagneticField = magneticField;
  }

  final Offset position;
  final int numberOfSpirals;
  final Magnet _magnet;

  /// Unused in source (always 1); kept for parity.
  final double sense = 1;

  double magneticField = 0;
  double previousMagneticField = 0;
  double emf = 0;

  /// Graphic half-turns used for EMF: `numberOfSpirals / 2`.
  double get numberOfCoils => numberOfSpirals / 2.0;

  void updateMagneticField() {
    magneticField = magneticFieldAtCoil(
      coilPosition: position,
      magnetPosition: _magnet.position,
      orientation: _magnet.orientation,
    );
  }

  /// `Coil.step(dt)` — EMF = N * ΔB / dt
  void step(double dt) {
    updateMagneticField();
    final changeInMagneticField = magneticField - previousMagneticField;
    emf = numberOfCoils * changeInMagneticField / dt;
    previousMagneticField = magneticField;
  }

  void reset() {
    magneticField = 0;
    previousMagneticField = 0;
    emf = 0;
    updateMagneticField();
    previousMagneticField = magneticField;
  }
}
