import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../intro/intro_play_painter.dart';
import '../phet_bevel.dart';
import '../phet_font.dart';
import 'systems_paint.dart';
import 'systems_view_properties.dart';

/// `SystemsVisibilityPanel`. Spring-force Total / Components is view-only.
class SystemsVisibilityPanel extends StatelessWidget {
  const SystemsVisibilityPanel({super.key, required this.properties});

  final SystemsViewProperties properties;

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
            _check(
              '外力',
              properties.appliedForceVectorVisible,
              () => properties.setAppliedForceVectorVisible(!properties.appliedForceVectorVisible),
              icon: const _MiniArrow(color: SystemsColors.appliedForce),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              '弹簧力',
              properties.springForceVectorVisible,
              () => properties.setSpringForceVectorVisible(!properties.springForceVectorVisible),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _radio(
                    key: const Key('systems-total'),
                    label: '合力',
                    selected: properties.springForceRepresentation == SpringForceRepresentation.total,
                    enabled: properties.springForceVectorVisible,
                    onTap: () => properties.springForceRepresentation = SpringForceRepresentation.total,
                    icon: const _MiniArrow(color: SystemsColors.totalSpringForce),
                  ),
                  const SizedBox(height: 10),
                  _radio(
                    key: const Key('systems-components'),
                    label: '分量',
                    selected: properties.springForceRepresentation == SpringForceRepresentation.components,
                    enabled: properties.springForceVectorVisible,
                    onTap: () => properties.springForceRepresentation = SpringForceRepresentation.components,
                    icon: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniArrow(color: SystemsColors.spring1Middle),
                        SizedBox(height: 4),
                        _MiniArrow(color: SystemsColors.spring2Middle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              '位移',
              properties.displacementVectorVisible,
              () => properties.setDisplacementVectorVisible(!properties.displacementVectorVisible),
              icon: const _MiniArrow(color: SystemsColors.displacement, filled: false),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              '平衡位置',
              properties.equilibriumPositionVisible,
              () => properties.setEquilibriumPositionVisible(!properties.equilibriumPositionVisible),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              '数值',
              properties.valuesVisible,
              () => properties.setValuesVisible(!properties.valuesVisible),
              enabled: properties.valuesEnabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(
    String label,
    bool checked,
    VoidCallback onTap, {
    Widget? icon,
    bool enabled = true,
  }) {
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
          Text(
            label,
            style: PhetFont.of(
              HookesLawConstants.controlFontSize,
              color: enabled ? const Color(0xFF000000) : const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radio({
    required Key key,
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
    required Widget icon,
  }) {
    final color = enabled ? const Color(0xFF000000) : const Color(0xFF888888);
    return GestureDetector(
      key: key,
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(16, 16),
            painter: _AquaRadioPainter(selected: selected, enabled: enabled),
          ),
          const SizedBox(width: 8),
          Text(label, style: PhetFont.of(HookesLawConstants.controlFontSize, color: color)),
          const SizedBox(width: 10),
          icon,
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
  const _MiniArrow({required this.color, this.filled = true});

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
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;
    if (filled) {
      final path = Path()
        ..moveTo(0, 3)
        ..lineTo(size.width - 8, 3)
        ..lineTo(size.width - 8, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width - 8, size.height)
        ..lineTo(size.width - 8, 7)
        ..lineTo(0, 7)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF000000),
      );
    } else {
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

class _AquaRadioPainter extends CustomPainter {
  const _AquaRadioPainter({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    paintAquaRadio(canvas, size.width / 2, selected: selected, enabled: enabled);
  }

  @override
  bool shouldRepaint(_AquaRadioPainter oldDelegate) {
    return oldDelegate.selected != selected || oldDelegate.enabled != enabled;
  }
}
