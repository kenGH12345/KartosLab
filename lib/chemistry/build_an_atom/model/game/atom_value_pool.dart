/// Challenge atom pools — PhET `AtomValuePool` + `CHALLENGE_POOLS`.
library;

import 'dart:math';

import '../number_atom.dart';
import 'challenge_pool_data.dart';

/// Mutable pool of unused atom values for one level's challenge generation.
class AtomValuePool {
  AtomValuePool(int levelIndex)
      : remaining = [
          for (final t in kChallengePoolTriples[levelIndex])
            NumberAtom(t[0], t[1], t[2]),
        ],
        used = <NumberAtom>[];

  final List<NumberAtom> remaining;
  final List<NumberAtom> used;

  static int poolCount(int levelIndex) =>
      kChallengePoolTriples[levelIndex].length;

  static int get totalPoolCount =>
      kChallengePoolTriples.fold<int>(0, (s, l) => s + l.length);

  void markAtomAsUsed(NumberAtom atomValue) {
    final index = remaining.indexOf(atomValue);
    if (index != -1) {
      remaining.removeAt(index);
      used.add(atomValue);
    }
  }

  /// PhET filter: `protonCount >= min && protonCount < max` and optional charge.
  NumberAtom getRandomAtomValue(
    Random random, {
    required int minProtonCount,
    required double maxProtonCount,
    required bool isChargedRequired,
  }) {
    bool meets(NumberAtom a) {
      return a.protons >= minProtonCount &&
          a.protons < maxProtonCount &&
          (!isChargedRequired || a.charge != 0);
    }

    var allowable = remaining.where(meets).toList();
    if (allowable.isEmpty) {
      allowable = used.where(meets).toList();
    }
    if (allowable.isEmpty) {
      throw StateError('No atoms found that match the specified criteria');
    }
    return allowable[random.nextInt(allowable.length)];
  }
}
