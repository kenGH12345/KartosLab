/// SpinComposer — LayoutSpec + ViewConfiguration → geometry (no measurement/RNG).
library;

import 'dart:ui';

import '../../layout/qm_global_layout_spec.dart';
import '../../layout/qm_spin_layout_spec.dart';
import '../configuration/spin_experiment_view_configuration.dart';
import '../model/spin_model.dart';
import '../transform/spin_view_transform.dart';

class SpinSgGeometry {
  const SpinSgGeometry({
    required this.centerView,
    required this.sizeView,
    required this.entranceView,
    required this.topExitView,
    required this.bottomExitView,
    required this.visible,
    required this.isZOriented,
    required this.directionControllable,
  });

  final Offset centerView;
  final Size sizeView;
  final Offset entranceView;
  final Offset topExitView;
  final Offset bottomExitView;
  final bool visible;
  final bool isZOriented;
  final bool directionControllable;
}

class SpinLayoutGeometry {
  const SpinLayoutGeometry({
    required this.designSize,
    required this.dividerX,
    required this.dividerRect,
    required this.prepArea,
    required this.measurementOrigin,
    required this.transform,
    required this.sourceCenterView,
    required this.sourceExitView,
    required this.sg0,
    required this.sg1,
    required this.sg2,
    required this.blockerView,
    required this.showBlocker,
    required this.comboTopLeft,
    required this.resetAll,
    required this.config,
  });

  final Size designSize;
  final double dividerX;
  final Rect dividerRect;
  final Rect prepArea;
  final Offset measurementOrigin;
  final SpinViewTransform transform;
  final Offset sourceCenterView;
  final Offset sourceExitView;
  final SpinSgGeometry sg0;
  final SpinSgGeometry sg1;
  final SpinSgGeometry sg2;
  final Offset? blockerView;
  final bool showBlocker;
  final Offset comboTopLeft;
  final Offset resetAll;
  final SpinExperimentViewConfiguration config;
}

class SpinComposer {
  const SpinComposer({
    this.global = const QmGlobalLayoutSpec(),
    this.spin = const QmSpinLayoutSpec(),
    this.meters = const SpinApparatusMeters(),
  });

  final QmGlobalLayoutSpec global;
  final QmSpinLayoutSpec spin;
  final SpinApparatusMeters meters;

  ({double scale, Offset origin}) designFrame(Size viewport) {
    final f = global.designFrame(viewport);
    return (scale: f.scale, origin: f.origin);
  }

  SpinSgGeometry _sg(
    SpinVec2 center,
    SpinViewTransform t, {
    required bool visible,
    required bool isZ,
    required bool controllable,
  }) {
    final w = t.modelToViewDeltaX(SpinApparatusMeters.sgWidth).abs();
    final h = t.modelToViewDeltaX(SpinApparatusMeters.sgHeight).abs();
    return SpinSgGeometry(
      centerView: t.physicsToView(center),
      sizeView: Size(w, h),
      entranceView: t.physicsToView(meters.entrance(center)),
      topExitView: t.physicsToView(meters.topExit(center)),
      bottomExitView: t.physicsToView(meters.bottomExit(center)),
      visible: visible,
      isZOriented: isZ,
      directionControllable: controllable,
    );
  }

  SpinLayoutGeometry compose({
    required Size viewport,
    required SpinExperimentViewConfiguration config,
  }) {
    // Measurement-area MVT origin (PhET: model 0 → experimentArea local 0).
    // X ≈ dividingLine + VBox xMargin + (-sourceLeftBounds) ≈ 300+30+144.
    // Y ≈ combo+title+margins + (-mdBounds.top) ≈ beam mid-lower of 618 frame.
    final measurementOrigin = Offset(
      QmSpinLayoutSpec.dividingLineX + 168,
      360,
    );
    final t = SpinViewTransform(origin: measurementOrigin);

    Offset? blocker;
    var showBlocker = false;
    if (config.blockingMode != BlockingMode.noBlocker &&
        !config.usingSingleApparatus &&
        config.sourceMode == SourceMode.continuous) {
      showBlocker = true;
      final exit = config.blockingMode == BlockingMode.blockUp
          ? meters.topExit(meters.sg0)
          : meters.bottomExit(meters.sg0);
      blocker = t.physicsToView(exit + SpinApparatusMeters.blockerOffset);
    }

    return SpinLayoutGeometry(
      designSize: Size(global.designWidth, global.designHeight),
      dividerX: QmSpinLayoutSpec.dividingLineX,
      dividerRect: Rect.fromLTWH(
        QmSpinLayoutSpec.dividingLineX - 1,
        QmSpinLayoutSpec.dividingLineTop,
        2,
        qmDividerHeight,
      ),
      prepArea: Rect.fromLTWH(
        qmScreenViewXMargin,
        QmSpinLayoutSpec.dividingLineTop,
        QmSpinLayoutSpec.dividingLineX - 2 * qmScreenViewXMargin,
        global.designHeight - QmSpinLayoutSpec.dividingLineTop - qmScreenViewYMargin,
      ),
      measurementOrigin: measurementOrigin,
      transform: t,
      sourceCenterView: t.physicsToView(meters.source),
      sourceExitView: t.physicsToView(meters.sourceExit),
      sg0: _sg(
        meters.sg0,
        t,
        visible: config.showSg0,
        isZ: config.sg0IsZ,
        controllable: config.sg0DirectionControllable,
      ),
      sg1: _sg(
        meters.sg1,
        t,
        visible: config.showSg1,
        isZ: config.sg1IsZ,
        controllable: config.sg1DirectionControllable,
      ),
      sg2: _sg(
        meters.sg2,
        t,
        visible: config.showSg2,
        isZ: config.sg2IsZ,
        controllable: config.sg2DirectionControllable,
      ),
      blockerView: blocker,
      showBlocker: showBlocker,
      comboTopLeft: Offset(QmSpinLayoutSpec.dividingLineX + 16, 16),
      resetAll: Offset(
        global.designWidth - qmScreenViewXMargin,
        global.designHeight - qmScreenViewYMargin,
      ),
      config: config,
    );
  }
}
