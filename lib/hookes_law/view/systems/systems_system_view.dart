import 'package:kratos/hookes_law/hookes_law_strings.dart';
import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/parallel_system.dart';
import '../../model/series_system.dart';
import '../intro/intro_play_painter.dart';
import '../phet_font.dart';
import 'systems_arm_drag.dart';
import 'systems_controls.dart';
import 'systems_paint.dart';
import 'systems_scene_painter.dart';
import 'systems_view_properties.dart';

class ParallelSystemView extends StatefulWidget {
  const ParallelSystemView({
    super.key,
    required this.system,
    required this.properties,
    required this.epoch,
  });

  final ParallelSystem system;
  final SystemsViewProperties properties;
  final int epoch;

  @override
  State<ParallelSystemView> createState() => _ParallelSystemViewState();
}

class _ParallelSystemViewState extends State<ParallelSystemView> with SystemsArmDrag {
  @override
  void initState() {
    super.initState();
    bindSpring(widget.system.topSpring);
    bindSpring(widget.system.bottomSpring);
    bindSpring(widget.system.equivalentSpring);
  }

  @override
  void didUpdateWidget(ParallelSystemView oldWidget) {
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
    final system = widget.system;
    final properties = widget.properties;
    final rightX = systemsX(system.equivalentSpring.right);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: HookesLawConstants.introSystemWidth,
          height: ParallelScenePainter.wallHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(HookesLawConstants.introSystemWidth, ParallelScenePainter.wallHeight),
                painter: ParallelScenePainter(
                  system: system,
                  properties: properties,
                  grippersOpen: grippersOpenFor(system.equivalentSpring),
                ),
              ),
              if (properties.appliedForceVectorVisible && system.equivalentSpring.appliedForce != 0)
                _marker('systems-applied-arrow-parallel', rightX, ParallelScenePainter.totalForceY),
              if (properties.showTotalSpringForce && system.equivalentSpring.springForce != 0)
                _marker('systems-total-arrow-parallel', rightX, ParallelScenePainter.totalForceY),
              if (properties.showComponentSpringForces && system.topSpring.springForce != 0)
                _marker(
                  'systems-top-component-arrow',
                  systemsX(system.topSpring.right),
                  ParallelScenePainter.topComponentY,
                ),
              if (properties.showComponentSpringForces && system.bottomSpring.springForce != 0)
                _marker(
                  'systems-bottom-component-arrow',
                  systemsX(system.bottomSpring.right),
                  ParallelScenePainter.bottomComponentY,
                ),
              if (properties.valuesVisible && properties.appliedForceVectorVisible)
                _value(
                  'systems-applied-value-parallel',
                  rightX,
                  ParallelScenePainter.totalForceY,
                  system.equivalentSpring.appliedForce,
                  HookesLawConstants.appliedForceDecimalPlaces,
                  SystemsColors.appliedForce,
                  alignZeroLeft: true,
                ),
              if (properties.valuesVisible && properties.showTotalSpringForce)
                _value(
                  'systems-total-value-parallel',
                  rightX,
                  ParallelScenePainter.totalForceY,
                  system.equivalentSpring.springForce,
                  HookesLawConstants.springForceDecimalPlaces,
                  SystemsColors.totalSpringForce,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.showComponentSpringForces)
                _value(
                  'systems-top-component-value',
                  systemsX(system.topSpring.right),
                  ParallelScenePainter.topComponentY,
                  system.topSpring.springForce,
                  HookesLawConstants.parallelSpringForceComponentsDecimalPlaces,
                  SystemsColors.spring1Middle,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.showComponentSpringForces)
                _value(
                  'systems-bottom-component-value',
                  systemsX(system.bottomSpring.right),
                  ParallelScenePainter.bottomComponentY,
                  system.bottomSpring.springForce,
                  HookesLawConstants.parallelSpringForceComponentsDecimalPlaces,
                  SystemsColors.spring2Middle,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.displacementVectorVisible)
                _value(
                  'systems-displacement-value-parallel',
                  systemsX(system.equivalentSpring.equilibriumX),
                  ParallelScenePainter.displacementTailY,
                  system.equivalentSpring.displacement,
                  HookesLawConstants.displacementDecimalPlaces,
                  SystemsColors.displacement,
                  alignZeroLeft: true,
                  units: 'm',
                  span: system.equivalentSpring.displacement * HookesLawConstants.unitDisplacementX,
                  below: true,
                  centerZero: true,
                  centerOnArrow: true,
                ),
              roboticHandDragTarget(
                key: const Key('systems-hand-parallel'),
                handX: rightX,
                axisY: ParallelScenePainter.axisY,
                onPanStart: (details) => startArmDrag(details, system.roboticArm),
                onPanUpdate: (details) => updateArmDrag(details, system.roboticArm, system.equivalentSpring),
                onPanEnd: (_) => endArmDrag(),
                onPanCancel: endArmDrag,
              ),
            ],
          ),
        ),
        const SizedBox(height: HookesLawConstants.systemsControlsGapBelowWall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: IntroColors.panelFill,
                    border: Border.all(color: IntroColors.panelStroke),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HookesLawConstants.springPanelXMargin,
                      vertical: HookesLawConstants.springPanelYMargin,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        systemsSpringControl(
                          title: '${HookesLawStrings.topSpring}:',
                          spring: system.topSpring,
                          thumbColor: SystemsColors.spring1Middle,
                          sliderKey: const Key('systems-k-top-slider'),
                          incrementKey: const Key('systems-k-top-increment'),
                          decrementKey: const Key('systems-k-top-decrement'),
                          onInteractionStart: gestureStart,
                          onInteractionEnd: gestureEnd,
                        ),
                        const SizedBox(height: 5),
                        const SystemsSeparator.horizontal(),
                        const SizedBox(height: 5),
                        systemsSpringControl(
                          title: '${HookesLawStrings.bottomSpring}:',
                          spring: system.bottomSpring,
                          thumbColor: SystemsColors.spring2Middle,
                          sliderKey: const Key('systems-k-bottom-slider'),
                          incrementKey: const Key('systems-k-bottom-increment'),
                          decrementKey: const Key('systems-k-bottom-decrement'),
                          onInteractionStart: gestureStart,
                          onInteractionEnd: gestureEnd,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                systemsForceControl(
                  equivalent: system.equivalentSpring,
                  sliderKey: const Key('systems-f-parallel-slider'),
                  incrementKey: const Key('systems-f-parallel-increment'),
                  decrementKey: const Key('systems-f-parallel-decrement'),
                  onInteractionStart: gestureStart,
                  onInteractionEnd: gestureEnd,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SeriesSystemView extends StatefulWidget {
  const SeriesSystemView({
    super.key,
    required this.system,
    required this.properties,
    required this.epoch,
  });

  final SeriesSystem system;
  final SystemsViewProperties properties;
  final int epoch;

  @override
  State<SeriesSystemView> createState() => _SeriesSystemViewState();
}

class _SeriesSystemViewState extends State<SeriesSystemView> with SystemsArmDrag {
  @override
  void initState() {
    super.initState();
    bindSpring(widget.system.leftSpring);
    bindSpring(widget.system.rightSpring);
    bindSpring(widget.system.equivalentSpring);
    bindNumber(
      widget.system.rightSpring.leftProperty.addListener,
      widget.system.rightSpring.leftProperty.removeListener,
    );
  }

  @override
  void didUpdateWidget(SeriesSystemView oldWidget) {
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
    final system = widget.system;
    final properties = widget.properties;
    final rightX = systemsX(system.rightSpring.right);
    final junctionX = systemsX(system.leftSpring.right);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: HookesLawConstants.introSystemWidth,
          height: SeriesScenePainter.wallHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(HookesLawConstants.introSystemWidth, SeriesScenePainter.wallHeight),
                painter: SeriesScenePainter(
                  system: system,
                  properties: properties,
                  grippersOpen: grippersOpenFor(system.equivalentSpring),
                ),
              ),
              if (properties.appliedForceVectorVisible && system.equivalentSpring.appliedForce != 0)
                _marker('systems-applied-arrow-series', rightX, SeriesScenePainter.rightForceY),
              if (properties.showTotalSpringForce && system.equivalentSpring.springForce != 0)
                _marker('systems-total-arrow-series', rightX, SeriesScenePainter.rightForceY),
              if (properties.showComponentSpringForces && system.leftSpring.springForce != 0)
                _marker('systems-left-component-arrow', junctionX, SeriesScenePainter.leftForceY),
              if (properties.showComponentSpringForces && system.leftSpring.appliedForce != 0)
                _marker('systems-left-applied-arrow', junctionX, SeriesScenePainter.leftForceY),
              if (properties.showComponentSpringForces && system.rightSpring.springForce != 0)
                _marker('systems-right-component-arrow', rightX, SeriesScenePainter.rightForceY),
              if (properties.valuesVisible && properties.showComponentSpringForces)
                _value(
                  'systems-left-component-value',
                  junctionX,
                  SeriesScenePainter.leftForceY,
                  system.leftSpring.springForce,
                  HookesLawConstants.seriesSpringForceComponentsDecimalPlaces,
                  SystemsColors.spring1Middle,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.showComponentSpringForces)
                _value(
                  'systems-left-applied-value',
                  junctionX,
                  SeriesScenePainter.leftForceY,
                  system.leftSpring.appliedForce,
                  HookesLawConstants.appliedForceDecimalPlaces,
                  SystemsColors.spring2Middle,
                  alignZeroLeft: true,
                ),
              if (properties.valuesVisible && properties.showComponentSpringForces)
                _value(
                  'systems-right-component-value',
                  rightX,
                  SeriesScenePainter.rightForceY,
                  system.rightSpring.springForce,
                  HookesLawConstants.seriesSpringForceComponentsDecimalPlaces,
                  SystemsColors.spring2Middle,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.appliedForceVectorVisible)
                _value(
                  'systems-applied-value-series',
                  rightX,
                  SeriesScenePainter.rightForceY,
                  system.equivalentSpring.appliedForce,
                  HookesLawConstants.appliedForceDecimalPlaces,
                  SystemsColors.appliedForce,
                  alignZeroLeft: true,
                ),
              if (properties.valuesVisible && properties.showTotalSpringForce)
                _value(
                  'systems-total-value-series',
                  rightX,
                  SeriesScenePainter.rightForceY,
                  system.equivalentSpring.springForce,
                  HookesLawConstants.springForceDecimalPlaces,
                  SystemsColors.totalSpringForce,
                  alignZeroLeft: false,
                ),
              if (properties.valuesVisible && properties.displacementVectorVisible)
                _value(
                  'systems-displacement-value-series',
                  systemsX(system.equivalentSpring.equilibriumX),
                  SeriesScenePainter.displacementTailY,
                  system.equivalentSpring.displacement,
                  HookesLawConstants.displacementDecimalPlaces,
                  SystemsColors.displacement,
                  alignZeroLeft: true,
                  units: 'm',
                  span: system.equivalentSpring.displacement * HookesLawConstants.unitDisplacementX,
                  below: true,
                  centerZero: true,
                  centerOnArrow: true,
                ),
              roboticHandDragTarget(
                key: const Key('systems-hand-series'),
                handX: rightX,
                axisY: SeriesScenePainter.axisY,
                onPanStart: (details) => startArmDrag(details, system.roboticArm),
                onPanUpdate: (details) => updateArmDrag(details, system.roboticArm, system.equivalentSpring),
                onPanEnd: (_) => endArmDrag(),
                onPanCancel: endArmDrag,
              ),
            ],
          ),
        ),
        const SizedBox(height: HookesLawConstants.systemsControlsGapBelowWall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: IntroColors.panelFill,
                  border: Border.all(color: IntroColors.panelStroke),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HookesLawConstants.springPanelXMargin,
                    vertical: HookesLawConstants.springPanelYMargin,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      systemsSpringControl(
                        title: '${HookesLawStrings.leftSpring}:',
                        spring: system.leftSpring,
                        thumbColor: SystemsColors.spring1Middle,
                        sliderKey: const Key('systems-k-left-slider'),
                        incrementKey: const Key('systems-k-left-increment'),
                        decrementKey: const Key('systems-k-left-decrement'),
                        onInteractionStart: gestureStart,
                        onInteractionEnd: gestureEnd,
                      ),
                      const SizedBox(width: 20),
                      const SystemsSeparator.vertical(),
                      const SizedBox(width: 20),
                      systemsSpringControl(
                        title: '${HookesLawStrings.rightSpring}:',
                        spring: system.rightSpring,
                        thumbColor: SystemsColors.spring2Middle,
                        sliderKey: const Key('systems-k-right-slider'),
                        incrementKey: const Key('systems-k-right-increment'),
                        decrementKey: const Key('systems-k-right-decrement'),
                        onInteractionStart: gestureStart,
                        onInteractionEnd: gestureEnd,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              systemsForceControl(
                equivalent: system.equivalentSpring,
                sliderKey: const Key('systems-f-series-slider'),
                incrementKey: const Key('systems-f-series-increment'),
                decrementKey: const Key('systems-f-series-decrement'),
                onInteractionStart: gestureStart,
                onInteractionEnd: gestureEnd,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _marker(String name, double x, double y) {
  return Positioned(
    left: x,
    top: y,
    child: IgnorePointer(
      child: SizedBox(key: Key(name), width: 1, height: 1),
    ),
  );
}

Widget _value(
  String name,
  double x,
  double y,
  double amount,
  int places,
  Color color, {
  required bool alignZeroLeft,
  String units = 'N',
  double? span,
  bool below = false,
  bool centerZero = false,
  bool centerOnArrow = false,
}) {
  final text = '${amount.abs().toStringAsFixed(places)} $units';
  final usedSpan = span ?? amount * HookesLawConstants.unitForceX;
  return Positioned(
    left: x,
    top: y,
    child: CustomSingleChildLayout(
      delegate: _ValueAnchor(
        usedSpan: usedSpan,
        alignZeroLeft: alignZeroLeft,
        centerZero: centerZero,
        centerOnArrow: centerOnArrow,
        below: below,
      ),
      child: IgnorePointer(
        child: DecoratedBox(
          key: Key(name),
          decoration: BoxDecoration(
            color: SystemsColors.valueScrim,
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

class _ValueAnchor extends SingleChildLayoutDelegate {
  _ValueAnchor({
    required this.usedSpan,
    required this.alignZeroLeft,
    required this.centerZero,
    required this.centerOnArrow,
    required this.below,
  });

  final double usedSpan;
  final bool alignZeroLeft;
  final bool centerZero;
  final bool centerOnArrow;
  final bool below;

  @override
  Size getSize(BoxConstraints constraints) => Size.zero;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final dx = _valueDx(
      childSize.width,
      usedSpan,
      alignZeroLeft: alignZeroLeft,
      centerZero: centerZero,
      centerOnArrow: centerOnArrow,
    );
    final half = HookesLawConstants.vectorHeadWidth / 2;
    final dy = below ? half : -(half + childSize.height);
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_ValueAnchor oldDelegate) {
    return oldDelegate.usedSpan != usedSpan ||
        oldDelegate.alignZeroLeft != alignZeroLeft ||
        oldDelegate.centerZero != centerZero ||
        oldDelegate.centerOnArrow != centerOnArrow ||
        oldDelegate.below != below;
  }
}

double _valueDx(
  double width,
  double usedSpan, {
  required bool alignZeroLeft,
  required bool centerZero,
  required bool centerOnArrow,
}) {
  if (centerOnArrow) {
    return usedSpan == 0 ? -width / 2 : usedSpan / 2 - width / 2;
  }
  if (usedSpan == 0) {
    if (centerZero) {
      return -width / 2;
    }
    return alignZeroLeft ? 5 : -5 - width;
  }
  if (width + 10 < usedSpan.abs()) {
    return usedSpan / 2 - width / 2;
  }
  if (usedSpan > 0) {
    return 5;
  }
  return -5 - width;
}
