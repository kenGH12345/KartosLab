import 'package:flutter/material.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/game_enums.dart';
import '../rpal_colors.dart';
import '../rpal_constants.dart';
import 'game_controller.dart';
import 'widgets/game_play_node.dart';
import 'widgets/game_results_node.dart';
import 'widgets/game_settings_node.dart';

/// Game screen — `GameScreenView.ts`.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.controller});

  final GameController? controller;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller =
      widget.controller ?? GameController();
  late final bool _ownsController = widget.controller == null;

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep top flush with TabBar; pad bottom so home-indicator does not clip
    // Challenge brackets / Settings Reset.
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: RpalColors.screenBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = _fitScale(constraints.biggest);
            return Center(
              child: SizedBox(
                width: RpalConstants.layoutWidth * scale,
                height: RpalConstants.layoutHeight * scale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: RpalConstants.layoutWidth,
                    height: RpalConstants.layoutHeight,
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        final phase = _controller.model.gamePhase;
                        return Stack(
                          children: [
                            if (phase == GamePhase.settings)
                              GameSettingsNode(controller: _controller),
                            if (phase == GamePhase.play)
                              GamePlayNode(controller: _controller),
                            if (phase == GamePhase.results)
                              GameResultsNode(controller: _controller),
                            if (phase == GamePhase.settings)
                              Positioned(
                                right: 40,
                                bottom: 40,
                                child: KratosResetAllButton(
                                  radius: 20.5 *
                                      RpalConstants.resetAllButtonScale,
                                  onPressed: _controller.reset,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _fitScale(Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return 1;
    }
    final sx = size.width / RpalConstants.layoutWidth;
    final sy = size.height / RpalConstants.layoutHeight;
    return sx < sy ? sx : sy;
  }
}
