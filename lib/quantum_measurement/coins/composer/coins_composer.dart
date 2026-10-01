/// CoinsComposer -?applies PHASE 2 CoinsLayoutSpec to design-space geometry.
/// No Model / RNG / measurement logic.
library;

import 'dart:ui';

import '../../layout/qm_coins_layout_spec.dart';
import '../../layout/qm_global_layout_spec.dart';

class CoinsLayoutGeometry {
  const CoinsLayoutGeometry({
    required this.designSize,
    required this.sceneSelector,
    required this.sceneOrigin,
    required this.dividerX,
    required this.dividerRect,
    required this.prepCenter,
    required this.measureCenter,
    required this.startMeasurementCenter,
    required this.prepAreaApprox,
    required this.singleTestBox,
    required this.multiTestBox,
    required this.resetAll,
  });

  final Size designSize;
  final Rect sceneSelector;
  final Offset sceneOrigin;
  final double dividerX;
  final Rect dividerRect;
  final Offset prepCenter;
  final Offset measureCenter;
  final Offset startMeasurementCenter;
  final Rect prepAreaApprox;
  final Rect singleTestBox;
  final Rect multiTestBox;
  final Offset resetAll;
}

class CoinsComposer {
  const CoinsComposer({
    this.global = const QmGlobalLayoutSpec(),
    this.coins = const QmCoinsLayoutSpec(),
  });

  final QmGlobalLayoutSpec global;
  final QmCoinsLayoutSpec coins;

  /// [preparing] selects divider X (prep 389 vs measure 205).
  CoinsLayoutGeometry compose({
    required Size viewport,
    required bool preparing,
  }) {
    final dw = global.designWidth;
    final dh = global.designHeight;
    final dividerX = preparing
        ? coins.dividerXDuringPreparation
        : coins.dividerXDuringMeasurement;

    final sceneOrigin = const Offset(
      QmCoinsLayoutSpec.sceneTranslationX,
      QmCoinsLayoutSpec.sceneTranslationY,
    );

    final prepCx = coins.preparationCenterX(dividerX);
    final measureCx = coins.measurementCenterX(dividerX);

    // Scene-local Y: content starts near top of scene; empirical bands from source.
    const prepCy = 260.0;
    const measureCy = 280.0;

    final singleBox = Rect.fromCenter(
      center: Offset(measureCx, 155),
      width: QmCoinsLayoutSpec.singleCoinTestBoxWidth,
      height: QmCoinsLayoutSpec.singleCoinTestBoxHeight,
    );
    // Keep multi box fully inside scene (height ≈ 618−75).
    // Slightly smaller + higher so title+box+radios never clip.
    final multiBox = Rect.fromCenter(
      center: Offset(measureCx - 20, 370),
      width: 180,
      height: 180,
    );

    final prepArea = Rect.fromCenter(
      center: Offset(prepCx, prepCy),
      width: preparing ? 280 : 180,
      height: 420,
    );

    final reset = global.resetAllAnchor(dw, dh);

    return CoinsLayoutGeometry(
      designSize: Size(dw, dh),
      sceneSelector: Rect.fromLTWH(
        qmScreenViewXMargin,
        qmScreenViewYMargin,
        dw - 2 * qmScreenViewXMargin,
        48,
      ),
      sceneOrigin: sceneOrigin,
      dividerX: dividerX,
      dividerRect: Rect.fromLTWH(
        dividerX - 1,
        sceneOrigin.dy,
        2,
        qmDividerHeight,
      ),
      prepCenter: Offset(prepCx, prepCy),
      measureCenter: Offset(measureCx, measureCy),
      startMeasurementCenter: Offset(
        dividerX,
        QmCoinsLayoutSpec.startMeasurementButtonCenterY,
      ),
      prepAreaApprox: prepArea,
      singleTestBox: singleBox,
      multiTestBox: multiBox,
      resetAll: Offset(reset.right, reset.bottom),
    );
  }

  /// Uniform scale + top-left of centered design frame in viewport.
  ({double scale, Offset origin}) designFrame(Size viewport) {
    final f = global.designFrame(viewport);
    return (scale: f.scale, origin: f.origin);
  }
}
