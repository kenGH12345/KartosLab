/// ValuesPanel — Mass (+ sliders) and optional More Data columns.
///
/// [MSS-SOURCE] `ValuesPanel.ts` / `ValuesColumnNode.ts`
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/controls/kratos_slider.dart';
import '../controller/my_solar_system_controller.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';
import '../render/mss_format.dart';

class MssValuesPanel extends StatelessWidget {
  const MssValuesPanel({super.key, required this.controller});

  final MySolarSystemController controller;

  @override
  Widget build(BuildContext context) {
    final showMore = controller.isLab && controller.moreDataVisible;
    final showSliders = !(controller.isLab && controller.moreDataVisible);
    final active = [for (final b in controller.bodies) if (b.isActive) b];

    return Material(
      key: const ValueKey('mss-values-panel'),
      color: MySolarSystemColors.panel,
      borderRadius:
          BorderRadius.circular(MySolarSystemConstants.panelCornerRadius),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MySolarSystemConstants.panelMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.isLab)
              Row(
                children: [
                  Checkbox(
                    key: const ValueKey('mss-more-data'),
                    value: controller.moreDataVisible,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (v) =>
                        controller.setMoreDataVisible(v ?? false),
                  ),
                  const Flexible(
                    child: Text(
                      MySolarSystemStrings.moreData,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            Text(
              controller.isLab
                  ? '${MySolarSystemStrings.mass} (${MySolarSystemStrings.unitKg})'
                  : MySolarSystemStrings.mass,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 4),
            for (final b in active) ...[
              Row(
                children: [
                  _bodyDot(b.index, b.color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${MssFormat.mass(b.mass)} ${MySolarSystemStrings.unitKg}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: b.color, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (showSliders)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return KratosSlider(
                      key: ValueKey('mss-mass-slider-${b.index}'),
                      label: '',
                      unit: MySolarSystemStrings.unitKg,
                      min: MySolarSystemConstants.massUiMin,
                      max: MySolarSystemConstants.massUiMax,
                      step: MySolarSystemConstants.massSliderStep,
                      value: b.mass.clamp(
                        MySolarSystemConstants.massUiMin,
                        MySolarSystemConstants.massUiMax,
                      ),
                      knobColor: b.color,
                      trackLength: (constraints.maxWidth - 8).clamp(
                        MySolarSystemConstants.valuesSliderTrackMin,
                        MySolarSystemConstants.valuesSliderTrackMax,
                      ),
                      compact: true,
                      onChanged: (v) => controller.setBodyMass(
                        controller.bodies.indexOf(b),
                        v,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 4),
            ],
            if (showMore) ...[
              const SizedBox(height: 8),
              Text(
                '${MySolarSystemStrings.position} (${MySolarSystemStrings.unitAu})',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Row(
                children: [
                  Expanded(child: _colHeader(MySolarSystemStrings.labelX)),
                  Expanded(child: _colHeader(MySolarSystemStrings.labelY)),
                ],
              ),
              for (final b in active)
                Row(
                  children: [
                    Expanded(
                      child: _numField(
                        key: ValueKey('mss-pos-x-${b.index}'),
                        value: MssFormat.positionAu(b.position.x),
                        color: b.color,
                        onSubmitted: (s) {
                          final v = double.tryParse(s);
                          if (v == null) return;
                          controller.setBodyPositionComponent(
                            controller.bodies.indexOf(b),
                            x: v,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _numField(
                        key: ValueKey('mss-pos-y-${b.index}'),
                        value: MssFormat.positionAu(b.position.y),
                        color: b.color,
                        onSubmitted: (s) {
                          final v = double.tryParse(s);
                          if (v == null) return;
                          controller.setBodyPositionComponent(
                            controller.bodies.indexOf(b),
                            y: v,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                '${MySolarSystemStrings.velocity} (${MySolarSystemStrings.unitKms})',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Row(
                children: [
                  Expanded(child: _colHeader(MySolarSystemStrings.labelVx)),
                  Expanded(child: _colHeader(MySolarSystemStrings.labelVy)),
                ],
              ),
              for (final b in active)
                Row(
                  children: [
                    Expanded(
                      child: _numField(
                        key: ValueKey('mss-vel-x-${b.index}'),
                        value: MssFormat.velocityKms(b.velocity.x),
                        color: b.color,
                        onSubmitted: (s) {
                          final v = double.tryParse(s);
                          if (v == null) return;
                          controller.setBodyVelocityComponent(
                            controller.bodies.indexOf(b),
                            vx: v,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _numField(
                        key: ValueKey('mss-vel-y-${b.index}'),
                        value: MssFormat.velocityKms(b.velocity.y),
                        color: b.color,
                        onSubmitted: (s) {
                          final v = double.tryParse(s);
                          if (v == null) return;
                          controller.setBodyVelocityComponent(
                            controller.bodies.indexOf(b),
                            vy: v,
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bodyDot(int index, Color color) {
    return Container(
      width: MySolarSystemConstants.valuesBodyDotSize,
      height: MySolarSystemConstants.valuesBodyDotSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _colHeader(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  Widget _numField({
    required Key key,
    required String value,
    required Color color,
    required ValueChanged<String> onSubmitted,
  }) {
    return SizedBox(
      height: MySolarSystemConstants.valuesNumFieldHeight,
      child: TextFormField(
        key: key,
        initialValue: value,
        style: TextStyle(color: color, fontSize: 12),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          border: OutlineInputBorder(),
        ),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}
