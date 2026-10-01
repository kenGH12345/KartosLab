import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/game/game_model.dart';
import '../../model/game/score_model.dart';
import '../../view/baa_phet_font.dart';
import '../../view/game/game_audio_adapter.dart';
import '../phet_face_node.dart';
import 'game_stars_display.dart';

/// vegas `LevelCompletedNode` + optional `BAARewardNode`.
class GameLevelCompletedView extends StatefulWidget {
  const GameLevelCompletedView({
    super.key,
    required this.game,
    required this.audio,
  });

  final GameModel game;
  final GameAudioAdapter audio;

  @override
  State<GameLevelCompletedView> createState() => _GameLevelCompletedViewState();
}

class _GameLevelCompletedViewState extends State<GameLevelCompletedView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;
  bool _audioPlayed = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() => _t = elapsed.inMilliseconds / 1000.0);
    })
      ..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_audioPlayed) return;
      _audioPlayed = true;
      if (widget.game.shouldShowReward) {
        widget.audio.gameOverPerfect();
      } else if (widget.game.score > 0) {
        widget.audio.gameOverImperfect();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final progress = StarProgress(score: g.score);
    final showReward = g.shouldShowReward;

    return Stack(
      children: [
        if (showReward) _RewardRain(t: _t),
        Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level ${g.levelNumber} Complete!',
                      style: BaaPhetFont.of(28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GameStarsDisplay(progress: progress, starSize: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Score: ${g.score} / 10',
                      style: BaaPhetFont.of(22),
                    ),
                    if (g.timerEnabled) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${_fmt(g.timer.elapsedSeconds)}',
                        style: BaaPhetFont.of(16),
                      ),
                      if (g.level?.isNewBestTime == true)
                        Text(
                          'New Best Time!',
                          style: BaaPhetFont.of(
                            14,
                            color: const Color(0xFF2E8B57),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    Material(
                      color: const Color(0xFF00FF99),
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: g.startOver,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          child: Text(
                            'Start Over',
                            style: BaaPhetFont.of(18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// Falling reward faces / orbs (PhET BAARewardNode simplified).
class _RewardRain extends StatelessWidget {
  const _RewardRain({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(42);
    final children = <Widget>[];
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble();
      final speed = 40 + rng.nextDouble() * 80;
      final phase = rng.nextDouble() * 10;
      final y = ((t * speed + phase * 30) % 520) - 40;
      final size = 18 + rng.nextDouble() * 22;
      children.add(Positioned(
        left: x * 740,
        top: y,
        child: i % 5 == 0
            ? PhetFaceNode(headDiameter: size, smiling: true)
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    const Color(0xFFD14600),
                    const Color(0xFF1177AA),
                    rng.nextDouble(),
                  )!
                      .withValues(alpha: 0.85),
                ),
              ),
      ));
    }
    return IgnorePointer(child: Stack(children: children));
  }
}
