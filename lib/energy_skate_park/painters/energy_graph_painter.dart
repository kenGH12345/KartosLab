import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/data_sample.dart';
import 'package:kratos/energy_skate_park/model/graphs_model.dart';

/// Plots KE / PE / thermal / total from [dataSamples] — never recomputes energy.
///
/// Source: Graphs EnergyChart.ts + GraphsConstants.PLOT_RANGES.
class EnergyGraphPainter extends CustomPainter {
  EnergyGraphPainter({
    required this.samples,
    required this.independentVariable,
    required this.kineticVisible,
    required this.potentialVisible,
    required this.thermalVisible,
    required this.totalVisible,
    this.zoomIndex = EspConstants.defaultEnergyGraphZoomIndex,
    this.cursorIndex,
    this.padLeft = 36,
    this.padRight = 8,
    this.padTop = 8,
    this.padBottom = 22,
    this.drawOuterAxisLabels = true,
  });

  final List<DataSample> samples;
  final GraphIndependentVariable independentVariable;
  final bool kineticVisible;
  final bool potentialVisible;
  final bool thermalVisible;
  final bool totalVisible;
  final int zoomIndex;
  final int? cursorIndex;
  final double padLeft;
  final double padRight;
  final double padTop;
  final double padBottom;
  final bool drawOuterAxisLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(
      padLeft,
      padTop,
      size.width - padRight,
      size.height - padBottom,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      Paint()..color = EspColors.chartPanelFill,
    );
    canvas.drawRect(
      chart,
      Paint()
        ..color = const Color(0xFFF8F8F8)
        ..style = PaintingStyle.fill,
    );

    final range = EspConstants.plotRanges[
        zoomIndex.clamp(0, EspConstants.plotRanges.length - 1)];
    final eMin = range.$1;
    final eMax = range.$2;

    double xMin;
    double xMax;
    if (independentVariable == GraphIndependentVariable.time) {
      xMin = 0;
      xMax = EspConstants.maxPlottedTime;
      if (samples.isNotEmpty) {
        final tMax = samples.map((s) => s.time).reduce(math.max);
        if (tMax > xMax) {
          xMin = tMax - EspConstants.maxPlottedTime;
          xMax = tMax;
        }
      }
    } else {
      // Position mode: x = positionX + offset (Graphs / EnergySkateParkConstants).
      xMin = 0;
      xMax = 10;
    }

    // Axes
    final axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(chart.left, chart.bottom),
      Offset(chart.right, chart.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chart.left, chart.top),
      Offset(chart.left, chart.bottom),
      axisPaint,
    );

    // Zero energy line
    if (eMin < 0 && eMax > 0) {
      final zy = _mapY(0, eMin, eMax, chart);
      canvas.drawLine(
        Offset(chart.left, zy),
        Offset(chart.right, zy),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );
    }

    void drawSeries(Color color, double Function(DataSample) yOf) {
      if (samples.length < 2) return;
      final path = Path();
      var started = false;
      for (final s in samples) {
        final xVal = independentVariable == GraphIndependentVariable.time
            ? s.time
            : s.positionX + EspConstants.positionPlotOffset;
        if (xVal < xMin || xVal > xMax) continue;
        final px = _mapX(xVal, xMin, xMax, chart);
        final py = _mapY(yOf(s), eMin, eMax, chart);
        if (!started) {
          path.moveTo(px, py);
          started = true;
        } else {
          path.lineTo(px, py);
        }
      }
      if (!started) return;
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (kineticVisible) {
      drawSeries(EspColors.kineticEnergy, (s) => s.kineticEnergy);
    }
    if (potentialVisible) {
      drawSeries(EspColors.potentialEnergy, (s) => s.potentialEnergy);
    }
    if (thermalVisible) {
      drawSeries(EspColors.thermalEnergy, (s) => s.thermalEnergy);
    }
    if (totalVisible) {
      drawSeries(EspColors.totalEnergy, (s) => s.totalEnergy);
    }

    // Cursor vertical line at selected sample.
    if (cursorIndex != null &&
        cursorIndex! >= 0 &&
        cursorIndex! < samples.length) {
      final s = samples[cursorIndex!];
      final xVal = independentVariable == GraphIndependentVariable.time
          ? s.time
          : s.positionX + EspConstants.positionPlotOffset;
      if (xVal >= xMin && xVal <= xMax) {
        final px = _mapX(xVal, xMin, xMax, chart);
        canvas.drawLine(
          Offset(px, chart.top),
          Offset(px, chart.bottom),
          Paint()
            ..color = Colors.black54
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Tick energy labels (inside chart pad when requested).
    if (drawOuterAxisLabels) {
      final labelStyle = const TextStyle(fontSize: 9, color: Colors.black54);
      _paintText(canvas, '${eMax.toStringAsFixed(0)} J',
          Offset(2, chart.top), labelStyle);
      _paintText(canvas, eMin.toStringAsFixed(0),
          Offset(2, chart.bottom - 10), labelStyle);
      final xLabel = independentVariable == GraphIndependentVariable.time
          ? 't (s)'
          : 'x (m)';
      _paintText(canvas, xLabel, Offset(chart.center.dx - 10, size.height - 14),
          labelStyle);
    } else {
      final labelStyle = const TextStyle(fontSize: 9, color: Colors.black45);
      _paintText(
        canvas,
        eMax.toStringAsFixed(0),
        Offset(chart.left + 2, chart.top + 2),
        labelStyle,
      );
      _paintText(
        canvas,
        eMin.toStringAsFixed(0),
        Offset(chart.left + 2, chart.bottom - 12),
        labelStyle,
      );
    }

    if (samples.isEmpty) {
      _paintText(
        canvas,
        'no samples',
        Offset(chart.center.dx - 28, chart.center.dy - 6),
        const TextStyle(fontSize: 11, color: Colors.black38),
      );
    }
  }

  static double _mapX(double v, double min, double max, Rect chart) {
    if (max <= min) return chart.left;
    return chart.left + (v - min) / (max - min) * chart.width;
  }

  static double _mapY(double e, double eMin, double eMax, Rect chart) {
    if (eMax <= eMin) return chart.bottom;
    final t = ((e - eMin) / (eMax - eMin)).clamp(0.0, 1.0);
    return chart.bottom - t * chart.height;
  }

  static void _paintText(
      Canvas canvas, String text, Offset o, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, o);
  }

  @override
  bool shouldRepaint(covariant EnergyGraphPainter old) =>
      old.samples != samples ||
      old.independentVariable != independentVariable ||
      old.kineticVisible != kineticVisible ||
      old.potentialVisible != potentialVisible ||
      old.thermalVisible != thermalVisible ||
      old.totalVisible != totalVisible ||
      old.zoomIndex != zoomIndex ||
      old.cursorIndex != cursorIndex;
}
