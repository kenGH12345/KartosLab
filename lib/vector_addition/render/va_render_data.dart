import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/enums.dart';

/// Immutable snapshot for painters — Painters must not recompute business fields.
class VaRenderData {
  const VaRenderData({
    required this.layoutSize,
    required this.graphRect,
    required this.originView,
    required this.gridVisible,
    required this.orientation,
    required this.majorGridLines,
    required this.minorGridLines,
    required this.axisSegments,
    required this.tickLabels,
    required this.vectors,
    required this.components,
    required this.resultants,
    this.baseVectors = const [],
    required this.componentStyle,
    required this.sumVisible,
    required this.valuesVisible,
    required this.anglesVisible,
    required this.angleConvention,
    required this.selectedSymbol,
    required this.toolboxSlots,
    required this.showEraser,
    required this.showToolbox,
    required this.controlPanel,
    required this.vectorValuesExpanded,
    required this.equationLabel,
    required this.anchors,
    this.selectedValues,
  });

  final Size layoutSize;
  final Rect graphRect;
  final Offset originView;
  final bool gridVisible;
  final GraphOrientation orientation;
  final List<VaLineSeg> majorGridLines;
  final List<VaLineSeg> minorGridLines;
  final List<VaLineSeg> axisSegments;
  final List<VaTickLabel> tickLabels;

  /// On-graph interactive vectors (view coordinates already transformed).
  final List<VaArrowRender> vectors;
  final List<VaArrowRender> components;
  final List<VaArrowRender> resultants;
  final List<VaArrowRender> baseVectors;

  final ComponentVectorStyle componentStyle;
  final bool sumVisible;
  final bool valuesVisible;
  final bool anglesVisible;
  final AngleConvention angleConvention;
  final String? selectedSymbol;

  final List<VaToolboxSlotRender> toolboxSlots;
  final bool showEraser;
  final bool showToolbox;
  final VaControlPanelRender controlPanel;
  final bool vectorValuesExpanded;
  final String? equationLabel;
  final VaLayoutAnchors anchors;

  /// Selected vector readout for Vector Values accordion (null → "No vector selected").
  final VaSelectedValuesRender? selectedValues;
}

/// Quantities shown in Vector Values accordion — PhET `VectorValuesAccordionBox`.
class VaSelectedValuesRender {
  const VaSelectedValuesRender({
    required this.symbol,
    required this.magnitude,
    required this.angleDegrees,
    required this.xComponent,
    required this.yComponent,
  });

  final String symbol;
  final double magnitude;
  final double? angleDegrees;
  final double xComponent;
  final double yComponent;
}

class VaLineSeg {
  const VaLineSeg(this.a, this.b);
  final Offset a;
  final Offset b;
}

class VaTickLabel {
  const VaTickLabel({required this.text, required this.position});
  final String text;
  final Offset position;
}

class VaArrowRender {
  const VaArrowRender({
    required this.tail,
    required this.tip,
    required this.color,
    required this.symbol,
    required this.magnitude,
    required this.angleDegrees,
    required this.onGraph,
    required this.dashed,
    required this.showLabel,
    required this.labelText,
    this.isResultant = false,
    this.showShadow = false,
    this.selected = false,
    this.showAngle = false,
    this.modelAngleRadians,
    this.viewMagnitude,
    this.isBaseVector = false,
    this.strokeColor,
    this.strokeWidth = 0,
  });

  final Offset tail;
  final Offset tip;
  final Color color;
  final String symbol;
  final double magnitude;
  final double? angleDegrees;
  final bool onGraph;
  final bool dashed;
  final bool showLabel;
  final String labelText;
  final bool isResultant;
  final bool showShadow;
  final bool selected;
  final bool showAngle;

  /// Model-space angle (radians, atan2) for arc; view Y-flip handled in painter.
  final double? modelAngleRadians;

  /// View-space vector length for arc radius scaling.
  final double? viewMagnitude;

  final bool isBaseVector;
  final Color? strokeColor;
  final double strokeWidth;
}

class VaToolboxSlotRender {
  const VaToolboxSlotRender({
    required this.symbol,
    required this.color,
    required this.available,
    required this.iconTipDelta,
  });

  final String symbol;
  final Color color;
  final bool available;
  final Offset iconTipDelta; // view delta for icon arrow
}

class VaControlPanelRender {
  const VaControlPanelRender({
    required this.showComponents,
    required this.showAngles,
    required this.showSum,
    required this.componentStyle,
    required this.sceneModeLabel,
    required this.equationOptions,
    required this.selectedEquationIndex,
  });

  final bool showComponents;
  final bool showAngles;
  final bool showSum;
  final ComponentVectorStyle componentStyle;
  final String sceneModeLabel;
  final List<String> equationOptions;
  final int selectedEquationIndex;
}

/// Major layout anchors in layout (1024×618) coordinates — for QA, not Painter magic.
class VaLayoutAnchors {
  const VaLayoutAnchors({
    required this.graphRect,
    required this.controlPanelRect,
    required this.toolboxRect,
    required this.vectorValuesRect,
    required this.eraserRect,
    required this.resetRect,
    required this.sceneRadioRect,
    this.equationBarRect = Rect.zero,
    this.baseVectorsRect = Rect.zero,
  });

  final Rect graphRect;
  final Rect controlPanelRect;
  final Rect toolboxRect;
  final Rect vectorValuesRect;
  final Rect eraserRect;
  final Rect resetRect;
  final Rect sceneRadioRect;

  /// Equations only: Equation accordion under Vector Values (PhET EquationAccordionBox).
  final Rect equationBarRect;

  /// Equations only: Base Vectors accordion under GraphControlPanel.
  final Rect baseVectorsRect;
}
