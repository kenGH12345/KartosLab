import 'dart:ui';

import 'beers_law_constants.dart';
import 'cuvette.dart';
import 'detector_mode.dart';
import 'light.dart';
import 'solution_in_cuvette.dart';

/// PhET `Detector` — body fixed; probe movable; A/T nullable.
class Detector {
  Detector({
    Offset bodyPosition = BeersLawConstants.detectorBodyPosition,
    Offset probePosition = BeersLawConstants.detectorProbePosition,
    this.probeDragBounds = BeersLawConstants.detectorProbeDragBounds,
    this.sensorDiameter = BeersLawConstants.detectorSensorDiameter,
  })  : bodyPosition = bodyPosition,
        _probePosition = probePosition,
        _mode = DetectorMode.transmittance,
        _initialBody = bodyPosition,
        _initialProbe = probePosition;

  final Offset bodyPosition;
  final Rect probeDragBounds;
  final double sensorDiameter;

  final Offset _initialBody;
  final Offset _initialProbe;

  Offset _probePosition;
  DetectorMode _mode;

  Offset get probePosition => _probePosition;
  DetectorMode get mode => _mode;

  double get probeMinY => _probePosition.dy - sensorDiameter / 2;
  double get probeMaxY => _probePosition.dy + sensorDiameter / 2;

  void setMode(DetectorMode mode) => _mode = mode;

  void setProbePosition(Offset position) {
    _probePosition = Offset(
      position.dx.clamp(probeDragBounds.left, probeDragBounds.right),
      position.dy.clamp(probeDragBounds.top, probeDragBounds.bottom),
    );
  }

  /// Source `isProbeInBeam`.
  bool isProbeInBeam(Light light) {
    return light.isOn &&
        probeMinY < light.minY &&
        probeMaxY > light.maxY &&
        _probePosition.dx > light.position.dx;
  }

  /// Optical path for detector reading — NOT full cuvette width.
  /// b = clamp(probe.x − cuvette.x, 0, width) when in beam; else null.
  double? pathLength(Light light, Cuvette cuvette) {
    if (!light.isOn || !isProbeInBeam(light)) return null;
    final raw = _probePosition.dx - cuvette.position.dx;
    return raw.clamp(0.0, cuvette.width);
  }

  double? absorbance(Light light, Cuvette cuvette, SolutionInCuvette fullPath) {
    final b = pathLength(light, cuvette);
    if (b == null) return null;
    return SolutionInCuvette.getAbsorbance(
      fullPath.molarAbsorptivity,
      b,
      fullPath.concentration,
    );
  }

  double? transmittance(
    Light light,
    Cuvette cuvette,
    SolutionInCuvette fullPath,
  ) {
    final a = absorbance(light, cuvette, fullPath);
    if (a == null) return null;
    return SolutionInCuvette.getTransmittance(a);
  }

  /// Pointer drag-end snap: if near beam and light on, align Y to beam center.
  void snapProbeToBeamIfClose(Light light) {
    if (!light.isOn) return;
    if (_probePosition.dx < light.position.dx) return;
    final dy = (_probePosition.dy - light.position.dy).abs();
    if (dy <= BeersLawConstants.probeBeamSnapThreshold) {
      setProbePosition(Offset(_probePosition.dx, light.position.dy));
    }
  }

  void reset() {
    // body is immutable Offset in our model (source resets BLLMovable but body is fixed)
    _probePosition = _initialProbe;
    _mode = DetectorMode.transmittance;
    // silence unused field warning for body reset parity
    assert(_initialBody == bodyPosition);
  }
}
