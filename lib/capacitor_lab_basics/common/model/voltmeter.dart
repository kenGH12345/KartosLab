import 'dart:ui' show Path;

import '../../clb_constants.dart';
import '../transform/path_intersection.dart';
import '../transform/probe_hit_tester.dart';
import '../transform/voltmeter_shape_creator.dart';
import '../transform/yaw_pitch_mvt.dart';
import 'circuit_position.dart';
import 'circuit_state.dart';
import 'parallel_circuit.dart';
import 'probe_target.dart';

/// Voltmeter model — `js/common/model/meter/Voltmeter.js`
class Voltmeter {
  Voltmeter({required bool Function() isVisible}) : _isVisible = isVisible;

  final bool Function() _isVisible;

  bool get visible => _isVisible();

  bool isDragged = false;

  double bodyX = 0;
  double bodyY = 0;
  double bodyZ = 0;

  double positiveProbeX = ClbConstants.positiveProbeX;
  double positiveProbeY = ClbConstants.positiveProbeY;
  double positiveProbeZ = 0;

  double negativeProbeX = ClbConstants.negativeProbeX;
  double negativeProbeY = ClbConstants.negativeProbeY;
  double negativeProbeZ = 0;

  /// `null` displays as "?" — Voltmeter.js:90-97
  double? measuredVoltage;

  ProbeTarget positiveProbeTarget = ProbeTarget.none;
  ProbeTarget negativeProbeTarget = ProbeTarget.none;

  void reset() {
    isDragged = false;
    bodyX = 0;
    bodyY = 0;
    bodyZ = 0;
    positiveProbeX = ClbConstants.positiveProbeX;
    positiveProbeY = ClbConstants.positiveProbeY;
    positiveProbeZ = 0;
    negativeProbeX = ClbConstants.negativeProbeX;
    negativeProbeY = ClbConstants.negativeProbeY;
    negativeProbeZ = 0;
    measuredVoltage = null;
    positiveProbeTarget = ProbeTarget.none;
    negativeProbeTarget = ProbeTarget.none;
  }

  /// Full measurement refresh — Voltmeter.js `updateValue`
  void updateMeasuredVoltage({
    required ParallelCircuit circuit,
    YawPitchMvt? mvt,
  }) {
    if (!visible) {
      measuredVoltage = null;
      positiveProbeTarget = ProbeTarget.none;
      negativeProbeTarget = ProbeTarget.none;
      return;
    }

    final transform = mvt ?? YawPitchMvt();
    final shapes = VoltmeterShapeCreator(this, transform);
    final tipPos = shapes.getPositiveProbeTipShape();
    final tipNeg = shapes.getNegativeProbeTipShape();

    if (_probesAreTouching(tipPos, tipNeg)) {
      positiveProbeTarget = ProbeTarget.otherProbe;
      negativeProbeTarget = ProbeTarget.otherProbe;
    } else {
      final tester = ProbeHitTester(circuit: circuit, mvt: transform);
      positiveProbeTarget = tester.getProbeTarget(tipPos);
      negativeProbeTarget = tester.getProbeTarget(tipNeg);
    }
    measuredVoltage = computeValue(circuit);
  }

  /// Voltmeter.js:163-227
  double? computeValue(ParallelCircuit circuit) {
    final pos = positiveProbeTarget;
    final neg = negativeProbeTarget;

    if (pos == ProbeTarget.none || neg == ProbeTarget.none) {
      return null;
    }
    if (pos == ProbeTarget.otherProbe || neg == ProbeTarget.otherProbe) {
      return 0;
    }

    var positiveCircuitPosition = pos.circuitPosition;
    var negativeCircuitPosition = neg.circuitPosition;

    if (positiveCircuitPosition == negativeCircuitPosition) {
      return 0;
    }

    if (circuit.circuitConnection == CircuitState.batteryConnected) {
      if (positiveCircuitPosition.isCapacitor) {
        positiveCircuitPosition = positiveCircuitPosition.isTop
            ? CircuitPosition.batteryTop
            : CircuitPosition.batteryBottom;
      }
      if (negativeCircuitPosition.isCapacitor) {
        negativeCircuitPosition = negativeCircuitPosition.isTop
            ? CircuitPosition.batteryTop
            : CircuitPosition.batteryBottom;
      }
    } else if (circuit.circuitConnection == CircuitState.lightBulbConnected) {
      if (positiveCircuitPosition.isLightBulb) {
        positiveCircuitPosition = positiveCircuitPosition.isTop
            ? CircuitPosition.capacitorTop
            : CircuitPosition.capacitorBottom;
      }
      if (negativeCircuitPosition.isLightBulb) {
        negativeCircuitPosition = negativeCircuitPosition.isTop
            ? CircuitPosition.capacitorTop
            : CircuitPosition.capacitorBottom;
      }
    }

    if (positiveCircuitPosition == negativeCircuitPosition) {
      return 0;
    } else if (positiveCircuitPosition.isBattery &&
        negativeCircuitPosition.isBattery) {
      return (positiveCircuitPosition.isTop ? 1.0 : -1.0) *
          circuit.getTotalVoltage();
    } else if (positiveCircuitPosition.isCapacitor &&
        negativeCircuitPosition.isCapacitor) {
      return (positiveCircuitPosition.isTop ? 1.0 : -1.0) *
          circuit.getCapacitorPlateVoltage();
    } else if (positiveCircuitPosition.isLightBulb &&
        negativeCircuitPosition.isLightBulb) {
      return 0;
    }
    return null;
  }

  static bool _probesAreTouching(Path pos, Path neg) =>
      PathIntersection.intersects(pos, neg);
}
