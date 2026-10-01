/// Interactivity mode — PhET `InteractivityMode`.
library;

enum InteractivityMode {
  /// Large atoms dragged between buckets and chamber.
  bucketsAndLargeAtoms,

  /// Small atoms added/removed via 0..100 quantity controls.
  slidersAndSmallAtoms,
}
