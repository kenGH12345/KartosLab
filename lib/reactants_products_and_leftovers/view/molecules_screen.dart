import 'package:flutter/material.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../rpal_colors.dart';
import '../rpal_constants.dart';
import 'molecules_controller.dart';
import 'widgets/molecules_reaction_bar.dart';
import 'widgets/molecules_scene.dart';

/// Molecules screen — `MoleculesScreenView.ts`.
class MoleculesScreen extends StatefulWidget {
  const MoleculesScreen({super.key, this.controller});

  final MoleculesController? controller;

  @override
  State<MoleculesScreen> createState() => _MoleculesScreenState();
}

class _MoleculesScreenState extends State<MoleculesScreen> {
  late final MoleculesController _controller =
      widget.controller ?? MoleculesController();
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
                      return Stack(
                        children: [
                          Column(
                            children: [
                              MoleculesReactionBar(
                                controller: _controller,
                                layoutWidth: RpalConstants.layoutWidth,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.topCenter,
                                  child: MoleculesScene(
                                    controller: _controller,
                                    reaction: _controller.selected,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: KratosResetAllButton(
                              radius: 20.5 * RpalConstants.resetAllButtonScale,
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
