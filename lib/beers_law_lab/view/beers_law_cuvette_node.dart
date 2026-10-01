import 'package:flutter/material.dart';

import '../model/beers_law_model.dart';
import 'beers_law_layout.dart';
import 'beers_law_mvt.dart';

/// PhET `CuvetteNode` — glass + fluid + orange double-arrow width handle.
class BeersLawCuvetteNode extends StatefulWidget {
  const BeersLawCuvetteNode({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  State<BeersLawCuvetteNode> createState() => _BeersLawCuvetteNodeState();
}

class _BeersLawCuvetteNodeState extends State<BeersLawCuvetteNode> {
  double? _startViewX;
  double? _startWidthCm;
  bool _highlight = false;

  BeersLawMvt get mvt => widget.mvt;
  BeersLawModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
    final pos = mvt.modelToView(model.cuvette.position);
    final w = mvt.modelToViewDelta(model.cuvette.width);
    final h = mvt.modelToViewDelta(model.cuvette.height);
    final fluidH = h * BeersLawLayout.solutionPercentFull;
    final fluidColor = model.solution.fluidColor
        .withValues(alpha: BeersLawLayout.solutionAlpha);
    final arrowColor = _highlight
        ? BeersLawLayout.cuvetteArrowHighlight
        : BeersLawLayout.cuvetteArrowFill;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: SizedBox(
        width: w + BeersLawLayout.arrowLength / 2 + 20,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Solution (bottom-aligned, 92% full)
            Positioned(
              left: 0,
              bottom: 0,
              width: w,
              height: fluidH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fluidColor,
                  border: Border.all(
                    color: BeersLawLayout.solutionStroke,
                    width: 0.5,
                  ),
                ),
              ),
            ),
            // Glass U-shape (open top)
            CustomPaint(
              size: Size(w, h),
              painter: _CuvetteGlassPainter(),
            ),
            // Width arrow at right bottom
            Positioned(
              left: w - BeersLawLayout.arrowLength / 2,
              bottom: 10,
              child: Semantics(
                label: 'Cuvette width',
                slider: true,
                value: '${model.cuvette.width.toStringAsFixed(2)} cm',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) {
                    _startViewX = d.globalPosition.dx;
                    _startWidthCm = model.cuvette.width;
                    setState(() => _highlight = true);
                  },
                  onPanUpdate: (d) {
                    if (_startViewX == null || _startWidthCm == null) return;
                    final deltaPx = d.globalPosition.dx - _startViewX!;
                    final deltaCm = mvt.viewToModelDelta(deltaPx);
                    model.setCuvetteWidth(_startWidthCm! + deltaCm);
                  },
                  onPanEnd: (_) {
                    model.snapCuvetteWidth();
                    setState(() => _highlight = false);
                  },
                  onPanCancel: () => setState(() => _highlight = false),
                  child: CustomPaint(
                    size: const Size(
                      BeersLawLayout.arrowLength,
                      BeersLawLayout.arrowHeadHeight,
                    ),
                    painter: _DoubleArrowPainter(color: arrowColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuvetteGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DoubleArrowPainter extends CustomPainter {
  _DoubleArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final path = Path();
    final hw = BeersLawLayout.arrowHeadWidth / 2;
    final hh = BeersLawLayout.arrowHeadHeight / 2;
    final tw = BeersLawLayout.arrowTailWidth / 2;
    // left head
    path.moveTo(0, cy);
    path.lineTo(hw, cy - hh);
    path.lineTo(hw, cy - tw);
    path.lineTo(size.width - hw, cy - tw);
    path.lineTo(size.width - hw, cy - hh);
    path.lineTo(size.width, cy);
    path.lineTo(size.width - hw, cy + hh);
    path.lineTo(size.width - hw, cy + tw);
    path.lineTo(hw, cy + tw);
    path.lineTo(hw, cy + hh);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DoubleArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
