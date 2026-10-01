
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/sticky_thermometer.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

void main() {
  test('ElementFollower preserves drop-time offset', () {
    final block = ThermalBlock(
      id: 'iron',
      blockType: BlockType.iron,
      position: const Offset(0.1, 0),
    );
    final t = StickyThermometer(
      id: 't0',
      position: const Offset(0.12, 0.02),
    );
    t.startFollowingBlock(block);
    block.position = const Offset(0.15, 0.05);
    t.stepFollow();
    expect(t.position.dx, closeTo(0.17, 1e-9));
    expect(t.position.dy, closeTo(0.07, 1e-9));
  });

  test('ElementFollower follows beaker position', () {
    final beaker = Beaker(
      id: 'water',
      beakerType: BeakerType.water,
      position: const Offset(-0.2, 0),
    );
    final t = StickyThermometer(
      id: 't1',
      position: const Offset(-0.18, 0.04),
    );
    t.startFollowingBeaker(beaker);
    beaker.position = const Offset(-0.25, 0.1);
    t.stepFollow();
    expect(t.position.dx, closeTo(-0.23, 1e-9));
    expect(t.position.dy, closeTo(0.14, 1e-9));
  });
}
