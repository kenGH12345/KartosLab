import '../../clb_constants.dart';
import 'circuit_state.dart';

/// Configuration bag — `js/common/model/CircuitConfig.js`
class CircuitConfig {
  CircuitConfig({
    this.capacitorXSpacing = ClbConstants.capacitanceCapacitorXSpacing,
    this.capacitorYSpacing = ClbConstants.capacitanceCapacitorYSpacing,
    this.plateWidth = ClbConstants.plateWidthDefault,
    this.plateSeparation = ClbConstants.plateSeparationDefault,
    this.wireExtent = ClbConstants.wireExtent,
    this.hasLightBulb = false,
    List<CircuitState>? circuitConnections,
  }) : circuitConnections = List.unmodifiable(
          circuitConnections ??
              const [
                CircuitState.batteryConnected,
                CircuitState.openCircuit,
                CircuitState.lightBulbConnected,
              ],
        );

  final double capacitorXSpacing;
  final double capacitorYSpacing;
  final double plateWidth;
  final double plateSeparation;
  final double wireExtent;
  final bool hasLightBulb;
  final List<CircuitState> circuitConnections;

  /// Capacitance screen defaults — only two switch positions.
  factory CircuitConfig.capacitanceScreen() => CircuitConfig(
        circuitConnections: const [
          CircuitState.batteryConnected,
          CircuitState.openCircuit,
        ],
      );

  /// Light Bulb screen defaults (three-state switch).
  factory CircuitConfig.lightBulbScreen({bool twoStateSwitch = false}) =>
      CircuitConfig(
        capacitorXSpacing: ClbConstants.lightBulbCapacitorXSpacing,
        capacitorYSpacing: ClbConstants.lightBulbCapacitorYSpacing,
        hasLightBulb: true,
        circuitConnections: twoStateSwitch
            ? const [
                CircuitState.batteryConnected,
                CircuitState.lightBulbConnected,
              ]
            : const [
                CircuitState.batteryConnected,
                CircuitState.openCircuit,
                CircuitState.lightBulbConnected,
              ],
      );
}
