import 'dart:math';

import 'package:flutter/material.dart';

import '../model/game_enums.dart';
import '../model/game_model.dart';
import '../model/substance.dart';

/// Thin View→Model bridge — `GameScreen` controller.
class GameController extends ChangeNotifier {
  GameController({GameModel? model}) : model = model ?? GameModel() {
    this.model.addListener(_onModel);
  }

  final GameModel model;

  void _onModel() => notifyListeners();

  @override
  void dispose() {
    model.removeListener(_onModel);
    model.dispose();
    super.dispose();
  }

  void reset() => model.reset();

  void play(int level) => model.play(level);

  void settings() => model.settings();

  void check() => model.check();

  void tryAgain() => model.tryAgain();

  void showAnswer() => model.showAnswer();

  void next() => model.next();

  void setGuessQuantity(Substance substance, int value) =>
      model.setGuessQuantity(substance, value);

  void setTimerEnabled(bool value) => model.setTimerEnabled(value);

  void setGameVisibility(GameVisibility value) =>
      model.setGameVisibility(value);
}

/// Deterministic layout seeds for RandomBox molecule positions.
List<Offset> randomBoxOffsets({
  required int count,
  required Size boxSize,
  Random? random,
}) {
  final rng = random ?? Random();
  final offsets = <Offset>[];
  const margin = 20.0;
  final usable = Size(
    max(1.0, boxSize.width - margin * 2),
    max(1.0, boxSize.height - margin * 2),
  );
  for (var i = 0; i < count; i++) {
    offsets.add(
      Offset(
        margin + rng.nextDouble() * usable.width,
        margin + rng.nextDouble() * usable.height,
      ),
    );
  }
  return offsets;
}
