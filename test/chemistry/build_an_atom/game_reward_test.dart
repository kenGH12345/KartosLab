import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/view/game/game_audio_adapter.dart';

void main() {
  test('perfect score triggers reward flag and audio hook', () {
    final audio = GameAudioAdapter();
    final g = GameModel(randomSeed: 80);
    g.startLevel(1);
    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    expect(g.shouldShowReward, isTrue);
    // Simulate level-complete audio path
    if (g.shouldShowReward) {
      audio.gameOverPerfect();
    }
    expect(audio.history, contains(GameAudioEvent.gameOverPerfectScore));
  });
}
