import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../data/bam_strings.dart';
import '../model/bam_collection_box.dart';
import 'bam_molecule_3d_dialog.dart';
import 'bam_molecule_thumbnail.dart';

/// Right "Your Molecules" panel. Ported from CollectionPanel + CollectionBoxNode.
class BamYourMoleculesPanel extends StatelessWidget {
  const BamYourMoleculesPanel({super.key, required this.controller});

  final BamController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final boxes = controller.collection.collectionBoxes;
        if (boxes.isEmpty) return const SizedBox.shrink();

        final isSingle = !controller.model.isMultipleCollection;
        final collectionIndex = controller.model.currentIndex + 1;
        final title = BamStrings.get('yourMolecules', 'Your Molecules');
        final collectionLabel = BamStrings.fillIn(
          BamStrings.get('collectionPattern', 'Collection {{number}}'),
          {'number': collectionIndex},
        );
        final nextLabel = BamStrings.get('nextCollection', 'Next Collection');
        final hasAnyCollected =
            boxes.any((b) => b.quantity > 0);

        return Material(
          color: BamConstants.moleculeCollectionBackground,
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      onPressed: controller.model.hasPreviousCollection()
                          ? controller.previousCollection
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Flexible(
                      child: Text(
                        collectionLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      onPressed: controller.model.hasNextCollection()
                          ? controller.nextCollection
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  children: [
                    for (final box in boxes)
                      _MoleculeCard(
                        box: box,
                        controller: controller,
                        isSingleCollectionMode: isSingle,
                      ),
                    if (controller.collection.allCollectionBoxesFilled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: controller.regenerateCollection,
                          child: Text(nextLabel),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: Center(
                  child: _BamCollectionRefreshButton(
                    onPressed: hasAnyCollected
                        ? controller.resetCollection
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoleculeCard extends StatelessWidget {
  const _MoleculeCard({
    required this.box,
    required this.controller,
    required this.isSingleCollectionMode,
  });

  final BamCollectionBox box;
  final BamController controller;
  final bool isSingleCollectionMode;

  @override
  Widget build(BuildContext context) {
    final molecule = box.moleculeType;
    final formulaFrag = molecule.getGeneralFormulaFragment();
    final full = box.isFull();
    final collected = box.quantity > 0;
    // Cue from CollectionBox.cueVisibilityProperty (model), not formula compare.
    final cue = box.feedback.cueVisible && !full;
    final blinkOn = box.feedback.borderBlinkOn;
    final borderColor = blinkOn
        ? BamConstants.moleculeCollectionBoxBorderBlink
        : full
            ? BamConstants.moleculeCollectionBoxHighlight
            : BamConstants.moleculeCollectionBackground;
    final borderWidth = blinkOn || full ? 4.0 : 2.0;

    final Widget header;
    if (isSingleCollectionMode) {
      header = Text(
        BamStrings.fillIn(
          BamStrings.get(
            'collectionSinglePattern',
            '{{general}} ({{display}})',
          ),
          {
            'general': formulaFrag,
            'display': molecule.getDisplayName(),
          },
        ),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      final goal = BamStrings.fillIn(
        BamStrings.get(
          'collectionMultipleGoalPattern',
          'Goal: {{number}}{{formula}}',
        ),
        {'number': box.capacity, 'formula': formulaFrag},
      );
      final have = box.quantity == 0
          ? BamStrings.get(
              'collectionMultipleQuantityEmpty',
              'You have: (empty)',
            )
          : BamStrings.fillIn(
              BamStrings.get(
                'collectionMultipleQuantityPattern',
                'You have: {{number}}{{formula}}',
              ),
              {'number': box.quantity, 'formula': formulaFrag},
            );
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(have, style: const TextStyle(fontSize: 11)),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 4),
          Row(
            children: [
              // ArrowNode cue: left of blackBox, fill blue, points at preview.
              if (cue)
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: _CollectionCueArrow(),
                ),
              Expanded(
                child: Material(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: borderColor, width: borderWidth),
                    borderRadius:
                        BorderRadius.circular(BamConstants.cornerRadius),
                  ),
                  child: InkWell(
                    onTap: () => controller.collectIntoBox(box),
                    child: SizedBox(
                      // CollectionBoxNode blackBox height ≈ 50
                      height: 50,
                      child: Stack(
                        children: [
                          // Black region = Molecule3DNode / thumbnail container
                          // (empty until quantity > 0), not a decorative filler.
                          if (collected)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 36),
                                child: BamMoleculeThumbnail(
                                  molecule: molecule,
                                ),
                              ),
                            ),
                          if (collected)
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Material(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(3),
                                child: InkWell(
                                  onTap: () => BamMolecule3dDialog.show(
                                    context,
                                    molecule,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      BamStrings.get('threeD', '3D'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// PhET ArrowNode cue: fill blue, stroke black, points into blackBox from left.
class _CollectionCueArrow extends StatelessWidget {
  const _CollectionCueArrow();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 16),
      painter: _CueArrowPainter(),
    );
  }
}

class _CueArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// scenery-phet `RefreshButton` as used by BAM `CollectionAreaNode`:
/// `iconHeight: 20`, `xMargin: 15`, `yMargin: 5`, `baseColor: Color.ORANGE`,
/// content = sun `syncShape` (not Material `Icons.refresh`).
class _BamCollectionRefreshButton extends StatefulWidget {
  const _BamCollectionRefreshButton({this.onPressed});

  final VoidCallback? onPressed;

  /// scenery `Color.ORANGE` (`#FFA500`).
  static const Color _base = Color(0xFFFFA500);

  /// sun `js/shapes/syncShape.ts`.
  static const String _syncPath =
      'M23.82,4.64C21.27,1.74,17.57,0,13.52,0,6.84,0,1.18,4.8.01,11.29c-.08.45.26.87.71.87h2.21c.36,0,.65-.26.72-.62.85-4.74,4.96-7.89,9.87-7.89,3.05,0,5.84,1.34,7.71,3.58l-2.51,2.51c-.71.71-.21,1.93.8,1.93h7.37c.63,0,1.13-.51,1.13-1.13V3.17c0-1.01-1.22-1.52-1.93-.8l-2.28,2.28Z M4.21,24.52c2.55,2.91,6.25,4.64,10.3,4.64,6.68,0,12.34-4.8,13.51-11.29.08-.45-.26-.87-.71-.87h-2.21c-.36,0-.65.26-.72.62-.85,4.74-4.96,7.89-9.87,7.89-3.05,0-5.84-1.34-7.71-3.58l2.51-2.51c.71-.71.21-1.93-.8-1.93H1.13c-.63,0-1.13.51-1.13,1.13v7.37c0,1.01,1.22,1.52,1.93.8l2.28-2.28Z';

  static const String _syncSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28.03 29.16">'
      '<path fill="#000000" d="$_syncPath"/></svg>';

  @override
  State<_BamCollectionRefreshButton> createState() =>
      _BamCollectionRefreshButtonState();
}

class _BamCollectionRefreshButtonState
    extends State<_BamCollectionRefreshButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: Transform.scale(
          scale: _pressed ? 0.96 : 1,
          child: CustomPaint(
            painter: const _Rect3DPushPainter(_BamCollectionRefreshButton._base),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: SizedBox(
                height: 20,
                width: 20 * (28.03 / 29.16),
                child: SvgPicture.string(
                  _BamCollectionRefreshButton._syncSvg,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// sun `RectangularButton.ThreeDAppearanceStrategy` (light from upper-left).
class _Rect3DPushPainter extends CustomPainter {
  const _Rect3DPushPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    final stroke = Color.lerp(base, Colors.black, 0.4)!;
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = stroke,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(base, Colors.white, 0.55)!,
            Color.lerp(base, Colors.white, 0.2)!,
            base,
            Color.lerp(base, Colors.black, 0.22)!,
          ],
          stops: const [0.0, 0.22, 0.72, 1.0],
        ).createShader(r.outerRect),
    );
  }

  @override
  bool shouldRepaint(covariant _Rect3DPushPainter oldDelegate) =>
      oldDelegate.base != base;
}
