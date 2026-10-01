import 'package:flutter/material.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../rpal_colors.dart';
import '../rpal_constants.dart';
import 'sandwiches_controller.dart';
import 'widgets/reaction_bar.dart';
import 'widgets/sandwiches_scene.dart';

/// Sandwiches screen — `SandwichesScreenView.ts`.
class SandwichesScreen extends StatefulWidget {
  const SandwichesScreen({super.key, this.controller});

  final SandwichesController? controller;

  @override
  State<SandwichesScreen> createState() => _SandwichesScreenState();
}

class _SandwichesScreenState extends State<SandwichesScreen> {
  late final SandwichesController _controller =
      widget.controller ?? SandwichesController();
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
                              ReactionBar(
                                controller: _controller,
                                layoutWidth: RpalConstants.layoutWidth,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.topCenter,
                                  child: SandwichesScene(
                                    controller: _controller,
                                    recipe: _controller.selected,
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
