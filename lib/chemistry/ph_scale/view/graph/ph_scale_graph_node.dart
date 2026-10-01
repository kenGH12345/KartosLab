import 'package:flutter/material.dart';

import '../../model/ph_chemistry.dart';
import '../../model/ph_scale_colors.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/solution_derived_properties.dart';
import '../ph_scale_fonts.dart';
import 'graph_enums.dart';
import 'graph_indicator.dart';
import 'graph_math.dart';
import 'graph_scale_painters.dart';

/// Full Graph feature — PhET `GraphNode.ts`.
///
/// Vertical log/linear scale + H₂O / H₃O⁺ / OH⁻ indicators (not curves).
class PhScaleGraphNode extends StatelessWidget {
  const PhScaleGraphNode({
    super.key,
    required this.state,
    required this.derived,
    required this.totalVolume,
    required this.logScaleHeight,
    this.linearScaleHeight = 440,
    this.interactive = false,
    this.onPHChanged,
    this.pH,
  });

  final GraphViewState state;
  final SolutionDerivedProperties derived;
  final double totalVolume;
  final double logScaleHeight;
  final double linearScaleHeight;
  final bool interactive;
  final ValueChanged<double>? onPHChanged;
  final PhValue pH;

  static const double scaleWidth = 100;
  static const double indicatorXOffset = 8;

  /// Left gutter so H₃O⁺ callout is fully inside the graph widget.
  static double leftGutter({required bool interactive}) =>
      GraphIndicator.layoutWidth(interactive: interactive) + indicatorXOffset;

  /// Right gutter so OH⁻ / H₂O callouts are fully inside the graph widget.
  static double rightGutter({required bool interactive}) =>
      GraphIndicator.layoutWidth(interactive: interactive) + indicatorXOffset;

  static double totalWidth({required bool interactive}) =>
      leftGutter(interactive: interactive) +
      scaleWidth +
      rightGutter(interactive: interactive);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _GraphControlPanel(state: state),
            // vertical connector
            Container(width: 1, height: 30, color: Colors.black),
            if (state.expanded) ...[
              _buildScaleWithIndicators(),
              if (state.hasLinearFeature) ...[
                Container(width: 1, height: 15, color: Colors.black),
                _ScaleSwitch(state: state),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildScaleWithIndicators() {
    final isLog = !state.hasLinearFeature ||
        state.scale == GraphScale.logarithmic;
    final height = isLog ? logScaleHeight : linearScaleHeight;

    final h3o = valueH3O(derived, state.units);
    final oh = valueOH(derived, state.units);
    final h2o = valueH2O(derived, state.units);

    late final double yH3o;
    late final double yOh;
    late final double yH2o;

    if (isLog) {
      yH3o = LogGraphMath.valueToY(h3o, height);
      yOh = LogGraphMath.valueToY(oh, height);
      yH2o = LogGraphMath.valueToY(h2o, height);
    } else {
      final ticks = linearTickYs(height);
      yH3o = linearValueToY(
        value: h3o,
        exponent: state.linearExponent,
        topTickY: ticks.topTickY,
        bottomTickY: ticks.bottomTickY,
        offScaleY: ticks.offScaleY,
      );
      yOh = linearValueToY(
        value: oh,
        exponent: state.linearExponent,
        topTickY: ticks.topTickY,
        bottomTickY: ticks.bottomTickY,
        offScaleY: ticks.offScaleY,
      );
      yH2o = linearValueToY(
        value: h2o,
        exponent: state.linearExponent,
        topTickY: ticks.topTickY,
        bottomTickY: ticks.bottomTickY,
        offScaleY: ticks.offScaleY - 4,
      );
    }

    final canDrag = interactive && isLog && onPHChanged != null;
    final leftG = leftGutter(interactive: canDrag);
    final totalW = leftG + scaleWidth + rightGutter(interactive: canDrag);

    return SizedBox(
      width: totalW,
      height: height + 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Scale centered between indicator gutters
          Positioned(
            left: leftG,
            top: 0,
            child: CustomPaint(
              size: Size(scaleWidth, height),
              painter: isLog
                  ? LogarithmicScalePainter(
                      scaleHeight: height,
                      scaleWidth: scaleWidth,
                    )
                  : LinearScalePainter(
                      scaleHeight: height,
                      scaleWidth: scaleWidth,
                      exponent: state.linearExponent,
                    ),
            ),
          ),
          // H3O left
          Positioned(
            left: leftG - GraphIndicator.bgW - indicatorXOffset,
            top: (yH3o - GraphIndicator.bgH / 2).clamp(0.0, height),
            child: GraphIndicator(
              species: GraphIndicatorSpecies.h3o,
              value: h3o,
              side: GraphIndicatorSide.left,
              anchorY: yH3o,
              interactive: canDrag,
              onVerticalDrag: canDrag
                  ? (d) {
                      final newY = (yH3o + d.delta.dy)
                          .clamp(0.0, height)
                          .toDouble();
                      GraphIndicatorDrag.apply(
                        yView: newY,
                        scaleHeight: height,
                        totalVolume: totalVolume,
                        units: state.units,
                        isH3O: true,
                        setPH: onPHChanged!,
                      );
                    }
                  : null,
            ),
          ),
          // OH right
          Positioned(
            left: leftG + scaleWidth + indicatorXOffset,
            top: (yOh - GraphIndicator.bgH / 2).clamp(0.0, height),
            child: GraphIndicator(
              species: GraphIndicatorSpecies.oh,
              value: oh,
              side: GraphIndicatorSide.right,
              anchorY: yOh,
              interactive: canDrag,
              onVerticalDrag: canDrag
                  ? (d) {
                      final newY =
                          (yOh + d.delta.dy).clamp(0.0, height).toDouble();
                      GraphIndicatorDrag.apply(
                        yView: newY,
                        scaleHeight: height,
                        totalVolume: totalVolume,
                        units: state.units,
                        isH3O: false,
                        setPH: onPHChanged!,
                      );
                    }
                  : null,
            ),
          ),
          // H2O right (never interactive)
          Positioned(
            left: leftG + scaleWidth + indicatorXOffset,
            top: (yH2o - GraphIndicator.bgH / 2).clamp(0.0, height),
            child: GraphIndicator(
              species: GraphIndicatorSpecies.h2o,
              value: h2o,
              side: GraphIndicatorSide.right,
              anchorY: yH2o,
            ),
          ),
          if (!isLog)
            Positioned(
              right: 0,
              top: height / 2 - 40,
              child: Column(
                children: [
                  _ZoomBtn(label: '+', onTap: state.zoomIn),
                  const SizedBox(height: 8),
                  _ZoomBtn(label: '−', onTap: state.zoomOut),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GraphControlPanel extends StatelessWidget {
  const _GraphControlPanel({required this.state});

  final GraphViewState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: PhScaleColors.panelFill,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AbSwitch(
              leftLabel: 'Concentration\n(mol/L)',
              rightLabel: 'Quantity\n(mol)',
              leftSelected: state.units == GraphUnits.molesPerLiter,
              onLeft: () => state.units = GraphUnits.molesPerLiter,
              onRight: () => state.units = GraphUnits.moles,
            ),
          ),
          const SizedBox(width: 8),
          _ExpandButton(
            expanded: state.expanded,
            onPressed: () => state.setExpanded(!state.expanded),
          ),
        ],
      ),
    );
  }
}

class _ScaleSwitch extends StatelessWidget {
  const _ScaleSwitch({required this.state});

  final GraphViewState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: _AbSwitch(
        leftLabel: 'Logarithmic',
        rightLabel: 'Linear',
        leftSelected: state.scale == GraphScale.logarithmic,
        onLeft: () => state.scale = GraphScale.logarithmic,
        onRight: () => state.scale = GraphScale.linear,
      ),
    );
  }
}

class _AbSwitch extends StatelessWidget {
  const _AbSwitch({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    TextStyle style(bool on) => PhScaleFonts.abSwitch.copyWith(
          color: on ? Colors.black : Colors.black38,
          height: 1.15,
          fontSize: 12,
        );
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: onLeft,
            child: Text(
              leftLabel,
              style: style(leftSelected),
              textAlign: TextAlign.right,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: leftSelected ? onRight : onLeft,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black54),
              ),
              alignment:
                  leftSelected ? Alignment.centerLeft : Alignment.centerRight,
              padding: const EdgeInsets.all(2),
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF0575B1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: GestureDetector(
            onTap: onRight,
            child: Text(
              rightLabel,
              style: style(!leftSelected),
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('ph_scale_graph_expand'),
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: PhScaleConstants.checkboxWidth + 9,
        height: PhScaleConstants.checkboxWidth + 9,
        decoration: BoxDecoration(
          color: const Color(0xFFF79722),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black54),
        ),
        alignment: Alignment.center,
        child: Text(
          expanded ? '−' : '+',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PhScaleColors.panelFill,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
