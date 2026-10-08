import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../phet_bevel.dart';
import '../phet_font.dart';
import 'intro_play_painter.dart';
import 'intro_view_properties.dart';

/// `IntroVisibilityPanel`. Five checkboxes, shared by both systems.
class IntroVisibilityPanel extends StatelessWidget {
  const IntroVisibilityPanel({super.key, required this.properties});

  final IntroViewProperties properties;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IntroColors.panelFill,
        border: Border.all(color: IntroColors.panelStroke),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HookesLawConstants.visibilityPanelMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              checked: properties.appliedForceVectorVisible,
              label: '外力',
              icon: const _MiniArrow(color: IntroColors.appliedForce, filled: true),
              onTap: () => properties.setAppliedForceVectorVisible(
                !properties.appliedForceVectorVisible,
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _row(
              checked: properties.springForceVectorVisible,
              label: '弹簧力',
              icon: const _MiniArrow(color: IntroColors.springMiddle, filled: true),
              onTap: () => properties.setSpringForceVectorVisible(
                !properties.springForceVectorVisible,
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _row(
              checked: properties.displacementVectorVisible,
              label: '位移',
              icon: const _MiniArrow(color: IntroColors.displacement, filled: false),
              onTap: () => properties.setDisplacementVectorVisible(
                !properties.displacementVectorVisible,
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _row(
              checked: properties.equilibriumPositionVisible,
              label: '平衡位置',
              icon: const _DashedIcon(),
              onTap: () => properties.setEquilibriumPositionVisible(
                !properties.equilibriumPositionVisible,
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _row(
              checked: properties.valuesVisible,
              label: '数值',
              enabled: properties.valuesEnabled,
              onTap: () => properties.setValuesVisible(!properties.valuesVisible),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required bool checked,
    required String label,
    required VoidCallback onTap,
    Widget? icon,
    bool enabled = true,
  }) {
    final color = enabled ? const Color(0xFF000000) : const Color(0xFF888888);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Box(checked: checked, enabled: enabled),
          const SizedBox(width: HookesLawConstants.checkboxSpacing),
          if (icon != null) ...[
            icon,
            const SizedBox(width: 6),
          ],
          Text(label, style: PhetFont.of(HookesLawConstants.controlFontSize, color: color)),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.checked, required this.enabled});

  final bool checked;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(HookesLawConstants.checkboxBoxWidth, HookesLawConstants.checkboxBoxWidth),
      painter: _CheckPainter(checked: checked, enabled: enabled),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.checked, required this.enabled});

  final bool checked;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    paintBeveledBox(canvas, rect, enabled: enabled, checked: checked);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) {
    return oldDelegate.checked != checked || oldDelegate.enabled != enabled;
  }
}

class _MiniArrow extends StatelessWidget {
  const _MiniArrow({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 10),
      painter: _MiniArrowPainter(color: color, filled: filled),
    );
  }
}

class _MiniArrowPainter extends CustomPainter {
  const _MiniArrowPainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    if (filled) {
      final path = Path()
        ..moveTo(0, size.height * 0.3)
        ..lineTo(size.width - 8, size.height * 0.3)
        ..lineTo(size.width - 8, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width - 8, size.height)
        ..lineTo(size.width - 8, size.height * 0.7)
        ..lineTo(0, size.height * 0.7)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF000000),
      );
    } else {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width - 8, size.height / 2), paint);
      final head = Path()
        ..moveTo(size.width - 8, 1)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width - 8, size.height - 1);
      canvas.drawPath(head, paint);
    }
  }

  @override
  bool shouldRepaint(_MiniArrowPainter oldDelegate) => false;
}

class _DashedIcon extends StatelessWidget {
  const _DashedIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 18),
      painter: _DashPainter(),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IntroColors.equilibrium
      ..strokeWidth = 2;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + 3), paint);
      y += 6;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
