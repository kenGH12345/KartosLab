import 'package:flutter/material.dart';

import '../model/phase_state.dart';
import '../som_assets.dart';
import '../som_strings.dart';

/// Solid / Liquid / Gas buttons — PhET `StatesPhaseControlNode`.
class StatesPhaseControl extends StatelessWidget {
  const StatesPhaseControl({
    super.key,
    required this.onPhaseSelected,
    this.selectedPhase,
    this.width = 175,
  });

  final ValueChanged<PhaseState> onPhaseSelected;
  final PhaseState? selectedPhase;
  final double width;

  static const Color selectedColor = Color(0xFFA5A7FF);
  static const Color deselectedColor = Color(0xFFF8D980);

  /// PhET VBox `spacing: 10`.
  static const double buttonSpacing = 10;

  /// PhET `ICON_HEIGHT`.
  static const double iconHeight = 25;

  /// PhET panel `xMargin: 5`, `yMargin: 8`.
  static const double xMargin = 5;
  static const double yMargin = 8;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width - xMargin * 2;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: xMargin,
        vertical: yMargin,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC8C8C8),
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PhaseButton(
            label: SomStrings.solid,
            asset: SomAssets.solidIcon,
            selected: selectedPhase == PhaseState.solid,
            width: buttonWidth,
            onTap: () => onPhaseSelected(PhaseState.solid),
          ),
          const SizedBox(height: buttonSpacing),
          _PhaseButton(
            label: SomStrings.liquid,
            asset: SomAssets.liquidIcon,
            selected: selectedPhase == PhaseState.liquid,
            width: buttonWidth,
            onTap: () => onPhaseSelected(PhaseState.liquid),
          ),
          const SizedBox(height: buttonSpacing),
          _PhaseButton(
            label: SomStrings.gas,
            asset: SomAssets.gasIcon,
            selected: selectedPhase == PhaseState.gas,
            width: buttonWidth,
            onTap: () => onPhaseSelected(PhaseState.gas),
          ),
        ],
      ),
    );
  }
}

class _PhaseButton extends StatelessWidget {
  const _PhaseButton({
    required this.label,
    required this.asset,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: selected
            ? StatesPhaseControl.selectedColor
            : StatesPhaseControl.deselectedColor,
        borderRadius: BorderRadius.circular(4),
        elevation: selected ? 0 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.45,
                  child: Center(
                    child: Image.asset(
                      asset,
                      height: StatesPhaseControl.iconHeight,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
