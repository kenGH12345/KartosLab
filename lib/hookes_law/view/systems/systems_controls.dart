import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/spring.dart';
import '../intro/intro_number_control.dart';
import '../intro/intro_play_painter.dart';
import 'systems_paint.dart';

Widget systemsSpringControl({
  required String title,
  required Spring spring,
  required Color thumbColor,
  required Key sliderKey,
  required Key incrementKey,
  required Key decrementKey,
  required VoidCallback onInteractionStart,
  required VoidCallback onInteractionEnd,
}) {
  final range = spring.springConstantRange;
  final mid = (range.min + range.max) / 2;
  return IntroNumberControl(
    title: title,
    value: spring.springConstant,
    min: range.min,
    max: range.max,
    sliderInterval: HookesLawConstants.springConstantSliderInterval,
    arrowInterval: HookesLawConstants.springConstantArrowInterval,
    decimalPlaces: HookesLawConstants.springConstantDecimalPlaces,
    units: 'N/m',
    thumbColor: thumbColor,
    trackWidth: HookesLawConstants.systemsSpringConstantTrackWidth,
    framed: false,
    majorTicks: [
      IntroTick(range.min, label: range.min.toStringAsFixed(0)),
      IntroTick(mid, label: mid.toStringAsFixed(0)),
      IntroTick(range.max, label: range.max.toStringAsFixed(0)),
    ],
    minorTickSpacing: 100,
    onChanged: spring.setSpringConstant,
    onInteractionStart: onInteractionStart,
    onInteractionEnd: onInteractionEnd,
    sliderKey: sliderKey,
    incrementKey: incrementKey,
    decrementKey: decrementKey,
  );
}

Widget systemsForceControl({
  required Spring equivalent,
  required Key sliderKey,
  required Key incrementKey,
  required Key decrementKey,
  required VoidCallback onInteractionStart,
  required VoidCallback onInteractionEnd,
}) {
  final range = equivalent.appliedForceRange;
  return IntroNumberControl(
    title: 'Applied Force:',
    value: equivalent.appliedForce,
    min: range.min,
    max: range.max,
    sliderInterval: HookesLawConstants.appliedForceSliderInterval,
    arrowInterval: HookesLawConstants.appliedForceArrowInterval,
    decimalPlaces: HookesLawConstants.appliedForceDecimalPlaces,
    units: 'N',
    thumbColor: SystemsColors.appliedForce,
    majorTicks: [
      IntroTick(range.min, label: range.min.toStringAsFixed(0)),
      IntroTick(range.min / 2),
      const IntroTick(0, label: '0'),
      IntroTick(range.max / 2),
      IntroTick(range.max, label: range.max.toStringAsFixed(0)),
    ],
    minorTickSpacing: 10,
    onChanged: equivalent.setAppliedForce,
    onInteractionStart: onInteractionStart,
    onInteractionEnd: onInteractionEnd,
    sliderKey: sliderKey,
    incrementKey: incrementKey,
    decrementKey: decrementKey,
  );
}

class SystemsSeparator extends StatelessWidget {
  const SystemsSeparator.horizontal({super.key}) : vertical = false;
  const SystemsSeparator.vertical({super.key}) : vertical = true;

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? 1 : 80,
      height: vertical ? 70 : 1,
      color: IntroColors.panelStroke,
    );
  }
}
