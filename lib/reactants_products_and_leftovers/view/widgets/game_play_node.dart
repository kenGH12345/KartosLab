import 'package:flutter/material.dart';

import '../../model/game_enums.dart';
import '../../rpal_colors.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';
import 'challenge_node.dart';

/// Play phase — `PlayNode.ts` (status bar + challenge).
class GamePlayNode extends StatelessWidget {
  const GamePlayNode({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final challenge = model.challenge;
    if (model.gamePhase != GamePhase.play || challenge == null) {
      return const SizedBox.shrink();
    }

    // Status bar fixed; challenge scales to remaining height so bottoms
    // (Reactants/Products/Leftovers) are not clipped under Home chrome.
    return Column(
      children: [
        _StatusBar(controller: controller),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: ChallengeNode(
                    controller: controller,
                    challenge: challenge,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final time = m.timer.elapsed;
    final mm = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = time.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      height: 42,
      color: RpalColors.statusBarFill,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            RpalStrings.levelN(m.level + 1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(width: 24),
          Text(
            RpalStrings.challengeProgress(
              m.challengeNumber,
              m.numberOfChallenges,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
          if (m.timerEnabled) ...[
            const SizedBox(width: 24),
            Text(
              '$mm:$ss',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Arial',
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${RpalStrings.score}: ${m.score}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: controller.settings,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE5F3FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              RpalStrings.startOver,
              style: TextStyle(fontSize: 14, fontFamily: 'Arial'),
            ),
          ),
        ],
      ),
    );
  }
}
