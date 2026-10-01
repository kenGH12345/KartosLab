import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/hookes_law_numbers.dart';
import '../../model/robotic_arm_drag.dart';
import '../../model/single_spring_system.dart';
import '../phet_font.dart';
import 'intro_number_control.dart';
import 'intro_play_painter.dart';
import 'intro_view_properties.dart';

/// One Intro spring system: play area plus the k and F controls.
///
/// Bound to [SingleSpringSystem]. The view does not keep a second copy of
/// F, x, or k.
class IntroSystemView extends StatefulWidget {
  const IntroSystemView({
    super.key,
    required this.system,
    required this.systemNumber,
    required this.properties,
    required this.epoch,
  });

  final SingleSpringSystem system;
  final int systemNumber;
  final IntroViewProperties properties;
  final int epoch;

  @override
  State<IntroSystemView> createState() => _IntroSystemViewState();
}

class _IntroSystemViewState extends State<IntroSystemView> {
  int _openGestures = 0;
  bool _armDrag = false;
  double _dragStartLeft = 0;
  double _dragStartGlobalX = 0;

  late final List<VoidCallback> _detach = [];

  SingleSpringSystem get system => widget.system;

  @override
  void initState() {
    super.initState();
    void bind(
      void Function(void Function(double)) add,
      void Function(void Function(double)) remove,
    ) {
      void listener(double _) {
        if (mounted) {
          setState(() {});
        }
      }

      add(listener);
      _detach.add(() => remove(listener));
    }

    final spring = system.spring;
    bind(spring.appliedForceProperty.addListener, spring.appliedForceProperty.removeListener);
    bind(spring.springConstantProperty.addListener, spring.springConstantProperty.removeListener);
    bind(spring.displacementProperty.addListener, spring.displacementProperty.removeListener);
    bind(spring.rightProperty.addListener, spring.rightProperty.removeListener);
  }

  @override
  void didUpdateWidget(IntroSystemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.epoch != oldWidget.epoch) {
      _armDrag = false;
      _openGestures = 0;
    }
  }

  @override
  void dispose() {
    for (final detach in _detach) {
      detach();
    }
    super.dispose();
  }

  void _gestureStart() {
    setState(() => _openGestures++);
  }

  void _gestureEnd() {
    setState(() => _openGestures = math.max(0, _openGestures - 1));
  }

  bool get _grippersOpen {
    final fixed = HookesLawNumbers.toFixedNumber(
      system.spring.displacement,
      HookesLawConstants.displacementDecimalPlaces,
    );
    return _openGestures == 0 && fixed == 0;
  }

  double _pixelsPerLayout(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) {
      return 1;
    }
    final origin = box.localToGlobal(Offset.zero);
    final step = box.localToGlobal(const Offset(1, 0));
    final scale = (step - origin).distance;
    return scale == 0 ? 1 : scale;
  }

  void _startArmDrag(DragStartDetails details) {
    _armDrag = true;
    _dragStartLeft = system.roboticArm.left;
    _dragStartGlobalX = details.globalPosition.dx;
    _gestureStart();
  }

  void _updateArmDrag(DragUpdateDetails details) {
    if (!_armDrag) {
      return;
    }
    final dx = (details.globalPosition.dx - _dragStartGlobalX) / _pixelsPerLayout(context);
    final proposed = _dragStartLeft + dx / HookesLawConstants.unitDisplacementX;
    applyRoboticArmPointerLeft(
      arm: system.roboticArm,
      springRightRange: system.spring.rightRange,
      proposedLeft: proposed,
    );
  }

  void _endArmDrag() {
    if (!_armDrag) {
      return;
    }
    _armDrag = false;
    _gestureEnd();
  }

  @override
  Widget build(BuildContext context) {
    final spring = system.spring;
    final n = widget.systemNumber;
    final unit = HookesLawConstants.unitDisplacementX;
    final springRight = IntroPlayPainter.attachmentX + unit * spring.right;
    final equilibriumX = IntroPlayPainter.attachmentX + unit * spring.equilibriumX;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: HookesLawConstants.introSystemWidth,
          height: HookesLawConstants.introPlayHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: const Size(
                  HookesLawConstants.introSystemWidth,
                  HookesLawConstants.introPlayHeight,
                ),
                painter: IntroPlayPainter(
                  system: system,
                  equilibriumVisible: widget.properties.equilibriumPositionVisible,
                  appliedForceVisible: widget.properties.appliedForceVectorVisible,
                  springForceVisible: widget.properties.springForceVectorVisible,
                  displacementVisible: widget.properties.displacementVectorVisible,
                  grippersOpen: _grippersOpen,
                ),
              ),
              if (widget.properties.equilibriumPositionVisible)
                Positioned(
                  left: equilibriumX,
                  top: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      key: Key('intro-equilibrium-$n'),
                      width: 2,
                      height: 2,
                    ),
                  ),
                ),
              if (widget.properties.appliedForceVectorVisible && spring.appliedForce != 0)
                _arrowMarker(
                  'intro-applied-arrow-$n',
                  springRight,
                  IntroPlayPainter.forceTailY,
                ),
              if (widget.properties.springForceVectorVisible && spring.springForce != 0)
                _arrowMarker(
                  'intro-spring-arrow-$n',
                  springRight,
                  IntroPlayPainter.forceTailY,
                ),
              if (widget.properties.displacementVectorVisible && spring.displacement != 0)
                _arrowMarker(
                  'intro-displacement-arrow-$n',
                  equilibriumX,
                  IntroPlayPainter.displacementTailY,
                ),
              if (widget.properties.valuesVisible && widget.properties.appliedForceVectorVisible)
                _valueLabel(
                  keyName: 'intro-applied-value-$n',
                  anchorX: springRight,
                  anchorY: IntroPlayPainter.forceTailY,
                  text: '${spring.appliedForce.abs().toStringAsFixed(HookesLawConstants.appliedForceDecimalPlaces)} N',
                  color: IntroColors.appliedForce,
                  above: true,
                  span: spring.appliedForce * HookesLawConstants.unitForceX,
                  alignZeroLeft: true,
                ),
              if (widget.properties.valuesVisible && widget.properties.springForceVectorVisible)
                _valueLabel(
                  keyName: 'intro-spring-value-$n',
                  anchorX: springRight,
                  anchorY: IntroPlayPainter.forceTailY,
                  text: '${spring.springForce.abs().toStringAsFixed(HookesLawConstants.springForceDecimalPlaces)} N',
                  color: IntroColors.springMiddle,
                  above: true,
                  span: spring.springForce * HookesLawConstants.unitForceX,
                  alignZeroLeft: false,
                ),
              if (widget.properties.valuesVisible && widget.properties.displacementVectorVisible)
                _valueLabel(
                  keyName: 'intro-displacement-value-$n',
                  anchorX: equilibriumX,
                  anchorY: IntroPlayPainter.displacementTailY,
                  text: '${spring.displacement.abs().toStringAsFixed(HookesLawConstants.displacementDecimalPlaces)} m',
                  color: IntroColors.displacement,
                  above: false,
                  centerOnArrow: true,
                  span: spring.displacement * unit,
                  alignZeroLeft: true,
                ),
              roboticHandDragTarget(
                key: Key('intro-hand-$n'),
                handX: springRight,
                axisY: IntroPlayPainter.axisY,
                onPanStart: _startArmDrag,
                onPanUpdate: _updateArmDrag,
                onPanEnd: (_) => _endArmDrag(),
                onPanCancel: _endArmDrag,
              ),
            ],
          ),
        ),
        const SizedBox(height: HookesLawConstants.introControlsGapBelowWall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntroNumberControl(
              title: 'Spring Constant $n:',
              value: spring.springConstant,
              min: spring.springConstantRange.min,
              max: spring.springConstantRange.max,
              sliderInterval: HookesLawConstants.springConstantSliderInterval,
              arrowInterval: HookesLawConstants.springConstantArrowInterval,
              decimalPlaces: HookesLawConstants.springConstantDecimalPlaces,
              units: 'N/m',
              thumbColor: IntroColors.springMiddle,
              majorTicks: [
                IntroTick(spring.springConstantRange.min, label: spring.springConstantRange.min.toStringAsFixed(0)),
                IntroTick(spring.springConstantRange.max / 2, label: (spring.springConstantRange.max / 2).toStringAsFixed(0)),
                IntroTick(spring.springConstantRange.max, label: spring.springConstantRange.max.toStringAsFixed(0)),
              ],
              minorTickSpacing: 100,
              onChanged: system.spring.setSpringConstant,
              onInteractionStart: _gestureStart,
              onInteractionEnd: _gestureEnd,
              sliderKey: Key('intro-k-slider-$n'),
              incrementKey: Key('intro-k-increment-$n'),
              decrementKey: Key('intro-k-decrement-$n'),
            ),
            const SizedBox(width: 10),
            IntroNumberControl(
              title: 'Applied Force $n:',
              value: spring.appliedForce,
              min: spring.appliedForceRange.min,
              max: spring.appliedForceRange.max,
              sliderInterval: HookesLawConstants.appliedForceSliderInterval,
              arrowInterval: HookesLawConstants.appliedForceArrowInterval,
              decimalPlaces: HookesLawConstants.appliedForceDecimalPlaces,
              units: 'N',
              thumbColor: IntroColors.appliedForce,
              majorTicks: const [
                IntroTick(-100, label: '-100'),
                IntroTick(-50),
                IntroTick(0, label: '0'),
                IntroTick(50),
                IntroTick(100, label: '100'),
              ],
              minorTickSpacing: 10,
              onChanged: system.spring.setAppliedForce,
              onInteractionStart: _gestureStart,
              onInteractionEnd: _gestureEnd,
              sliderKey: Key('intro-f-slider-$n'),
              incrementKey: Key('intro-f-increment-$n'),
              decrementKey: Key('intro-f-decrement-$n'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _arrowMarker(String name, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: IgnorePointer(
        child: SizedBox(key: Key(name), width: 1, height: 1),
      ),
    );
  }

  Widget _valueLabel({
    required String keyName,
    required double anchorX,
    required double anchorY,
    required String text,
    required Color color,
    required bool above,
    required double span,
    required bool alignZeroLeft,
    bool centerOnArrow = false,
  }) {
    final style = PhetFont.of(HookesLawConstants.controlFontSize, color: color);
    return Positioned(
      left: anchorX,
      top: anchorY,
      child: CustomSingleChildLayout(
        delegate: _IntroValueAnchor(
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
              child: Text(text, style: style),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroValueAnchor extends SingleChildLayoutDelegate {
  _IntroValueAnchor({
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
  bool shouldRelayout(_IntroValueAnchor oldDelegate) {
    return oldDelegate.span != span ||
        oldDelegate.alignZeroLeft != alignZeroLeft ||
        oldDelegate.above != above ||
        oldDelegate.centerOnArrow != centerOnArrow;
  }
}
