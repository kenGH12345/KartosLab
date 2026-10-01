import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_assets.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_shared_constants.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/model/game/balance_game_challenge.dart';
import 'package:kratos/balancing_act/view/ba_game_controller.dart';
import 'package:kratos/balancing_act/view/ba_viewport.dart';
import 'package:kratos/balancing_act/view/painters/ba_position_painters.dart';
import 'package:kratos/balancing_act/view/painters/ba_scene_painters.dart';
import 'package:kratos/balancing_act/view/widgets/ba_control_panels.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_node.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_value_entry.dart';
import 'package:kratos/balancing_act/view/widgets/ba_star_node.dart';
import 'package:kratos/balancing_act/view/widgets/ba_styled_svg.dart';
import 'package:kratos/balancing_act/view/widgets/ba_text.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/hookes_law/view/phet_font.dart';

/// Balancing Act — Game Screen only (no Home).
class BaGameScreen extends StatefulWidget {
  const BaGameScreen({super.key, this.controller});

  final BaGameController? controller;

  @override
  State<BaGameScreen> createState() => _BaGameScreenState();
}

class _BaGameScreenState extends State<BaGameScreen>
    with TickerProviderStateMixin {
  late final BaGameController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? BaGameController();
    _controller.attach(this);
    _controller.addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    if (_controller.clock.isRunning) {
      _controller.clock.pause();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaViewport(
      layoutKey: const Key('ba_game_viewport'),
      child: _BaGameStage(controller: _controller),
    );
  }
}

class _BaGameStage extends StatelessWidget {
  const _BaGameStage({required this.controller});

  final BaGameController controller;
  static final GlobalKey _stageKey = GlobalKey(debugLabel: 'ba_game_stage');

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final state = model.gameState;

    return SizedBox(
      key: _stageKey,
      width: BaSharedConstants.layoutWidth,
      height: BaSharedConstants.layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (state == BaGameState.choosingLevel)
            _LevelSelectOverlay(controller: controller)
          else ...[
            _ChallengeScene(
              controller: controller,
              stageKey: _stageKey,
            ),
            if (state != BaGameState.showingLevelResults)
              _StatusBar(controller: controller),
            if (state == BaGameState.showingLevelResults)
              _LevelCompletedOverlay(controller: controller)
            else
              _ChallengeChrome(controller: controller),
          ],
        ],
      ),
    );
  }
}

class _ChallengeScene extends StatelessWidget {
  const _ChallengeScene({
    required this.controller,
    required this.stageKey,
  });

  final BaGameController controller;
  final GlobalKey stageKey;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final mvt = controller.mvt;
    final plank = model.plank;
    final interactive =
        model.gameState == BaGameState.presentingInteractiveChallenge;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: BaBalanceScenePainter(
              mvt: mvt,
              plank: plank,
              columnState: model.columnState,
            ),
          ),
        ),
        if (model.positionMarkerState == PositionIndicatorChoice.marks)
          Positioned.fill(
            child: CustomPaint(
              painter: BaPositionMarksPainter(mvt: mvt, plank: plank),
            ),
          ),
        if (model.positionMarkerState == PositionIndicatorChoice.rulers)
          Positioned.fill(
            child: CustomPaint(
              painter: BaRotatingRulerPainter(mvt: mvt, plank: plank),
            ),
          ),
        Positioned.fill(
          child: CustomPaint(
            painter: BaLevelIndicatorPainter(
              mvt: mvt,
              plank: plank,
              visible: true,
            ),
          ),
        ),
        ...[...model.fixedMasses, ...model.movableMasses].map(
          (mass) => BaMassNode(
            key: ValueKey(identityHashCode(mass)),
            mass: mass,
            mvt: mvt,
            showLabel: !mass.isMystery,
            stageKey: stageKey,
            onDragStart: interactive
                ? (p) => controller.beginDrag(mass, p)
                : (_) {},
            onDragUpdate: interactive ? controller.updateDrag : (_) {},
            onDragEnd: interactive ? controller.endDrag : () {},
          ),
        ),
        Positioned(
          right: 10,
          top: 55,
          width: 180,
          child: BaPositionPanel(
            value: model.positionMarkerState,
            onChanged: controller.setPositionChoice,
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final BaGameController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 42,
      child: Container(
        key: const Key('ba_game_status_bar'),
        color: const Color.fromRGBO(36, 88, 151, 1),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              BaStrings.challengeBanner(
                m.level + 1,
                m.challengeIndex + 1,
                BaGameConstants.challengesPerProblemSet,
              ),
              style: PhetFont.of(16, color: Colors.white),
            ),
            const Spacer(),
            if (m.timerEnabled)
              Text(
                _formatTime(m.elapsedTime),
                style: PhetFont.of(16, color: Colors.white),
              ),
            const SizedBox(width: 16),
            Text(
              '${BaStrings.score}: ${m.score}',
              style: PhetFont.of(16, color: Colors.white),
            ),
            const SizedBox(width: 16),
            TextButton(
              key: const Key('ba_game_start_over'),
              onPressed: controller.newGame,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(BaStrings.startOver, style: PhetFont.of(14)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    final s = seconds.floor();
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

class _ChallengeChrome extends StatelessWidget {
  const _ChallengeChrome({required this.controller});

  final BaGameController controller;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final c = model.getCurrentChallenge();
    final mvt = controller.mvt;
    final state = model.gameState;

    return Stack(
      children: [
        // Title — scoreboard.bottom + 20 (source BalanceGameView ManualConstraint)
        if (c != null)
          Positioned(
            left: 20,
            right: 20,
            top: 50,
            child: Text(
              _titleFor(c),
              textAlign: TextAlign.center,
              style: PhetFont.of(36, fontWeight: FontWeight.bold).copyWith(
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
                ],
              ),
            ),
          ),

        // Mass entry — directly under title (source: massValueProxy.top = title.maxY + 4)
        if (c?.kind == BaChallengeKind.massDeduction &&
            (state == BaGameState.presentingInteractiveChallenge ||
                state == BaGameState.displayingCorrectAnswer ||
                state == BaGameState.showingIncorrectAnswerFeedbackTryAgain ||
                state == BaGameState.showingIncorrectAnswerFeedbackMoveOn ||
                state == BaGameState.showingCorrectAnswerFeedback))
          Positioned(
            left: 0,
            right: 0,
            top: 100,
            child: Center(
              child: BaMassValueEntry(
                value: controller.massEntryValue,
                enabled: state == BaGameState.presentingInteractiveChallenge,
                onChanged: controller.setMassEntry,
              ),
            ),
          ),

        // Tilt prediction — bottom at model Y = plankHeight + 0.8 (source)
        if (c?.kind == BaChallengeKind.tiltPrediction &&
            (state == BaGameState.presentingInteractiveChallenge ||
                state == BaGameState.displayingCorrectAnswer ||
                state == BaGameState.showingIncorrectAnswerFeedbackTryAgain ||
                state == BaGameState.showingIncorrectAnswerFeedbackMoveOn ||
                state == BaGameState.showingCorrectAnswerFeedback))
          Positioned(
            left: 0,
            right: 0,
            top: mvt.modelToViewY(BaGeometry.plankHeight + 0.8) - 70,
            child: Center(
              child: _TiltPredictionSelector(
                value: controller.tiltPrediction,
                enabled: state == BaGameState.presentingInteractiveChallenge,
                highlightCorrect: state == BaGameState.displayingCorrectAnswer,
                onChanged: controller.setTiltPrediction,
              ),
            ),
          ),

        // Face feedback — centerY at model Y = 2.2
        if (state == BaGameState.showingCorrectAnswerFeedback ||
            state == BaGameState.showingIncorrectAnswerFeedbackTryAgain ||
            state == BaGameState.showingIncorrectAnswerFeedbackMoveOn)
          Positioned(
            left: mvt.modelToViewX(0) - 40,
            top: mvt.modelToViewY(2.2) - 50,
            child: _FaceFeedback(
              correct: state == BaGameState.showingCorrectAnswerFeedback,
              points: state == BaGameState.showingCorrectAnswerFeedback
                  ? model.getChallengeCurrentPointValue()
                  : model.score,
            ),
          ),

        // Action buttons — model (0, -0.3)
        Positioned(
          left: mvt.modelToViewX(0) - 70,
          top: mvt.modelToViewY(-0.3) - 20,
          child: _ActionButtons(controller: controller),
        ),
      ],
    );
  }

  String _titleFor(BalanceGameChallenge c) {
    switch (c.kind) {
      case BaChallengeKind.balanceMasses:
        return BaStrings.balanceMe;
      case BaChallengeKind.massDeduction:
        return BaStrings.whatIsTheMass;
      case BaChallengeKind.tiltPrediction:
        return BaStrings.whatWillHappen;
    }
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller});

  final BaGameController controller;

  static const Color _fill = Color.fromRGBO(0, 255, 153, 1);

  @override
  Widget build(BuildContext context) {
    final state = controller.model.gameState;
    Widget? button;
    switch (state) {
      case BaGameState.presentingInteractiveChallenge:
        button = _gameButton(
          key: const Key('ba_game_check'),
          label: BaStrings.check,
          enabled: controller.canCheckAnswer,
          onPressed: controller.checkAnswer,
        );
      case BaGameState.showingCorrectAnswerFeedback:
      case BaGameState.displayingCorrectAnswer:
        button = _gameButton(
          key: const Key('ba_game_next'),
          label: BaStrings.next,
          enabled: true,
          onPressed: controller.nextChallenge,
        );
      case BaGameState.showingIncorrectAnswerFeedbackTryAgain:
        button = _gameButton(
          key: const Key('ba_game_try_again'),
          label: BaStrings.tryAgain,
          enabled: true,
          onPressed: controller.tryAgain,
        );
      case BaGameState.showingIncorrectAnswerFeedbackMoveOn:
        button = _gameButton(
          key: const Key('ba_game_show_answer'),
          label: BaStrings.showAnswer,
          enabled: true,
          onPressed: controller.displayCorrectAnswer,
        );
      default:
        button = null;
    }
    return button ?? const SizedBox.shrink();
  }

  Widget _gameButton({
    required Key key,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      key: key,
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _fill,
        foregroundColor: Colors.black,
        disabledBackgroundColor: _fill.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        textStyle: PhetFont.of(24),
      ),
      child: Text(label),
    );
  }
}

class _TiltPredictionSelector extends StatelessWidget {
  const _TiltPredictionSelector({
    required this.value,
    required this.enabled,
    required this.highlightCorrect,
    required this.onChanged,
  });

  final TiltPredictionState value;
  final bool enabled;
  final bool highlightCorrect;
  final ValueChanged<TiltPredictionState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ba_game_tilt_selector'),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: BaColors.panelFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tiltOption(
            TiltPredictionState.tiltDownOnLeftSide,
            BaAssets.plankTippedLeft,
          ),
          _tiltOption(
            TiltPredictionState.stayBalanced,
            BaAssets.plankBalanced,
          ),
          _tiltOption(
            TiltPredictionState.tiltDownOnRightSide,
            BaAssets.plankTippedRight,
          ),
        ],
      ),
    );
  }

  Widget _tiltOption(TiltPredictionState state, String asset) {
    final selected = value == state;
    final highlight = highlightCorrect && selected;
    return GestureDetector(
      onTap: enabled ? () => onChanged(state) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: highlight
                ? Colors.green
                : selected
                    ? Colors.blue
                    : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: BaSvgPicture.asset(asset, width: 72, height: 40),
      ),
    );
  }
}

class _FaceFeedback extends StatelessWidget {
  const _FaceFeedback({required this.correct, required this.points});

  final bool correct;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ba_game_face_feedback'),
      width: 80,
      height: 100,
      alignment: Alignment.center,
      child: Column(
        children: [
          CustomPaint(
            size: const Size(70, 70),
            painter: _FacePainter(smiling: correct),
          ),
          Text(
            correct ? '+$points' : '$points',
            style: PhetFont.of(18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.smiling});
  final bool smiling;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFE066));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(c.dx - 15, c.dy - 8), 4, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(c.dx + 15, c.dy - 8), 4, Paint()..color = Colors.black);
    final mouth = Path();
    if (smiling) {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + 5), width: 36, height: 28),
        0.2,
        2.7,
      );
    } else {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + 22), width: 36, height: 28),
        3.5,
        2.5,
      );
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.smiling != smiling;
}

class _LevelSelectOverlay extends StatelessWidget {
  const _LevelSelectOverlay({required this.controller});

  final BaGameController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: BaBalanceScenePainter(
              mvt: controller.mvt,
              plank: controller.model.plank,
              columnState: ColumnState.doubleColumns,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.white.withValues(alpha: 0.85)),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(BaStrings.selectLevel, style: PhetFont.of(30), textHeightBehavior: BaText.baseline),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _LevelButton(
                      level: i,
                      score: controller.model.bestScores[i],
                      icon: BaAssets.gameLevelIcons[i],
                      onPressed: () => controller.startLevel(i),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Timer', style: PhetFont.of(14)),
                  Switch(
                    value: controller.model.timerEnabled,
                    onChanged: controller.setTimerEnabled,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: KratosResetAllButton(
            key: const Key('ba_game_reset_all'),
            radius: 20.5 * BaSharedConstants.resetAllButtonScale,
            onPressed: controller.resetAll,
          ),
        ),
      ],
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.level,
    required this.score,
    required this.icon,
    required this.onPressed,
  });

  final int level;
  final int score;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(242, 255, 204, 1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('ba_game_level_$level'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              BaSvgPicture.asset(icon, height: 70, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text('${BaStrings.level} ${level + 1}', style: PhetFont.of(14), textHeightBehavior: BaText.baseline),
              BaScoreStars(score: score, perfect: 12, count: 6, outerRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCompletedOverlay extends StatelessWidget {
  const _LevelCompletedOverlay({required this.controller});

  final BaGameController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Container(
      key: const Key('ba_game_level_completed'),
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level ${m.level + 1} Complete',
              style: PhetFont.of(28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${BaStrings.score}: ${m.score} / ${BaGameConstants.maxScorePerGame}',
              style: PhetFont.of(20),
            ),
            const SizedBox(height: 8),
            BaScoreStars(
              score: m.score,
              perfect: BaGameConstants.maxScorePerGame,
              count: 6,
              outerRadius: 10,
            ),
            if (m.timerEnabled) ...[
              const SizedBox(height: 8),
              Text('Time: ${m.elapsedTime.toStringAsFixed(0)} s',
                  style: PhetFont.of(16)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('ba_game_continue'),
              onPressed: controller.continueFromResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 255, 153, 1),
                foregroundColor: Colors.black,
              ),
              child: Text(BaStrings.continueLabel, style: PhetFont.of(20)),
            ),
          ],
        ),
      ),
    );
  }
}
