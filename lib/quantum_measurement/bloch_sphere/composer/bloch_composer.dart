/// BlochComposer — LayoutSpec → static module geometry (no physics).
library;

import 'dart:ui';

import '../../layout/qm_bloch_layout_spec.dart';
import '../../layout/qm_global_layout_spec.dart';
import '../projection/bloch_projection.dart';

class BlochLayoutGeometry {
  const BlochLayoutGeometry({
    required this.designSize,
    required this.dividerX,
    required this.dividerRect,
    required this.prepArea,
    required this.prepSphereCenter,
    required this.prepSphereScale,
    required this.measurementArea,
    required this.measureSphereCenter,
    required this.measureSphereScale,
    required this.controlsOrigin,
    required this.magneticFieldBottom,
    required this.resetAll,
  });

  final Size designSize;
  final double dividerX;
  final Rect dividerRect;
  final Rect prepArea;
  final Offset prepSphereCenter;
  final double prepSphereScale;
  final Rect measurementArea;
  final Offset measureSphereCenter;
  final double measureSphereScale;
  final Offset controlsOrigin;
  final Offset magneticFieldBottom;
  final Offset resetAll;
}

class BlochComposer {
  const BlochComposer({
    this.global = const QmGlobalLayoutSpec(),
    this.bloch = const QmBlochLayoutSpec(),
  });

  final QmGlobalLayoutSpec global;
  final QmBlochLayoutSpec bloch;

  ({double scale, Offset origin}) designFrame(Size viewport) {
    final f = global.designFrame(viewport);
    return (scale: f.scale, origin: f.origin);
  }

  BlochLayoutGeometry compose({required Size viewport}) {
    final divX = QmBlochLayoutSpec.dividingLineX;
    final measLeft = bloch.measurementAreaLeft; // 390
    final measTop = qmScreenViewYMargin; // 10

    // Prep column: centered between layout left and divider.
    final prepCx = bloch.preparationCenterX(0, divX);
    final prepTop = bloch.preparationTop(0);

    // Prep sphere roughly mid of left column (content-driven VBox; approximate center).
    final prepSphereCenter = Offset(prepCx, prepTop + 220);

    // Measurement area root FIXED: left=390, top=10.
    // Equation panel (~70) then sphere at panel.bottom+35 → center ≈ top+70+35+100.
    final measureSphereCenter = Offset(measLeft + 160, measTop + 215);
    final controlsOrigin = Offset(
      measureSphereCenter.dx + blochSphereRadius + 60,
      measTop + 10,
    );

    return BlochLayoutGeometry(
      designSize: Size(global.designWidth, global.designHeight),
      dividerX: divX,
      dividerRect: Rect.fromLTWH(
        divX - 1,
        QmBlochLayoutSpec.dividingLineTop,
        2,
        qmDividerHeight,
      ),
      prepArea: Rect.fromLTWH(
        qmScreenViewXMargin,
        prepTop,
        divX - 2 * qmScreenViewXMargin,
        global.designHeight - prepTop - qmScreenViewYMargin,
      ),
      prepSphereCenter: prepSphereCenter,
      prepSphereScale: QmBlochLayoutSpec.preparationSphereScale,
      measurementArea: Rect.fromLTWH(
        measLeft,
        measTop,
        global.designWidth - measLeft - qmScreenViewXMargin,
        global.designHeight - measTop - qmScreenViewYMargin,
      ),
      measureSphereCenter: measureSphereCenter,
      measureSphereScale: 1.0,
      controlsOrigin: controlsOrigin,
      magneticFieldBottom: Offset(
        measureSphereCenter.dx,
        global.designHeight - 30,
      ),
      resetAll: Offset(
        global.designWidth - qmScreenViewXMargin,
        global.designHeight - qmScreenViewYMargin,
      ),
    );
  }
}
