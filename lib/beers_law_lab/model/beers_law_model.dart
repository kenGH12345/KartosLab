import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'beam.dart';
import 'beers_law_solution.dart';
import 'cuvette.dart';
import 'detector.dart';
import 'detector_mode.dart';
import 'detector_probe_jump_positions.dart';
import 'jump_position.dart';
import 'light.dart';
import 'light_mode.dart';
import 'ruler.dart';
import 'ruler_jump_positions.dart';
import 'solution_in_cuvette.dart';

/// PhET `BeersLawModel` — reactive (no step). Independent of ConcentrationModel.
///
/// [ChangeNotifier] is view wiring only — physics formulas unchanged.
class BeersLawModel extends ChangeNotifier {
  BeersLawModel() {
    solutions =
        List<BeersLawSolution>.unmodifiable(BeersLawSolution.createAll());
    _solution = solutions.first;
    light = Light(initialSolution: _solution);
    cuvette = Cuvette();
    solutionInCuvette = SolutionInCuvette(
      solution: _solution,
      cuvetteWidth: cuvette.width,
      wavelength: light.wavelength,
    );
    detector = Detector();
    beam = Beam(
      light: light,
      cuvette: cuvette,
      detector: detector,
      solutionInCuvette: solutionInCuvette,
    );
    ruler = Ruler();
    _detectorProbeJumpPositions = buildDetectorProbeJumpPositions(
      cuvette: cuvette,
      light: light,
      detector: detector,
    );
    _rulerJumpPositions = buildRulerJumpPositions(
      cuvette: cuvette,
      light: light,
      ruler: ruler,
    );
    detectorProbeJumpPositionIndex = 0;
    rulerJumpPositionIndex = 0;
  }

  late final List<BeersLawSolution> solutions;
  late BeersLawSolution _solution;

  late final Light light;
  late final Cuvette cuvette;
  late final SolutionInCuvette solutionInCuvette;
  late final Detector detector;
  late final Beam beam;
  late final Ruler ruler;

  late List<JumpPosition> _detectorProbeJumpPositions;
  late List<JumpPosition> _rulerJumpPositions;

  /// Jump indices — NOT reset by [reset] (source BeersLawModel.reset).
  int detectorProbeJumpPositionIndex = 0;
  int rulerJumpPositionIndex = 0;

  BeersLawSolution get solution => _solution;

  List<JumpPosition> get detectorProbeJumpPositions {
    _refreshDetectorJumps();
    return _detectorProbeJumpPositions;
  }

  List<JumpPosition> get rulerJumpPositions {
    _refreshRulerJumps();
    return _rulerJumpPositions;
  }

  void _syncSolutionInCuvette() {
    solutionInCuvette.update(
      solution: _solution,
      cuvetteWidth: cuvette.width,
      wavelength: light.wavelength,
    );
  }

  void _refreshDetectorJumps() {
    _detectorProbeJumpPositions = buildDetectorProbeJumpPositions(
      cuvette: cuvette,
      light: light,
      detector: detector,
    );
  }

  void _refreshRulerJumps() {
    _rulerJumpPositions = buildRulerJumpPositions(
      cuvette: cuvette,
      light: light,
      ruler: ruler,
    );
  }

  void _notify() => notifyListeners();

  // --- Mutators (all reactive; no clock) ---

  void setSolution(BeersLawSolution value) {
    assert(solutions.contains(value));
    _solution = value;
    light.applySolution(value);
    _syncSolutionInCuvette();
    _notify();
  }

  void setLightOn(bool on) {
    light.setOn(on);
    _notify();
  }

  void setLightMode(LightMode mode) {
    light.setMode(mode, _solution);
    _syncSolutionInCuvette();
    _notify();
  }

  /// Only effective in VARIABLE mode.
  void setWavelength(double nm) {
    light.setWavelength(nm);
    _syncSolutionInCuvette();
    _notify();
  }

  void setConcentration(double molesPerLiter) {
    _solution.setConcentration(molesPerLiter);
    _syncSolutionInCuvette();
    _notify();
  }

  void setDisplayConcentration(double viewValue) {
    _solution.setDisplayConcentration(viewValue);
    _syncSolutionInCuvette();
    _notify();
  }

  void setCuvetteWidth(double cm) {
    cuvette.setWidth(cm);
    _syncSolutionInCuvette();
    _notify();
  }

  void snapCuvetteWidth() {
    cuvette.snapWidth();
    _syncSolutionInCuvette();
    _notify();
  }

  void setDetectorProbePosition(Offset position) {
    detector.setProbePosition(position);
    _notify();
  }

  void endDetectorProbeDrag() {
    detector.snapProbeToBeamIfClose(light);
    _notify();
  }

  void setDetectorMode(DetectorMode mode) {
    detector.setMode(mode);
    _notify();
  }

  void setRulerPosition(Offset position) {
    ruler.setPosition(position);
    _notify();
  }

  /// Cycle detector probe to next landmark (`J` shortcut).
  void jumpDetectorProbe() {
    _refreshDetectorJumps();
    detectorProbeJumpPositionIndex =
        (detectorProbeJumpPositionIndex + 1) %
            _detectorProbeJumpPositions.length;
    final target =
        _detectorProbeJumpPositions[detectorProbeJumpPositionIndex];
    detector.setProbePosition(target.position);
    _notify();
  }

  /// Cycle ruler to next landmark (`J` shortcut).
  void jumpRuler() {
    _refreshRulerJumps();
    rulerJumpPositionIndex =
        (rulerJumpPositionIndex + 1) % _rulerJumpPositions.length;
    final target = _rulerJumpPositions[rulerJumpPositionIndex];
    ruler.setPosition(target.position);
    _notify();
  }

  // --- Derived readings ---

  bool get isProbeInBeam => detector.isProbeInBeam(light);

  double? get detectorPathLength => detector.pathLength(light, cuvette);

  double? get absorbance =>
      detector.absorbance(light, cuvette, solutionInCuvette);

  double? get transmittance =>
      detector.transmittance(light, cuvette, solutionInCuvette);

  /// Display value for current detector mode; null → UI shows "—".
  double? get displayedMeasurement {
    switch (detector.mode) {
      case DetectorMode.transmittance:
        final t = transmittance;
        return t == null ? null : 100 * t;
      case DetectorMode.absorbance:
        return absorbance;
    }
  }

  /// Source `BeersLawModel.reset` — does NOT reset jump indices or snapInterval.
  void reset() {
    for (final s in solutions) {
      s.reset();
    }
    _solution = solutions.first;
    light.reset();
    cuvette.reset();
    detector.reset();
    ruler.reset();
    _syncSolutionInCuvette();
    _notify();
  }
}
