import 'package:kratos/hookes_law/hookes_law_strings.dart';
import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/robotic_arm.dart';
import '../../model/spring.dart';
import '../intro/intro_number_control.dart';
import '../intro/intro_play_painter.dart';
import '../phet_font.dart';
import '../systems/systems_arm_drag.dart';
import 'energy_scene_painter.dart';
import 'energy_view_properties.dart';

/// One blue spring, displacement control, and spring-constant control.
/// `EnergySystemNode.ts` + `EnergySpringControls.ts`.
class EnergySystemView extends StatefulWidget {
  const EnergySystemView({
    super.key,
    required this.spring,
    required this.arm,
    required this.properties,
    required this.epoch,
    required this.onLayoutHeight,
  });

  final Spring spring;
  final RoboticArm arm;
  final EnergyViewProperties properties;
  final int epoch;
  final ValueChanged<double> onLayoutHeight;

  @override
  State<EnergySystemView> createState() => _EnergySystemViewState();
}

class _EnergySystemViewState extends State<EnergySystemView> with SystemsArmDrag {
  @override
  void initState() {
    super.initState();
    bindSpring(widget.spring);
  }

  @override
  void didUpdateWidget(EnergySystemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.epoch != oldWidget.epoch) {
      cancelGestures();
    }
  }

  @override
  void dispose() {
    unbindAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final height = context.size?.height;
      if (height != null) {
        widget.onLayoutHeight(height);
      }
    });
    final spring = widget.spring;
    final properties = widget.properties;
    final rightX = EnergyScenePainter.attachmentX + HookesLawConstants.unitDisplacementX * spring.right;
    final equilibriumX =
        EnergyScenePainter.attachmentX + HookesLawConstants.unitDisplacementX * spring.equilibriumX;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: HookesLawConstants.introSystemWidth,
          height: HookesLawConstants.wallHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(HookesLawConstants.introSystemWidth, HookesLawConstants.wallHeight),
                painter: EnergyScenePainter(
                  spring: spring,
                  grippersOpen: grippersOpenFor(spring),
                  equilibriumVisible: properties.equilibriumPositionVisible,
                  appliedForceVisible: properties.appliedForceVectorVisible,
                  displacementVisible: properties.displacementVectorVisible,
                  armRight: widget.arm.right,
                ),
              ),
              if (properties.valuesVisible && properties.appliedForceVectorVisible)
                _EnergyValue(
                  keyName: 'energy-applied-value',
                  anchorX: rightX,
                  anchorY: EnergyScenePainter.forceTailY,
                  text:
                      '${spring.appliedForce.abs().toStringAsFixed(HookesLawConstants.appliedForceDecimalPlaces)} N',
                  color: IntroColors.appliedForce,
                  above: true,
                  span: spring.appliedForce * HookesLawConstants.energyUnitForceX,
                  alignZeroLeft: true,
                ),
              if (properties.valuesVisible && properties.displacementVectorVisible)
                _EnergyValue(
                  keyName: 'energy-displacement-value',
                  anchorX: equilibriumX,
                  anchorY: EnergyScenePainter.displacementTailY,
                  text:
                      '${spring.displacement.abs().toStringAsFixed(HookesLawConstants.displacementDecimalPlaces)} m',
                  color: IntroColors.displacement,
                  above: false,
                  span: spring.displacement * HookesLawConstants.unitDisplacementX,
                  alignZeroLeft: true,
                  centerOnArrow: true,
                ),
              roboticHandDragTarget(
                key: const Key('energy-hand'),
                handX: rightX,
                axisY: EnergyScenePainter.axisY,
                onPanStart: (details) => startArmDrag(details, widget.arm),
                onPanUpdate: (details) => updateArmDrag(details, widget.arm, spring),
                onPanEnd: (_) => endArmDrag(),
                onPanCancel: endArmDrag,
              ),
            ],
          ),
        ),
        const SizedBox(height: HookesLawConstants.energyControlsGapBelowWall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntroNumberControl(
              title: '${HookesLawStrings.springConstant}:',
              value: spring.springConstant,
              min: spring.springConstantRange.min,
              max: spring.springConstantRange.max,
              sliderInterval: HookesLawConstants.springConstantSliderInterval,
              arrowInterval: HookesLawConstants.springConstantArrowInterval,
              decimalPlaces: HookesLawConstants.springConstantDecimalPlaces,
              units: 'N/m',
              thumbColor: IntroColors.springMiddle,
              majorTicks: const [
                IntroTick(100, label: '100'),
                IntroTick(200, label: '200'),
                IntroTick(300, label: '300'),
                IntroTick(400, label: '400'),
              ],
              minorTickSpacing: 50,
              onChanged: spring.setSpringConstant,
              onInteractionStart: gestureStart,
              onInteractionEnd: gestureEnd,
              sliderKey: const Key('energy-k-slider'),
              incrementKey: const Key('energy-k-increment'),
              decrementKey: const Key('energy-k-decrement'),
            ),
            const SizedBox(width: 10),
            IntroNumberControl(
              title: '${HookesLawStrings.displacement}:',
              value: spring.displacement,
              min: spring.displacementRange.min,
              max: spring.displacementRange.max,
              sliderInterval: HookesLawConstants.displacementSliderInterval,
              arrowInterval: HookesLawConstants.displacementArrowInterval,
              decimalPlaces: HookesLawConstants.displacementDecimalPlaces,
              units: 'm',
              thumbColor: IntroColors.displacement,
              majorTicks: const [
                IntroTick(-1, label: '-1'),
                IntroTick(0, label: '0'),
                IntroTick(1, label: '1'),
              ],
              minorTickSpacing: 0.2,
              onChanged: spring.setDisplacement,
              onInteractionStart: gestureStart,
              onInteractionEnd: gestureEnd,
              sliderKey: const Key('energy-x-slider'),
              incrementKey: const Key('energy-x-increment'),
              decrementKey: const Key('energy-x-decrement'),
            ),
          ],
          ),
        ),
      ],
    );
  }
}

class _EnergyValue extends StatelessWidget {
  const _EnergyValue({
    required this.keyName,
    required this.anchorX,
    required this.anchorY,
    required this.text,
    required this.color,
    required this.above,
    required this.span,
    required this.alignZeroLeft,
    this.centerOnArrow = false,
  });

  final String keyName;
  final double anchorX;
  final double anchorY;
  final String text;
  final Color color;
  final bool above;
  final double span;
  final bool alignZeroLeft;
  final bool centerOnArrow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: anchorX,
      top: anchorY,
      child: CustomSingleChildLayout(
        delegate: _EnergyValueAnchor(
          span: span,
          alignZeroLeft: alignZeroLeft,
          above: above,
          centerOnArrow: centerOnArrow,
        ),
        child: IgnorePointer(
          child: DecoratedBox(
            key: Key(keyName),
            decoration: BoxDecoration(
              color: IntroColors.valueScrim,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Text(text, style: PhetFont.of(HookesLawConstants.controlFontSize, color: color)),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnergyValueAnchor extends SingleChildLayoutDelegate {
  _EnergyValueAnchor({
    required this.span,
    required this.alignZeroLeft,
    required this.above,
    required this.centerOnArrow,
  });

  final double span;
  final bool alignZeroLeft;
  final bool above;
  final bool centerOnArrow;

  @override
  Size getSize(BoxConstraints constraints) => Size.zero;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final width = childSize.width;
    final double dx;
    if (centerOnArrow) {
      dx = span == 0 ? -width / 2 : span / 2 - width / 2;
    } else if (span == 0) {
      dx = alignZeroLeft ? 5 : -5 - width;
    } else if (width + 10 < span.abs()) {
      dx = span / 2 - width / 2;
    } else if (span > 0) {
      dx = 5;
    } else {
      dx = -5 - width;
    }
    final half = HookesLawConstants.vectorHeadWidth / 2;
    final dy = above ? -(half + childSize.height) : half;
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_EnergyValueAnchor oldDelegate) {
    return oldDelegate.span != span ||
        oldDelegate.alignZeroLeft != alignZeroLeft ||
        oldDelegate.above != above ||
        oldDelegate.centerOnArrow != centerOnArrow;
  }
}
