/// 半衰期数轴基础视图：Painter（轴/刻度/指针）+ 上标标签。
///
/// 只接收 [HalfLifeNumberLineReading]。指针位置由 [HalfLifePointerAnimator]
/// 在 model X 上插值。读数条立即显示 Reading，不跟指针动画。
/// 不含 less/more stable、info。
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../model/half_life_number_line.dart';
import '../model/half_life_pointer_animator.dart';
import '../painters/half_life_number_line_painter.dart';
import 'half_life_number_line_readout.dart';

class HalfLifeNumberLineView extends StatefulWidget {
  const HalfLifeNumberLineView({
    super.key,
    required this.reading,
    this.readoutLeftInset = 0,
  });

  final HalfLifeNumberLineReading reading;

  /// Decay 屏为 info 按钮预留。[已确认] indent+maxHeight+10；Dialog 内为 0
  final double readoutLeftInset;

  static const double height = HalfLifeNumberLineMetrics.readoutBandHeight +
      HalfLifeNumberLineMetrics.axisY +
      HalfLifeNumberLineMetrics.tickExtent / 2 +
      HalfLifeNumberLineMetrics.labelFontSize * 1.4;

  @override
  State<HalfLifeNumberLineView> createState() => _HalfLifeNumberLineViewState();
}

class _HalfLifeNumberLineViewState extends State<HalfLifeNumberLineView>
    with SingleTickerProviderStateMixin {
  final HalfLifePointerAnimator _animator = HalfLifePointerAnimator();
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animator.setTarget(widget.reading);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant HalfLifeNumberLineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reading != widget.reading) {
      _animator.setTarget(widget.reading);
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0) return;
    _animator.tick(dt);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _animator.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = _animator.pose;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : HalfLifeChartTransform.originalViewWidth;
        const axisY = HalfLifeNumberLineMetrics.axisY;
        const tickBottom =
            axisY + HalfLifeNumberLineMetrics.tickExtent / 2;
        const axisH = HalfLifeNumberLineView.height -
            HalfLifeNumberLineMetrics.readoutBandHeight;
        return SizedBox(
          key: const ValueKey('ban_half_life_number_line'),
          width: w,
          height: HalfLifeNumberLineView.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: HalfLifeNumberLineMetrics.readoutBandHeight,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: widget.readoutLeftInset),
                    child: HalfLifeNumberLineReadout(reading: widget.reading),
                  ),
                ),
              ),
              SizedBox(
                width: w,
                height: axisH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(w, axisH),
                      painter: HalfLifeNumberLinePainter(
                        reading: widget.reading,
                        displayExponent: pose.exponent,
                        displayRotation: pose.rotation,
                      ),
                    ),
                    for (final e in HalfLifeNumberLine.tickExponents())
                      Positioned(
                        key: ValueKey('ban_half_life_tick_$e'),
                        left:
                            HalfLifeChartTransform.modelToViewX(e.toDouble(), w),
                        top: tickBottom,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: _TickLabel(exponent: e),
                        ),
                      ),
                    if (pose.visible)
                      Positioned(
                        key: const ValueKey('ban_half_life_pointer'),
                        left: HalfLifeChartTransform.modelToViewX(
                            pose.exponent, w),
                        top: axisY,
                        child: const SizedBox(width: 1, height: 1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TickLabel extends StatelessWidget {
  const _TickLabel({required this.exponent});

  final int exponent;

  @override
  Widget build(BuildContext context) {
    const baseSize = HalfLifeNumberLineMetrics.labelFontSize;
    const color = Color(0xFF000000);
    if (exponent == 0) {
      return const Text(
        '1',
        style: TextStyle(fontSize: baseSize, color: color, height: 1),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '10',
            style: TextStyle(fontSize: baseSize, color: color, height: 1),
          ),
          TextSpan(
            text: '$exponent',
            style: const TextStyle(
              fontSize: baseSize * HalfLifeNumberLineMetrics.superscriptScale,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
