import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/atom_value_pool.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_pool_data.dart';

void main() {
  group('CHALLENGE_POOLS', () {
    test('four levels exist', () {
      expect(kChallengePoolTriples.length, 4);
    });

    test('pool counts match PhET AtomValuePool.ts', () {
      expect(AtomValuePool.poolCount(0), 32);
      expect(AtomValuePool.poolCount(1), 32);
      expect(AtomValuePool.poolCount(2), 60);
      expect(AtomValuePool.poolCount(3), 60);
      expect(AtomValuePool.totalPoolCount, 184);
    });

    test('first and last rows of each level', () {
      expect(kChallengePoolTriples[0].first, [1, 0, 0]);
      expect(kChallengePoolTriples[0].last, [10, 12, 10]);
      expect(kChallengePoolTriples[2].last, [18, 22, 18]);
      expect(kChallengePoolTriples[3].last, [18, 22, 18]);
    });
  });
}
