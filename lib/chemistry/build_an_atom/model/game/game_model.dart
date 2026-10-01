/// Game screen model — PhET `GameModel` state machine + scoring.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../constants/baa_constants.dart';
import '../number_atom.dart';
import 'answer_atom.dart';
import 'challenge.dart';
import 'challenge_descriptor.dart';
import 'game_level.dart';
import 'game_state.dart';
import 'game_timer.dart';
import 'score_model.dart';

/// Full game model: 4 levels, challenges, score, timer, reset / startOver.
class GameModel extends ChangeNotifier {
  GameModel({int? randomSeed})
      : _randomSeed = randomSeed ?? 0,
        _random = Random(randomSeed ?? 0) {
    levels = List<GameLevel>.generate(
      BAAConstants.numberOfGameLevels,
      (i) => GameLevel(levelNumber: i + 1, random: _random),
    );
  }

  int _randomSeed;
  Random _random;

  late final List<GameLevel> levels;
  final GameTimer timer = GameTimer();

  GameState gameState = GameState.levelSelection;
  GameLevel? level;
  Challenge? challenge;
  int challengeNumber = 1; // 1-based
  int score = 0;
  int attempts = 0;
  int pointsForCurrentChallenge = 0;
  bool timerEnabled = false;

  int get randomSeed => _randomSeed;

  int get levelNumber => level?.levelNumber ?? 0;

  bool get shouldShowReward {
    final lvl = level;
    if (lvl == null) return false;
    return score >= lvl.perfectScore;
  }

  StarProgress get starProgress => StarProgress(score: score);

  StarProgress bestStarProgress(GameLevel lvl) =>
      StarProgress(score: lvl.bestScore);

  /// Select and start a level (1-based).
  void startLevel(int levelNumber) {
    assert(levelNumber >= 1 && levelNumber <= levels.length);
    level = levels[levelNumber - 1];
    level!.regenerateChallenges(_random);
    level!.startLevel();
    challengeNumber = 1;
    attempts = 0;
    score = 0;
    pointsForCurrentChallenge = 0;
    _setChallenge(challengeNumber);
    if (timerEnabled) {
      timer.reset();
      timer.start();
    } else {
      timer.reset();
    }
    notifyListeners();
  }

  void _setChallenge(int number) {
    final lvl = level!;
    final descriptor = lvl.challengeDescriptors[number - 1];
    attempts = 0;
    pointsForCurrentChallenge = 0;
    challenge = Challenge(
      type: descriptor.type,
      correctAnswer: descriptor.atomValue,
    );
    gameState = GameState.presentingChallenge;
  }

  /// Check a submitted answer (PhET `GameModel.check`).
  void check(AnswerAtom submitted) {
    final lvl = level;
    final ch = challenge;
    if (lvl == null || ch == null) return;
    // One transition per action — ignore Check outside answering state.
    if (gameState != GameState.presentingChallenge) return;

    attempts++;
    final correct = ch.isCorrect(submitted);
    final points = pointsForAttempt(attempts);
    pointsForCurrentChallenge = points;
    if (correct) {
      score += points;
      gameState = GameState.solvedCorrectly;
      if (lvl.isLastChallenge(challengeNumber)) {
        _endLevel();
      }
    } else if (attempts < BAAConstants.maxAttemptsPerChallenge) {
      gameState = GameState.tryAgain;
    } else {
      gameState = GameState.attemptsExhausted;
      if (lvl.isLastChallenge(challengeNumber)) {
        _endLevel();
      }
    }
    notifyListeners();
  }

  /// After tryAgain button — return to answering.
  void tryAgain() {
    gameState = GameState.presentingChallenge;
    notifyListeners();
  }

  /// Show answer after attempts exhausted.
  void displayCorrectAnswer() {
    gameState = GameState.showingAnswer;
    notifyListeners();
  }

  /// Advance to next challenge or levelCompleted.
  void next() {
    final lvl = level;
    if (lvl == null) return;
    if (!lvl.isLastChallenge(challengeNumber)) {
      challengeNumber++;
      _setChallenge(challengeNumber);
    } else {
      gameState = GameState.levelCompleted;
      challenge = null;
    }
    notifyListeners();
  }

  void _endLevel() {
    final lvl = level!;
    timer.stop();
    lvl.endLevel(
      score: score,
      timeSeconds: timer.elapsedSeconds,
      timerEnabled: timerEnabled,
    );
    _randomSeed++;
    _random = Random(_randomSeed);
  }

  /// Start Over — keep best scores; return to level selection; bump seed.
  void startOver() {
    _resetToStart();
    level = null;
    challenge = null;
    gameState = GameState.levelSelection;
    _randomSeed++;
    _random = Random(_randomSeed);
    notifyListeners();
  }

  /// Reset All — clear best scores, timer preference, back to selection.
  void reset() {
    _resetToStart();
    for (final lvl in levels) {
      lvl.reset();
    }
    level = null;
    challenge = null;
    timerEnabled = false;
    gameState = GameState.levelSelection;
    notifyListeners();
  }

  void _resetToStart() {
    attempts = 0;
    score = 0;
    pointsForCurrentChallenge = 0;
    challengeNumber = 1;
    timer.reset();
  }

  void setTimerEnabled(bool enabled) {
    timerEnabled = enabled;
    notifyListeners();
  }

  /// Advance timer when a level is being played.
  void step(double dt) {
    timer.tick(dt);
    if (timer.isRunning) {
      notifyListeners();
    }
  }

  /// Element-challenge helper mirroring PhET view submission.
  void checkElementAnswer({
    required int selectedProtons,
    required NeutralOrIon neutralOrIon,
  }) {
    final ch = challenge;
    if (ch == null) return;
    final submitted = AnswerAtom.forElementSubmission(
      selectedProtons: selectedProtons,
      correctAnswer: ch.correctAnswerAtom,
      neutralOrIon: neutralOrIon,
    );
    check(submitted);
  }

  /// Expose current descriptor for tests.
  ChallengeDescriptor? get currentDescriptor {
    final lvl = level;
    if (lvl == null) return null;
    if (challengeNumber < 1 ||
        challengeNumber > lvl.challengeDescriptors.length) {
      return null;
    }
    return lvl.challengeDescriptors[challengeNumber - 1];
  }

  NumberAtom? get correctAnswer => challenge?.correctAnswerAtom;
}
