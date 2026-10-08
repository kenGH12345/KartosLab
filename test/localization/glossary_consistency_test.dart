import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('canonical physics terms match glossary', () {
    expect(loc.physics.mass, '质量');
    expect(loc.physics.weight, '重量');
    expect(loc.physics.gravity, '重力');
    expect(loc.physics.gravityForce, '引力');
    expect(loc.physics.density, '密度');
    expect(loc.physics.volume, '体积');
    expect(loc.physics.pressure, '压强');
    expect(loc.physics.buoyancy, '浮力');
    expect(loc.physics.force, '力');
  });

  test('parameterized mass keeps unit token', () {
    final s = loc.physics.massWithValue(2);
    expect(s, contains('质量'));
    expect(s, contains('2'));
    expect(s, contains('kg'));
  });

  test('mass ≠ weight', () {
    expect(loc.physics.mass, isNot(loc.physics.weight));
  });
}
