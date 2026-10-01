/// Runtime challenge instance — PhET `BAAGameChallenge` domain subset.
library;

import '../number_atom.dart';
import 'answer_atom.dart';
import 'challenge_type.dart';

/// One configured challenge with a correct answer.
class Challenge {
  Challenge({
    required this.type,
    required NumberAtom correctAnswer,
  }) : correctAnswerAtom = correctAnswer;

  final ChallengeType type;
  NumberAtom correctAnswerAtom;

  bool isAnswerInteractive = true;

  void setCorrectAnswer(NumberAtom atom) {
    correctAnswerAtom = atom;
  }

  /// Whether [submitted] matches the correct answer (AnswerAtom semantics).
  bool isCorrect(AnswerAtom submitted) {
    // Compare submitted against correct NumberAtom using AnswerAtom rules
    // where `this` side carries ion/neutral when present.
    return submitted.equalsAnswer(correctAnswerAtom);
  }
}
