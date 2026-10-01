import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('AnswerAtom.equals', () {
    test('same particles match', () {
      const a = AnswerAtom(1, 0, 1);
      const b = NumberAtom(1, 0, 1);
      expect(a.equalsAnswer(b), isTrue);
    });

    test('different particles fail', () {
      const a = AnswerAtom(1, 0, 1);
      const b = NumberAtom(2, 2, 2);
      expect(a.equalsAnswer(b), isFalse);
    });

    test('ion vs neutral against NumberAtom charge', () {
      const correct = NumberAtom(1, 0, 0); // charge +1
      const ion = AnswerAtom(1, 0, 0, neutralOrIon: NeutralOrIon.ion);
      const neutral = AnswerAtom(1, 0, 0, neutralOrIon: NeutralOrIon.neutral);
      expect(ion.equalsAnswer(correct), isTrue);
      expect(neutral.equalsAnswer(correct), isFalse);

      const neutralAtom = NumberAtom(1, 0, 1);
      expect(
        const AnswerAtom(1, 0, 1, neutralOrIon: NeutralOrIon.neutral)
            .equalsAnswer(neutralAtom),
        isTrue,
      );
      expect(
        const AnswerAtom(1, 0, 1, neutralOrIon: NeutralOrIon.ion)
            .equalsAnswer(neutralAtom),
        isFalse,
      );
    });

    test('noSelection ignores ion check', () {
      const a = AnswerAtom(1, 0, 0, neutralOrIon: NeutralOrIon.noSelection);
      expect(a.equalsAnswer(const NumberAtom(1, 0, 0)), isTrue);
    });

    test('element submission copies N/e from correct', () {
      const correct = NumberAtom(3, 4, 3);
      final submitted = AnswerAtom.forElementSubmission(
        selectedProtons: 3,
        correctAnswer: correct,
        neutralOrIon: NeutralOrIon.neutral,
      );
      expect(submitted.neutrons, 4);
      expect(submitted.electrons, 3);
      expect(submitted.equalsAnswer(correct), isTrue);

      final wrongZ = AnswerAtom.forElementSubmission(
        selectedProtons: 4,
        correctAnswer: correct,
        neutralOrIon: NeutralOrIon.neutral,
      );
      expect(wrongZ.equalsAnswer(correct), isFalse);
    });
  });
}
