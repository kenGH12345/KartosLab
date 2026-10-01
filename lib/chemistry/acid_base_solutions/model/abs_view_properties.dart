/// View mode for the beaker representation — PhET `ViewMode.ts`.
enum AbsViewMode {
  particles,
  graph,
  hideViews,
}

/// Selected measurement tool — PhET `ToolMode.ts`.
///
/// UI exposes pHMeter / pHPaper / conductivityTester only; `none` exists for
/// PhET-iO but is not shown in the radio group.
enum AbsToolMode {
  pHMeter,
  pHPaper,
  conductivityTester,
  none,
}

/// View-specific properties — PhET `ABSViewProperties.ts`.
class AbsViewProperties {
  AbsViewMode viewMode = AbsViewMode.particles;
  AbsToolMode toolMode = AbsToolMode.pHMeter;

  void reset() {
    viewMode = AbsViewMode.particles;
    toolMode = AbsToolMode.pHMeter;
  }
}
