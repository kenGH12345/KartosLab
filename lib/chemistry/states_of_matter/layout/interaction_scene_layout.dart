import '../transform/som_coordinate_transform.dart';
import '../transform/som_interaction_transform.dart';

/// PhET `AtomicInteractionsScreenView` layout anchors (logical 834×504).
class InteractionSceneLayout {
  InteractionSceneLayout._();

  static const double inset = 15;
  static const double panelWidth = 209;
  static const double maxTextWidth = 80;

  /// PhET `PUSH_PIN_WIDTH` — scale = width / intrinsic.
  static const double pushPinWidth = 20;

  /// PhET `HandNode.WIDTH` (scenery-phet `hand.png`).
  static const double handWidth = 80;

  /// Graph left = MVT(0) + graphXOffset (SoM basic, no heterogeneous zoom).
  static const double graphXOffset = -31;
  static const double graphTopExtra = 5;

  /// PhET `PotentialGraphNode` wide: 350 × (350×0.75).
  static const double graphWidth = 350;
  static const double graphHeight = graphWidth * 0.75; // 262.5

  static const double resetRadius = 17;
  static const double resetSideInset = 15;
  static const double resetBottomInset = 5;

  /// PhET `ParticleNode.OVERLAP_ENLARGEMENT_FACTOR`.
  static const double particleOverlapFactor = 1.25;

  /// Return Atom: left = 6×INSET, bottom = layoutBottom − 2×INSET.
  static const double returnAtomLeft = inset * 6;
  static const double returnAtomBottomInset = inset * 2;

  /// TimeControl: centerX = layoutCenterX + 20, bottom = layoutBottom − 14.
  static const double timeControlCenterXOffset = 20;
  static const double timeControlBottomInset = 14;

  static double graphLeft() =>
      SomInteractionTransform.originX + graphXOffset;

  static double atomsPanelRight() =>
      SomCoordinateTransform.layoutBoundsWidth - inset;

  static const double layoutWidth = SomCoordinateTransform.layoutBoundsWidth;
  static const double layoutHeight = SomCoordinateTransform.layoutBoundsHeight;
}
