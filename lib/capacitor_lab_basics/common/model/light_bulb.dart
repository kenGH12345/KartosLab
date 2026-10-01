import '../../clb_constants.dart';

/// Light bulb — `js/common/model/LightBulb.js`
class LightBulb {
  LightBulb({
    required this.x,
    required this.y,
    this.z = 0,
    this.resistance = ClbConstants.lightBulbResistance,
  });

  final double x;
  final double y;
  final double z;
  final double resistance;

  double get baseWidth => ClbConstants.bulbBaseWidth;
  double get baseHeight => ClbConstants.bulbBaseHeight;

  /// Ohm's law — `LightBulb.getCurrent`
  double getCurrent(double voltage) => voltage / resistance;

  /// Top terminal — `LightBulb.getTopConnectionPoint` (= position)
  ({double x, double y, double z}) getTopConnectionPoint() =>
      (x: x, y: y, z: z);

  /// Bottom terminal — `x − width·3/5` — LightBulb.js:80-81
  ({double x, double y, double z}) getBottomConnectionPoint() => (
        x: x - baseWidth * 3 / 5,
        y: y,
        z: z,
      );

  /// Default position for Light Bulb circuit — `LightBulbCircuit.js:46-50`
  factory LightBulb.forCircuit({
    required double capacitorXSpacing,
    required double capacitorYSpacing,
  }) {
    return LightBulb(
      x: ClbConstants.batteryX +
          capacitorXSpacing +
          ClbConstants.lightBulbXSpacing,
      y: ClbConstants.batteryY + capacitorYSpacing,
      z: ClbConstants.batteryZ,
    );
  }
}
