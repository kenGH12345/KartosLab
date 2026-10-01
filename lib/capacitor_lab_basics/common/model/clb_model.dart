import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../../clb_constants.dart';
import 'bar_meter.dart';
import 'parallel_circuit.dart';
import 'time_speed.dart';
import 'voltmeter.dart';

/// Shared across both screens — `capacitor-lab-basics-main.js` `switchUsedProperty`
class ClbSharedState extends ChangeNotifier {
  bool _switchUsed = false;

  bool get switchUsed => _switchUsed;

  set switchUsed(bool value) {
    if (value == _switchUsed) return;
    _switchUsed = value;
    notifyListeners();
  }

  void markSwitchUsed() => switchUsed = true;

  void reset() {
    _switchUsed = false;
    notifyListeners();
  }
}

/// Current-direction arrow style (derived from [ClbModel.currentOrientation]).
/// View maps this to colors — not stored as Color in the model.
enum CurrentArrowStyle { electrons, conventional }

/// Base model — `js/common/model/CLBModel.js`
///
/// ```
/// source state → derived state → render data (later phase)
/// ```
class ClbModel extends ChangeNotifier {
  ClbModel({
    required this.circuit,
    required this.shared,
  }) {
    circuit.maxPlateCharge = maxPlateCharge;
    circuit.maxEffectiveEField = maxEffectiveEField;
    circuit.addListener(_onCircuitChanged);
    shared.addListener(notifyListeners);

    voltmeter = Voltmeter(isVisible: () => voltmeterVisible);

    capacitanceMeter = BarMeter(
      isVisible: () => capacitanceMeterVisible,
      setVisible: (v) {
        capacitanceMeterVisible = v;
        notifyListeners();
      },
      value: () => circuit.capacitor.capacitance,
      resetVisible: () {
        capacitanceMeterVisible = true;
      },
    );
    plateChargeMeter = BarMeter(
      isVisible: () => topPlateChargeMeterVisible,
      setVisible: (v) {
        topPlateChargeMeterVisible = v;
        notifyListeners();
      },
      value: () => circuit.capacitor.plateCharge,
      resetVisible: () {
        topPlateChargeMeterVisible = false;
      },
    );
    storedEnergyMeter = BarMeter(
      isVisible: () => storedEnergyMeterVisible,
      setVisible: (v) {
        storedEnergyMeterVisible = v;
        notifyListeners();
      },
      value: () => circuit.capacitor.storedEnergy,
      resetVisible: () {
        storedEnergyMeterVisible = false;
      },
    );
  }

  final ParallelCircuit circuit;
  final ClbSharedState shared;

  late final Voltmeter voltmeter;
  late final BarMeter capacitanceMeter;
  late final BarMeter plateChargeMeter;
  late final BarMeter storedEnergyMeter;

  // —— Source state (CLBModel.js defaults) ——
  bool plateChargesVisible = true;
  bool electricFieldVisible = false;
  bool capacitanceMeterVisible = true;
  bool topPlateChargeMeterVisible = false;
  bool storedEnergyMeterVisible = false;
  bool barGraphsVisible = true;
  bool voltmeterVisible = false;
  bool currentVisible = true;

  /// 0 = electrons, π = conventional — `currentOrientationProperty`
  double currentOrientation = 0;

  bool isPlaying = true;
  TimeSpeed timeSpeed = TimeSpeed.normal;

  /// Stopwatch elapsed (model seconds).
  double stopwatchTime = 0;
  bool stopwatchRunning = false;
  /// Dragged out of Light Bulb toolbox — `Stopwatch.isVisibleProperty`.
  bool stopwatchVisible = false;
  /// Play-area top-left (canvas px) — `Stopwatch.positionProperty`.
  double stopwatchX = 40;
  double stopwatchY = ClbConstants.canvasHeight - 188;

  /// `Stopwatch.reset` when returned to toolbox — CLBLightBulbScreenView.js:65-66
  void returnStopwatchToToolbox() {
    stopwatchTime = 0;
    stopwatchRunning = false;
    stopwatchVisible = false;
    stopwatchX = 40;
    stopwatchY = ClbConstants.canvasHeight - 188;
    notifyListeners();
  }

  void placeStopwatchAt(Offset topLeft) {
    stopwatchX = topLeft.dx;
    stopwatchY = topLeft.dy;
    stopwatchVisible = true;
    notifyListeners();
  }

  // —— Derived ——

  CurrentArrowStyle get arrowStyle => currentOrientation == 0
      ? CurrentArrowStyle.electrons
      : CurrentArrowStyle.conventional;

  /// Q_max = ε₀ · A_max · V_max / d_min — `CLBModel.getMaxPlateCharge`
  double get maxPlateCharge {
    final maxArea = ClbConstants.plateWidthMax * ClbConstants.plateWidthMax;
    return ClbConstants.epsilon0 *
        maxArea *
        ClbConstants.batteryVoltageMax /
        ClbConstants.plateSeparationMin;
  }

  /// E_max = (A_max/A_min) · V_max / d_min — `CLBModel.getMaxEffectiveEField`
  double get maxEffectiveEField {
    final maxArea = ClbConstants.plateWidthMax * ClbConstants.plateWidthMax;
    final minArea = ClbConstants.plateWidthMin * ClbConstants.plateWidthMin;
    return maxArea /
        minArea *
        ClbConstants.batteryVoltageMax /
        ClbConstants.plateSeparationMin;
  }

  void setPlateChargesVisible(bool v) {
    plateChargesVisible = v;
    notifyListeners();
  }

  void setElectricFieldVisible(bool v) {
    electricFieldVisible = v;
    notifyListeners();
  }

  void setBarGraphsVisible(bool v) {
    barGraphsVisible = v;
    notifyListeners();
  }

  void setVoltmeterVisible(bool v) {
    voltmeterVisible = v;
    refreshVoltmeterReading();
    notifyListeners();
  }

  void setCurrentVisible(bool v) {
    currentVisible = v;
    notifyListeners();
  }

  void setCurrentOrientation(double radians) {
    currentOrientation = radians;
    notifyListeners();
  }

  /// View-layer mutation (voltmeter drag etc.) without a dedicated setter.
  void notifyViewChanged() {
    refreshVoltmeterReading();
    notifyListeners();
  }

  void refreshVoltmeterReading() {
    voltmeter.updateMeasuredVoltage(circuit: circuit);
  }

  void _onCircuitChanged() {
    refreshVoltmeterReading();
    notifyListeners();
  }

  void setPlaying(bool v) {
    isPlaying = v;
    notifyListeners();
  }

  void setTimeSpeed(TimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  /// `CLBModel.step`
  void step(double dt, {bool isManual = false}) {
    if (isPlaying || isManual) {
      final adjustedDt = isManual
          ? dt
          : dt * (timeSpeed == TimeSpeed.slow ? ClbConstants.slowTimeScale : 1);
      circuit.step(adjustedDt);
      if (stopwatchRunning) {
        stopwatchTime += adjustedDt;
      }
      notifyListeners();
    }
  }

  void manualStep() => step(ClbConstants.manualStepDt, isManual: true);

  /// Base reset — `CLBModel.reset`
  /// Does **not** reset topPlateCharge / storedEnergy meter visibles
  /// (screen models reset those via BarMeter.reset / explicit flags).
  @mustCallSuper
  void reset() {
    plateChargesVisible = true;
    electricFieldVisible = false;
    capacitanceMeterVisible = true;
    barGraphsVisible = true;
    voltmeterVisible = false;
    currentVisible = true;
    currentOrientation = 0;
    shared.reset();
    isPlaying = true;
    timeSpeed = TimeSpeed.normal;
    stopwatchTime = 0;
    stopwatchRunning = false;
    stopwatchVisible = false;
    stopwatchX = 40;
    stopwatchY = ClbConstants.canvasHeight - 188;
    voltmeter.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    circuit.removeListener(_onCircuitChanged);
    shared.removeListener(notifyListeners);
    circuit.dispose();
    super.dispose();
  }
}
