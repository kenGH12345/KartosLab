import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../data/bam_element.dart';
import '../data/bam_strings.dart';
import '../model/bam_atom.dart';
import '../model/bam_bucket.dart';

/// Bottom atom inventory carousel. Ported from KitPanel + KitNode (BucketFront).
///
/// Layout: prev arrow | buckets | next arrow
/// Page dots below. Counts from [BamBucket.particleList] / capacity.
class BamAtomInventory extends StatelessWidget {
  const BamAtomInventory({super.key, required this.controller});

  final BamController controller;

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
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: BamConstants.kitBackground,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: BamConstants.kitBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SizedBox(
                    height: 118,
                    child: Row(
                      children: [
                        _CarouselArrow(
                          icon: Icons.chevron_left,
                          enabled: kits.length > 1,
                          onPressed: controller.previousKit,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final bucket in kit.buckets)
                                _BucketWidget(
                                  bucket: bucket,
                                  label: elementLabel(bucket.element),
                                  onTap: () {
                                    if (bucket.particleList.isEmpty) return;
                                    final play = controller.model
                                        .collectionLayout
                                        .availablePlayAreaBounds
                                        .center;
                                    final atom = bucket.particleList.last;
                                    controller.startDragFromBucket(atom, play);
                                    controller.endDrag(play);
                                  },
                                ),
                            ],
                          ),
                        ),
                        _CarouselArrow(
                          icon: Icons.chevron_right,
                          enabled: kits.length > 1,
                          onPressed: controller.nextKit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
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
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: enabled
            ? BamConstants.kitArrowBackgroundEnabled
            : Colors.grey.shade300,
        shape: const CircleBorder(
          side: BorderSide(color: BamConstants.kitArrowBorderEnabled),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
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
    required this.bucket,
    required this.label,
    required this.onTap,
  });

  final BamBucket bucket;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = bucket.particleList.length;
    final capacity = bucket.capacity;
    return GestureDetector(
      onTap: available > 0 ? onTap : null,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 64,
              width: 88,
              child: CustomPaint(
                painter: _BucketPainter(
                  color: bucket.element.color,
                  atoms: bucket.particleList,
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$available/$capacity',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simplified BucketFront: elliptical bowl + stacked atom spheres.
class _BucketPainter extends CustomPainter {
  _BucketPainter({required this.color, required this.atoms});

  final Color color;
  final List<BamPlayAtom> atoms;

  @override
  void paint(Canvas canvas, Size size) {
    final bowl = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, size.height * 0.35, size.width - 8, size.height * 0.55),
      const Radius.circular(8),
    );
    // hole (darker top)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.38),
        width: size.width * 0.78,
        height: size.height * 0.22,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    // front face
    final front = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.white, 0.25)!,
          Color.lerp(color, Colors.black, 0.15)!,
        ],
      ).createShader(bowl.outerRect);
    canvas.drawRRect(bowl, front);
    canvas.drawRRect(
      bowl,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // atoms sitting in bucket (up to 4 visible)
    final show = atoms.take(4).toList();
    for (var i = 0; i < show.length; i++) {
      final ax = size.width * (0.32 + (i % 3) * 0.18);
      final ay = size.height * (0.42 - (i ~/ 3) * 0.12);
      final r = (show[i].covalentRadius * 0.18).clamp(6.0, 12.0);
      canvas.drawCircle(Offset(ax, ay), r, Paint()..color = show[i].element.color);
      canvas.drawCircle(
        Offset(ax, ay),
        r,
        Paint()
          ..color = Colors.black45
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BucketPainter oldDelegate) => true;
}
