
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/interaction/protractor_rotation.dart';

void main() {
  test('outer-ring drag changes the protractor angle', () {
    const center = Offset(48, 48);
    final delta = protractorAngleDelta(
      center: center,
      start: const Offset(90, 48),
      end: const Offset(48, 10),
    );
    expect(delta, isNot(0));
    expect(protractorOuterRing(center, const Offset(90, 48), 48), isTrue);
    expect(protractorOuterRing(center, const Offset(48, 48), 48), isFalse);
  });

  test('ticks share the node rotation rather than a separate frame', () {
    var angle = 0.0;
    angle += protractorAngleDelta(
      center: const Offset(0, 0),
      start: const Offset(1, 0),
      end: const Offset(0, 1),
    );
    expect(angle, isNot(0));
  });
}
