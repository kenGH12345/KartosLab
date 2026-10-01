import '../normal_modes_constants.dart';
import '../solver/normal_mode_math.dart';
import '../solver/two_dimensions_solver.dart';
import 'amplitude_direction.dart';
import 'mass.dart';
import 'nm_vec.dart';
import 'spring.dart';
import 'time_speed.dart';

class DragIndex {
  const DragIndex(this.i, this.j);
  final int i;
  final int j;
}

/// `js/two-dimensions/model/TwoDimensionsModel.js`
class TwoDimensionsModel {
  TwoDimensionsModel() {
    masses = List<List<Mass>>.generate(
      NormalModesConstants.maxMasses,
      (_) => List<Mass>.generate(
        NormalModesConstants.maxMasses,
        (_) => Mass(equilibriumPosition: NmVec.zero, visible: false),
      ),
    );
    springsX = List<List<Spring?>>.generate(
      NormalModesConstants.maxSprings,
      (_) => List<Spring?>.filled(NormalModesConstants.maxSprings, null),
    );
    springsY = List<List<Spring?>>.generate(
      NormalModesConstants.maxSprings,
      (_) => List<Spring?>.filled(NormalModesConstants.maxSprings, null),
    );
    for (var i = 0; i < NormalModesConstants.maxSprings; i++) {
      for (var j = 0; j < NormalModesConstants.maxSprings; j++) {
        if (i != NormalModesConstants.maxSprings - 1) {
          springsX[i][j] = Spring(masses[i + 1][j], masses[i + 1][j + 1]);
        }
        if (j != NormalModesConstants.maxSprings - 1) {
          springsY[i][j] = Spring(masses[i][j + 1], masses[i + 1][j + 1]);
        }
      }
    }
    modeXAmplitudes = _zeroGrid();
    modeYAmplitudes = _zeroGrid();
    modeXPhases = _zeroGrid();
    modeYPhases = _zeroGrid();
    _relocateMasses();
    refreshFrequencies();
    sineProduct = TwoDimensionsSolver.calculateSineProducts(numberOfMasses);
  }

  late final List<List<Mass>> masses;
  late final List<List<Spring?>> springsX;
  late final List<List<Spring?>> springsY;
  late final List<List<double>> modeXAmplitudes;
  late final List<List<double>> modeYAmplitudes;
  late final List<List<double>> modeXPhases;
  late final List<List<double>> modeYPhases;
  List<List<double>> modeFrequencies = const [];
  late List<List<List<List<double>>>> sineProduct;

  double dtAccum = 0;
  double time = 0;
  bool playing = true;
  NmTimeSpeed timeSpeed = NmTimeSpeed.normal;
  bool springsVisible = true;
  int numberOfMasses = NormalModesConstants.defaultNumberOfMasses;
  AmplitudeDirection amplitudeDirection = AmplitudeDirection.vertical;
  bool arrowsVisible = true;
  DragIndex? draggingMassIndexes;

  double get timeScale => timeSpeed == NmTimeSpeed.normal
      ? NormalModesConstants.normalSpeed
      : NormalModesConstants.slowSpeed;

  double get maxAmplitude => NormalModeMath.maxAmplitude2D(numberOfMasses);

  static List<List<double>> _zeroGrid() => List<List<double>>.generate(
        NormalModesConstants.maxMassesPerRow,
        (_) => List<double>.filled(
          NormalModesConstants.maxMassesPerRow,
          NormalModesConstants.initialAmplitude,
        ),
      );

  void refreshFrequencies() {
    modeFrequencies = TwoDimensionsSolver.frequenciesFor(numberOfMasses);
  }

  void _relocateMasses() {
    var y = NormalModesConstants.topWallY;
    final xStep = NormalModesConstants.distanceBetweenXWalls /
        (numberOfMasses + 1);
    final yStep = NormalModesConstants.distanceBetweenYWalls /
        (numberOfMasses + 1);
    final xFinal =
        NormalModesConstants.leftWallX + NormalModesConstants.distanceBetweenXWalls;
    final yFinal =
        NormalModesConstants.topWallY - NormalModesConstants.distanceBetweenYWalls;
    for (var i = 0; i < NormalModesConstants.maxMasses; i++) {
      var x = NormalModesConstants.leftWallX;
      for (var j = 0; j < NormalModesConstants.maxMasses; j++) {
        masses[i][j].equilibriumPosition = NmVec(x, y);
        masses[i][j].visible = i <= numberOfMasses && j <= numberOfMasses;
        masses[i][j].zeroPosition();
        if (x < xFinal - xStep / 2) {
          x += xStep;
        }
      }
      if (y > yFinal + yStep / 2) {
        y -= yStep;
      }
    }
  }

  void setNumberOfMasses(int n) {
    numberOfMasses = n.clamp(
      NormalModesConstants.minMassesPerRow,
      NormalModesConstants.maxMassesPerRow,
    );
    _relocateMasses();
    sineProduct = TwoDimensionsSolver.calculateSineProducts(numberOfMasses);
    resetNormalModes();
    refreshFrequencies();
  }

  void resetNormalModes() {
    for (var i = 0; i < NormalModesConstants.maxMassesPerRow; i++) {
      for (var j = 0; j < NormalModesConstants.maxMassesPerRow; j++) {
        modeXAmplitudes[i][j] = NormalModesConstants.initialAmplitude;
        modeYAmplitudes[i][j] = NormalModesConstants.initialAmplitude;
        modeXPhases[i][j] = NormalModesConstants.initialPhase;
        modeYPhases[i][j] = NormalModesConstants.initialPhase;
      }
    }
  }

  void reset() {
    dtAccum = 0;
    playing = true;
    timeSpeed = NmTimeSpeed.normal;
    springsVisible = true;
    amplitudeDirection = AmplitudeDirection.vertical;
    arrowsVisible = true;
    draggingMassIndexes = null;
    numberOfMasses = NormalModesConstants.defaultNumberOfMasses;
    _relocateMasses();
    sineProduct = TwoDimensionsSolver.calculateSineProducts(numberOfMasses);
    zeroPositions();
    refreshFrequencies();
  }

  void initialPositions() {
    playing = false;
    time = 0;
    setExactPositions();
  }

  void zeroPositions() {
    for (final row in masses) {
      for (final mass in row) {
        mass.zeroPosition();
      }
    }
    resetNormalModes();
  }

  void step(double dt) {
    dt = dt > NormalModesConstants.maxWallDt
        ? NormalModesConstants.maxWallDt
        : dt;
    if (playing) {
      dtAccum += dt;
      while (dtAccum >= NormalModesConstants.fixedDt) {
        dtAccum -= NormalModesConstants.fixedDt;
        singleStep(NormalModesConstants.fixedDt);
      }
    } else if (draggingMassIndexes == null) {
      setExactPositions();
    }
  }

  void singleStep(double dt) {
    dt *= timeScale;
    time += dt;
    if (draggingMassIndexes != null) {
      TwoDimensionsSolver.setVerletPositions(
        masses: masses,
        n: numberOfMasses,
        dragI: draggingMassIndexes!.i,
        dragJ: draggingMassIndexes!.j,
        dt: dt,
      );
    } else {
      setExactPositions();
    }
  }

  void setExactPositions() {
    TwoDimensionsSolver.setExactPositions(
      masses: masses,
      n: numberOfMasses,
      ampX: modeXAmplitudes,
      ampY: modeYAmplitudes,
      phaseX: modeXPhases,
      phaseY: modeYPhases,
      frequencies: modeFrequencies,
      sineProduct: sineProduct,
      time: time,
    );
  }

  void computeModeAmplitudesAndPhases() {
    time = 0;
    refreshFrequencies();
    TwoDimensionsSolver.computeModeAmplitudesAndPhases(
      masses: masses,
      n: numberOfMasses,
      ampX: modeXAmplitudes,
      ampY: modeYAmplitudes,
      phaseX: modeXPhases,
      phaseY: modeYPhases,
      frequencies: modeFrequencies,
      sineProduct: sineProduct,
    );
  }

  void toggleAmplitudeCell(int row, int col) {
    if (row >= numberOfMasses || col >= numberOfMasses) return;
    final grid = amplitudeDirection == AmplitudeDirection.vertical
        ? modeYAmplitudes
        : modeXAmplitudes;
    final current = grid[row][col];
    const eps = 1e-4;
    final maxA = maxAmplitude;
    if (current >= maxA - eps && current <= maxA + eps) {
      grid[row][col] = NormalModesConstants.minAmplitude;
    } else {
      grid[row][col] = maxA;
    }
    if (!playing && draggingMassIndexes == null) setExactPositions();
  }

  List<Spring> get visibleSpringList {
    final out = <Spring>[];
    for (final row in springsX) {
      for (final s in row) {
        if (s != null) out.add(s);
      }
    }
    for (final row in springsY) {
      for (final s in row) {
        if (s != null) out.add(s);
      }
    }
    return out;
  }
}
