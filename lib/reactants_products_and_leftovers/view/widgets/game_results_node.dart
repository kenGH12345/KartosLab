import 'package:flutter/material.dart';

import '../../model/game_enums.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';

/// Results phase — `ResultsNode.ts` / LevelCompletedNode subset.
class GameResultsNode extends StatelessWidget {
  const GameResultsNode({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    if (model.gamePhase != GamePhase.results) {
      return const SizedBox.shrink();
    }

    final perfect = model.getPerfectScore(model.level);
    final isPerfect = model.isPerfectScore();
    final stars = perfect == 0
        ? 0
        : ((model.score / perfect) * RpalConstants.challengesPerLevel)
            .round()
            .clamp(0, RpalConstants.challengesPerLevel);

    final time = model.timer.elapsed;
    final mm = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = time.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Stack(
      children: [
        if (isPerfect)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RewardPainter(level: model.level)),
            ),
          ),
        Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: RpalColors.statusBarFill, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  RpalStrings.levelN(model.level + 1),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  RpalStrings.levelCompleted,
                  style: TextStyle(fontSize: 22, fontFamily: 'Arial'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var s = 0; s < RpalConstants.challengesPerLevel; s++)
                      Text(
                        s < stars ? '★' : '☆',
                        style: TextStyle(
                          fontSize: 36,
                          color: s < stars
                              ? const Color(0xFFFFD700)
                              : Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${RpalStrings.score}: ${model.score} / $perfect',
                  style: const TextStyle(fontSize: 20, fontFamily: 'Arial'),
                ),
                if (model.timerEnabled) ...[
                  const SizedBox(height: 8),
                  Text(
                    model.isNewBestTime
                        ? 'Time: $mm:$ss (Your New Best!)'
                        : 'Time: $mm:$ss',
                    style: const TextStyle(fontSize: 16, fontFamily: 'Arial'),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.settings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2E96B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    RpalStrings.continueButton,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardPainter extends CustomPainter {
  _RewardPainter({required this.level});
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0x66FF6B6B),
      const Color(0x664ECDC4),
      const Color(0x66FFE66D),
      const Color(0x6695E1D3),
    ];
    for (var i = 0; i < 24; i++) {
      final paint = Paint()..color = colors[(i + level) % colors.length];
      final x = (i * 37 + level * 13) % size.width;
      final y = (i * 53 + level * 29) % size.height;
      canvas.drawCircle(Offset(x, y), 18 + (i % 5) * 4.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RewardPainter oldDelegate) =>
      oldDelegate.level != level;
}
