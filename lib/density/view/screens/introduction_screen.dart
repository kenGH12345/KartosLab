import 'package:flutter/material.dart';

import '../../../common/controls/kratos_radio_group.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../../controller/density_controller.dart';
import '../../density_strings.dart';
import '../../model/density_block.dart';
import '../canvas/density_canvas.dart';
import '../controls/intro_block_panel.dart';
import '../widgets/density_number_line.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key, required this.controller});

  final DensityController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final intro = controller.intro;
        return NineGridLayout(
          topCenter: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DensityNumberLine(
              blockA: intro.blockA,
              blockB: intro.blockB.visible ? intro.blockB : null,
            ),
          ),
          center: DensityCanvas(controller: controller),
          footer: _IntroFooter(controller: controller),
        );
      },
    );
  }
}

class _IntroFooter extends StatelessWidget {
  const _IntroFooter({required this.controller});

  final DensityController controller;

  @override
  Widget build(BuildContext context) {
    final intro = controller.intro;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IntroBlockPanel(controller: controller, block: intro.blockA),
                if (intro.blockB.visible) ...[
                  const SizedBox(width: 16),
                  IntroBlockPanel(controller: controller, block: intro.blockB),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: KratosRadioGroup<TwoBlockMode>(
                  items: TwoBlockMode.values,
                  itemLabels: const [
                    DensityStrings.oneBlock,
                    DensityStrings.twoBlocks,
                  ],
                  value: intro.mode,
                  direction: Axis.horizontal,
                  onChanged: controller.setIntroMode,
                ),
              ),
              TextButton(
                onPressed: controller.resetIntro,
                child: const Text(DensityStrings.resetAll),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
