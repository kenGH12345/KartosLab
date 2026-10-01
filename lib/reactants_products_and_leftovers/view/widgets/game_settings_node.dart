import 'package:flutter/material.dart';

import '../../model/game_enums.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';

/// Level selection + visibility — `SettingsNode.ts`.
class GameSettingsNode extends StatelessWidget {
  const GameSettingsNode({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                RpalStrings.chooseYourLevel,
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 45),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < model.numberOfLevels; i++) ...[
                    if (i > 0) const SizedBox(width: 24),
                    _LevelButton(
                      levelIndex: i,
                      bestScore: model.bestScores[i],
                      perfectScore: model.getPerfectScore(i),
                      onPressed: () => controller.play(i),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 45),
              _VisibilityPanel(
                value: model.gameVisibility,
                onChanged: controller.setGameVisibility,
              ),
            ],
          ),
        ),
        Positioned(
          left: 40,
          bottom: 40,
          child: _TimerToggle(
            enabled: model.timerEnabled,
            onChanged: controller.setTimerEnabled,
          ),
        ),
      ],
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.levelIndex,
    required this.bestScore,
    required this.perfectScore,
    required this.onPressed,
  });

  final int levelIndex;
  final int bestScore;
  final int perfectScore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final stars = perfectScore == 0
        ? 0
        : ((bestScore / perfectScore) * RpalConstants.challengesPerLevel)
            .round()
            .clamp(0, RpalConstants.challengesPerLevel);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RpalColors.statusBarFill, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Text(
                RpalStrings.levelN(levelIndex + 1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 8),
              _LevelIcon(levelIndex: levelIndex),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var s = 0; s < RpalConstants.challengesPerLevel; s++)
                    Text(
                      s < stars ? '★' : '☆',
                      style: TextStyle(
                        fontSize: 16,
                        color: s < stars
                            ? const Color(0xFFFFD700)
                            : Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelIcon extends StatelessWidget {
  const _LevelIcon({required this.levelIndex});
  final int levelIndex;

  @override
  Widget build(BuildContext context) {
    // Source RPALLevelSelectionButtonGroup icons: ?→HCl / H2O→? / NH3→??
    switch (levelIndex) {
      case 0:
        return const Text(
          '${RpalStrings.questionMark}  →  HCl',
          style: TextStyle(fontSize: 18, fontFamily: 'Arial'),
        );
      case 1:
        return const Text(
          'H₂O  →  ${RpalStrings.questionMark}',
          style: TextStyle(fontSize: 18, fontFamily: 'Arial'),
        );
      default:
        return const Text(
          'NH₃  →  ${RpalStrings.doubleQuestionMark}',
          style: TextStyle(fontSize: 18, fontFamily: 'Arial'),
        );
    }
  }
}

class _VisibilityPanel extends StatelessWidget {
  const _VisibilityPanel({required this.value, required this.onChanged});

  final GameVisibility value;
  final ValueChanged<GameVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final v in GameVisibility.values)
            InkWell(
              onTap: () => onChanged(v),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomPaint(
                      size: const Size(18, 18),
                      painter: _RadioPainter(selected: value == v),
                    ),
                  ),
                  Text(
                    _label(v),
                    style: const TextStyle(fontSize: 16, fontFamily: 'Arial'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _label(GameVisibility v) {
    switch (v) {
      case GameVisibility.showAll:
        return RpalStrings.showAll;
      case GameVisibility.hideMolecules:
        return RpalStrings.hideMolecules;
      case GameVisibility.hideNumbers:
        return RpalStrings.hideNumbers;
    }
  }
}

class _TimerToggle extends StatelessWidget {
  const _TimerToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Colors.grey)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onChanged(!enabled),
        child: SizedBox(
          width: 50,
          height: 50,
          child: CustomPaint(
            painter: _ClockPainter(enabled: enabled),
          ),
        ),
      ),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = RpalColors.statusBarFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, size.width / 2 - 1, stroke);
    if (selected) {
      canvas.drawCircle(
        c,
        size.width / 4,
        Paint()..color = RpalColors.statusBarFill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.enabled});
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;
    final paint = Paint()
      ..color = enabled ? RpalColors.statusBarFill : Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(c, r, paint);
    canvas.drawLine(c, Offset(c.dx, c.dy - r * 0.55), paint);
    canvas.drawLine(c, Offset(c.dx + r * 0.4, c.dy), paint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.enabled != enabled;
}
