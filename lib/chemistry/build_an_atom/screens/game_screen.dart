import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../model/game/game_model.dart';
import '../model/game/game_state.dart';
import '../view/baa_page_shell.dart';
import '../view/game/game_audio_adapter.dart';
import '../widgets/game/game_challenge_view.dart';
import '../widgets/game/game_level_completed_view.dart';
import '../widgets/game/game_level_selection_view.dart';
import '../widgets/game/game_status_bar.dart';
import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';

/// Build an Atom — Game Screen (PhET `GameScreen` / `GameScreenView`).
class BuildAnAtomGameScreen extends StatefulWidget {
  const BuildAnAtomGameScreen({
    super.key,
    this.model,
    this.audio,
    this.embedded = false,
  });

  final GameModel? model;
  final GameAudioAdapter? audio;
  final bool embedded;

  static const title = 'Build an Atom — Game';
  /// BAAColors.gameScreenBackgroundColorProperty
  static const backgroundColor = Color(0xFFFFFFDF);

  @override
  State<BuildAnAtomGameScreen> createState() => BuildAnAtomGameScreenState();
}

class BuildAnAtomGameScreenState extends State<BuildAnAtomGameScreen>
    with SingleTickerProviderStateMixin {
  late final GameModel _game;
  late final GameAudioAdapter _audio;
  late final Ticker _ticker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    // Owned when widget.model == null; GameModel is not ChangeNotifier-disposed
    // on leave (may be reinjected). Timer is always stopped in dispose().
    _game = widget.model ?? GameModel(randomSeed: 1);
    _audio = widget.audio ?? GameAudioAdapter();
    _ticker = createTicker(_onTick)..start();
    // Return to an in-progress timed level: resume (leave always stops).
    _resumeTimerIfNeeded();
  }

  void _resumeTimerIfNeeded() {
    if (!_game.timerEnabled) return;
    if (_game.level == null) return;
    final s = _game.gameState;
    if (s == GameState.levelSelection || s == GameState.levelCompleted) return;
    if (!_game.timer.isRunning) {
      _game.timer.start();
    }
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final dt = (elapsed - last).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.1) return;
    _game.step(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    // Stop timing stream so leave/return cannot double-accumulate.
    _game.timer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final play = BaaPageShell(
      child: ColoredBox(
        color: BuildAnAtomGameScreen.backgroundColor,
        child: ListenableBuilder(
          listenable: _game,
          builder: (context, _) {
            final state = _game.gameState;
            final showStatus = state != GameState.levelSelection &&
                state != GameState.levelCompleted;
            return Stack(
              children: [
                if (state == GameState.levelSelection)
                  GameLevelSelectionView(game: _game)
                else if (state == GameState.levelCompleted)
                  GameLevelCompletedView(game: _game, audio: _audio)
                else ...[
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(height: 40),
                  ),
                  Positioned.fill(
                    child: GameChallengeView(game: _game, audio: _audio),
                  ),
                ],
                if (showStatus)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: GameStatusBar(game: _game),
                  ),
              ],
            );
          },
        ),
      ),
    );
    if (widget.embedded) return play;
    return Scaffold(
      backgroundColor: BuildAnAtomGameScreen.backgroundColor,
      appBar: AppBar(
        title: const Text(BaaStrings.game),
        backgroundColor: const Color(0xFF1177AA),
        foregroundColor: Colors.white,
        actions: [
          if (Navigator.of(context).canPop())
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('返回', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: play,
    );
  }
}
