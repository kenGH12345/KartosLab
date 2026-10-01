/// Answer atom with ion/neutral selection — PhET `AnswerAtom`.
library;

import '../number_atom.dart';

/// Neutral / ion radio selection used by element challenges.
enum NeutralOrIon {
  neutral,
  ion,
  noSelection,
}

/// NumberAtom plus optional ion/neutral semantics for answer checking.
class AnswerAtom extends NumberAtom {
  const AnswerAtom(
    super.protons,
    super.neutrons,
    super.electrons, {
    this.neutralOrIon = NeutralOrIon.noSelection,
  });

  const AnswerAtom.counts({
    required super.protonCount,
    required super.neutronCount,
    required super.electronCount,
    this.neutralOrIon = NeutralOrIon.noSelection,
  }) : super.counts();

  final NeutralOrIon neutralOrIon;

  /// PhET `AnswerAtom.equals`.
  ///
  /// Particle counts must match. If [other] is also [AnswerAtom], compare
  /// [neutralOrIon] directly. If [other] is a plain [NumberAtom]:
  /// - `noSelection` → ion check always passes
  /// - `ion` → other.charge != 0
  /// - `neutral` → other.charge == 0
  bool equalsAnswer(NumberAtom other) {
    final particleCountsAreEqual = countsEqual(other);
    final bool neutralOrIonIsEqual;
    if (other is AnswerAtom) {
      neutralOrIonIsEqual = neutralOrIon == other.neutralOrIon;
    } else {
      switch (neutralOrIon) {
        case NeutralOrIon.noSelection:
          neutralOrIonIsEqual = true;
        case NeutralOrIon.ion:
          neutralOrIonIsEqual = other.charge != 0;
        case NeutralOrIon.neutral:
          neutralOrIonIsEqual = other.charge == 0;
      }
    }
    return particleCountsAreEqual && neutralOrIonIsEqual;
  }

  /// Build the submitted answer for element challenges: user Z + ion choice,
  /// N/e copied from the correct answer (PhET `ToElementChallengeView.checkAnswer`).
  static AnswerAtom forElementSubmission({
    required int selectedProtons,
    required NumberAtom correctAnswer,
    required NeutralOrIon neutralOrIon,
  }) {
    return AnswerAtom(
      selectedProtons,
      correctAnswer.neutrons,
      correctAnswer.electrons,
      neutralOrIon: neutralOrIon,
    );
  }
}
