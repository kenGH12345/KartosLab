import 'bl_vec2.dart';

/// scenery-phet `WireNode` cubic: start, start+normal1, end+normal2, end.
class CubicWire {
  const CubicWire(this.start, this.control1, this.control2, this.end);

  final BlVec2 start;
  final BlVec2 control1;
  final BlVec2 control2;
  final BlVec2 end;

  factory CubicWire.between({
    required BlVec2 start,
    required BlVec2 startNormal,
    required BlVec2 end,
    required BlVec2 endNormal,
  }) {
    return CubicWire(
      start,
      start + startNormal,
      end + endNormal,
      end,
    );
  }

  /// View-pixel normals used by intensity meter and wave sensor.
  static const BlVec2 bodyNormal = BlVec2(25, 0);
  static const BlVec2 sensorNormal = BlVec2(0, 25);
}
