import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/wire_geometry.dart';

void main() {
  test('wire is a cubic, not a straight segment', () {
    final wire = CubicWire.between(
      start: const BlVec2(0, 0),
      startNormal: CubicWire.bodyNormal,
      end: const BlVec2(80, 40),
      endNormal: CubicWire.sensorNormal,
    );
    expect(wire.control1.x, 25);
    expect(wire.control1.y, 0);
    expect(wire.control2.x, 80);
    expect(wire.control2.y, 65);
    expect(wire.control1.y, isNot((wire.start.y + wire.end.y) / 2));
  });
}
