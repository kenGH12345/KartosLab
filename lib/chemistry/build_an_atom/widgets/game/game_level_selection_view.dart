import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../../constants/baa_constants.dart';
import '../../model/game/game_model.dart';
import '../../model/game/score_model.dart';
import '../../view/baa_phet_font.dart';
import 'game_level_icon.dart';
import 'game_stars_display.dart';

/// PhET `LevelSelectionNode`.
class GameLevelSelectionView extends StatelessWidget {
  const GameLevelSelectionView({super.key, required this.game});

  final GameModel game;

  static const _titles = [
    'Periodic Table',
    'Mass and Charge',
    'Symbols',
    'Advanced',
  ];

  /// BAAColors.levelSelectorColorProperty `#D4AAD4`
  static const levelSelectorColor = Color(0xFFD4AAD4);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        return Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose Your Game!',
                    style: BaaPhetFont.of(30, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final lvl = game.levels[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: _LevelButton(
                          levelNumber: i + 1,
                          title: _titles[i],
                          progress: StarProgress(score: lvl.bestScore),
                          bestTime: game.timerEnabled && lvl.bestTimeSeconds > 0
                              ? lvl.bestTimeSeconds
                              : null,
                          onTap: () => game.startLevel(i + 1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Positioned(
              left: BAAConstants.controlsInset.toDouble(),
              bottom: BAAConstants.controlsInset.toDouble(),
              child: _TimerToggle(
                enabled: game.timerEnabled,
                onChanged: game.setTimerEnabled,
              ),
            ),
            Positioned(
              right: BAAConstants.controlsInset.toDouble(),
              bottom: BAAConstants.controlsInset.toDouble(),
              child: KratosResetAllButton(
                onPressed: game.reset,
                radius: BAAConstants.resetButtonRadius,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.levelNumber,
    required this.title,
    required this.progress,
    required this.onTap,
    this.bestTime,
  });

  final int levelNumber;
  final String title;
  final StarProgress progress;
  final VoidCallback onTap;
  final int? bestTime;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GameLevelSelectionView.levelSelectorColor,
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 150,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameLevelIcon(levelNumber: levelNumber, size: 56),
              const SizedBox(height: 4),
              Text(title, style: BaaPhetFont.of(12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              GameStarsDisplay(progress: progress, starSize: 14),
              if (bestTime != null)
                Text(
                  _formatTime(bestTime!),
                  style: BaaPhetFont.of(11, color: Colors.black54),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _TimerToggle extends StatelessWidget {
  const _TimerToggle({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // vegas GameTimerToggleButton — rectangular chrome, not Material Icons.timer alone
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => onChanged(!enabled),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(18, 18),
                painter: _TimerGlyphPainter(
                  color: enabled ? const Color(0xFF1177AA) : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                enabled ? 'Timer: ON' : 'Timer: OFF',
                style: BaaPhetFont.of(
                  14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? const Color(0xFF1177AA) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerGlyphPainter extends CustomPainter {
  _TimerGlyphPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 1);
    final r = size.width * 0.38;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(c, r, p);
    canvas.drawLine(c, Offset(c.dx, c.dy - r * 0.55), p);
    canvas.drawLine(c, Offset(c.dx + r * 0.4, c.dy), p);
    canvas.drawLine(
      Offset(c.dx - 3, c.dy - r - 1),
      Offset(c.dx + 3, c.dy - r - 1),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
