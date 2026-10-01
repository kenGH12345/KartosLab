import '../normal_modes_constants.dart';
import '../solver/one_dimension_solver.dart';
import 'amplitude_direction.dart';
import 'mass.dart';
import 'nm_vec.dart';
import 'spring.dart';
import 'time_speed.dart';

/// `js/one-dimension/model/OneDimensionModel.js`
class OneDimensionModel {
  OneDimensionModel() {
    masses = List<Mass>.generate(
      NormalModesConstants.maxMasses,
      (_) => Mass(equilibriumPosition: NmVec.zero, visible: false),
    );
    springs = List<Spring>.generate(
      NormalModesConstants.maxSprings,
      (i) => Spring(masses[i], masses[i + 1]),
    );
    modeAmplitudes = List<double>.filled(
      NormalModesConstants.maxMassesPerRow,
      NormalModesConstants.initialAmplitude,
    );
    modePhases = List<double>.filled(
      NormalModesConstants.maxMassesPerRow,
      NormalModesConstants.initialPhase,
    );
    _relocateMasses();
    refreshFrequencies();
  }

  late final List<Mass> masses;
  late final List<Spring> springs;
  late final List<double> modeAmplitudes;
  late final List<double> modePhases;
  List<double> modeFrequencies = const [];

  double dtAccum = 0;
  double time = 0;
  bool playing = true;
  NmTimeSpeed timeSpeed = NmTimeSpeed.normal;
  bool springsVisible = true;
  int numberOfMasses = NormalModesConstants.defaultNumberOfMasses;
  AmplitudeDirection amplitudeDirection = AmplitudeDirection.vertical;
  bool arrowsVisible = true;
  bool phasesVisible = false;

  /// 0 default; visible masses are 1..N; -1 after drag end. `<= 0` means not dragging.
  int draggingMassIndex = 0;

  double get timeScale => timeSpeed == NmTimeSpeed.normal
      ? NormalModesConstants.normalSpeed
      : NormalModesConstants.slowSpeed;

  void refreshFrequencies() {
    modeFrequencies = OneDimensionSolver.frequenciesFor(numberOfMasses);
  }

  void _relocateMasses() {
    var x = NormalModesConstants.leftWallX;
    final xStep = NormalModesConstants.distanceBetweenXWalls /
        (numberOfMasses + 1);
    final xFinal =
        NormalModesConstants.leftWallX + NormalModesConstants.distanceBetweenXWalls;
    for (var i = 0; i < NormalModesConstants.maxMasses; i++) {
      masses[i].equilibriumPosition = NmVec(x, 0);
      masses[i].visible = i <= numberOfMasses;
      masses[i].zeroPosition();
      if (x < xFinal - xStep / 2) {
        x += xStep;
      }
    }
  }

  void setNumberOfMasses(int n) {
    final clamped = n.clamp(
      NormalModesConstants.minMassesPerRow,
      NormalModesConstants.maxMassesPerRow,
    );
    numberOfMasses = clamped;
    _relocateMasses();
    resetNormalModes();
    refreshFrequencies();
  }

  void resetNormalModes() {
    for (var i = 0; i < NormalModesConstants.maxMassesPerRow; i++) {
      modeAmplitudes[i] = NormalModesConstants.initialAmplitude;
      modePhases[i] = NormalModesConstants.initialPhase;
    }
  }

  void reset() {
    dtAccum = 0;
    playing = true;
    timeSpeed = NmTimeSpeed.normal;
    springsVisible = true;
    amplitudeDirection = AmplitudeDirection.vertical;
    arrowsVisible = true;
    phasesVisible = false;
    draggingMassIndex = 0;
    numberOfMasses = NormalModesConstants.defaultNumberOfMasses;
    _relocateMasses();
    zeroPositions();
    refreshFrequencies();
  }

  void initialPositions() {
    playing = false;
    time = 0;
    setExactPositions();
  }

  void zeroPositions() {
    for (final mass in masses) {
      mass.zeroPosition();
    }
    resetNormalModes();
  }

  void step(double dt) {
    dt = mathMinDt(dt);
    if (playing) {
      dtAccum += dt;
      while (dtAccum >= NormalModesConstants.fixedDt) {
        dtAccum -= NormalModesConstants.fixedDt;
        singleStep(NormalModesConstants.fixedDt);
      }
    } else if (draggingMassIndex <= 0) {
      setExactPositions();
    }
  }

  void singleStep(double dt) {
    dt *= timeScale;
    time += dt;
    if (draggingMassIndex > 0) {
      OneDimensionSolver.setVerletPositions(
        masses: masses,
        n: numberOfMasses,
        draggingMassIndex: draggingMassIndex,
        dt: dt,
      );
    } else {
      setExactPositions();
    }
  }

  void setExactPositions() {
    OneDimensionSolver.setExactPositions(
      masses: masses,
      n: numberOfMasses,
      amplitudes: modeAmplitudes,
      phases: modePhases,
      frequencies: modeFrequencies,
      time: time,
      direction: amplitudeDirection,
    );
  }

  void computeModeAmplitudesAndPhases() {
    time = 0;
    refreshFrequencies();
    OneDimensionSolver.computeModeAmplitudesAndPhases(
      masses: masses,
      n: numberOfMasses,
      direction: amplitudeDirection,
      amplitudes: modeAmplitudes,
      phases: modePhases,
      frequencies: modeFrequencies,
    );
  }

  void setModeAmplitude(int index, double value) {
    if (index < 0 || index >= modeAmplitudes.length) return;
    modeAmplitudes[index] = value < 0 ? 0 : value;
    if (draggingMassIndex <= 0) setExactPositions();
  }

  void setModePhase(int index, double value) {
    if (index < 0 || index >= modePhases.length) return;
    modePhases[index] = value;
    if (draggingMassIndex <= 0) setExactPositions();
  }

  static double mathMinDt(double dt) =>
      dt > NormalModesConstants.maxWallDt ? NormalModesConstants.maxWallDt : dt;
}
