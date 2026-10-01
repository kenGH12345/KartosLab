import 'dart:ui';

import 'time_plot_data_series.dart';

/// Shared layout / sampling constants for HI/SP measurement plots (PhET TimePlotNode / PositionPlotNode).
abstract final class QwiPlotConstants {
  static const double chartHeight = 135;
  static const double timeChartWidth = 190;
  static const double timeChartRightGap = 30;
  static const double timeChartBottomGap = 40;
  static const double panelLeftPad = 8;
  static const double panelTopPad = 12;
  static const double panelRightPad = 12;
  static const double panelBottomPad = 8;

  static const double minYFraction = 0.12;
  static const double maxYFraction = 0.88;
  static const double apertureToPanelGap = 8;
  static const double apertureHeight = 6;
  static const double apertureFrame = 3.5;
  static const int positionSamplesPerPixel = 2;

  static const Color probeColor = Color(0xFF808080);
  static const Color wireColor = Color(0xFF5A5A5A);
}

class WavePlotPoint {
  const WavePlotPoint({required this.x, required this.value});
  final double x;
  final double value;
}

/// Model-owned measurement plot state. Visibility lives on the controller.
class MeasurementPlotsState {
  final TimePlotDataSeries timeSeries = TimePlotDataSeries();

  /// Probe crosshair as fraction of wave region [0,1]×[0,1].
  double probeNormX = 0.3;
  double probeNormY = 0.4;

  /// Time-chart panel origin as fraction of wave region (top-left of chart content area).
  /// Null → default PhET placement relative to wave.
  double? timeChartNormX;
  double? timeChartNormY;

  double lineYFraction = 0.5;

  List<WavePlotPoint> positionPoints = const [];

  Offset probeCanvas(Rect wave) => Offset(
        wave.left + probeNormX * wave.width,
        wave.top + probeNormY * wave.height,
      );

  Offset timeChartCanvas(Rect wave) {
    final defaultLeft = wave.width -
        QwiPlotConstants.timeChartWidth -
        QwiPlotConstants.timeChartRightGap;
    final defaultTop = wave.height -
        QwiPlotConstants.chartHeight -
        QwiPlotConstants.timeChartBottomGap;
    return Offset(
      wave.left + (timeChartNormX ?? (defaultLeft / wave.width)) * wave.width,
      wave.top + (timeChartNormY ?? (defaultTop / wave.height)) * wave.height,
    );
  }

  void setProbeFromCanvas(Rect wave, double x, double y) {
    probeNormX = ((x - wave.left) / wave.width).clamp(0.0, 1.0);
    probeNormY = ((y - wave.top) / wave.height).clamp(0.0, 1.0);
  }

  void setTimeChartFromCanvas(Rect wave, double left, double top) {
    timeChartNormX = (left - wave.left) / wave.width;
    timeChartNormY = (top - wave.top) / wave.height;
  }

  void clearTimeData() => timeSeries.reset();

  void reset() {
    timeSeries.reset();
    probeNormX = 0.3;
    probeNormY = 0.4;
    timeChartNormX = null;
    timeChartNormY = null;
    lineYFraction = 0.5;
    positionPoints = const [];
  }
}
