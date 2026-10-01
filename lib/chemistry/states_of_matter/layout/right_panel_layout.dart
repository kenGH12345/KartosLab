import 'phase_changes_scene_layout.dart';

/// PhET Phase Changes right-column geometry (`PhaseChangesScreenView`).
///
/// Stack: Molecules → Interaction Potential → Phase Diagram, with
/// [interPanelSpacing] between sections. Heights come from PhET content
/// constants rather than ad-hoc Flutter magic numbers.
class RightPanelLayout {
  RightPanelLayout._();

  static const double panelWidth = 170;
  static const double panelXInset = 15;
  static const double panelTop = 5;
  static const double interPanelSpacing = 8;

  /// Accordion title bar (expand button 12 + buttonYMargin 4×2 + text).
  static const double headerHeight = 28;

  static const double contentYMargin = 5;
  static const double contentXMargin = 6;

  /// `PotentialGraphNode` narrow (Phase Changes accordion content).
  static const double narrowGraphWidth = 135;
  static const double narrowGraphHeight = narrowGraphWidth * 0.8; // 108

  /// `PhaseDiagram` WIDTH×HEIGHT.
  static const double phaseDiagramWidth = 148;
  static const double phaseDiagramHeight = phaseDiagramWidth * 0.75; // 111

  /// Expanded Interaction Potential accordion content height (graph + margins).
  static double interactionPotentialContentHeight() =>
      narrowGraphHeight + contentYMargin * 2;

  /// Expanded Phase Diagram accordion content height.
  static double phaseDiagramContentHeight() =>
      phaseDiagramHeight + contentYMargin * 2;

  /// Max height for right accordion stack so Phase Diagram stays above Reset.
  ///
  /// `layoutH − panelTop − (resetBottom + 2×radius + gap)`.
  static double maxStackHeight() =>
      PhaseChangesSceneLayout.layoutHeight -
      panelTop -
      PhaseChangesSceneLayout.resetBottomInset -
      PhaseChangesSceneLayout.resetRadius * 2 -
      10;
}
