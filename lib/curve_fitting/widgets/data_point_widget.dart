import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../format_number.dart';
import '../model/curve_fitting_model.dart';
import '../model/data_point.dart';
import '../transform/math_coordinate_transform.dart';

/// Interactive data point — PhET `PointNode`.
///
/// Drag updates [DataPoint] via model listeners → Fit → residuals → stats.
/// Coordinates: global → [layoutKey] local → [transform.viewToModel].
class DataPointWidget extends StatefulWidget {
  const DataPointWidget({
    super.key,
    required this.model,
    required this.point,
    required this.transform,
    required this.layoutKey,
    this.onBumpOut,
  });

  final CurveFittingModel model;
  final DataPoint point;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final VoidCallback? onBumpOut;

  @override
  State<DataPointWidget> createState() => _DataPointWidgetState();
}

class _DataPointWidgetState extends State<DataPointWidget>
    with SingleTickerProviderStateMixin {
  bool _halo = false;
  bool _deltaHalo = false;
  Ticker? _returnTicker;
  double _animFromX = 0;
  double _animFromY = 0;
  double _animElapsed = 0;
  double _animDuration = 0;
  bool _wasDragging = false;

  /// True while this widget owns an in-progress pan (vs bucket-started drag).
  bool _owningDrag = false;

  DataPoint get point => widget.point;
  CurveFittingModel get model => widget.model;
  MathCoordinateTransform get transform => widget.transform;

  @override
  void initState() {
    super.initState();
    _wasDragging = point.dragging;
    point.addListener(_onPointNotify);
  }

  @override
  void dispose() {
    _returnTicker?.dispose();
    point.removeListener(_onPointNotify);
    super.dispose();
  }

  void _onPointNotify() {
    if (_wasDragging && !point.dragging && !point.isInsideGraph) {
      _startReturnAnimation();
    }
    _wasDragging = point.dragging;
    if (mounted) setState(() {});
  }

  void _startReturnAnimation() {
    if (point.animationActive) return;
    final dx = point.x - point.initialX;
    final dy = point.y - point.initialY;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= 1e-9) {
      model.removePoint(point);
      return;
    }
    point.animationActive = true;
    model.pointUpdated();
    _animFromX = point.x;
    _animFromY = point.y;
    _animElapsed = 0;
    _animDuration = dist / CurveFittingConstants.animationSpeed;
    _returnTicker?.dispose();
    _returnTicker = createTicker((elapsed) {
      _animElapsed = elapsed.inMicroseconds / 1e6;
      final t = (_animElapsed / _animDuration).clamp(0.0, 1.0);
      point.setPosition(
        _animFromX + (point.initialX - _animFromX) * t,
        _animFromY + (point.initialY - _animFromY) * t,
      );
      if (t >= 1) {
        _returnTicker?.stop();
        _returnTicker?.dispose();
        _returnTicker = null;
        point.animationActive = false;
        model.removePoint(point);
      }
    })
      ..start();
  }

  Offset? _layoutLocal(Offset global) {
    final box =
        widget.layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  void _onDragEnd() {
    _owningDrag = false;
    point.setDragging(false);
    model.pointUpdated();
    widget.onBumpOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    final center = transform.modelToView(Offset(point.x, point.y));
    final deltaView = transform.modelToViewDeltaY(point.delta).abs();
    final r = CurveFittingConstants.pointRadius;
    final hitPad = CurveFittingConstants.pointHitDilation;
    final hitR = r + hitPad;
    final barColor = model.residualsVisible
        ? CurveFittingColors.lightGray
        : CurveFittingColors.blue;
    final showCentral = !model.residualsVisible;
    final showValues = model.valuesVisible && point.isInsideGraph;

    final boxH = math.max(deltaView * 2 + 24, hitR * 4);
    final boxW = 120.0;

    // While bucket owns the drag, this widget still paints but must not
    // compete for the same gesture.
    final absorbSelf = point.dragging && !_owningDrag;

    return Positioned(
      left: center.dx - boxW / 2,
      top: center.dy - boxH / 2,
      width: boxW,
      height: boxH,
      child: IgnorePointer(
        ignoring: absorbSelf || point.animationActive,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (showCentral)
              Positioned(
                left: boxW / 2 - 0.5,
                top: boxH / 2 - deltaView,
                child: IgnorePointer(
                  child: Container(
                    width: 1,
                    height: deltaView * 2,
                    color: barColor,
                  ),
                ),
              ),
            _errorBar(
              top: boxH / 2 - deltaView - 1,
              color: barColor,
              onVerticalDrag: (dyView) {
                final modelDy = transform.viewToModelDeltaY(dyView);
                final next = (point.delta - modelDy).clamp(
                  CurveFittingConstants.minDelta,
                  CurveFittingConstants.maxDelta,
                );
                point.delta = next;
                model.pointUpdated();
              },
            ),
            _errorBar(
              top: boxH / 2 + deltaView - 1,
              color: barColor,
              onVerticalDrag: (dyView) {
                final modelDy = transform.viewToModelDeltaY(dyView);
                final next = (point.delta + modelDy).clamp(
                  CurveFittingConstants.minDelta,
                  CurveFittingConstants.maxDelta,
                );
                point.delta = next;
                model.pointUpdated();
              },
            ),
            if (_halo)
              Positioned(
                left: boxW / 2 - r * 1.75,
                top: boxH / 2 - r * 1.75,
                child: IgnorePointer(
                  child: Container(
                    width: r * 3.5,
                    height: r * 3.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          CurveFittingColors.pointFill.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            // Point body — hit = visual radius + PhET dilation(5).
            // Use [Listener] (not GestureDetector) so point.notify/setState
            // during drag cannot cancel the pointer via the gesture arena.
            Positioned(
              left: boxW / 2 - hitR,
              top: boxH / 2 - hitR,
              width: hitR * 2,
              height: hitR * 2,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  if (point.animationActive) return;
                  _owningDrag = true;
                  point.setDragging(true);
                  setState(() => _halo = true);
                },
                onPointerMove: (e) {
                  if (!point.dragging || !_owningDrag) return;
                  final local = _layoutLocal(e.position);
                  if (local == null) return;
                  final m = transform.viewToModel(local);
                  point.setPosition(m.dx, m.dy);
                },
                onPointerUp: (_) {
                  setState(() => _halo = false);
                  _onDragEnd();
                },
                onPointerCancel: (_) {
                  setState(() => _halo = false);
                  _onDragEnd();
                },
                child: Center(
                  child: Container(
                    width: r * 2,
                    height: r * 2,
                    decoration: BoxDecoration(
                      color: CurveFittingColors.pointFill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CurveFittingColors.pointStroke,
                        width: CurveFittingConstants.pointLineWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showValues) ...[
              Positioned(
                left: boxW / 2 + r + 4,
                top: boxH / 2 - 10,
                child: IgnorePointer(
                  child: _ValueChip(
                    text: CurveFittingStrings.pointCoordinatesPattern(
                      xCoordinate: toFixed(point.x, 1),
                      yCoordinate: toFixed(point.y, 1),
                    ),
                    fill: CurveFittingColors.pointFill.withValues(alpha: 0.75),
                  ),
                ),
              ),
              Positioned(
                left: boxW / 2 + 14,
                top: boxH / 2 - deltaView - 18,
                child: IgnorePointer(
                  child: _ValueChip(
                    text: CurveFittingStrings.deltaEqualsPattern(
                      y: CurveFittingStrings.ySymbol,
                      deltaValue: toFixed(point.delta, 1),
                    ),
                    fill: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorBar({
    required double top,
    required Color color,
    required void Function(double dyView) onVerticalDrag,
  }) {
    return Positioned(
      left: 50,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => setState(() => _deltaHalo = true),
        onPanUpdate: (d) => onVerticalDrag(d.delta.dy),
        onPanEnd: (_) => setState(() => _deltaHalo = false),
        child: Container(
          width: 20 + 2 * CurveFittingConstants.pointHitDilation,
          height: 4 + 2 * CurveFittingConstants.pointHitDilation,
          alignment: Alignment.center,
          child: Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
              boxShadow: _deltaHalo
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.text, required this.fill});

  final String text;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
