import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/view/widgets/ba_text.dart';

/// Show panel — VerticalCheckboxGroup + Panel.
class BaShowPanel extends StatelessWidget {
  const BaShowPanel({
    super.key,
    required this.massLabels,
    required this.forces,
    required this.level,
    required this.onMassLabels,
    required this.onForces,
    required this.onLevel,
  });

  final bool massLabels;
  final bool forces;
  final bool level;
  final ValueChanged<bool> onMassLabels;
  final ValueChanged<bool> onForces;
  final ValueChanged<bool> onLevel;

  @override
  Widget build(BuildContext context) {
    return _BaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BaText(BaStrings.show, size: 16),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                _BaCheckRow(
                  label: BaStrings.massLabels,
                  value: massLabels,
                  onChanged: onMassLabels,
                ),
                _BaCheckRow(
                  label: BaStrings.forcesFromObjects,
                  value: forces,
                  onChanged: onForces,
                ),
                _BaCheckRow(
                  label: BaStrings.level,
                  value: level,
                  onChanged: onLevel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Position radio panel.
class BaPositionPanel extends StatelessWidget {
  const BaPositionPanel({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PositionIndicatorChoice value;
  final ValueChanged<PositionIndicatorChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BaText(BaStrings.position, size: 16),
          const SizedBox(height: 7),
          _BaRadioRow(
            label: BaStrings.none,
            selected: value == PositionIndicatorChoice.none,
            onTap: () => onChanged(PositionIndicatorChoice.none),
          ),
          _BaRadioRow(
            label: BaStrings.rulers,
            selected: value == PositionIndicatorChoice.rulers,
            onTap: () => onChanged(PositionIndicatorChoice.rulers),
          ),
          _BaRadioRow(
            label: BaStrings.marks,
            selected: value == PositionIndicatorChoice.marks,
            onTap: () => onChanged(PositionIndicatorChoice.marks),
          ),
        ],
      ),
    );
  }
}

class _BaPanel extends StatelessWidget {
  const _BaPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 170, maxWidth: 220),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: BaColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BaCheckRow extends StatelessWidget {
  const _BaCheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// scenery-phet checkbox box size ≈ 15
  static const double boxSize = 15;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: boxSize,
              height: boxSize,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: BaText(
                label,
                size: 14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaRadioRow extends StatelessWidget {
  const _BaRadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BaRadioDot(selected: selected),
            const SizedBox(width: 6),
            BaText(label, size: 14),
          ],
        ),
      ),
    );
  }
}

class _BaRadioDot extends StatelessWidget {
  const _BaRadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
