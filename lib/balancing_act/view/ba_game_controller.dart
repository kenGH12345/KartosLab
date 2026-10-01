import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/balancing_act/ba_mvt.dart';
import 'package:kratos/balancing_act/ba_shared_constants.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/model/ba_vector2.dart';
import 'package:kratos/balancing_act/model/game/balance_game_challenge.dart';
import 'package:kratos/balancing_act/model/game/balance_game_model.dart';
import 'package:kratos/balancing_act/view/game/ba_game_audio.dart';
import 'package:kratos/common/simulation_clock.dart';

/// Game clock + model bridge. Physics only via [BalanceGameModel.step].
class BaGameController extends ChangeNotifier {
  BaGameController({
    BalanceGameModel? model,
    BaGameAudioPlayer? audio,
    List<BalanceGameChallenge> Function(int level)? challengeSetFactory,
  })  : model = model ??
            BalanceGameModel(challengeSetFactory: challengeSetFactory),
        mvt = BaModelViewTransform.game(),
        audio = audio ?? BaGameAudioPlayer(),
        clock = SimulationClock(fps: 60) {
    clock.onTick = _onTick;
  }

  final BalanceGameModel model;
  final BaModelViewTransform mvt;
  final BaGameAudioPlayer audio;
  final SimulationClock clock;

  BaMass? _dragging;
  BaVector2? _dragOffset;

  /// Mass deduction entry (kg). Source: MassValueEntryNode.
  double massEntryValue = 0;

  /// Tilt prediction selection.
  TiltPredictionState tiltPrediction = TiltPredictionState.none;

  /// Accumulator for 1 Hz game timer (source setInterval 1000).
  double _timerAccum = 0;

  BaMass? get dragging => _dragging;

  void attach(TickerProvider vsync) {
    if (clock.isRunning) {
      clock.pause();
    }
    clock.attach(vsync);
    clock.play();
  }

  void _onTick(double dt, double total) {
    model.step(dt);
    if (model.timerEnabled &&
        model.gameState != BaGameState.choosingLevel &&
        model.gameState != BaGameState.showingLevelResults) {
      _timerAccum += dt;
      while (_timerAccum >= 1.0) {
        _timerAccum -= 1.0;
        model.tickTimerOneSecond();
      }
    }
    notifyListeners();
  }

  void startLevel(int level) {
    massEntryValue = 0;
    tiltPrediction = TiltPredictionState.none;
    _timerAccum = 0;
    model.startLevel(level);
    notifyListeners();
  }

  void newGame() {
    massEntryValue = 0;
    tiltPrediction = TiltPredictionState.none;
    _timerAccum = 0;
    model.newGame();
    notifyListeners();
  }

  void resetAll() {
    _dragging = null;
    _dragOffset = null;
    massEntryValue = 0;
    tiltPrediction = TiltPredictionState.none;
    _timerAccum = 0;
    model.reset();
    notifyListeners();
  }

  void setTimerEnabled(bool v) {
    model.timerEnabled = v;
    notifyListeners();
  }

  void setPositionChoice(PositionIndicatorChoice c) {
    model.positionMarkerState = c;
    notifyListeners();
  }

  void setMassEntry(double kg) {
    massEntryValue = kg.clamp(0, 100);
    notifyListeners();
  }

  void setTiltPrediction(TiltPredictionState s) {
    tiltPrediction = s;
    notifyListeners();
  }

  void beginDrag(BaMass mass, Offset viewPos) {
    if (model.gameState != BaGameState.presentingInteractiveChallenge) return;
    if (!model.movableMasses.contains(mass)) return;
    final modelPos = mvt.viewToModel(viewPos);
    _dragging = mass;
    _dragOffset = mass.position.minus(modelPos);
    model.beginDragMovable(mass);
    notifyListeners();
  }

  void updateDrag(Offset viewPos) {
    final mass = _dragging;
    final offset = _dragOffset;
    if (mass == null || offset == null) return;
    final modelPos = mvt.viewToModel(viewPos);
    model.dragMovableTo(mass, modelPos.plus(offset));
    notifyListeners();
  }

  void endDrag() {
    final mass = _dragging;
    if (mass == null) return;
    model.endDragMovable(mass);
    _dragging = null;
    _dragOffset = null;
    notifyListeners();
  }

  bool get canCheckAnswer {
    final c = model.getCurrentChallenge();
    if (c == null) return false;
    if (model.gameState != BaGameState.presentingInteractiveChallenge) {
      return false;
    }
    switch (c.kind) {
      case BaChallengeKind.balanceMasses:
        final centerX = model.plank.getPlankSurfaceCenter().x;
        return model.plank.massesOnSurface.any((m) => m.position.x > centerX);
      case BaChallengeKind.tiltPrediction:
        return tiltPrediction != TiltPredictionState.none;
      case BaChallengeKind.massDeduction:
        return massEntryValue != 0;
    }
  }

  void checkAnswer() {
    final c = model.getCurrentChallenge();
    if (c == null) return;
    if (c.kind == BaChallengeKind.massDeduction) {
      model.checkAnswer(mass: massEntryValue);
    } else if (c.kind == BaChallengeKind.tiltPrediction) {
      model.checkAnswer(tiltPrediction: tiltPrediction);
    } else {
      model.checkAnswer();
    }
    _playFeedbackAudio();
    notifyListeners();
  }

  void _playFeedbackAudio() {
    switch (model.gameState) {
      case BaGameState.showingCorrectAnswerFeedback:
        audio.correctAnswer();
      case BaGameState.showingIncorrectAnswerFeedbackTryAgain:
      case BaGameState.showingIncorrectAnswerFeedbackMoveOn:
        audio.wrongAnswer();
      default:
        break;
    }
  }

  void tryAgain() {
    model.tryAgain();
    // Source: tilt selection resets; mass entry cleared only if first attempt
    // was wrong with incorrectGuesses==0 before tryAgain — after tryAgain,
    // incorrectGuesses stays. MassValueEntry clears only when incorrectGuesses
    // was 0 when entering presentingInteractiveChallenge from feedback.
    // View clears tilt always; mass entry cleared only if incorrectGuesses==0
    // when returning — but after wrong, incorrectGuesses >= 1, so keep value.
    tiltPrediction = TiltPredictionState.none;
    notifyListeners();
  }

  void displayCorrectAnswer() {
    model.displayCorrectAnswer();
    final c = model.getCurrentChallenge();
    if (c?.kind == BaChallengeKind.massDeduction) {
      massEntryValue = model.getTotalFixedMassValue();
    } else if (c?.kind == BaChallengeKind.tiltPrediction) {
      tiltPrediction = model.getTipDirection();
    }
    notifyListeners();
  }

  void nextChallenge() {
    final before = model.gameState;
    model.nextChallenge();
    massEntryValue = 0;
    tiltPrediction = TiltPredictionState.none;
    if (model.gameState == BaGameState.showingLevelResults &&
        before != BaGameState.showingLevelResults) {
      _playLevelCompleteAudio();
    }
    notifyListeners();
  }

  void _playLevelCompleteAudio() {
    if (model.score == BaGameConstants.maxScorePerGame) {
      audio.gameOverPerfectScore();
    } else if (model.score == 0) {
      audio.gameOverZeroScore();
    } else {
      audio.gameOverImperfectScore();
    }
  }

  void continueFromResults() {
    model.newGame();
    notifyListeners();
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}
