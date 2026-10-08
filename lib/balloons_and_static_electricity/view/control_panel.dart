import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import 'base_view_layout.dart';
import 'package:kratos/balloons_and_static_electricity/base_strings.dart';

/// Bottom controls — PhET `ControlPanel.ts` as Stack children (not full-screen overlay).
class BaseControlPanel extends StatelessWidget {
  const BaseControlPanel({
    super.key,
    required this.model,
    this.onResetBalloons,
    this.onResetAll,
  });

  final BalloonsStaticElectricityModel model;
  final VoidCallback? onResetBalloons;
  final VoidCallback? onResetAll;

  static const labelStyle = TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );

  /// Emits positioned control widgets for the play-area [Stack].
  List<Widget> buildStackChildren() {
    final two = model.twoBalloonsVisible;
    final wallVisible = model.wall.isVisible;
    return [
      Positioned(
        left: BaseViewLayout.controlsLeft,
        bottom: BaseViewLayout.bottomControlSpacing,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChargeModePanel(model: model),
            const SizedBox(width: BaseViewLayout.visibilityControlsSpacing),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BalloonCountSelector(model: model),
                const SizedBox(height: 2),
                _YellowPushButton(
                  label: two ? BaseStrings.resetBalloons : BaseStrings.resetBalloon,
                  onPressed: () {
                    model.resetBalloons();
                    onResetBalloons?.call();
                  },
                  minWidth: 140,
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        right: 4.5,
        bottom: BaseViewLayout.bottomControlSpacing,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            KratosResetAllButton(
              radius: BaseViewLayout.resetAllRadius,
              onPressed: () {
                model.reset();
                onResetAll?.call();
              },
            ),
            const SizedBox(width: 14),
            _YellowPushButton(
              label: wallVisible ? BaseStrings.removeWall : BaseStrings.addWall,
              onPressed: () {
                if (wallVisible) {
                  model.removeWall();
                } else {
                  model.addWall();
                }
              },
              minWidth: 100,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Not used as a single overlay; play area spreads [buildStackChildren].
    return const SizedBox.shrink();
  }
}

class _ChargeModePanel extends StatelessWidget {
  const _ChargeModePanel({required this.model});

  final BalloonsStaticElectricityModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in [
            (ShowCharges.allCharges, BaseStrings.showAllCharges),
            (ShowCharges.noCharges, BaseStrings.showNoCharges),
            (ShowCharges.chargeDifferences, BaseStrings.showChargeDifferences),
          ])
            _AquaRadioRow(
              selected: model.showCharges == entry.$1,
              label: entry.$2,
              onTap: () => model.setShowCharges(entry.$1),
            ),
        ],
      ),
    );
  }
}

class _AquaRadioRow extends StatelessWidget {
  const _AquaRadioRow({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 1.5),
                color: Colors.white,
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0575C9),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(label, style: BaseControlPanel.labelStyle),
          ],
        ),
      ),
    );
  }
}

class _BalloonCountSelector extends StatelessWidget {
  const _BalloonCountSelector({required this.model});

  final BalloonsStaticElectricityModel model;

  @override
  Widget build(BuildContext context) {
    final two = model.twoBalloonsVisible;
    final iconH = 222 * BaseViewLayout.balloonIconScale;
    final iconW = 134 * BaseViewLayout.balloonIconScale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SceneChip(
          selected: !two,
          onTap: () => model.setTwoBalloons(false),
          child: SizedBox(
            width: iconW,
            height: iconH,
            child: Image.asset(
              BaseAssets.yellowBalloon,
              width: iconW,
              height: iconH,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _SceneChip(
          selected: two,
          onTap: () => model.setTwoBalloons(true),
          child: SizedBox(
            width: (160 + 134) * BaseViewLayout.balloonIconScale,
            height: iconH,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 160 * BaseViewLayout.balloonIconScale,
                  child: Image.asset(
                    BaseAssets.greenBalloon,
                    width: iconW,
                    height: iconH,
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  BaseAssets.yellowBalloon,
                  width: iconW,
                  height: iconH,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SceneChip extends StatelessWidget {
  const _SceneChip({
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFF5C400) : const Color(0xFF969696),
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _YellowPushButton extends StatelessWidget {
  const _YellowPushButton({
    required this.label,
    required this.onPressed,
    this.minWidth = 100,
  });

  final String label;
  final VoidCallback onPressed;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseViewLayout.controlButtonBaseColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black87, width: 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: BaseControlPanel.labelStyle,
          ),
        ),
      ),
    );
  }
}
