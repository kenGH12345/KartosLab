import 'package:flutter/material.dart';

import '../../faradays_law_assets.dart';

/// `RectangularRadioButtonGroup` for 1-coil vs 2-coil (`topCoilVisible`).
class CoilRadioGroup extends StatelessWidget {
  const CoilRadioGroup({
    super.key,
    required this.topCoilVisible,
    required this.onChanged,
  });

  final bool topCoilVisible;
  final ValueChanged<bool> onChanged;

  static const Color baseColor = Color(0xFFCDD5F6);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Circuit Mode',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CoilRadioButton(
            key: const Key('faradays_law_coil_single'),
            selected: !topCoilVisible,
            onTap: () => onChanged(false),
            child: const _SingleCoilIcon(),
          ),
          const SizedBox(width: 8),
          _CoilRadioButton(
            key: const Key('faradays_law_coil_double'),
            selected: topCoilVisible,
            onTap: () => onChanged(true),
            child: const _DoubleCoilIcon(),
          ),
        ],
      ),
    );
  }
}

class _CoilRadioButton extends StatelessWidget {
  const _CoilRadioButton({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: CoilRadioGroup.baseColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.black,
            width: selected ? 3 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Scale 0.21 of CoilNode (already 1/3 mipmap) ≈ 0.07 of intrinsic.
class _SingleCoilIcon extends StatelessWidget {
  const _SingleCoilIcon();

  @override
  Widget build(BuildContext context) {
    // Keep invisible two-coil slot for height parity (source excludeInvisible=false)
    return SizedBox(
      width: 36,
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(
            opacity: 0,
            child: Image.asset(
              FaradaysLawAssets.twoLoopFront,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Image.asset(
            FaradaysLawAssets.fourLoopFront,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}

class _DoubleCoilIcon extends StatelessWidget {
  const _DoubleCoilIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 72,
      child: Column(
        children: [
          Image.asset(
            FaradaysLawAssets.twoLoopFront,
            height: 28,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 4),
          Image.asset(
            FaradaysLawAssets.fourLoopFront,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
