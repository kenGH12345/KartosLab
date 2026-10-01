import 'package:flutter/material.dart';

import '../../model/game/game_model.dart';
import '../../view/baa_phet_font.dart';

/// vegas `FiniteStatusBar` subset for BAA Game.
class GameStatusBar extends StatelessWidget {
  const GameStatusBar({super.key, required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final elapsed = game.timer.elapsedSeconds;
        return Container(
          height: 40,
          width: double.infinity,
          color: const Color(0xFF3175CA),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level ${game.levelNumber}',
                  style: BaaPhetFont.of(
                    16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Challenge ${game.challengeNumber} of 5',
                  style: BaaPhetFont.of(14, color: Colors.white),
                ),
                const SizedBox(width: 16),
                if (game.timerEnabled) ...[
                  Text(
                    _formatTime(elapsed),
                    style: BaaPhetFont.of(
                      16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  'Score: ${game.score}',
                  style: BaaPhetFont.of(
                    16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: const Color(0xFFE5F3FF),
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: game.startOver,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        'Start Over',
                        style: BaaPhetFont.of(14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
