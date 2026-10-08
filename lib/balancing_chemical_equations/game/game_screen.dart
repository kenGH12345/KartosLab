import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/balancing_chemical_equations/bce_constants.dart';
import 'package:kratos/balancing_chemical_equations/game/bce_reward_node.dart';
import 'package:kratos/balancing_chemical_equations/game/game_feedback_node.dart';
import 'package:kratos/balancing_chemical_equations/game/game_level.dart';
import 'package:kratos/balancing_chemical_equations/game/game_model.dart';
import 'package:kratos/balancing_chemical_equations/game/game_state.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_audio_player.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_timer.dart';
import 'package:kratos/balancing_chemical_equations/views/bce_equation_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bce_molecule_node.dart';
import 'package:kratos/balancing_chemical_equations/views/horizontal_aligner.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';

/// PhET `GameScreen` / `GameScreenView` — level selection + play + completed.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.model, this.audioPlayer});

  final GameModel? model;
  final GameAudioPlayer? audioPlayer;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameModel _model;
  late final bool _ownsModel;
  late final GameAudioPlayer _audio;
  GameState? _prevState;

  static const _boxSize = Size(285, 340);
  static const _boxXSpacing = 140.0;
  static const _bg = Color(0xFFFFFFE4);
  static const _statusBarColor = Color.fromRGBO(49, 117, 202, 1);

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? GameModel();
    _audio = widget.audioPlayer ?? const GameAudioPlayer();
    _prevState = _model.gameState;
    _model.addListener(_onModelChanged);
  }

  void _onModelChanged() {
    final prev = _prevState;
    final next = _model.gameState;
    if (prev == GameState.check &&
        (next == GameState.next ||
            next == GameState.tryAgain ||
            next == GameState.showAnswer)) {
      if (_model.challenge.isSimplified && next == GameState.next) {
        _audio.correctAnswer();
      } else if (next == GameState.tryAgain || next == GameState.showAnswer) {
        _audio.wrongAnswer();
      }
    }
    if (prev != GameState.levelCompleted && next == GameState.levelCompleted) {
      if (_model.isPerfectScore()) {
        _audio.gameOverPerfectScore();
      } else {
        _audio.gameOverImperfectScore();
      }
    }
    _prevState = next;
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _audio.dispose();
    if (_ownsModel) _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: BceConstants.layoutWidth,
              height: BceConstants.layoutHeight,
              child: ListenableBuilder(
                listenable: _model,
                builder: (context, _) {
                  switch (_model.gameState) {
                    case GameState.levelSelection:
                      return _LevelSelectionView(model: _model);
                    case GameState.levelCompleted:
                      return _LevelCompletedView(model: _model);
                    default:
                      return _LevelPlayView(
                        model: _model,
                        boxSize: _boxSize,
                        boxXSpacing: _boxXSpacing,
                        statusBarColor: _statusBarColor,
                      );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Level selection ─────────────────────────────────────────────────────────

class _LevelSelectionView extends StatelessWidget {
  const _LevelSelectionView({required this.model});
  final GameModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 40,
          child: Text(
            'Choose Your Level!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < model.levels.length; i++) ...[
                if (i > 0) const SizedBox(width: 50),
                _LevelButton(
                  level: model.levels[i],
                  showBestTime: model.timerEnabled,
                  onTap: () => model.selectLevel(model.levels[i]),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: _TimerToggle(
            enabled: model.timerEnabled,
            onChanged: model.setTimerEnabled,
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Transform.scale(
            scale: 0.8,
            child: KratosResetAllButton(
              onPressed: model.reset,
              radius: 20.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.level,
    required this.showBestTime,
    required this.onTap,
  });
  final GameLevel level;
  final bool showBestTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stars = _filledStars(level.bestScore, level.getPerfectScore(), 5);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        height: 155,
        decoration: BoxDecoration(
          color: const Color(0xFFD9EBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black54, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 3),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${level.levelNumber}',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 48,
              child: FittedBox(
                fit: BoxFit.contain,
                child: BceMoleculeNode(molecule: level.iconMolecule, scale: 0.85),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: CustomPaint(
                      size: const Size(14, 14),
                      painter: _StarPainter(filled: i < stars),
                    ),
                  ),
              ],
            ),
            if (showBestTime && level.bestTime > 0)
              Text(
                GameTimer.formatTime(level.bestTime),
                style: const TextStyle(fontFamily: 'Arial', fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  static int _filledStars(int score, int perfect, int count) {
    if (perfect <= 0 || score <= 0) return 0;
    return math.min(count, (score * count / perfect).floor());
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.filled});
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);
    canvas.drawPath(
      path,
      Paint()..color = filled ? const Color(0xFFFFD700) : const Color(0xFFCCCCCC),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black54,
    );
  }

  Path _starPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.filled != filled;
}

class _TimerToggle extends StatelessWidget {
  const _TimerToggle({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black54),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: _ClockPainter(),
            ),
            const SizedBox(width: 6),
            Text(
              enabled ? 'On' : 'Off',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 0.5;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white,
    );
    canvas.drawLine(c, Offset(c.dx, c.dy - r * 0.55),
        Paint()..color = Colors.white..strokeWidth = 1.5);
    canvas.drawLine(c, Offset(c.dx + r * 0.4, c.dy),
        Paint()..color = Colors.white..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Play ────────────────────────────────────────────────────────────────────

class _LevelPlayView extends StatelessWidget {
  const _LevelPlayView({
    required this.model,
    required this.boxSize,
    required this.boxXSpacing,
    required this.statusBarColor,
  });

  final GameModel model;
  final Size boxSize;
  final double boxXSpacing;
  final Color statusBarColor;

  @override
  Widget build(BuildContext context) {
    const layoutW = BceConstants.layoutWidth;
    final aligner = HorizontalAligner(
      screenWidth: layoutW,
      boxWidth: boxSize.width,
      boxXSpacing: boxXSpacing,
    );
    const statusH = 40.0;

    return Stack(
      children: [
        // Status bar
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: statusH,
          child: ColoredBox(
            color: statusBarColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    'Challenge ${model.challengeNumber} of ${model.numberOfChallenges}',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Score: ${model.score}',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (model.timerEnabled) ...[
                    const SizedBox(width: 16),
                    Text(
                      GameTimer.formatTime(model.timer.elapsedSeconds),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: model.startOver,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Start Over',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Particles
        Positioned(
          left: 0,
          right: 0,
          top: statusH + 15,
          child: SizedBox(
            height: boxSize.height + 28,
            child: ParticlesNode(
              equation: model.challenge,
              aligner: aligner,
              boxSize: boxSize,
              coefficientsMax: GameModel.coefficientsRange.max,
              reactantsExpanded: model.reactantsExpanded,
              productsExpanded: model.productsExpanded,
              onToggleReactants: model.toggleReactants,
              onToggleProducts: model.toggleProducts,
              arrowHighlightEnabled: model.balancedHighlightEnabled,
            ),
          ),
        ),

        // Equation
        Positioned(
          left: 0,
          bottom: 70,
          child: BceEquationNode(
            equation: model.challenge,
            aligner: aligner,
            coefficientsEditable: model.coefficientsEditable,
            balancedHighlightEnabled: model.balancedHighlightEnabled,
          ),
        ),

        // Check / Next
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.checkButtonVisible)
                  Opacity(
                    opacity: model.checkEnabled ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !model.checkEnabled,
                      child: _GamePushButton(
                        label: BceStrings.check,
                        onPressed: model.check,
                      ),
                    ),
                  ),
                if (model.nextButtonVisible)
                  _GamePushButton(label: BceStrings.next, onPressed: model.next),
              ],
            ),
          ),
        ),

        // Feedback overlay (center)
        if (model.feedbackVisible)
          Positioned.fill(
            child: Center(
              child: GameFeedbackNode(model: model),
            ),
          ),
      ],
    );
  }
}

class _GamePushButton extends StatelessWidget {
  const _GamePushButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFF00),
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Level completed ─────────────────────────────────────────────────────────

class _LevelCompletedView extends StatelessWidget {
  const _LevelCompletedView({required this.model});
  final GameModel model;

  @override
  Widget build(BuildContext context) {
    final level = model.level!;
    final perfect = model.isPerfectScore();
    final stars = _LevelButton._filledStars(
      model.score,
      level.getPerfectScore(),
      level.getNumberOfChallenges(),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Perfect-score reward rain (source BCERewardNode behind completed UI)
        if (perfect)
          Positioned.fill(
            child: BceRewardNode(levelNumber: level.levelNumber),
          ),
        Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black54),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  perfect ? 'Perfect Score!' : 'Level Complete',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Score: ${model.score} / ${level.getPerfectScore()}',
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 20),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < level.getNumberOfChallenges(); i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: CustomPaint(
                          size: Size(
                            math.min(60, 300 / level.getNumberOfChallenges()),
                            math.min(60, 300 / level.getNumberOfChallenges()),
                          ),
                          painter: _StarPainter(filled: i < stars),
                        ),
                      ),
                  ],
                ),
                if (model.timerEnabled) ...[
                  const SizedBox(height: 10),
                  Text(
                    model.isNewBestTime
                        ? 'Time: ${GameTimer.formatTime(model.timer.elapsedSeconds)} (Your New Best!)'
                        : 'Time: ${GameTimer.formatTime(model.timer.elapsedSeconds)}',
                    style: const TextStyle(fontFamily: 'Arial', fontSize: 16),
                  ),
                ],
                const SizedBox(height: 20),
                _GamePushButton(
                  label: BceStrings.continueLabel,
                  onPressed: model.startOver,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
