import 'enums.dart';

/// View-level Properties shared by screens — mirrors `VectorAdditionViewProperties`.
class VaViewProperties {
  bool valuesVisible = false;
  bool anglesVisible = false;
  bool gridVisible = true;
  bool vectorValuesExpanded = true;

  /// Preferences default — PhET `AngleConvention` signed [-180,180).
  AngleConvention angleConvention = AngleConvention.signed;

  /// Explore / Lab: Sum checkbox (default false).
  bool sumVisible = false;

  /// Equations: resultant checkbox (default true).
  bool equationsResultantVisible = true;

  bool baseVectorsVisible = false;

  /// Equations: Equation accordion (default true) — PhET `equationAccordionBoxExpandedProperty`.
  bool equationExpanded = true;

  /// Equations: Base Vectors accordion (default false) — PhET `baseVectorsAccordionBoxExpandedProperty`.
  bool baseVectorsExpanded = false;

  void resetExplore() {
    valuesVisible = false;
    anglesVisible = false;
    gridVisible = true;
    vectorValuesExpanded = true;
    sumVisible = false;
    angleConvention = AngleConvention.signed;
  }

  void resetEquations() {
    valuesVisible = false;
    anglesVisible = false;
    gridVisible = true;
    vectorValuesExpanded = true;
    equationsResultantVisible = true;
    baseVectorsVisible = false;
    equationExpanded = true;
    baseVectorsExpanded = false;
    angleConvention = AngleConvention.signed;
  }
}

/// Mutable screen-level style holder (component style is in model).
class VaComponentStyleState {
  ComponentVectorStyle style = ComponentVectorStyle.invisible;

  void reset() => style = ComponentVectorStyle.invisible;
}
