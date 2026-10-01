import 'dart:ui' show Size, Offset, Rect;

import 'package:flutter/material.dart' show Color;

import '../membrane_transport_constants.dart';
import '../membrane_transport_feature_set.dart';
import '../model/transport_protein_type.dart';

/// Design-space layout bounds — joist `ScreenView.DEFAULT_LAYOUT_BOUNDS`
/// `Bounds2(0,0,1024,618)`. MembraneTransportScreenView does not override.
/// Observation 534×400 from constants (unchanged).
class MembraneTransportLayoutPrimitives {
  MembraneTransportLayoutPrimitives._();

  static const double designWidth = 1024;
  static const double designHeight = 618;

  static const double obsWidth = MembraneTransportConstants.observationWindowWidth;
  static const double obsHeight = MembraneTransportConstants.observationWindowHeight;
  static const double marginX = MembraneTransportConstants.screenViewXMargin;
  static const double marginY = MembraneTransportConstants.screenViewYMargin;

  static const double mvtScale = MembraneTransportConstants.mvtScale;

  /// CONTENT_DRIVEN: SolutesPanel icon maxWidth 53 + padding/title.
  static const double solutesPanelWidth = 80;
  static const double soluteControlWidth = 88;
  static const double soluteControlHeight = 70;
  static const double timeControlHeight = 48;
  static const double timeControlWidth = 160;
  static const double eraserWidth = 44;
  static const double eraserHeight = 36;
  static const double cellMaxWidth = 120;
  static const double proteinPanelWidth = 216;
  /// PhET accordion content ~720; reset sits to the right on 1024 canvas.
  static const double graphWidth = 720;
  /// SoluteBarChartNode BOX_WIDTH / BOX_HEIGHT
  static const double barChartBoxWidth = 124;
  static const double barChartBoxHeight = 92;
  /// Gap between time-control bottom and Solute Concentrations top.
  static const double graphGapBelowTime = 12;
  /// Accordion content Path height (fits under title within expanded height).
  static const double graphContentHeight = 96;
  /// Title + content; 618 − 8 − (416 + 48 + 12) = 134
  static const double graphExpandedHeight = 134;
  static const double resetRadius = 20.5;
  static const double observationCornerRadius = 3;

  /// Thumbnail — PhET ThumbnailNode.ts
  static const double thumbnailWidth = 15;
  static double get thumbnailHeight =>
      thumbnailWidth * obsHeight / obsWidth;

  /// Uniform design→viewport scale (PhET ScreenView). Scale **up** on large
  /// devices; do not cap at 1.0 (that caused tablet letterboxing).
  static double fitScale(double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 1;
    final s = (maxWidth / designWidth < maxHeight / designHeight)
        ? maxWidth / designWidth
        : maxHeight / designHeight;
    return s.clamp(0.35, 8.0);
  }

  static Size physicalSize(double scale) =>
      Size(designWidth * scale, designHeight * scale);
}

/// Resolved rectangles / anchors in design coordinates (1024×618).
///
/// Formulas from LAYOUT_SPEC.md / MembraneTransportScreenView.ts.
/// Shared across all FeatureSets; feature gates visibility, not geometry.
class MembraneTransportLayoutSpec {
  MembraneTransportLayoutSpec._();

  static Rect get observation => Rect.fromLTWH(
        MembraneTransportLayoutPrimitives.designWidth / 2 -
            MembraneTransportLayoutPrimitives.obsWidth / 2,
        MembraneTransportLayoutPrimitives.marginY,
        MembraneTransportLayoutPrimitives.obsWidth,
        MembraneTransportLayoutPrimitives.obsHeight,
      );

  static Offset get observationCenter => observation.center;

  /// Model (0,0) → observation local view.
  static Offset modelToObservationView(double mx, double my) {
    final c = Offset(observation.width / 2, observation.height / 2);
    return Offset(
      c.dx + mx * MembraneTransportLayoutPrimitives.mvtScale,
      c.dy - my * MembraneTransportLayoutPrimitives.mvtScale,
    );
  }

  static Offset observationViewToModel(Offset view) {
    final c = Offset(observation.width / 2, observation.height / 2);
    return Offset(
      (view.dx - c.dx) / MembraneTransportLayoutPrimitives.mvtScale,
      -(view.dy - c.dy) / MembraneTransportLayoutPrimitives.mvtScale,
    );
  }

  static double get timeControlTop =>
      observation.bottom + MembraneTransportLayoutPrimitives.marginY;

  static double get timeControlCenterX => observation.center.dx;

  static double get timeControlCenterY =>
      timeControlTop + MembraneTransportLayoutPrimitives.timeControlHeight / 2;

  static double get graphLeft => MembraneTransportLayoutPrimitives.marginX;

  /// Below time strip — keeps Solute Concentrations clear of play/pause.
  static double get graphTop =>
      timeControlTop +
      MembraneTransportLayoutPrimitives.timeControlHeight +
      MembraneTransportLayoutPrimitives.graphGapBelowTime;

  static double get graphBottom =>
      MembraneTransportLayoutPrimitives.designHeight -
      MembraneTransportLayoutPrimitives.marginY;

  static double get solutesPanelLeft => graphLeft;

  /// ≡ screenViewMVT.modelToViewY(MEMBRANE_BOUNDS.centerY) = obs.centerY
  static double get solutesPanelCenterY => observation.center.dy;

  static double get solutesPanelRight =>
      solutesPanelLeft + MembraneTransportLayoutPrimitives.solutesPanelWidth;

  /// Mid-gap between solutes panel and observation.
  static double get soluteControlCenterX =>
      solutesPanelRight + (observation.left - solutesPanelRight) / 2;

  static double get soluteControlLeft =>
      soluteControlCenterX -
      MembraneTransportLayoutPrimitives.soluteControlWidth / 2;

  static double get proteinPanelTop => observation.top;

  static double get proteinPanelRight =>
      MembraneTransportLayoutPrimitives.designWidth -
      MembraneTransportLayoutPrimitives.marginX;

  static double get resetRight => proteinPanelRight;

  static double get resetBottom =>
      MembraneTransportLayoutPrimitives.designHeight -
      MembraneTransportLayoutPrimitives.marginY;

  /// cell.left = soluteControlsParent.left + 3
  static double get cellLeft => soluteControlLeft + 3;

  static double get cellTop => observation.center.dy;

  /// Thumbnail center relative to cell (source: cell.centerX - 3, cell.top + 1.5)
  static Offset get thumbnailCenter => Offset(
        cellLeft + MembraneTransportLayoutPrimitives.cellMaxWidth / 2 - 3,
        cellTop + 1.5,
      );

  static bool showProteinPanel(MembraneTransportFeatureSet fs) =>
      featureSetHasProteins(fs);

  /// Resolve all primary slots for tests / Composer.
  static MembraneTransportLayoutSlots resolve({
    required MembraneTransportFeatureSet featureSet,
  }) {
    final obs = observation;
    return MembraneTransportLayoutSlots(
      featureSet: featureSet,
      canvas: const Size(
        MembraneTransportLayoutPrimitives.designWidth,
        MembraneTransportLayoutPrimitives.designHeight,
      ),
      observation: obs,
      timeControlTop: timeControlTop,
      timeControlCenterX: timeControlCenterX,
      timeControlCenterY: timeControlCenterY,
      eraserLeft: obs.left,
      eraserCenterY: timeControlCenterY,
      checksRight: obs.right,
      checksCenterY: timeControlCenterY,
      graphLeft: graphLeft,
      graphTop: graphTop,
      graphBottom: graphBottom,
      solutesPanelLeft: solutesPanelLeft,
      solutesPanelCenterY: solutesPanelCenterY,
      soluteControlCenterX: soluteControlCenterX,
      outsideControlTop: obs.top,
      insideControlBottom: obs.bottom,
      cellLeft: cellLeft,
      cellTop: cellTop,
      thumbnailCenter: thumbnailCenter,
      proteinPanelTop: proteinPanelTop,
      proteinPanelRight: proteinPanelRight,
      resetRight: resetRight,
      resetBottom: resetBottom,
      showProteinPanel: showProteinPanel(featureSet),
    );
  }
}

/// Snapshot of resolved design-space slots (one Composer pass).
class MembraneTransportLayoutSlots {
  const MembraneTransportLayoutSlots({
    required this.featureSet,
    required this.canvas,
    required this.observation,
    required this.timeControlTop,
    required this.timeControlCenterX,
    required this.timeControlCenterY,
    required this.eraserLeft,
    required this.eraserCenterY,
    required this.checksRight,
    required this.checksCenterY,
    required this.graphLeft,
    required this.graphTop,
    required this.graphBottom,
    required this.solutesPanelLeft,
    required this.solutesPanelCenterY,
    required this.soluteControlCenterX,
    required this.outsideControlTop,
    required this.insideControlBottom,
    required this.cellLeft,
    required this.cellTop,
    required this.thumbnailCenter,
    required this.proteinPanelTop,
    required this.proteinPanelRight,
    required this.resetRight,
    required this.resetBottom,
    required this.showProteinPanel,
  });

  final MembraneTransportFeatureSet featureSet;
  final Size canvas;
  final Rect observation;
  final double timeControlTop;
  final double timeControlCenterX;
  final double timeControlCenterY;
  final double eraserLeft;
  final double eraserCenterY;
  final double checksRight;
  final double checksCenterY;
  final double graphLeft;
  final double graphTop;
  final double graphBottom;
  final double solutesPanelLeft;
  final double solutesPanelCenterY;
  final double soluteControlCenterX;
  final double outsideControlTop;
  final double insideControlBottom;
  final double cellLeft;
  final double cellTop;
  final Offset thumbnailCenter;
  final double proteinPanelTop;
  final double proteinPanelRight;
  final double resetRight;
  final double resetBottom;
  final bool showProteinPanel;
}

/// Asset paths for original PhET SVGs.
class MembraneTransportAssets {
  MembraneTransportAssets._();

  static const String _base = 'assets/simulations/membrane_transport/images';

  static String particle(String typeName) => '$_base/$typeName.svg';

  static const String oxygen = '$_base/oxygen.svg';
  static const String carbonDioxide = '$_base/carbonDioxide.svg';
  static const String sodiumIon = '$_base/sodiumIon.svg';
  static const String potassiumIon = '$_base/potassiumIon.svg';
  static const String glucose = '$_base/glucose.svg';
  static const String atp = '$_base/atp.svg';
  static const String adp = '$_base/adp.svg';
  static const String phosphate = '$_base/phosphate.svg';
  static const String cell = '$_base/cell.svg';
  /// scenery-phet `images/eraser.svg` (styles inlined for flutter_svg)
  static const String eraser = '$_base/eraser.svg';
  /// PhET EraserButton `iconWidth: 20`, MT screen `scale: 1.2`
  static const double eraserIconWidth = 24;
  static const String simpleDiffusionHome =
      '$_base/simple_diffusion_home_icon.svg';
  static const String facilitatedDiffusionHome =
      '$_base/facilitated_diffusion_home_icon.svg';
  static const String activeTransportHome =
      '$_base/active_transport_home_icon.svg';
  static const String playgroundHome = '$_base/playground_home_icon.svg';
  static const String simpleDiffusionNav =
      '$_base/simple_diffusion_nav_icon.svg';
  static const String facilitatedDiffusionNav =
      '$_base/facilitated_diffusion_nav_icon.svg';
  static const String activeTransportNav =
      '$_base/active_transport_nav_icon.svg';
  static const String playgroundNav = '$_base/playground_nav_icon.svg';

  static const String sodiumLeakage = '$_base/sodiumLeakage.svg';
  static const String potassiumLeakage = '$_base/potassiumLeakage.svg';
  static const String sodiumVoltageGatedOpen =
      '$_base/sodiumVoltageGatedOpen.svg';
  static const String sodiumVoltageGatedClosed =
      '$_base/sodiumVoltageGatedClosed.svg';
  static const String potassiumVoltageGatedOpen =
      '$_base/potassiumVoltageGatedOpen.svg';
  static const String potassiumVoltageGatedClosed =
      '$_base/potassiumVoltageGatedClosed.svg';
  static const String sodiumLigandGatedOpen =
      '$_base/sodiumLigandGatedOpen.svg';
  static const String sodiumLigandGatedClosed =
      '$_base/sodiumLigandGatedClosed.svg';
  static const String potassiumLigandGatedOpen =
      '$_base/potassiumLigandGatedOpen.svg';
  static const String potassiumLigandGatedClosed =
      '$_base/potassiumLigandGatedClosed.svg';
  static const String sodiumLigand = '$_base/sodiumLigand.svg';
  static const String potassiumLigand = '$_base/potassiumLigand.svg';
  static const String naKPumpState1 = '$_base/naKPumpState1.svg';
  static const String naKPumpState2 = '$_base/naKPumpState2.svg';
  static const String sodiumGlucoseCotransporterState1 =
      '$_base/sodiumGlucoseCotransporterState1.svg';
  static const String sodiumGlucoseCotransporterState3 =
      '$_base/sodiumGlucoseCotransporterState3.svg';

  static String forParticleType(String name) {
    switch (name) {
      case 'oxygen':
        return oxygen;
      case 'carbonDioxide':
        return carbonDioxide;
      case 'sodiumIon':
        return sodiumIon;
      case 'potassiumIon':
        return potassiumIon;
      case 'glucose':
        return glucose;
      case 'atp':
        return atp;
      case 'adp':
        return adp;
      case 'phosphate':
        return phosphate;
      case 'triangleLigand':
        return sodiumLigand;
      case 'starLigand':
        return potassiumLigand;
      default:
        return oxygen;
    }
  }

  /// Resolve protein SVG for membrane / toolbox. [state] selects open/closed.
  static String forProtein(TransportProteinType type, {String? state}) {
    switch (type) {
      case TransportProteinType.sodiumIonLeakageChannel:
        return sodiumLeakage;
      case TransportProteinType.potassiumIonLeakageChannel:
        return potassiumLeakage;
      case TransportProteinType.sodiumIonVoltageGatedChannel:
        return state == 'openNegative50mV'
            ? sodiumVoltageGatedOpen
            : sodiumVoltageGatedClosed;
      case TransportProteinType.potassiumIonVoltageGatedChannel:
        return state == 'open30mV'
            ? potassiumVoltageGatedOpen
            : potassiumVoltageGatedClosed;
      case TransportProteinType.sodiumIonLigandGatedChannel:
        return (state == 'ligandBoundOpen' || state == 'ligandUnboundOpen')
            ? sodiumLigandGatedOpen
            : sodiumLigandGatedClosed;
      case TransportProteinType.potassiumIonLigandGatedChannel:
        return (state == 'ligandBoundOpen' || state == 'ligandUnboundOpen')
            ? potassiumLigandGatedOpen
            : potassiumLigandGatedClosed;
      case TransportProteinType.sodiumPotassiumPump:
        return (state == 'openToOutsideAwaitingPotassium' ||
                state == 'openToOutsidePotassiumBound')
            ? naKPumpState2
            : naKPumpState1;
      case TransportProteinType.sodiumGlucoseCotransporter:
        return state == 'openToInside'
            ? sodiumGlucoseCotransporterState3
            : sodiumGlucoseCotransporterState1;
    }
  }

  static String forProteinToolbox(TransportProteinType type) =>
      forProtein(type);
}

/// Colors from `MembraneTransportColors.ts`.
class MembraneTransportColors {
  MembraneTransportColors._();

  static const Color outsideCell = Color(0xFFB8DFFF);
  static const Color insideCell = Color(0xFFFDF4C9);
  static const Color observationOutside = Color(0xFFDBEFFF);
  static const Color observationInside = Color(0xFFFFF9F0);
  static const Color lipidHead = Color.fromRGBO(248, 161, 46, 1);
  static const Color lipidTail = Color.fromRGBO(229, 68, 143, 1);
  static const Color phospholipidHead = Color.fromRGBO(220, 120, 39, 1);
  static const Color phospholipidTail = Color.fromRGBO(234, 144, 255, 1);
  static const Color crossingHighlight = Color(0xFFFFFF94);
  static const Color ligandButton = Color.fromRGBO(255, 240, 105, 1);
}
