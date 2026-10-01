import 'package:flutter/material.dart';

import '../../rendering/texture/buoyancy_texture_asset.dart';
import '../two_block_mode.dart';

/// Source: `BlocksModeRadioButtonGroup` — aligned with ResetAll.
/// Uses original PhET single/double cuboid icon assets.
class BuoyancyBlocksModeRadio extends StatelessWidget {
  const BuoyancyBlocksModeRadio({
    super.key,
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
              onTap: () => onChanged(TwoBlockMode.oneBlock),
              child: Image.asset(
                BuoyancyTextureAsset.singleCuboid,
                width: 36,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 4),
            _ModeButton(
              selected: value == TwoBlockMode.twoBlocks,
              onTap: () => onChanged(TwoBlockMode.twoBlocks),
              child: Image.asset(
                BuoyancyTextureAsset.doubleCuboid,
                width: 40,
                height: 28,
                fit: BoxFit.contain,
              ),
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
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
        child: child,
      ),
    );
  }
}
