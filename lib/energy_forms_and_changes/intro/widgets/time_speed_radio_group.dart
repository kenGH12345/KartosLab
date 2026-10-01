import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';

/// PhET `TimeSpeedRadioButtonGroup` (VerticalAquaRadioButtonGroup).
///
/// Evidence: `scenery-phet/js/TimeSpeedRadioButtonGroup.ts`
/// - vertical stack, spacing 9
/// - label font 14
/// - radio radius ≈ label height / 2
/// - order from [timeSpeeds]: NORMAL then FAST (EFACIntroScreenView)
///
/// Does **not** change FF×4 model behavior — only selection UI.
class TimeSpeedRadioGroup extends StatelessWidget {
  const TimeSpeedRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final EfacTimeSpeed value;
  final ValueChanged<EfacTimeSpeed> onChanged;
  final bool enabled;

  /// VerticalAquaRadioButtonGroup default spacing
  static const double spacing = 9;

  /// PhetFont(14) → radius ≈ half text height (~7)
  static const double radioRadius = 7;

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    height: 1.0,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    // EFACIntroScreenView: timeSpeeds: [ NORMAL, FAST ]
    const items = <(EfacTimeSpeed, String)>[
      (EfacTimeSpeed.normal, EfacStrings.normal),
      (EfacTimeSpeed.fastForward, EfacStrings.fastForward),
    ];
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: spacing),
              _AquaRadioRow(
                selected: value == items[i].$1,
                label: items[i].$2,
                onTap: () => onChanged(items[i].$1),
              ),
            ],
          ],
        ),
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
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(
              TimeSpeedRadioGroup.radioRadius * 2,
              TimeSpeedRadioGroup.radioRadius * 2,
            ),
            painter: _AquaRadioPainter(selected: selected),
          ),
          const SizedBox(width: 8),
          Text(label, style: TimeSpeedRadioGroup.labelStyle),
        ],
      ),
    );
  }
}

/// sun `AquaRadioButton` look: outer stroke + inner fill when selected.
class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (selected) {
      canvas.drawCircle(
        c,
        r * 0.55,
        Paint()..color = const Color(0xFF0099FF), // AquaRadioButton selected
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
