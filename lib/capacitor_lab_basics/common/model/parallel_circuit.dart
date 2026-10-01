import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../clb_constants.dart';
import '../transform/circuit_geometry.dart';
import 'battery.dart';
import 'capacitor.dart';
import 'circuit_config.dart';
import 'circuit_state.dart';
import 'light_bulb.dart';

/// Parallel circuit base — `js/common/model/ParallelCircuit.js`
///
/// Phase 2: electrical behavior only (no wire Shape / probe hit-testing).
abstract class ParallelCircuit extends ChangeNotifier {
  ParallelCircuit(this.config)
      : battery = Battery(),
        capacitor = Capacitor(
          plateWidth: config.plateWidth,
          plateSeparation: config.plateSeparation,
          x: ClbConstants.batteryX + config.capacitorXSpacing,
          y: ClbConstants.batteryY + config.capacitorYSpacing,
          z: ClbConstants.batteryZ,
        ),
        lightBulb = config.hasLightBulb
            ? LightBulb.forCircuit(
                capacitorXSpacing: config.capacitorXSpacing,
                capacitorYSpacing: config.capacitorYSpacing,
              )
            : null {
    capacitor.connectionProvider = () => circuitConnection;
    capacitor.onCapacitanceChanged = (oldC, newC) {
      updatePlateVoltages();
      notifyListeners();
    };
    battery.addListener(_onBatteryVoltageChanged);

    // Default: battery connected → plates follow battery voltage.
    updatePlateVoltages();
  }

  final CircuitConfig config;
  final Battery battery;
  final Capacitor capacitor;
  final LightBulb? lightBulb;

  /// Signed current — `currentAmplitudeProperty`
  double currentAmplitude = 0;

  /// Switch / connection state — default BATTERY_CONNECTED
  CircuitState circuitConnection = CircuitState.batteryConnected;

  /// Top / bottom switch blade angles (radians) — `CircuitSwitch.angleProperty`
  double topSwitchAngle = CircuitGeometry.angleForConnection(
    connection: CircuitState.batteryConnected,
    isTop: true,
  );
  double bottomSwitchAngle = CircuitGeometry.angleForConnection(
    connection: CircuitState.batteryConnected,
    isTop: false,
  );

  /// Charge stored when leaving battery connection — `disconnectedPlateChargeProperty`
  double disconnectedPlateCharge = 0;

  /// For dQ/dt — `previousTotalCharge` (initial 0 in PhET)
  double previousTotalCharge = 0;

  /// Set by [ClbModel] after construction — visualization scaling only in later phases.
  double maxPlateCharge = double.infinity;
  double maxEffectiveEField = double.infinity;

  List<CircuitState> get allowedConnections => config.circuitConnections;

  double getTotalVoltage() => battery.voltage;

  double getTotalCharge() => capacitor.plateCharge;

  double getCapacitorPlateVoltage() => capacitor.plateVoltage;

  bool isOpen() =>
      circuitConnection == CircuitState.openCircuit ||
      circuitConnection == CircuitState.switchInTransit;

  /// Subclasses implement plate-voltage rules.
  void updatePlateVoltages();

  void setCircuitConnection(CircuitState next) {
    if (next == circuitConnection) return;
    // Validate against allowed steady states (transit always allowed while dragging).
    if (next != CircuitState.switchInTransit &&
        !allowedConnections.contains(next)) {
      throw ArgumentError(
        'Connection $next not allowed for this circuit: $allowedConnections',
      );
    }

    // When leaving battery: store Q before voltage update — ParallelCircuit.js:168-172
    if (next != CircuitState.batteryConnected) {
      disconnectedPlateCharge = getTotalCharge();
    }
    circuitConnection = next;
    if (next != CircuitState.switchInTransit) {
      topSwitchAngle =
          CircuitGeometry.angleForConnection(connection: next, isTop: true);
      bottomSwitchAngle =
          CircuitGeometry.angleForConnection(connection: next, isTop: false);
    }
    updatePlateVoltages();
    notifyListeners();
  }

  /// Drag-time switch pose — sets SWITCH_IN_TRANSIT + one blade angle.
  void setSwitchAngleInTransit({
    required bool isTop,
    required double angle,
  }) {
    final minA = math.min(
      CircuitGeometry.leftLimitAngle(isTop: isTop),
      CircuitGeometry.rightLimitAngle(isTop: isTop),
    );
    final maxA = math.max(
      CircuitGeometry.leftLimitAngle(isTop: isTop),
      CircuitGeometry.rightLimitAngle(isTop: isTop),
    );
    final clamped = angle.clamp(minA, maxA);
    if (circuitConnection != CircuitState.switchInTransit) {
      // Leaving battery stores Q (same as setCircuitConnection)
      if (circuitConnection == CircuitState.batteryConnected) {
        disconnectedPlateCharge = getTotalCharge();
      }
      circuitConnection = CircuitState.switchInTransit;
      updatePlateVoltages();
    }
    if (isTop) {
      topSwitchAngle = clamped;
    } else {
      bottomSwitchAngle = clamped;
    }
    notifyListeners();
  }

  void _onBatteryVoltageChanged() {
    // PhET: polarity always follows voltage; plate V only while battery-connected.
    // Always notify so UI (battery flip) + voltmeter refresh even when open.
    if (circuitConnection == CircuitState.batteryConnected) {
      updatePlateVoltages();
    }
    notifyListeners();
  }

  /// `ParallelCircuit.step` → updateCurrentAmplitude
  void step(double dt) {
    updateCurrentAmplitude(dt);
  }

  /// I ≈ dQ/dt — `ParallelCircuit.updateCurrentAmplitude`
  void updateCurrentAmplitude(double dt) {
    final q = getTotalCharge();
    // PhET checks !== -1; value is never -1 in source, so always compute.
    if (dt != 0) {
      final dQ = q - previousTotalCharge;
      currentAmplitude = dQ / dt;
    }
    previousTotalCharge = q;
    notifyListeners();
  }

  void reset() {
    battery.reset();
    capacitor.reset();
    currentAmplitude = 0;
    circuitConnection = CircuitState.batteryConnected;
    topSwitchAngle = CircuitGeometry.angleForConnection(
      connection: CircuitState.batteryConnected,
      isTop: true,
    );
    bottomSwitchAngle = CircuitGeometry.angleForConnection(
      connection: CircuitState.batteryConnected,
      isTop: false,
    );
    disconnectedPlateCharge = 0;
    previousTotalCharge = 0;
    updatePlateVoltages();
    notifyListeners();
  }

  @override
  void dispose() {
    battery.removeListener(_onBatteryVoltageChanged);
    battery.dispose();
    capacitor.dispose();
    super.dispose();
  }
}

/// Capacitance-screen circuit — `CapacitanceCircuit.js`
class CapacitanceCircuit extends ParallelCircuit {
  CapacitanceCircuit([CircuitConfig? config])
      : super(config ?? CircuitConfig.capacitanceScreen());

  @override
  void updatePlateVoltages() {
    if (circuitConnection == CircuitState.batteryConnected) {
      capacitor.setPlateVoltage(battery.voltage);
    } else {
      // OPEN / TRANSIT: V = Q_disconnected / C — CapacitanceCircuit.js:49-53
      final c = capacitor.capacitance;
      capacitor.setPlateVoltage(
        c == 0 ? 0 : disconnectedPlateCharge / c,
      );
    }
  }
}

/// Light-bulb-screen circuit — `LightBulbCircuit.js`
class LightBulbCircuit extends ParallelCircuit {
  LightBulbCircuit([CircuitConfig? config])
      : super(config ?? CircuitConfig.lightBulbScreen()) {
    assert(lightBulb != null);
    // Geometry multilink — LightBulbCircuit.js:72-80
    capacitor.onCapacitanceChanged = (oldC, newC) {
      updatePlateVoltages();
      if (circuitConnection == CircuitState.lightBulbConnected &&
          capacitor.plateVoltage.abs() > ClbConstants.minVoltageForDischarge) {
        // dt=0 → voltage unchanged by exp; Vo already adjusted via updateDischargeParameters
        capacitor.discharge(lightBulb!.resistance, 0);
      }
      notifyListeners();
    };
  }

  @override
  void updatePlateVoltages() {
    if (circuitConnection == CircuitState.batteryConnected) {
      capacitor.setPlateVoltage(battery.voltage);
    } else if (circuitConnection == CircuitState.openCircuit) {
      final c = capacitor.capacitance;
      capacitor.setPlateVoltage(
        c == 0 ? 0 : disconnectedPlateCharge / c,
      );
    }
    // LIGHT_BULB_CONNECTED / SWITCH_IN_TRANSIT: leave plate voltage as-is
  }

  @override
  void step(double dt) {
    super.step(dt);

    if (circuitConnection == CircuitState.lightBulbConnected) {
      if (capacitor.plateVoltage.abs() > ClbConstants.minVoltageForDischarge) {
        capacitor.discharge(lightBulb!.resistance, dt);
      } else {
        capacitor.setPlateVoltage(0);
        currentAmplitude = 0;
        previousTotalCharge = 0; // #130
      }
      notifyListeners();
    }
  }

  @override
  void updateCurrentAmplitude(double dt) {
    if (circuitConnection == CircuitState.lightBulbConnected) {
      var current = capacitor.plateVoltage / lightBulb!.resistance;
      // Cutoff doubled for #58 — LightBulbCircuit.js:160-163
      final cutoff =
          2 * ClbConstants.minVoltageForDischarge / lightBulb!.resistance;
      if (current.abs() < cutoff) {
        current = 0;
      }
      currentAmplitude = current;
      notifyListeners();
    } else {
      super.updateCurrentAmplitude(dt);
    }
  }
}
