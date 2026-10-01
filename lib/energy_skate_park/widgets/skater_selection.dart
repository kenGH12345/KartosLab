import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';

/// SkaterRadioButtonGroup.ts — 8 headshots, 4 per row, selected stroke border.
class SkaterSelectionPanel extends StatelessWidget {
  const SkaterSelectionPanel({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _headshotScale = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          EspStrings.skaterSelection,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            for (var i = 0; i < SkaterImageSet.count; i++)
              _SkaterRadioButton(
                index: i,
                selected: selectedIndex == i,
                headshotScale: _headshotScale,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _SkaterRadioButton extends StatelessWidget {
  const _SkaterRadioButton({
    required this.index,
    required this.selected,
    required this.headshotScale,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final double headshotScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const corner = EspConstants.radioButtonCornerRadius;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(corner),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(corner),
            border: Border.all(
              color: selected
                  ? EspColors.radioSelected
                  : const Color(0xFFCCCCCC),
              width: selected ? 2.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            SkaterImageSet.at(index).headshotAsset,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
