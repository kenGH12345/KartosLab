import 'dart:math';

import 'package:flutter/foundation.dart';

import '../rpal_constants.dart';
import 'box_type.dart';
import 'challenge.dart';
import 'challenge_factory.dart';
import 'game_enums.dart';
import 'substance.dart';

/// Simple game timer — vegas `GameTimer` subset.
class GameTimer {
  final Stopwatch _watch = Stopwatch();
  Duration get elapsed => _watch.elapsed;
  double get elapsedSeconds => _watch.elapsedMilliseconds / 1000.0;
  bool get isRunning => _watch.isRunning;

  void start() {
    _watch
      ..reset()
      ..start();
  }

  void stop() {
    if (_watch.isRunning) {
      _watch.stop();
    }
  }

  void reset() {
    _watch
      ..stop()
      ..reset();
  }
}

/// Game model — `GameModel.ts`.
class GameModel extends ChangeNotifier {
  GameModel({
    this.numberOfLevels = RpalConstants.gameLevels,
    this.maxQuantity = RpalConstants.quantityMax,
    Random? random,
  }) : _random = random ?? Random() {
    bestScores = List.filled(numberOfLevels, 0);
    bestTimesSeconds = List<double?>.filled(numberOfLevels, null);
  }

  final int numberOfLevels;
  final int maxQuantity;
  final Random _random;

  bool timerEnabled = false;
  GameVisibility gameVisibility = GameVisibility.showAll;
  int level = 0;
  int score = 0;
  int numberOfChallenges = 0;
  Challenge? challenge;
  int challengeNumber = 0; // 1-based; 0 = none
  GamePhase gamePhase = GamePhase.settings;
  PlayState playState = PlayState.none;

  List<Challenge> challenges = [];
  late List<int> bestScores;
  late List<double?> bestTimesSeconds;
  bool isNewBestTime = false;
  final GameTimer timer = GameTimer();

  int getPerfectScore(int levelIndex) =>
      ChallengeFactory.getNumberOfChallenges(levelIndex) *
      RpalConstants.pointsFirstCheck;

  int getNumberOfChallenges(int levelIndex) =>
      ChallengeFactory.getNumberOfChallenges(levelIndex);

  bool isPerfectScore() => score == getPerfectScore(level);

  void reset() {
    timerEnabled = false;
    gameVisibility = GameVisibility.showAll;
    level = 0;
    score = 0;
    numberOfChallenges = 0;
    challenge = null;
    challengeNumber = 0;
    gamePhase = GamePhase.settings;
    playState = PlayState.none;
    challenges = [];
    bestScores = List.filled(numberOfLevels, 0);
    bestTimesSeconds = List<double?>.filled(numberOfLevels, null);
    isNewBestTime = false;
    timer.reset();
    notifyListeners();
  }

  void settings() {
    timer.stop();
    playState = PlayState.none;
    gamePhase = GamePhase.settings;
    notifyListeners();
  }

  void play(int levelIndex) {
    assert(gamePhase == GamePhase.settings);
    level = levelIndex;
    score = 0;
    _initChallenges();
    timer.start();
    playState = PlayState.firstCheck;
    gamePhase = GamePhase.play;
    notifyListeners();
  }

  void check() {
    assert(
      playState == PlayState.firstCheck || playState == PlayState.secondCheck,
    );
    final current = challenge!;
    if (current.isCorrect()) {
      if (challengeNumber == challenges.length) {
        timer.stop();
      }
      final points = playState == PlayState.firstCheck
          ? RpalConstants.pointsFirstCheck
          : RpalConstants.pointsSecondCheck;
      current.points = points;
      score += points;
      playState = PlayState.next;
    } else {
      playState = playState == PlayState.firstCheck
          ? PlayState.tryAgain
          : PlayState.showAnswer;
    }
    notifyListeners();
  }

  void tryAgain() {
    assert(playState == PlayState.tryAgain);
    playState = PlayState.secondCheck;
    notifyListeners();
  }

  /// Moving from TRY_AGAIN to SECOND_CHECK when quantity changes (#37).
  void onGuessQuantityChanged() {
    if (playState == PlayState.tryAgain) {
      playState = PlayState.secondCheck;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void showAnswer() {
    assert(playState == PlayState.showAnswer);
    challenge!.showAnswer();
    playState = PlayState.next;
    notifyListeners();
  }

  void next() {
    if (challengeNumber == challenges.length) {
      _results();
    } else {
      challengeNumber += 1;
      challenge = challenges[challengeNumber - 1];
      playState = PlayState.firstCheck;
      notifyListeners();
    }
  }

  void _results() {
    assert(gamePhase == GamePhase.play);
    timer.stop();
    final time = timer.elapsedSeconds;
    // Vegas GameUtils.updateScoreAndBestTime
    if (score > bestScores[level]) {
      bestScores[level] = score;
    }
    final prevTime = bestTimesSeconds[level];
    isNewBestTime = prevTime == null || time < prevTime;
    if (isNewBestTime) {
      bestTimesSeconds[level] = time;
    }
    playState = PlayState.none;
    gamePhase = GamePhase.results;
    notifyListeners();
  }

  bool get checkEnabled {
    final current = challenge;
    if (current == null) return false;
    final guess = current.guess;
    if (current.interactiveBox == BoxType.before) {
      return guess.reactants.any((s) => s.quantity != 0);
    }
    return guess.products.any((s) => s.quantity != 0) ||
        guess.leftovers.any((s) => s.quantity != 0);
  }

  void setGuessQuantity(Substance substance, int value) {
    final clamped = value.clamp(0, maxQuantity);
    if (substance.quantity == clamped) {
      onGuessQuantityChanged();
      return;
    }
    substance.quantity = clamped;
    onGuessQuantityChanged();
  }

  void _initChallenges() {
    challenges = ChallengeFactory.createChallenges(
      level,
      maxQuantity,
      moleculesVisible: gameVisibility != GameVisibility.hideMolecules,
      numbersVisible: gameVisibility != GameVisibility.hideNumbers,
      random: _random,
    );
    numberOfChallenges = challenges.length;
    challengeNumber = 1;
    challenge = challenges[0];
  }

  void setTimerEnabled(bool value) {
    if (timerEnabled == value) return;
    timerEnabled = value;
    notifyListeners();
  }

  void setGameVisibility(GameVisibility value) {
    if (gameVisibility == value) return;
    gameVisibility = value;
    notifyListeners();
  }
}
