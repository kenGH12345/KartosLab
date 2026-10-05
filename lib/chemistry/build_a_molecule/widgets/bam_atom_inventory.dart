import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../data/bam_element.dart';
import '../data/bam_strings.dart';
import '../model/bam_atom.dart';
import '../model/bam_bucket.dart';
import '../painters/bam_atom_sphere_painter.dart';

/// Bottom atom inventory carousel. Ported from KitPanel + KitNode (BucketFront).
class BamAtomInventory extends StatelessWidget {
  const BamAtomInventory({
    super.key,
    required this.controller,
    required this.onBucketDragStart,
  });

  final BamController controller;
  final void Function(BamPlayAtom atom, Offset globalPosition) onBucketDragStart;

  static String elementLabel(BamElement element) {
    const keys = {
      'H': 'hydrogen',
      'O': 'oxygen',
      'C': 'carbon',
      'N': 'nitrogen',
      'Cl': 'chlorine',
      'F': 'fluorine',
      'B': 'boron',
      'Si': 'silicon',
      'S': 'sulphur',
      'P': 'phosphorus',
      'Br': 'bromine',
      'I': 'iodine',
    };
    final key = keys[element.symbol];
    if (key == null) return element.symbol;
    return BamStrings.get(key, element.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final kit = controller.kit;
        final kits = controller.collection.kits;
        if (kit == null) return const SizedBox.shrink();
        final index = kits.indexOf(kit);

        return ColoredBox(
          color: BamConstants.playAreaBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
            child: Column(
              children: [
                Expanded(
                  child: Material(
                    color: BamConstants.kitBackground,
                    elevation: 2,
                    clipBehavior: Clip.none,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: BamConstants.kitBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _CarouselArrow(
                          pointingLeft: true,
                          enabled: kits.length > 1,
                          onPressed: controller.previousKit,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < kit.buckets.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                                _BucketWidget(
                                  key: ValueKey(
                                    'bam_bucket_${kit.buckets[i].element.symbol}',
                                  ),
                                  bucket: kit.buckets[i],
                                  label: elementLabel(kit.buckets[i].element),
                                  onDragStart: onBucketDragStart,
                                  draggingFromBucket:
                                      controller.draggingFromBucket,
                                ),
                              ],
                            ],
                          ),
                        ),
                        _CarouselArrow(
                          pointingLeft: false,
                          enabled: kits.length > 1,
                          onPressed: controller.nextKit,
                        ),
                      ],
                    ),
                  ),
                ),
                _PageDots(count: kits.length, index: index),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.pointingLeft,
    required this.enabled,
    required this.onPressed,
  });

  final bool pointingLeft;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: SizedBox(
        width: 28,
        height: 48,
        child: CustomPaint(
          painter: _ChevronPainter(pointingLeft: pointingLeft),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.pointingLeft});

  final bool pointingLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final dx = pointingLeft ? -7.0 : 7.0;
    final path = Path()
      ..moveTo(c.dx - dx * 0.15, c.dy - 8)
      ..lineTo(c.dx + dx, c.dy)
      ..lineTo(c.dx - dx * 0.15, c.dy + 8);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6A6A6A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.pointingLeft != pointingLeft;
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox(height: 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? Colors.black : Colors.white,
              border: Border.all(color: Colors.black, width: 1.2),
            ),
          ),
      ],
    );
  }
}

class _BucketWidget extends StatelessWidget {
  const _BucketWidget({
    super.key,
    required this.bucket,
    required this.label,
    required this.onDragStart,
    required this.draggingFromBucket,
  });

  final BamBucket bucket;
  final String label;
  final void Function(BamPlayAtom atom, Offset globalPosition) onDragStart;
  final bool draggingFromBucket;

  @override
  Widget build(BuildContext context) {
    final available = bucket.particleList.length;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: available == 0 || draggingFromBucket
          ? null
          : (e) {
              final atom = bucket.particleList.last;
              onDragStart(atom, e.position);
            },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final n = bucket.particleList.length;
          final w = BamAtomSpherePainter.kitBowlWidth(
            bucket.element.covalentRadius,
            n == 0 ? 1 : n,
          );
          final h = constraints.maxHeight.isFinite && constraints.maxHeight > 8
              ? constraints.maxHeight
              : 96.0;
          return SizedBox(
            width: w,
            height: h,
            child: CustomPaint(
              size: Size(w, h),
              painter: _BucketPainter(
                color: bucket.element.color,
                atoms: bucket.particleList,
                label: label,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// scenery-phet BucketFront: wide shallow bowl + BAMBucket two-row packing.
class _BucketPainter extends CustomPainter {
  _BucketPainter({
    required this.color,
    required this.atoms,
    required this.label,
  });

  final Color color;
  final List<BamPlayAtom> atoms;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final n = atoms.length;
    final covalent = n == 0 ? 37.0 : atoms.first.covalentRadius;
    final r = BamAtomSpherePainter.bucketAtomRadius(
      covalent,
      count: n == 0 ? 1 : n,
    );
    final onBottom = n <= 2 ? n : (n / 2).floor() + 1;
    final onTop = n - onBottom;

    final bowlH = (r * 2.4 + 22).clamp(40.0, 56.0);
    final bottomY = size.height - 3;
    final topY = bottomY - bowlH;
    final holeCenter = Offset(size.width / 2, topY + 6);
    final holeRy = (bowlH * 0.22).clamp(5.0, 10.0);
    final rx = size.width / 2 - 2;
    final holeRect = Rect.fromCenter(
      center: holeCenter,
      width: size.width * 0.96,
      height: holeRy * 2,
    );

    var bowlColor = color;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness > 0.88) {
      bowlColor = const Color(0xFFE4E4E4);
    }
    final bowlHsl = HSLColor.fromColor(bowlColor);

    canvas.drawOval(holeRect, Paint()..color = const Color(0xFF2E2E2E));

    final body = Path()
      ..moveTo(holeCenter.dx - rx * 0.98, holeCenter.dy)
      ..lineTo(holeCenter.dx - rx * 0.86, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.86, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.98, holeCenter.dy)
      ..close();
    final front = Path.combine(
      PathOperation.difference,
      body,
      Path()..addOval(holeRect),
    );
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            bowlHsl
                .withLightness((bowlHsl.lightness + 0.12).clamp(0.0, 1.0))
                .toColor(),
            bowlColor,
            bowlHsl
                .withLightness((bowlHsl.lightness - 0.12).clamp(0.0, 1.0))
                .toColor(),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, topY, size.width, bowlH)),
    );

    final spacing = r * 2.05;
    void paintRow(int start, int count, double y) {
      if (count <= 0) return;
      final totalW = (count - 1) * spacing;
      final startX = holeCenter.dx - totalW / 2;
      for (var i = 0; i < count; i++) {
        final atom = atoms[start + i];
        BamAtomSpherePainter.paint(
          canvas,
          Offset(startX + i * spacing, y),
          r,
          atom.element.color,
          symbol: atom.symbol,
        );
      }
    }

    // Bottom row sits in the mouth; top row stacks like BAMBucket.
    paintRow(0, onBottom, holeCenter.dy);
    paintRow(onBottom, onTop, holeCenter.dy - r * 1.55);

    if (label.isNotEmpty) {
      final lightBowl = bowlHsl.lightness > 0.62;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: lightBowl ? const Color(0xFF4A4A4A) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: lightBowl
                ? const []
                : const [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width * 0.86);
      tp.paint(
        canvas,
        Offset(
          holeCenter.dx - tp.width / 2,
          (holeCenter.dy + bottomY) / 2 - tp.height / 2 + 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BucketPainter oldDelegate) => true;
}
