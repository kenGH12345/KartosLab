import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/equation.dart';
import '../model/equation_term.dart';
import '../vegas/game_timer.dart';
import '../vegas/game_utils.dart';
import 'game_level.dart';
import 'game_state.dart';

/// PhET `GameModel` — level selection, challenges, scoring, timer, state machine.
class GameModel extends ChangeNotifier {
  GameModel({Random? random}) {
    final rng = random ?? Random();
    levels = [
      GameLevel.level1(random: rng),
      GameLevel.level2(random: Random(rng.nextInt(1 << 30))),
      GameLevel.level3(random: Random(rng.nextInt(1 << 30))),
    ];
    _challenges = [levels.first.getEquation(0)];
    timer.addListener(notifyListeners);
  }

  late final List<GameLevel> levels;
  final GameTimer timer = GameTimer();

  GameLevel? _level;
  GameState _gameState = GameState.levelSelection;
  int _score = 0;
  late List<Equation> _challenges;
  int _challengeNumber = 1; // 1-based
  int _attempts = 0;
  int _points = 0;
  bool timerEnabled = false;
  bool isNewBestTime = false;
  bool reactantsExpanded = true;
  bool productsExpanded = true;
  bool coefficientsEditable = true;
  bool showWhy = false;
  bool balancedHighlightEnabled = false;
  /// Source: nextButton.visible set *before* balance() in initNext.
  bool _standaloneNextVisible = false;

  GameLevel? get level => _level;
  int get levelNumber => _level?.levelNumber ?? 0;
  GameState get gameState => _gameState;
  int get score => _score;
  List<Equation> get challenges => List.unmodifiable(_challenges);
  int get numberOfChallenges => _challenges.length;
  int get challengeNumber => _challengeNumber;
  Equation get challenge =>
      (_challengeNumber >= 1 && _challengeNumber <= _challenges.length)
          ? _challenges[_challengeNumber - 1]
          : _challenges.first;
  int get attempts => _attempts;
  int get points => _points;

  static const CoefficientRange coefficientsRange = BceCoefficientRanges.game;

  void selectLevel(GameLevel level) {
    _level = level;
    _startGame();
  }

  void setTimerEnabled(bool enabled) {
    if (timerEnabled == enabled) return;
    timerEnabled = enabled;
    notifyListeners();
  }

  void toggleReactants() {
    reactantsExpanded = !reactantsExpanded;
    notifyListeners();
  }

  void toggleProducts() {
    productsExpanded = !productsExpanded;
    notifyListeners();
  }

  void setShowWhy(bool value) {
    if (showWhy == value) return;
    showWhy = value;
    notifyListeners();
  }

  void toggleShowWhy() => setShowWhy(!showWhy);

  /// Full Reset All (level selection screen).
  void reset() {
    _resetToStart();
    for (final l in levels) {
      l.reset();
    }
    _level = null;
    _setGameState(GameState.levelSelection);
    _challengeNumber = 1;
    timerEnabled = false;
    reactantsExpanded = true;
    productsExpanded = true;
    showWhy = false;
    notifyListeners();
  }

  void _resetToStart() {
    isNewBestTime = false;
    _attempts = 0;
    _points = 0;
    _score = 0;
    timer.reset();
  }

  void _setGameState(GameState value) {
    assert(isValidGameStateTransition(_gameState, value) ||
        _gameState == value);
    _gameState = value;
    _applyViewForState();
  }

  void _applyViewForState() {
    switch (_gameState) {
      case GameState.check:
        coefficientsEditable = true;
        balancedHighlightEnabled = false;
        showWhy = false;
      case GameState.tryAgain:
      case GameState.showAnswer:
        coefficientsEditable = false;
        balancedHighlightEnabled = false;
      case GameState.next:
        coefficientsEditable = false;
        balancedHighlightEnabled = true;
        // Source LevelNode.initNext: nextButton.visible = !isSimplified
        // is evaluated BEFORE equation.balance().
        _standaloneNextVisible = !challenge.isSimplified;
        challenge.balance();
      case GameState.levelSelection:
      case GameState.levelCompleted:
        coefficientsEditable = false;
        showWhy = false;
        _standaloneNextVisible = false;
    }
  }

  void _startGame() {
    final level = _level!;
    _resetToStart();
    _challenges = level.getChallenges();
    _challengeNumber = 1;
    challenge.reset();
    reactantsExpanded = true;
    productsExpanded = true;
    if (timerEnabled) {
      timer.start();
    }
    _setGameState(GameState.check);
    notifyListeners();
  }

  void _endGame() {
    timer.stop();
    final level = _level!;
    isNewBestTime = GameUtils.updateScoreAndBestTime(
      score: _score,
      time: timer.elapsedSeconds,
      setBestScore: (v) => level.bestScore = v,
      setBestTime: (v) => level.bestTime = v,
      getBestScore: () => level.bestScore,
      getBestTime: () => level.bestTime,
    );
  }

  /// Check button — awards points only when [Equation.isSimplified].
  void check() {
    assert(_gameState == GameState.check);
    _attempts++;

    if (challenge.isSimplified) {
      if (_attempts == 1) {
        _points = GameLevel.pointsFirstAttempt;
      } else if (_attempts == 2) {
        _points = GameLevel.pointsSecondAttempt;
      } else {
        _points = 0;
      }
      _score += _points;
      _setGameState(GameState.next);
      if (_challengeNumber == _challenges.length) {
        _endGame();
      }
    } else if (_attempts < 2) {
      _setGameState(GameState.tryAgain);
    } else {
      if (_challengeNumber == _challenges.length) {
        _endGame();
      }
      _setGameState(GameState.showAnswer);
    }
    notifyListeners();
  }

  void tryAgain() {
    assert(_gameState == GameState.tryAgain);
    _setGameState(GameState.check);
    notifyListeners();
  }

  /// Show Answer — no points; transitions to `next` then balance().
  void showAnswer() {
    assert(_gameState == GameState.showAnswer);
    _setGameState(GameState.next);
    notifyListeners();
  }

  void next() {
    assert(_gameState == GameState.next);
    if (_challengeNumber < _challenges.length) {
      _attempts = 0;
      _points = 0;
      _challengeNumber++;
      challenge.reset();
      _setGameState(GameState.check);
    } else {
      _setGameState(GameState.levelCompleted);
    }
    notifyListeners();
  }

  /// Start Over — preserves bestScore/bestTime and timerEnabled.
  void startOver() {
    _resetToStart();
    _level = null;
    _setGameState(GameState.levelSelection);
    showWhy = false;
    notifyListeners();
  }

  bool isPerfectScore() {
    final level = _level;
    if (level == null) return false;
    return level.isPerfectScore(_score);
  }

  /// Whether Check is enabled (source: hasNonZeroCoefficient).
  bool get checkEnabled =>
      _gameState == GameState.check && challenge.hasNonZeroCoefficient;

  /// Feedback panel should show for tryAgain/showAnswer, or next with points>0.
  bool get feedbackVisible {
    switch (_gameState) {
      case GameState.tryAgain:
      case GameState.showAnswer:
        return true;
      case GameState.next:
        return _points > 0;
      default:
        return false;
    }
  }

  bool get nextButtonVisible =>
      _gameState == GameState.next && _standaloneNextVisible;

  bool get checkButtonVisible => _gameState == GameState.check;

  @override
  void dispose() {
    timer.removeListener(notifyListeners);
    timer.dispose();
    for (final level in levels) {
      level.disposePool();
    }
    super.dispose();
  }
}
