import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../controller/discrete_controller.dart';
import '../controller/wave_game_controller.dart';
import '../controller/wave_packet_controller.dart';
import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../model/axis_description.dart';
import '../model/domain.dart';
import '../model/series_type.dart';
import '../model/wave_game_level.dart';
import '../solver/equation_markup.dart';
import '../solver/fourier_synthesis.dart';
import '../solver/harmonic_quantities.dart';
import '../solver/wave_packet_math.dart';
import '../solver/waveform_presets.dart';
import 'fmw_mvt.dart';
import 'fmw_render_data.dart';

/// Builds painter-ready [RenderData] from models via solvers (no math in painters).
class FmwRenderBuilder {
  FmwRenderBuilder._();

  static DiscreteRenderData fromDiscrete(DiscreteController c) {
    final m = c.model;
    final series = m.fourierSeries;
    final n = series.numberOfHarmonics;
    final yAxis = DiscreteAxisDescriptions.defaultYAxisDescription;
    final xAxis = m.xAxisDescription;
    final xRange = xAxis.createRangeForDomain(m.domain, series.L, series.T);

    final bars = <FmwAmplitudeBarData>[
      for (var i = 0; i < n; i++)
        FmwAmplitudeBarData(
          order: i + 1,
          value: series.amplitudes[i],
          color: FmwColors.harmonicColor(i + 1),
        ),
    ];

    final harmonicPolylines = <FmwPolylineData>[];
    final mvt = FmwMvt.forChart(
      xMin: xRange.$1,
      xMax: xRange.$2,
      yMin: yAxis.rangeMin,
      yMax: yAxis.rangeMax,
      width: FmwConstants.chartWidth,
      height: FmwConstants.chartHeight,
    );

    for (var i = 0; i < n; i++) {
      final amp = series.amplitudes[i];
      if (amp == 0) continue;
      final order = i + 1;
      final points = FourierSynthesis.createHarmonicDataSet(
        order: order,
        amplitude: amp,
        xAxisDescription: xAxis,
        domain: m.domain,
        seriesType: m.seriesType,
        t: m.t,
        L: series.L,
        T: series.T,
      );
      harmonicPolylines.add(
        FmwPolylineData(
          points: _mapPoints(points, mvt),
          color: FmwColors.harmonicColor(order),
        ),
      );
    }

    final sumPoints = FourierSynthesis.createSumDataSet(
      amplitudes: series.amplitudes,
      xAxisDescription: xAxis,
      domain: m.domain,
      seriesType: m.seriesType,
      t: m.t,
      L: series.L,
      T: series.T,
    );
    final sumPolylines = <FmwPolylineData>[
      FmwPolylineData(
        points: _mapPoints(sumPoints, mvt),
        color: FmwColors.sumPlotStroke,
        strokeWidth: 2,
      ),
    ];

    if (m.infiniteHarmonicsVisible) {
      final infinite = WaveformPresets.getInfiniteHarmonicsDataSet(
        m.waveform,
        m.domain,
        m.seriesType,
        m.t,
        series.L,
        series.T,
      );
      if (infinite != null) {
        sumPolylines.insert(
          0,
          FmwPolylineData(
            points: _mapPoints(infinite, mvt),
            color: FmwColors.secondaryWaveformStroke,
            strokeWidth: 1.5,
          ),
        );
      }
    }

    final gridScale = m.domain == Domain.time ? series.T : series.L;

    FmwCalipersData? wavelengthCalipers;
    if (m.wavelengthCalipersVisible) {
      final order = m.wavelengthTool.order;
      final lambda = HarmonicQuantities.wavelength(order, L: series.L);
      wavelengthCalipers = FmwCalipersData(
        origin: Offset(m.wavelengthTool.positionX, m.wavelengthTool.positionY),
        measuredWidthView: mvt.modelToViewDeltaX(lambda),
        color: FmwColors.harmonicColor(order),
        label: 'λ$order',
      );
    }

    FmwCalipersData? periodCalipers;
    if (m.periodCalipersVisible) {
      final order = m.periodTool.order;
      final periodN = HarmonicQuantities.period(order, fundamentalPeriod: series.T);
      periodCalipers = FmwCalipersData(
        origin: Offset(m.periodTool.positionX, m.periodTool.positionY),
        measuredWidthView: mvt.modelToViewDeltaX(periodN),
        color: FmwColors.harmonicColor(order),
        label: 'T$order',
      );
    }

    FmwPeriodClockData? periodClock;
    if (m.periodClockVisible) {
      final order = m.periodTool.order;
      final periodN =
          HarmonicQuantities.period(order, fundamentalPeriod: series.T);
      final percent = periodN == 0 ? 0.0 : (m.t % periodN) / periodN;
      periodClock = FmwPeriodClockData(
        center: Offset(m.periodClockPositionX, m.periodClockPositionY),
        radius: 28,
        percentTime: percent,
        color: FmwColors.harmonicColor(order),
        label: 'T$order',
      );
    }

    final equationText = EquationMarkup.getGeneralFormMarkup(
      m.domain,
      m.seriesType,
      m.equationForm,
    );

    return DiscreteRenderData(
      bars: bars,
      amplitudesYMin: yAxis.rangeMin,
      amplitudesYMax: yAxis.rangeMax,
      harmonicsChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: yAxis.rangeMin,
        yMax: yAxis.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing * gridScale,
        gridYSpacing: yAxis.gridLineSpacing,
        polylines: harmonicPolylines,
        width: FmwConstants.chartWidth,
        height: FmwConstants.chartHeight,
      ),
      sumChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: yAxis.rangeMin,
        yMax: yAxis.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing * gridScale,
        gridYSpacing: yAxis.gridLineSpacing,
        polylines: sumPolylines,
        width: FmwConstants.chartWidth,
        height: FmwConstants.chartHeight,
      ),
      numberOfHarmonics: n,
      wavelengthCalipers: wavelengthCalipers,
      periodCalipers: periodCalipers,
      periodClock: periodClock,
      equationText: equationText,
    );
  }

  static WaveGameRenderData? fromWaveGame(WaveGameController c) {
    final level = c.selectedLevel;
    if (level == null) return null;
    return _fromWaveGameLevel(level);
  }

  static WaveGameRenderData _fromWaveGameLevel(WaveGameLevel level) {
    final yAxis = DiscreteAxisDescriptions.defaultYAxisDescription;
    final xAxis = DiscreteAxisDescriptions.defaultXAxisDescription;
    final guess = level.guessSeries;
    final answer = level.answerSeries;
    final xRange = xAxis.createRangeForDomain(Domain.space, guess.L, guess.T);
    final nControls = level.numberOfAmplitudeControls;

    final bars = <FmwAmplitudeBarData>[
      for (var i = 0; i < nControls; i++)
        FmwAmplitudeBarData(
          order: i + 1,
          value: guess.amplitudes[i],
          color: FmwColors.harmonicColor(i + 1),
        ),
    ];

    final mvt = FmwMvt.forChart(
      xMin: xRange.$1,
      xMax: xRange.$2,
      yMin: yAxis.rangeMin,
      yMax: yAxis.rangeMax,
    );

    final guessPoints = FourierSynthesis.createSumDataSet(
      amplitudes: guess.amplitudes,
      xAxisDescription: xAxis,
      domain: Domain.space,
      seriesType: SeriesType.sin,
      t: 0,
      L: guess.L,
      T: guess.T,
    );

    final answerPoints = FourierSynthesis.createSumDataSet(
      amplitudes: answer.amplitudes,
      xAxisDescription: xAxis,
      domain: Domain.space,
      seriesType: SeriesType.sin,
      t: 0,
      L: answer.L,
      T: answer.T,
    );

    // PhET Sum chart always overlays answer (magenta) under guess (black).
    final sumPolylines = <FmwPolylineData>[
      FmwPolylineData(
        points: _mapPoints(answerPoints, mvt),
        color: FmwColors.answerSumPlotStroke,
        strokeWidth: FmwConstants.secondaryWaveformLineWidth,
      ),
      FmwPolylineData(
        points: _mapPoints(guessPoints, mvt),
        color: FmwColors.guessSumPlotStroke,
        strokeWidth: 2,
      ),
    ];

    final harmonicPolylines = <FmwPolylineData>[];
    for (var i = 0; i < nControls; i++) {
      final amp = guess.amplitudes[i];
      if (amp == 0) continue;
      final order = i + 1;
      final pts = FourierSynthesis.createHarmonicDataSet(
        order: order,
        amplitude: amp,
        xAxisDescription: xAxis,
        domain: Domain.space,
        seriesType: SeriesType.sin,
        t: 0,
        L: guess.L,
        T: guess.T,
      );
      harmonicPolylines.add(
        FmwPolylineData(
          points: _mapPoints(pts, mvt),
          color: FmwColors.harmonicColor(order),
        ),
      );
    }

    return WaveGameRenderData(
      bars: bars,
      amplitudesYMin: yAxis.rangeMin,
      amplitudesYMax: yAxis.rangeMax,
      harmonicsChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: yAxis.rangeMin,
        yMax: yAxis.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing * guess.L,
        gridYSpacing: yAxis.gridLineSpacing,
        polylines: harmonicPolylines,
      ),
      sumChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: yAxis.rangeMin,
        yMax: yAxis.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing * guess.L,
        gridYSpacing: yAxis.gridLineSpacing,
        polylines: sumPolylines,
      ),
      numberOfAmplitudeControls: nControls,
      isSolved: level.isSolved,
      isMatched: level.isMatched,
    );
  }

  static WavePacketRenderData fromWavePacket(WavePacketController c) {
    final m = c.model;
    final packet = m.wavePacket;
    final xAxis = m.xAxisDescription;
    final xRange = xAxis.createRange(1);
    final yAmp = m.amplitudesYAxisDescription;
    final ySum = WavePacketAxisDescriptions.sumYAxisDescription;

    final kRange = WavePacketAxisDescriptions.amplitudesXAxisDescription
        .createRange(math.pi);
    final amplitudesXMin = kRange.$1;
    final amplitudesXMax = kRange.$2;

    final components = packet.components;
    final bars = <FmwAmplitudeBarData>[
      for (var i = 0; i < components.length; i++)
        FmwAmplitudeBarData(
          order: i + 1,
          value: components[i].amplitude,
          color: _componentGray(i, components.length),
          waveNumber: components[i].waveNumber,
        ),
    ];

    final mvtAmp = FmwMvt.forChart(
      xMin: amplitudesXMin,
      xMax: amplitudesXMax,
      yMin: yAmp.rangeMin,
      yMax: yAmp.rangeMax,
    );

    final continuousPts = m.createContinuousWaveformDataSet();
    final continuousPolyline = _mapPoints(continuousPts, mvtAmp);

    FmwWidthIndicatorData? ampWidth;
    if (m.widthIndicatorsVisible) {
      final ind = WavePacketMath.amplitudesWidthIndicator(
        center: packet.center,
        standardDeviation: packet.standardDeviation,
        componentSpacing: packet.componentSpacing,
      );
      final centerView = mvtAmp.modelToView(ind.x, ind.y);
      ampWidth = FmwWidthIndicatorData(
        centerView: centerView,
        halfWidthView: mvtAmp.modelToViewDeltaX(ind.width) / 2,
        label: m.domain == Domain.space ? '2σₖ' : '2σω',
      );
    }

    final componentSets = m.createComponentDataSets();
    final mvtComponents = FmwMvt.forChart(
      xMin: xRange.$1,
      xMax: xRange.$2,
      yMin: ySum.rangeMin,
      yMax: ySum.rangeMax,
    );
    final componentPolylines = <FmwPolylineData>[
      for (var i = 0; i < componentSets.length; i++)
        FmwPolylineData(
          points: _mapPoints(componentSets[i], mvtComponents),
          color: _componentGray(i, componentSets.length),
          strokeWidth: 1,
        ),
    ];

    final sumPoints = m.createSumDataSet();
    final envelopePoints = m.createEnvelopeDataSet();
    final mvtSum = FmwMvt.forChart(
      xMin: xRange.$1,
      xMax: xRange.$2,
      yMin: ySum.rangeMin,
      yMax: ySum.rangeMax,
    );

    FmwWidthIndicatorData? sumWidth;
    if (m.widthIndicatorsVisible) {
      final ind = WavePacketMath.sumWidthIndicator(
        conjugateStandardDeviation: packet.conjugateStandardDeviation,
      );
      final centerView = mvtSum.modelToView(ind.x, ind.y);
      sumWidth = FmwWidthIndicatorData(
        centerView: centerView,
        halfWidthView: mvtSum.modelToViewDeltaX(ind.width) / 2,
        label: m.domain == Domain.space ? '2σₓ' : '2σₜ',
      );
    }

    final sumPolylines = <FmwPolylineData>[
      if (envelopePoints.isNotEmpty)
        FmwPolylineData(
          points: _mapPoints(envelopePoints, mvtSum),
          color: FmwColors.secondaryWaveformStroke,
          strokeWidth: 1.5,
        ),
      if (sumPoints.isNotEmpty)
        FmwPolylineData(
          points: _mapPoints(sumPoints, mvtSum),
          color: FmwColors.sumPlotStroke,
          strokeWidth: 2,
        ),
    ];

    return WavePacketRenderData(
      amplitudeBars: bars,
      amplitudesYMin: yAmp.rangeMin,
      amplitudesYMax: yAmp.rangeMax,
      amplitudesXMin: amplitudesXMin,
      amplitudesXMax: amplitudesXMax,
      continuousPolyline: continuousPolyline,
      amplitudesWidthIndicator: ampWidth,
      componentsChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: ySum.rangeMin,
        yMax: ySum.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing,
        gridYSpacing: ySum.gridLineSpacing,
        polylines: componentPolylines,
      ),
      sumChart: FmwChartRenderData(
        xMin: xRange.$1,
        xMax: xRange.$2,
        yMin: ySum.rangeMin,
        yMax: ySum.rangeMax,
        gridXSpacing: xAxis.gridLineSpacing,
        gridYSpacing: ySum.gridLineSpacing,
        polylines: sumPolylines,
        widthIndicator: sumWidth,
      ),
    );
  }

  static List<Offset> _mapPoints(List<FmwPoint> points, FmwMvt mvt) {
    return [for (final p in points) mvt.modelToView(p.x, p.y)];
  }

  static Color _componentGray(int index, int total) {
    if (total <= 1) {
      final g = FmwColors.fourierComponentGrayMin.round();
      return Color.fromRGBO(g, g, g, 1);
    }
    final t = index / (total - 1);
    final g = (FmwColors.fourierComponentGrayMin +
            t *
                (FmwColors.fourierComponentGrayMax -
                    FmwColors.fourierComponentGrayMin))
        .round()
        .clamp(0, 255);
    return Color.fromRGBO(g, g, g, 1);
  }
}
