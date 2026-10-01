import 'dart:ui';

import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';

/// Model state for draggable measurement tools (EnergySkateParkModel.ts +
/// MeasuringTapeNode / StopwatchNode / ReferenceHeightLine.ts).
///
/// Distance is always computed in **model meters** via [EspVec.distance].
class MeasurementTools {
  MeasurementTools();

  bool stopwatchVisible = false;

  /// Stopwatch position in **view** coordinates (PhET Stopwatch.positionProperty).
  Offset stopwatchViewPosition = const Offset(120, 72);

  double stopwatchTime = 0;

  bool measuringTapeVisible = false;

  /// Tape endpoints in **model** meters (measuringTapeBase/TipPositionProperty).
  EspVec measuringTapeBase = const EspVec(0, 0);
  EspVec measuringTapeTip = const EspVec(1, 0);

  /// Distance in model meters — never derived from screen pixels in Widgets.
  double get measuringTapeDistanceMeters =>
      measuringTapeBase.distance(measuringTapeTip);

  void resetStopwatch() {
    stopwatchTime = 0;
  }

  /// Stopwatch.ts visibility listener.
  void onStopwatchHidden() {
    stopwatchTime = 0;
  }

  void resetMeasuringTape() {
    measuringTapeBase = const EspVec(0, 0);
    measuringTapeTip = const EspVec(1, 0);
  }

  void resetAll() {
    stopwatchVisible = false;
    stopwatchTime = 0;
    stopwatchViewPosition = const Offset(120, 72);
    measuringTapeVisible = false;
    resetMeasuringTape();
  }

  /// Clamp model position to play-area bounds (availableModelBounds subset).
  EspVec clampTapePoint(EspVec p) => EspVec(
        p.x.clamp(
          EspConstants.playAreaModelMinX,
          EspConstants.playAreaModelMaxX,
        ),
        p.y.clamp(0.0, EspConstants.referenceHeightMax + 2),
      );

  /// Place tape at model point with default 1 m span (ToolboxPanel.ts:109).
  void placeMeasuringTapeAt(EspVec modelBase) {
    measuringTapeBase = clampTapePoint(modelBase);
    measuringTapeTip = clampTapePoint(modelBase.plusXY(1, 0));
    measuringTapeVisible = true;
  }

  /// Place stopwatch at view point (ToolboxPanel.ts:137-141).
  void placeStopwatchAtView(Offset viewTopLeft, Size widgetSize) {
    stopwatchViewPosition = Offset(
      viewTopLeft.dx.clamp(0.0, widgetSize.width - 100),
      viewTopLeft.dy.clamp(0.0, widgetSize.height - 48),
    );
    stopwatchVisible = true;
  }

  void dragStopwatchTo(Offset viewPos, Size widgetSize) {
    stopwatchViewPosition = Offset(
      viewPos.dx.clamp(0.0, widgetSize.width - 100),
      viewPos.dy.clamp(0.0, widgetSize.height - 48),
    );
  }
}
