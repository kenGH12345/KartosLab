import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../model/equations_vector.dart';
import '../model/root_vector.dart';
import '../model/screen_models.dart';
import '../model/va_vec.dart';
import '../model/vector.dart';
import '../transform/math_coordinate_transform.dart';
import '../vector_addition_constants.dart';
import 'va_render_data.dart';

/// Builds [VaRenderData] from model — all business derivation happens here.
class VaRenderBuilder {
  const VaRenderBuilder();

  VaRenderData build(VaScreenModel model, {Size? layoutSize}) {
    final layout = layoutSize ??
        const Size(
          VectorAdditionConstants.layoutWidth,
          VectorAdditionConstants.layoutHeight,
        );
    final scene = model.scene;
    final graph = scene.graph;
    final t = graph.transform;
    final graphRect = t.viewBounds;
    final originView = t.modelToView(VaVec.zero);

    final majors = <VaLineSeg>[];
    final minors = <VaLineSeg>[];
    final ticks = <VaTickLabel>[];
    final axes = <VaLineSeg>[];

    _buildGrid(graph.bounds, t, majors, minors, ticks);
    _buildAxes(graph.orientation, graph.bounds, t, axes);

    final vectors = <VaArrowRender>[];
    final components = <VaArrowRender>[];
    final resultants = <VaArrowRender>[];
    final baseVectors = <VaArrowRender>[];
    final toolbox = <VaToolboxSlotRender>[];

    final isEquations = model is EquationsModel;
    final sumVisible = isEquations
        ? model.view.equationsResultantVisible
        : model.view.sumVisible;

    for (final set in scene.vectorSets) {
      for (final v in set.activeVectors) {
        final selected = identical(scene.selected, v);
        if (v.isOnGraph) {
          vectors.add(_arrow(
            v,
            t,
            set.palette.vectorFill,
            model.view,
            dashed: false,
            selected: selected,
          ));
          if (model.componentStyle.style != ComponentVectorStyle.invisible) {
            components.addAll(_components(v, t, set.palette.vectorFill, model));
          }
        } else {
          // Off-graph but still active (popped / animating). Shadow only when
          // not returning to toolbox — PhET VectorNode shadowMultilink.
          vectors.add(_arrow(
            v,
            t,
            set.palette.vectorFill,
            model.view,
            dashed: false,
            showShadow: !v.animateToToolbox && !v.isAnimating,
            selected: selected,
          ));
        }
      }

      // Toolbox: Explore = one slot per vector; Lab = one slot per set.
      if (!isEquations) {
        if (scene.vectorSets.length > 1) {
          // Lab: one slot showing set symbol
          final available =
              set.allVectors.any((v) => !set.activeVectors.contains(v));
          final sample = set.allVectors.first;
          toolbox.add(VaToolboxSlotRender(
            symbol: set.resultantSymbol.startsWith('s_')
                ? set.resultantSymbol.substring(2)
                : sample.symbol.split('_').first,
            color: set.palette.vectorFill,
            available: available,
            iconTipDelta: t.modelToViewDelta(sample.xyComponents),
          ));
        } else {
          for (final v in set.allVectors) {
            final inToolbox = !set.activeVectors.contains(v);
            toolbox.add(VaToolboxSlotRender(
              symbol: v.symbol,
              color: set.palette.vectorFill,
              available: inToolbox,
              iconTipDelta: t.modelToViewDelta(v.xyComponents),
            ));
          }
        }
      }

      final r = set.resultant;
      final defined = r.isDefined;
      if (sumVisible && defined && r.isOnGraph) {
        resultants.add(_arrow(
          r,
          t,
          set.palette.sumFill,
          model.view,
          dashed: false,
          isResultant: true,
          selected: identical(scene.selected, r),
        ));
        if (model.componentStyle.style != ComponentVectorStyle.invisible) {
          components.addAll(
            _components(r, t, set.palette.sumFill, model, dashed: true),
          );
        }
      }
    }

    // Equations base vectors from EquationsVector (coefficient × base).
    if (isEquations && model.view.baseVectorsVisible) {
      final set = scene.vectorSets.first;
      for (final v in set.allVectors) {
        if (v is! EquationsVector) continue;
        final xy = v.baseXy;
        final tail = v.baseTailPosition;
        final tipView = t.modelToView(tail + xy);
        final tailView = t.modelToView(tail);
        final viewMag = (tipView - tailView).distance;
        final ang = xy.isEffectivelyZero ? 0.0 : xy.angle;
        var deg = ang * 180 / math.pi;
        if (model.view.angleConvention == AngleConvention.unsigned) {
          deg = RootVector.signedToUnsignedDegrees(deg);
        }
        baseVectors.add(VaArrowRender(
          tail: tailView,
          tip: tipView,
          color: set.palette.baseVectorFill,
          symbol: v.symbol,
          magnitude: xy.magnitude,
          angleDegrees: deg,
          onGraph: true,
          dashed: false,
          showLabel: true,
          labelText: v.symbol,
          isBaseVector: true,
          strokeColor: set.palette.effectiveBaseStroke,
          strokeWidth: VectorAdditionConstants.baseVectorLineWidth,
          modelAngleRadians: xy.isEffectivelyZero ? null : ang,
          viewMagnitude: viewMag,
        ));
      }
    }

    // Fix Lab toolbox symbols to u/v
    if (model is LabModel) {
      toolbox.clear();
      for (final set in scene.vectorSets) {
        final sym = set.allVectors.first.symbol.split('_').first;
        toolbox.add(VaToolboxSlotRender(
          symbol: sym,
          color: set.palette.vectorFill,
          available:
              set.allVectors.any((v) => !set.activeVectors.contains(v)),
          iconTipDelta: t.modelToViewDelta(
            set.allVectors.first.initialXyComponents,
          ),
        ));
      }
    }

    final anchors = _anchors(graphRect, isEquations: isEquations);
    final equationLabel =
        model is EquationsModel ? model.equationLabel : null;

    VaSelectedValuesRender? selectedValues;
    final sel = scene.selected;
    if (sel != null) {
      selectedValues = VaSelectedValuesRender(
        symbol: sel.symbol,
        magnitude: sel.magnitude,
        angleDegrees: sel.getAngleDegrees(model.view.angleConvention),
        xComponent: sel.xComponent,
        yComponent: sel.yComponent,
      );
    }

    return VaRenderData(
      layoutSize: layout,
      graphRect: graphRect,
      originView: originView,
      gridVisible: model.view.gridVisible,
      orientation: graph.orientation,
      majorGridLines: majors,
      minorGridLines: minors,
      axisSegments: axes,
      tickLabels: ticks,
      vectors: vectors,
      components: components,
      resultants: resultants,
      baseVectors: baseVectors,
      componentStyle: model.componentStyle.style,
      sumVisible: sumVisible,
      valuesVisible: model.view.valuesVisible,
      anglesVisible: model.view.anglesVisible,
      angleConvention: model.view.angleConvention,
      selectedSymbol: scene.selected?.symbol,
      toolboxSlots: toolbox,
      showEraser: !isEquations,
      showToolbox: !isEquations,
      controlPanel: VaControlPanelRender(
        showComponents: model is! Explore1DModel,
        showAngles: model is! Explore1DModel,
        showSum: true,
        componentStyle: model.componentStyle.style,
        sceneModeLabel: scene.name,
        equationOptions: isEquations
            ? const ['a + b = c', 'a − b = c', 'a + b + c = 0']
            : const [],
        selectedEquationIndex: switch (model) {
          final EquationsModel m =>
            EquationType.values.indexOf(m.equationType),
          _ => 0,
        },
      ),
      vectorValuesExpanded: model.view.vectorValuesExpanded,
      equationLabel: equationLabel,
      anchors: anchors,
      selectedValues: selectedValues,
    );
  }

  void _buildGrid(
    VaBounds bounds,
    MathCoordinateTransform t,
    List<VaLineSeg> majors,
    List<VaLineSeg> minors,
    List<VaTickLabel> ticks,
  ) {
    final major = VectorAdditionConstants.majorGridSpacing;
    final minor = VectorAdditionConstants.minorGridSpacing;
    final labelEvery = VectorAdditionConstants.tickLabelSpacing;

    var x = bounds.minX - (bounds.minX % minor);
    while (x <= bounds.maxX + 1e-9) {
      final a = t.modelToView(VaVec(x, bounds.minY));
      final b = t.modelToView(VaVec(x, bounds.maxY));
      final isMajor = (x / major).abs() % 1 < 1e-9 ||
          ((x / major) - (x / major).roundToDouble()).abs() < 1e-9;
      (isMajor ? majors : minors).add(VaLineSeg(a, b));
      if ((x / labelEvery).abs() % 1 < 1e-9 ||
          ((x / labelEvery) - (x / labelEvery).roundToDouble()).abs() < 1e-9) {
        if (x.abs() > 1e-9) {
          ticks.add(VaTickLabel(
            text: x.round().toString(),
            position: t.modelToView(VaVec(x, 0)) + const Offset(0, 15),
          ));
        }
      }
      x += minor;
    }

    var y = bounds.minY - (bounds.minY % minor);
    while (y <= bounds.maxY + 1e-9) {
      final a = t.modelToView(VaVec(bounds.minX, y));
      final b = t.modelToView(VaVec(bounds.maxX, y));
      final isMajor = (y / major).abs() % 1 < 1e-9 ||
          ((y / major) - (y / major).roundToDouble()).abs() < 1e-9;
      (isMajor ? majors : minors).add(VaLineSeg(a, b));
      if ((y / labelEvery).abs() % 1 < 1e-9 ||
          ((y / labelEvery) - (y / labelEvery).roundToDouble()).abs() < 1e-9) {
        if (y.abs() > 1e-9) {
          ticks.add(VaTickLabel(
            text: y.round().toString(),
            position: t.modelToView(VaVec(0, y)) + const Offset(15, 0),
          ));
        }
      }
      y += minor;
    }
  }

  void _buildAxes(
    GraphOrientation orientation,
    VaBounds bounds,
    MathCoordinateTransform t,
    List<VaLineSeg> axes,
  ) {
    if (orientation != GraphOrientation.vertical) {
      axes.add(VaLineSeg(
        t.modelToView(VaVec(bounds.minX, 0)),
        t.modelToView(VaVec(bounds.maxX, 0)),
      ));
    }
    if (orientation != GraphOrientation.horizontal) {
      axes.add(VaLineSeg(
        t.modelToView(VaVec(0, bounds.minY)),
        t.modelToView(VaVec(0, bounds.maxY)),
      ));
    }
  }

  VaArrowRender _arrow(
    VaVector v,
    MathCoordinateTransform t,
    Color color,
    dynamic view, {
    required bool dashed,
    bool isResultant = false,
    bool showShadow = false,
    bool selected = false,
  }) {
    final valuesVisible = view.valuesVisible as bool;
    final mag = v.magnitude;
    final convention = view.angleConvention as AngleConvention;
    final label = valuesVisible
        ? '|${v.symbol}|=${mag.toStringAsFixed(VectorAdditionConstants.vectorValueDecimalPlaces)}'
        : v.symbol;
    final tipView = t.modelToView(v.tip);
    final tailView = t.modelToView(v.tailPosition);
    return VaArrowRender(
      tail: tailView,
      tip: tipView,
      color: color,
      symbol: v.symbol,
      magnitude: mag,
      angleDegrees: v.getAngleDegrees(convention),
      onGraph: v.isOnGraph,
      dashed: dashed,
      showLabel: true,
      labelText: label,
      isResultant: isResultant,
      showShadow: showShadow,
      selected: selected,
      showAngle: (view.anglesVisible as bool) && v.isOnGraph && mag > 0,
      modelAngleRadians: v.angle,
      viewMagnitude: (tipView - tailView).distance,
    );
  }

  List<VaArrowRender> _components(
    VaVector v,
    MathCoordinateTransform t,
    Color color,
    VaScreenModel model, {
    bool dashed = true,
  }) {
    final out = <VaArrowRender>[];
    for (final c in [v.xComponentVector, v.yComponentVector]) {
      if (c.magnitude < VectorAdditionConstants.zeroThreshold) continue;
      final scalar = c.labelMagnitude(model.view.valuesVisible);
      out.add(VaArrowRender(
        tail: t.modelToView(c.tailPosition),
        tip: t.modelToView(c.tip),
        color: color.withValues(alpha: 0.85),
        symbol: '',
        magnitude: c.magnitude,
        angleDegrees: null,
        onGraph: true,
        dashed: dashed,
        showLabel: scalar != null,
        labelText: scalar?.toStringAsFixed(1) ?? '',
      ));
    }
    return out;
  }

  VaLayoutAnchors _anchors(Rect graphRect, {required bool isEquations}) {
    const layoutW = VectorAdditionConstants.layoutWidth;
    const layoutH = VectorAdditionConstants.layoutHeight;
    const mx = VectorAdditionConstants.screenViewXMargin;
    const my = VectorAdditionConstants.screenViewYMargin;
    const panelW = VectorAdditionConstants.rightPanelWidth;

    // PhET: GraphControlPanel.right = layout.right−20, top = layout.top+16
    final control = Rect.fromLTWH(
      layoutW - mx - panelW,
      my,
      panelW,
      isEquations ? 300 : 220,
    );

    // Vector Values: centerX = graph.centerX
    // Equations relocates top to SCREEN_VIEW_Y_MARGIN (EquationsSceneNode).
    // Explore/Lab: top ≈ 35 (VectorAdditionSceneNode).
    final valuesH = isEquations
        ? VectorAdditionConstants.vectorValuesContentHeight + 12
        : VectorAdditionConstants.vectorValuesContentHeight +
            VectorAdditionConstants.accordionChromePad;
    final valuesW = VectorAdditionConstants.vectorValuesContentWidth +
        VectorAdditionConstants.accordionChromePad;
    final valuesTop = isEquations ? my.toDouble() : 35.0;
    final values = Rect.fromCenter(
      center: Offset(graphRect.center.dx, valuesTop + valuesH / 2),
      width: valuesW,
      height: valuesH,
    );

    // Equation accordion: centerX = graph.centerX, top = values.bottom + 10
    // Height uses equationBarMinHeight so NumberPickers are not clipped.
    final eqH = VectorAdditionConstants.equationBarMinHeight;
    final eqW = VectorAdditionConstants.equationContentWidth +
        VectorAdditionConstants.accordionChromePad;
    final equation = isEquations
        ? Rect.fromCenter(
            center: Offset(
              graphRect.center.dx,
              values.bottom + 10 + eqH / 2,
            ),
            width: eqW,
            height: eqH,
          )
        : Rect.zero;

    // Base Vectors: right = layout.right−20, top = graphControlPanel.bottom + 8
    final baseVectors = isEquations
        ? Rect.fromLTWH(control.left, control.bottom + 8, panelW, 200)
        : Rect.zero;

    final toolbox = Rect.fromLTWH(
      control.left,
      layoutH - my - 48 - 90 - VectorAdditionConstants.spaceBelowVectorToolbox,
      160,
      90,
    );
    final eraser = Rect.fromLTWH(
      graphRect.right - 40,
      graphRect.bottom + 15,
      40,
      40,
    );
    // ResetAll: right = layout.maxX−20, bottom = layout.maxY−16
    final reset = Rect.fromLTWH(layoutW - mx - 52, layoutH - my - 52, 52, 52);
    // Scene radio: left = panel.left, bottom = reset.bottom
    final radio = Rect.fromLTWH(control.left, reset.top, 110, 52);

    return VaLayoutAnchors(
      graphRect: graphRect,
      controlPanelRect: control,
      toolboxRect: isEquations ? Rect.zero : toolbox,
      vectorValuesRect: values,
      eraserRect: isEquations ? Rect.zero : eraser,
      resetRect: reset,
      sceneRadioRect: radio,
      equationBarRect: equation,
      baseVectorsRect: baseVectors,
    );
  }
}
