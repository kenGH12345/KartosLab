import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../intro/intro_play_painter.dart';
import '../phet_bevel.dart';
import '../phet_font.dart';
import 'energy_view_properties.dart';

/// `EnergyVisibilityPanel.ts`. Graph radios, then the Energy triangle
/// checkbox (enabled only on Force Plot), then the vector checkboxes.
class EnergyVisibilityPanel extends StatelessWidget {
  const EnergyVisibilityPanel({super.key, required this.properties});

  final EnergyViewProperties properties;

  @override
  Widget build(BuildContext context) {
    final forcePlot = properties.graph == EnergyGraphKind.forcePlot;
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
            _radio('energy-radio-bar', 'Bar Graph', properties.graph == EnergyGraphKind.barGraph, () {
              properties.graphKind = EnergyGraphKind.barGraph;
            }),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _radio('energy-radio-energy', 'Energy Plot', properties.graph == EnergyGraphKind.energyPlot, () {
              properties.graphKind = EnergyGraphKind.energyPlot;
            }),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _radio('energy-radio-force', 'Force Plot', forcePlot, () {
              properties.graphKind = EnergyGraphKind.forcePlot;
            }),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: _check(
                key: const Key('energy-checkbox'),
                label: 'Energy',
                checked: properties.energyOnForcePlotVisible,
                enabled: forcePlot,
                onTap: () => properties.setEnergyOnForcePlotVisible(!properties.energyOnForcePlotVisible),
              ),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            Container(height: 1, width: 150, color: IntroColors.panelStroke),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              label: 'Applied Force',
              checked: properties.appliedForceVectorVisible,
              onTap: () => properties.setAppliedForceVectorVisible(!properties.appliedForceVectorVisible),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              label: 'Displacement',
              checked: properties.displacementVectorVisible,
              onTap: () => properties.setDisplacementVectorVisible(!properties.displacementVectorVisible),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              label: 'Equilibrium Position',
              checked: properties.equilibriumPositionVisible,
              onTap: () => properties.setEquilibriumPositionVisible(!properties.equilibriumPositionVisible),
            ),
            const SizedBox(height: HookesLawConstants.visibilityPanelSpacing),
            _check(
              label: 'Values',
              checked: properties.valuesVisible,
              onTap: () => properties.setValuesVisible(!properties.valuesVisible),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _radio(String keyName, String label, bool selected, VoidCallback onTap) {
  return GestureDetector(
    key: Key(keyName),
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(16, 16),
          painter: _EnergyRadioPainter(selected: selected),
        ),
        const SizedBox(width: 8),
        Text(label, style: PhetFont.of(HookesLawConstants.controlFontSize)),
      ],
    ),
  );
}

Widget _check({
  Key? key,
  required String label,
  required bool checked,
  required VoidCallback onTap,
  bool enabled = true,
}) {
  return GestureDetector(
    key: key,
    onTap: enabled ? onTap : null,
    behavior: HitTestBehavior.opaque,
    child: Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(HookesLawConstants.checkboxBoxWidth, HookesLawConstants.checkboxBoxWidth),
            painter: _EnergyCheckPainter(checked: checked, enabled: enabled),
          ),
          const SizedBox(width: 8),
          Text(label, style: PhetFont.of(HookesLawConstants.controlFontSize)),
        ],
      ),
    ),
  );
}

class _EnergyRadioPainter extends CustomPainter {
  const _EnergyRadioPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    paintAquaRadio(canvas, size.width / 2, selected: selected, enabled: true);
  }

  @override
  bool shouldRepaint(_EnergyRadioPainter oldDelegate) => oldDelegate.selected != selected;
}

class _EnergyCheckPainter extends CustomPainter {
  const _EnergyCheckPainter({required this.checked, required this.enabled});

  final bool checked;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    paintBeveledBox(canvas, Offset.zero & size, enabled: enabled, checked: checked);
  }

  @override
  bool shouldRepaint(_EnergyCheckPainter oldDelegate) {
    return oldDelegate.checked != checked || oldDelegate.enabled != enabled;
  }
}
