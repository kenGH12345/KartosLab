import 'package:flutter/material.dart';

import '../cck_assets.dart';
import '../cck_colors.dart';
import '../cck_constants.dart';
import '../cck_strings.dart';
import '../controller/cck_ac_controller.dart';
import '../model/cck_vec.dart';
import '../model/elements.dart';
import '../model/enums.dart';
import 'toolbox_catalog.dart';
import 'toolbox_icons.dart';

class CckPanel extends StatelessWidget {
  const CckPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CckColors.panelFill,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: CckColors.panelStroke,
          width: CckConstants.panelLineWidth,
        ),
        borderRadius: BorderRadius.circular(CckConstants.cornerRadius),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}

class ElementToolbox extends StatelessWidget {
  const ElementToolbox({
    super.key,
    required this.controller,
    required this.page,
    required this.onPageChanged,
    required this.onSpawn,
  });

  final CckAcController controller;
  final int page;
  final ValueChanged<int> onPageChanged;
  final void Function(CckToolboxSpec spec) onSpawn;

  @override
  Widget build(BuildContext context) {
    final items = page == 0 ? kCckToolboxPage1 : kCckToolboxPage2;
    return CckPanel(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        children: [
          InkWell(
            onTap: page > 0 ? () => onPageChanged(page - 1) : null,
            child: Icon(
              Icons.keyboard_arrow_up,
              size: 18,
              color: page > 0 ? Colors.black : Colors.black26,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (final spec in items)
                  Expanded(
                    child: _ToolboxRow(
                      spec: spec,
                      enabled: controller.circuit.canSpawn(
                        spec.kind,
                        spec.resistorKind,
                      ),
                      showLabel: controller.circuit.showLabels,
                      onSpawn: () => onSpawn(spec),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: page < 1 ? () => onPageChanged(page + 1) : null,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: page < 1 ? Colors.black : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolboxRow extends StatelessWidget {
  const _ToolboxRow({
    required this.spec,
    required this.enabled,
    required this.showLabel,
    required this.onSpawn,
  });

  final CckToolboxSpec spec;
  final bool enabled;
  final bool showLabel;
  final VoidCallback onSpawn;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: InkWell(
        onTap: enabled ? onSpawn : null,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CckToolboxIcon(spec: spec, height: CckConstants.toolboxIconHeight),
              if (showLabel)
                Text(
                  spec.label,
                  style: const TextStyle(fontSize: 10, height: 1.05),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    final t = controller.circuit.viewType;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        _square(
          selected: t == CckViewType.lifelike,
          onTap: () => controller.setViewType(CckViewType.lifelike),
          semantic: CckStrings.lifelike,
          child: Image.asset(CckAssets.battery, height: 18, filterQuality: FilterQuality.medium),
        ),
        const SizedBox(width: 10),
        _square(
          selected: t == CckViewType.schematic,
          onTap: () => controller.setViewType(CckViewType.schematic),
          semantic: CckStrings.schematic,
          key: const Key('cck-view-schematic'),
          child: const CckSchematicBatteryIcon(height: 18),
        ),
        ],
      ),
    );
  }

  Widget _square({
    required bool selected,
    required VoidCallback onTap,
    required String semantic,
    required Widget child,
    Key? key,
  }) {
    return Semantics(
      key: key,
      button: true,
      label: semantic,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: selected ? 1 : 0.4,
          child: Container(
            width: 44,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? CckColors.viewButtonSelected : CckColors.panelFill,
              border: Border.all(color: CckColors.panelStroke, width: 1.2),
              borderRadius: BorderRadius.circular(CckConstants.cornerRadius),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class ZoomButtons extends StatelessWidget {
  const ZoomButtons({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    return CckPanel(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => controller.setZoomIndex(controller.circuit.zoomIndex - 1),
              child: const Icon(Icons.remove, size: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${controller.circuit.animatedZoom.toStringAsFixed(1)}×',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            InkWell(
              onTap: () => controller.setZoomIndex(controller.circuit.zoomIndex + 1),
              child: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayOptionsPanel extends StatelessWidget {
  const DisplayOptionsPanel({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller.circuit;
    return CckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _check(CckStrings.showCurrent, c.showCurrent, controller.setShowCurrent),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: RadioGroup<CckCurrentType>(
              groupValue: c.currentType,
              onChanged: (v) {
                if (v != null) controller.setCurrentType(v);
              },
              child: Column(
                children: [
                  _radio(
                    CckCurrentType.electrons,
                    CckStrings.electrons,
                    const CckElectronBadge(),
                  ),
                  _radio(
                    CckCurrentType.conventional,
                    CckStrings.conventional,
                    const CckConventionalArrowBadge(),
                  ),
                ],
              ),
            ),
          ),
          _check(CckStrings.labels, c.showLabels, controller.setShowLabels),
          _check(CckStrings.values, c.showValues, controller.setShowValues),
          _check(CckStrings.stopwatch, c.stopwatchVisible, controller.setStopwatchVisible),
        ],
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio(CckCurrentType value, String label, Widget icon) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Radio<CckCurrentType>(
            value: value,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          icon,
        ],
      ),
    );
  }
}

class SensorToolbox extends StatelessWidget {
  const SensorToolbox({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller.circuit;
    return CckPanel(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.95,
        children: [
          _tile(
            CckStrings.voltmeter,
            c.voltmeters.first.active,
            () => controller.toggleVoltmeter(),
            Image.asset(CckAssets.voltmeterBody, height: 40, filterQuality: FilterQuality.medium),
          ),
          _tile(
            CckStrings.ammeter,
            c.elements.any((e) => e is CckSeriesAmmeter),
            () {
              if (c.elements.any((e) => e is CckSeriesAmmeter)) return;
              controller.spawn(
                CckElementKind.seriesAmmeter,
                const CckVec(280, 220),
              );
            },
            Image.asset(CckAssets.ammeterBody, height: 28, filterQuality: FilterQuality.medium),
          ),
          _tile(
            CckStrings.voltageChart,
            c.voltageChartVisible,
            controller.toggleVoltageChart,
            const CckChartIcon(),
          ),
          _tile(
            CckStrings.currentChart,
            c.currentChartVisible,
            controller.toggleCurrentChart,
            const CckChartIcon(),
          ),
        ],
      ),
    );
  }

  Widget _tile(String label, bool on, VoidCallback tap, Widget icon) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Opacity(opacity: on ? 0.45 : 1, child: icon),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, height: 1.05),
          ),
        ],
      ),
    );
  }
}

class AdvancedPanel extends StatelessWidget {
  const AdvancedPanel({
    super.key,
    required this.controller,
    required this.expanded,
    required this.onToggle,
  });

  final CckAcController controller;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = controller.circuit;
    return CckPanel(
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    CckStrings.advanced,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: CckColors.expandButtonGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    expanded ? Icons.remove : Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            const Text(CckStrings.wireResistivity, style: TextStyle(fontSize: 12)),
            Slider(
              min: CckConstants.wireResistivityMin,
              max: CckConstants.wireResistivityMax,
              value: c.wireResistivity.clamp(
                CckConstants.wireResistivityMin,
                CckConstants.wireResistivityMax,
              ),
              onChanged: controller.setWireResistivity,
            ),
            const Text(CckStrings.sourceResistance, style: TextStyle(fontSize: 12)),
            Slider(
              min: CckConstants.batteryMinimumResistance,
              max: CckConstants.batteryResistanceMax,
              value: c.sourceResistance.clamp(
                CckConstants.batteryMinimumResistance,
                CckConstants.batteryResistanceMax,
              ),
              onChanged: controller.setSourceResistance,
            ),
          ],
        ],
      ),
    );
  }
}

class TimeControlBar extends StatelessWidget {
  const TimeControlBar({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    final playing = controller.circuit.playing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.circuit.stopwatchVisible)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${controller.circuit.stopwatchTime.toStringAsFixed(2)} s',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        _round(
          diameter: 52,
          color: CckColors.timeControlBlue,
          onTap: () => controller.setPlaying(!playing),
          icon: playing ? Icons.pause : Icons.play_arrow,
        ),
        const SizedBox(width: 8),
        _round(
          diameter: 36,
          color: const Color(0xFF9E9E9E),
          onTap: playing ? null : controller.stepOnce,
          icon: Icons.skip_next,
          enabled: !playing,
        ),
      ],
    );
  }

  Widget _round({
    required double diameter,
    required Color color,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Icon(icon, color: Colors.white, size: diameter * 0.48),
        ),
      ),
    );
  }
}

class EditBar extends StatelessWidget {
  const EditBar({super.key, required this.controller});
  final CckAcController controller;

  @override
  Widget build(BuildContext context) {
    final el = controller.circuit.selectedElement;
    if (el == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: CckColors.editPanelFill,
      child: Row(
        children: [
          Expanded(
            child: Text(
              CckStrings.tapToEdit,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (el is CckSwitch)
            TextButton(
              onPressed: () => controller.toggleSwitch(el),
              child: Text(
                  el.closed ? CckStrings.openSwitch : CckStrings.closeSwitch),
            ),
          if (el is CckBattery)
            _num(el.voltage, 0, CckConstants.acMaxVoltage, (v) {
              controller.setBatteryVoltage(el, v);
            }, 'V'),
          if (el is CckAcSource) ...[
            _num(el.maximumVoltage, 0, CckConstants.acMaxVoltage, (v) {
              controller.setAcVoltage(el, v);
            }, 'V'),
            _num(el.frequency, CckConstants.acFrequencyMin, CckConstants.acFrequencyMax, (v) {
              controller.setAcFrequency(el, v);
            }, 'Hz'),
          ],
          if (el is CckResistor && el.resistorKind == CckResistorKind.resistor)
            _num(el.resistanceValue, 0, 120, (v) {
              controller.setResistance(el, v);
            }, 'Ω'),
          if (el is CckLightBulb)
            _num(el.resistanceValue, 0, 120, (v) {
              controller.setBulbResistance(el, v);
            }, 'Ω'),
          if (el is CckCapacitor)
            _num(
              el.capacitance,
              CckConstants.capacitanceMin,
              CckConstants.capacitanceMax,
              (v) {
                controller.setCapacitance(el, v);
              },
              'F',
            ),
          if (el is CckInductor)
            _num(
              el.inductance,
              CckConstants.inductanceMin,
              CckConstants.inductanceMax,
              (v) {
                controller.setInductance(el, v);
              },
              'H',
            ),
          if (el is CckFuse)
            _num(
              el.currentRating,
              CckConstants.fuseRatingMin,
              CckConstants.fuseRatingMax,
              (v) {
                controller.setFuseRating(el, v);
              },
              'A',
            ),
          IconButton(
            onPressed: controller.deleteSelected,
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _num(
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String unit,
  ) {
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              min: min,
              max: max,
              value: value.clamp(min, max),
              onChanged: onChanged,
            ),
          ),
          Text('${value.toStringAsFixed(2)} $unit', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
