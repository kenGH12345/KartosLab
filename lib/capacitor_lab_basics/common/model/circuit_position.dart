/// Wire / contact positions — `js/common/model/CircuitPosition.js`
enum CircuitPosition {
  batteryTop,
  batteryBottom,
  lightBulbTop,
  lightBulbBottom,
  capacitorTop,
  capacitorBottom,
  circuitSwitchTop,
  circuitSwitchBottom;

  bool get isTop =>
      this == batteryTop ||
      this == lightBulbTop ||
      this == capacitorTop ||
      this == circuitSwitchTop;

  bool get isBattery => this == batteryTop || this == batteryBottom;

  bool get isLightBulb => this == lightBulbTop || this == lightBulbBottom;

  bool get isCapacitor => this == capacitorTop || this == capacitorBottom;
}
