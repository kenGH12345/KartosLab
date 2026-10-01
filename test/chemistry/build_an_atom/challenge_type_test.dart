import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_type.dart';

void main() {
  test('ChallengeType has exactly 15 values', () {
    expect(ChallengeType.values.length, ChallengeType.count);
    expect(ChallengeType.values.length, 15);
  });

  test('ids match PhET ChallengeTypeValues', () {
    const expected = [
      'counts-to-element',
      'counts-to-charge',
      'counts-to-mass-number',
      'counts-to-symbol-all',
      'counts-to-symbol-charge',
      'counts-to-symbol-mass-number',
      'schematic-to-element',
      'schematic-to-charge',
      'schematic-to-mass-number',
      'schematic-to-symbol-all',
      'schematic-to-symbol-charge',
      'schematic-to-symbol-mass-number',
      'schematic-to-symbol-proton-count',
      'symbol-to-counts',
      'symbol-to-schematic',
    ];
    expect(ChallengeType.values.map((e) => e.id).toList(), expected);
  });
}
