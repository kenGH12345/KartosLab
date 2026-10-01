import 'circuit_position.dart';

/// What a voltmeter probe tip is touching — `js/common/model/ProbeTarget.js`
enum ProbeTarget {
  none,
  otherProbe,
  batteryTopTerminal,
  lightBulbTop,
  lightBulbBottom,
  capacitorTop,
  capacitorBottom,
  switchConnectionTop,
  switchConnectionBottom,
  wireSwitchTop,
  wireSwitchBottom,
  wireCapacitorTop,
  wireCapacitorBottom,
  wireBatteryTop,
  wireBatteryBottom,
  wireLightBulbTop,
  wireLightBulbBottom;

  /// Maps probe target → general circuit rail — `ProbeTarget.getCircuitPosition`
  ///
  /// Switch / switch-wire targets collapse to capacitor rails.
  CircuitPosition get circuitPosition {
    switch (this) {
      case ProbeTarget.batteryTopTerminal:
      case ProbeTarget.wireBatteryTop:
        return CircuitPosition.batteryTop;
      case ProbeTarget.wireBatteryBottom:
        return CircuitPosition.batteryBottom;
      case ProbeTarget.lightBulbTop:
      case ProbeTarget.wireLightBulbTop:
        return CircuitPosition.lightBulbTop;
      case ProbeTarget.lightBulbBottom:
      case ProbeTarget.wireLightBulbBottom:
        return CircuitPosition.lightBulbBottom;
      case ProbeTarget.capacitorTop:
      case ProbeTarget.switchConnectionTop:
      case ProbeTarget.wireSwitchTop:
      case ProbeTarget.wireCapacitorTop:
        return CircuitPosition.capacitorTop;
      case ProbeTarget.capacitorBottom:
      case ProbeTarget.switchConnectionBottom:
      case ProbeTarget.wireSwitchBottom:
      case ProbeTarget.wireCapacitorBottom:
        return CircuitPosition.capacitorBottom;
      case ProbeTarget.none:
      case ProbeTarget.otherProbe:
        throw StateError('No circuit position for $this');
    }
  }
}
