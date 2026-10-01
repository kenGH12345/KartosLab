import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/score_model.dart';

void main() {
  test('star progress proportion and half-star', () {
    expect(StarProgress(score: 0).filledStars, 0);
    expect(StarProgress(score: 10).filledStars, 5);
    expect(StarProgress(score: 5).filledStars, 2);
    expect(StarProgress(score: 5).hasHalfStar, isTrue);
    expect(StarProgress(score: 1).remainder, closeTo(0.5, 1e-9));
  });

  test('game starProgress starts empty', () {
    final g = GameModel(randomSeed: 1);
    g.startLevel(1);
    expect(g.starProgress.filledStars, 0);
    expect(g.starProgress.emptyStars, 5);
  });
}
