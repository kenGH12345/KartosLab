import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

/// PhET `BlockNode` — three textured faces with perspective Path geometry.
///
/// Coordinate chain (EFACIntroScreenView + BlockNode.ts):
/// 1. `translation = mvt.modelToViewPosition(block.position)`
/// 2. Local (0,0) = untransformed bottom-center
///    `Rectangle(-w/2, 0, w, h)` after scale(s,−s) → x∈[-face/2,face/2], y∈[-face,0]
/// 3. Front corners = that rect + `blockFaceOffset`
///    (`Vector2(-edge/2,0).rotated(-PERSPECTIVE_ANGLE)`)
///
/// Do **not** anchor the painted front bottom to MVT — that skips step 2.
class BlockNodeWidget extends StatefulWidget {
  const BlockNodeWidget({
    super.key,
    required this.block,
    required this.size,
    required this.energyChunksVisible,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanStart,
  });

  final ThermalBlock block;

  /// Face size in view px = `mvt.modelToViewDelta(surfaceWidth)`.
  final double size;
  final bool energyChunksVisible;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragStartCallback? onPanStart;

  @override
  State<BlockNodeWidget> createState() => _BlockNodeWidgetState();

  /// `BLOCK_PERSPECTIVE_EDGE_PROPORTION`
  static double get perspectiveEdgeProportion {
    final zx = EfacConstants.zToXOffsetMultiplier;
    final zy = EfacConstants.zToYOffsetMultiplier;
    return math.sqrt(zx * zx + zy * zy);
  }

  /// `BLOCK_PERSPECTIVE_ANGLE`
  static double get perspectiveAngle => math.atan2(
        -EfacConstants.zToYOffsetMultiplier,
        -EfacConstants.zToXOffsetMultiplier,
      );

  /// PhET `blockFaceOffset` in view px (Y-down).
  static Offset blockFaceOffset(double faceSize) {
    final edge = faceSize * perspectiveEdgeProportion;
    final angle = perspectiveAngle;
    // Vector2(-edge/2, 0).rotated(-PERSPECTIVE_ANGLE)
    return Offset(
      -edge / 2 * math.cos(-angle),
      -edge / 2 * math.sin(-angle),
    );
  }

  /// PhET `backCornersOffset` in view px (Y-down).
  static Offset backCornersOffset(double faceSize) {
    final edge = faceSize * perspectiveEdgeProportion;
    final angle = perspectiveAngle;
    return Offset(
      edge * math.cos(-angle),
      edge * math.sin(-angle),
    );
  }

  /// Canvas shift so PhET local (0,0) maps to this point in the paint buffer.
  ///
  /// PhET local: x∈[-face/2,face/2]+offsets, y∈[-face,0]+offsets (can be <0).
  static Offset canvasOrigin(double faceSize) {
    final face = blockFaceOffset(faceSize);
    final back = backCornersOffset(faceSize);
    final half = faceSize / 2;
    final xs = <double>[
      -half + face.dx,
      half + face.dx,
      -half + face.dx + back.dx,
      half + face.dx + back.dx,
      0, // node origin
    ];
    final ys = <double>[
      -faceSize + face.dy,
      0 + face.dy,
      -faceSize + face.dy + back.dy,
      0 + face.dy + back.dy,
      0,
    ];
    const pad = 2.0;
    return Offset(
      -xs.reduce(math.min) + pad,
      -ys.reduce(math.min) + pad,
    );
  }

  /// Widget top-left → PhET node origin (0,0). Use with
  /// `Positioned(left: mvt.x - dx, top: mvt.y - dy)`.
  static Offset localOriginFromTopLeft(double faceSize) =>
      canvasOrigin(faceSize);

  static Size paintSizeFor(double faceSize) {
    final origin = canvasOrigin(faceSize);
    final face = blockFaceOffset(faceSize);
    final back = backCornersOffset(faceSize);
    final half = faceSize / 2;
    final pts = <Offset>[
      Offset(-half, -faceSize) + face,
      Offset(half, -faceSize) + face,
      Offset(-half, 0) + face,
      Offset(half, 0) + face,
      Offset(-half, -faceSize) + face + back,
      Offset(half, -faceSize) + face + back,
      Offset(-half, 0) + face + back,
      Offset(half, 0) + face + back,
      Offset.zero,
    ];
    final maxX = pts.map((p) => p.dx + origin.dx).reduce(math.max);
    final maxY = pts.map((p) => p.dy + origin.dy).reduce(math.max);
    return Size(maxX + 2, maxY + 2);
  }
}

class _BlockNodeWidgetState extends State<BlockNodeWidget> {
  ui.Image? _front;
  ui.Image? _right;
  ui.Image? _top;

  @override
  void initState() {
    super.initState();
    _loadTextures();
  }

  @override
  void didUpdateWidget(covariant BlockNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.blockType != widget.block.blockType) {
      _loadTextures();
    }
  }

  Future<void> _loadTextures() async {
    final isIron = widget.block.blockType == BlockType.iron;
    final frontPath =
        isIron ? EfacAssets.ironTextureFront : EfacAssets.brickTextureFront;
    final rightPath =
        isIron ? EfacAssets.ironTextureRight : EfacAssets.brickTextureRight;
    final topPath =
        isIron ? EfacAssets.ironTextureTop : EfacAssets.brickTextureTop;
    final results = await Future.wait([
      _decode(frontPath),
      _decode(rightPath),
      _decode(topPath),
    ]);
    if (!mounted) return;
    setState(() {
      _front = results[0];
      _right = results[1];
      _top = results[2];
    });
  }

  Future<ui.Image> _decode(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    final isIron = widget.block.blockType == BlockType.iron;
    final label = isIron ? EfacStrings.iron : EfacStrings.brick;
    final paintSize = BlockNodeWidget.paintSizeFor(widget.size);
    final canvasOrigin = BlockNodeWidget.canvasOrigin(widget.size);

    // Label center on front face (BlockNode.ts), not below the widget.
    final face = BlockNodeWidget.blockFaceOffset(widget.size);
    final labelCenter = canvasOrigin +
        Offset(0, -widget.size / 2) +
        face;

    return GestureDetector(
      onPanStart: widget.onPanStart,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      child: SizedBox(
        width: paintSize.width,
        height: paintSize.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: widget.energyChunksVisible ? 0.55 : 1,
                child: CustomPaint(
                  painter: _BlockPerspectivePainter(
                    faceSize: widget.size,
                    canvasOrigin: canvasOrigin,
                    front: _front,
                    side: _right,
                    top: _top,
                    edgeColor: isIron
                        ? const Color(0xFF6A6A6A)
                        : const Color(0xFF8B4513),
                  ),
                ),
              ),
            ),
            Positioned(
              left: labelCenter.dx - 40,
              top: labelCenter.dy - 6,
              width: 80,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, height: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints in PhET BlockNode local space, shifted by [canvasOrigin].
class _BlockPerspectivePainter extends CustomPainter {
  _BlockPerspectivePainter({
    required this.faceSize,
    required this.canvasOrigin,
    required this.front,
    required this.side,
    required this.top,
    required this.edgeColor,
  });

  final double faceSize;
  final Offset canvasOrigin;
  final ui.Image? front;
  final ui.Image? side;
  final ui.Image? top;
  final Color edgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final face = BlockNodeWidget.blockFaceOffset(faceSize);
    final back = BlockNodeWidget.backCornersOffset(faceSize);
    final half = faceSize / 2;

    Offset p(double x, double y) => Offset(x, y) + face + canvasOrigin;

    // blockRect corners (Y-down PhET local) + faceOffset, then canvas shift.
    final lowerLeftFront = p(-half, 0);
    final lowerRightFront = p(half, 0);
    final upperRightFront = p(half, -faceSize);
    final upperLeftFront = p(-half, -faceSize);
    final upperLeftBack = upperLeftFront + back;
    final upperRightBack = upperRightFront + back;
    final lowerRightBack = lowerRightFront + back;
    final lowerLeftBack = lowerLeftFront + back;

    Path quad(Offset a, Offset b, Offset c, Offset d) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();

    // Back edges (visible when transparent / EC on) — BlockNode.ts
    final backEdges = Path()
      ..moveTo(lowerLeftBack.dx, lowerLeftBack.dy)
      ..lineTo(lowerRightBack.dx, lowerRightBack.dy)
      ..moveTo(lowerLeftBack.dx, lowerLeftBack.dy)
      ..lineTo(lowerLeftFront.dx, lowerLeftFront.dy)
      ..moveTo(lowerLeftBack.dx, lowerLeftBack.dy)
      ..lineTo(upperLeftBack.dx, upperLeftBack.dy);

    final topShape =
        quad(upperLeftFront, upperLeftBack, upperRightBack, upperRightFront);
    final sideShape =
        quad(upperRightBack, lowerRightBack, lowerRightFront, upperRightFront);
    final faceShape =
        quad(upperRightFront, upperLeftFront, lowerLeftFront, lowerRightFront);

    canvas.drawPath(
      backEdges,
      Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    _drawTextured(canvas, topShape, top);
    _drawTextured(canvas, sideShape, side);
    _drawTextured(canvas, faceShape, front);

    final outline = Path()
      ..moveTo(upperLeftBack.dx, upperLeftBack.dy)
      ..lineTo(upperRightBack.dx, upperRightBack.dy)
      ..lineTo(upperRightFront.dx, upperRightFront.dy)
      ..lineTo(upperLeftFront.dx, upperLeftFront.dy)
      ..lineTo(upperLeftBack.dx, upperLeftBack.dy)
      ..moveTo(upperLeftFront.dx, upperLeftFront.dy)
      ..lineTo(lowerLeftFront.dx, lowerLeftFront.dy)
      ..lineTo(lowerRightFront.dx, lowerRightFront.dy)
      ..lineTo(upperRightFront.dx, upperRightFront.dy)
      ..moveTo(lowerRightFront.dx, lowerRightFront.dy)
      ..lineTo(lowerRightBack.dx, lowerRightBack.dy)
      ..lineTo(upperRightBack.dx, upperRightBack.dy);

    canvas.drawPath(
      outline,
      Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawTextured(Canvas canvas, Path shape, ui.Image? image) {
    canvas.save();
    canvas.clipPath(shape);
    final bounds = shape.getBounds();
    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: bounds,
        image: image,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      );
    } else {
      canvas.drawPath(shape, Paint()..color = Colors.grey.shade400);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlockPerspectivePainter oldDelegate) =>
      oldDelegate.front != front ||
      oldDelegate.side != side ||
      oldDelegate.top != top ||
      oldDelegate.faceSize != faceSize ||
      oldDelegate.canvasOrigin != canvasOrigin;
}
