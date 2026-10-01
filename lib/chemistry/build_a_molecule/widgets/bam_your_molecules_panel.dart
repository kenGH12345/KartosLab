import 'package:flutter/material.dart';

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
                  child: Material(
                    color: hasAnyCollected
                        ? Colors.orange
                        : Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      onTap: hasAnyCollected
                          ? controller.resetCollection
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Icon(Icons.refresh, size: 22),
                      ),
                    ),
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
