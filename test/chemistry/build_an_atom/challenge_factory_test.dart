import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_descriptor_set_factory.dart';

void main() {
  group('ChallengeDescriptorSetFactory', () {
    test('creates 5 challenges per level', () {
      for (var level = 0; level < 4; level++) {
        final set = ChallengeDescriptorSetFactory.createSet(
          levelIndex: level,
          random: Random(42),
        );
        expect(set.length, BAAConstants.challengesPerLevel);
      }
    });

    test('same seed → same sequence', () {
      final a = ChallengeDescriptorSetFactory.createSet(
        levelIndex: 0,
        random: Random(12345),
      );
      final b = ChallengeDescriptorSetFactory.createSet(
        levelIndex: 0,
        random: Random(12345),
      );
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].type, b[i].type);
        expect(a[i].atomValue, b[i].atomValue);
      }
    });

    test('no consecutive duplicate challenge types', () {
      for (var seed = 0; seed < 50; seed++) {
        for (var level = 0; level < 4; level++) {
          final set = ChallengeDescriptorSetFactory.createSet(
            levelIndex: level,
            random: Random(seed),
          );
          for (var i = 1; i < set.length; i++) {
            expect(
              set[i].type,
              isNot(set[i - 1].type),
              reason: 'seed=$seed level=$level i=$i',
            );
          }
        }
      }
    });

    test('schematic Z < 3; non-schematic Z >= 4', () {
      for (var seed = 0; seed < 40; seed++) {
        for (var level = 0; level < 4; level++) {
          final set = ChallengeDescriptorSetFactory.createSet(
            levelIndex: level,
            random: Random(seed),
          );
          for (final d in set) {
            if (d.type.isSchematicRelated) {
              expect(
                d.atomValue.protons <
                    BAAConstants.maxProtonNumberForSchematicChallenges,
                isTrue,
                reason: '${d.type} Z=${d.atomValue.protons}',
              );
            } else {
              expect(
                d.atomValue.protons >=
                    BAAConstants.maxProtonNumberForSchematicChallenges + 1,
                isTrue,
                reason: '${d.type} Z=${d.atomValue.protons}',
              );
            }
          }
        }
      }
    });
  });
}
