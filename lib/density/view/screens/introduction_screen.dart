import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../../controller/density_controller.dart';
import '../../density_constants.dart';
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
              _BlocksModeRadio(
                value: intro.mode,
                onChanged: controller.setIntroMode,
              ),
              const Spacer(),
              KratosResetAllButton(
                onPressed: controller.resetIntro,
                radius: 20.5,
                tooltip: DensityStrings.resetAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// PhET `BlocksModeRadioButtonGroup` — original single/double cuboid icons.
class _BlocksModeRadio extends StatelessWidget {
  const _BlocksModeRadio({
    required this.value,
    required this.onChanged,
  });

  final TwoBlockMode value;
  final ValueChanged<TwoBlockMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEEEEE),
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeButton(
              selected: value == TwoBlockMode.oneBlock,
              tooltip: DensityStrings.oneBlock,
              onTap: () => onChanged(TwoBlockMode.oneBlock),
              asset: DensityConstants.singleCuboidAsset,
            ),
            const SizedBox(width: 4),
            _ModeButton(
              selected: value == TwoBlockMode.twoBlocks,
              tooltip: DensityStrings.twoBlocks,
              onTap: () => onChanged(TwoBlockMode.twoBlocks),
              asset: DensityConstants.doubleCuboidAsset,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.tooltip,
    required this.onTap,
    required this.asset,
  });

  final bool selected;
  final String tooltip;
  final VoidCallback onTap;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFB3E5FC) : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? const Color(0xFF0288D1) : const Color(0xFF9E9E9E),
              width: selected ? 2 : 1,
            ),
          ),
          child: Image.asset(
            asset,
            width: tooltip == DensityStrings.twoBlocks ? 40 : 36,
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
