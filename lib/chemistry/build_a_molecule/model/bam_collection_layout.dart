import 'dart:ui' show Offset, Rect;

import '../bam_constants.dart';

/// Play-area / kit-area bounds. Ported from CollectionLayout.ts.
class BamCollectionLayout {
  BamCollectionLayout({required this.hasCollectionPanel}) {
    const kitHeight = 550.0;
    final availableWidth =
        BamConstants.modelSize.width - 2 * BamConstants.modelPadding;
    final halfWidth = availableWidth / 2;
    final kitBottom =
        -BamConstants.modelSize.height / 2 + BamConstants.modelPadding;
    final kitTop = kitBottom + kitHeight;
    final kitAvailableWidth = hasCollectionPanel ? 0.75 : 1.0;

    availableKitBounds = Rect.fromLTWH(
      -halfWidth,
      kitBottom,
      availableWidth * kitAvailableWidth,
      kitHeight,
    );

    availablePlayAreaBounds = Rect.fromLTWH(
      -BamConstants.modelSize.width / 2,
      kitTop,
      availableKitBounds.width + BamConstants.modelPadding * 2,
      BamConstants.modelSize.height / 2 - kitTop,
    );
  }

  final bool hasCollectionPanel;
  late final Rect availableKitBounds;
  late final Rect availablePlayAreaBounds;

  bool containsPlayPoint(Offset point) =>
      availablePlayAreaBounds.contains(point);

  bool isInKitArea(Offset point) => availableKitBounds.contains(point);
}
