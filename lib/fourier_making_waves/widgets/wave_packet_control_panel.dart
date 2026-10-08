import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/controls/kratos_radio_group.dart';
import '../fmw_colors.dart';
import '../fmw_strings.dart';
import '../model/domain.dart';
import '../model/series_type.dart';
import '../model/wave_packet.dart';

/// Wave Packet screen right-hand controls.
class WavePacketControlPanel extends StatelessWidget {
  const WavePacketControlPanel({
    super.key,
    required this.domain,
    required this.seriesType,
    required this.componentSpacing,
    required this.center,
    required this.standardDeviation,
    required this.widthIndicatorsVisible,
    required this.waveformEnvelopeVisible,
    required this.continuousWaveformVisible,
    required this.onDomain,
    required this.onSeriesType,
    required this.onComponentSpacing,
    required this.onCenter,
    required this.onStandardDeviation,
    required this.onWidthIndicators,
    required this.onEnvelope,
    required this.onContinuous,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final Domain domain;
  final SeriesType seriesType;
  final double componentSpacing;
  final double center;
  final double standardDeviation;
  final bool widthIndicatorsVisible;
  final bool waveformEnvelopeVisible;
  final bool continuousWaveformVisible;
  final ValueChanged<Domain> onDomain;
  final ValueChanged<SeriesType> onSeriesType;
  final ValueChanged<double> onComponentSpacing;
  final ValueChanged<double> onCenter;
  final ValueChanged<double> onStandardDeviation;
  final ValueChanged<bool> onWidthIndicators;
  final ValueChanged<bool> onEnvelope;
  final ValueChanged<bool> onContinuous;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FmwColors.panelFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: FmwColors.panelStroke),
      ),
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KratosRadioGroup<Domain>(
              label: FmwStrings.domain,
              items: const [Domain.space, Domain.time],
              itemLabels: [
                FmwStrings.domainLabel(Domain.space),
                FmwStrings.domainLabel(Domain.time),
              ],
              value: domain,
              onChanged: onDomain,
            ),
            const SizedBox(height: 8),
            KratosRadioGroup<SeriesType>(
              label: FmwStrings.seriesType,
              items: SeriesType.values,
              itemLabels: [
                for (final s in SeriesType.values) FmwStrings.seriesLabel(s),
              ],
              value: seriesType,
              onChanged: onSeriesType,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 8),
            Text(FmwStrings.componentSpacing,
                style: Theme.of(context).textTheme.labelLarge),
            DropdownButton<double>(
              value: componentSpacing,
              isExpanded: true,
              items: [
                for (final v in WavePacket.componentSpacingValues)
                  DropdownMenuItem(
                    value: v,
                    child: Text(_spacingLabel(v)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onComponentSpacing(v);
              },
            ),
            const SizedBox(height: 12),
            Text(
              '${FmwStrings.center}: ${(center / math.pi).toStringAsFixed(1)}π',
            ),
            Slider(
              value: center.clamp(WavePacket.centerMin, WavePacket.centerMax),
              min: WavePacket.centerMin,
              max: WavePacket.centerMax,
              onChanged: onCenter,
            ),
            Text(
              '${FmwStrings.standardDeviation}: ${(standardDeviation / math.pi).toStringAsFixed(2)}π',
            ),
            Slider(
              value: standardDeviation.clamp(
                WavePacket.standardDeviationMin,
                WavePacket.standardDeviationMax,
              ),
              min: WavePacket.standardDeviationMin,
              max: WavePacket.standardDeviationMax,
              onChanged: onStandardDeviation,
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.showWidthIndicators),
              value: widthIndicatorsVisible,
              onChanged: (v) => onWidthIndicators(v ?? false),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.showEnvelope),
              value: waveformEnvelopeVisible,
              onChanged: (v) => onEnvelope(v ?? false),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.showContinuous),
              value: continuousWaveformVisible,
              onChanged: (v) => onContinuous(v ?? false),
            ),
            const Divider(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  onPressed: onZoomOut,
                  child: Text(FmwStrings.zoomOut),
                ),
                OutlinedButton(
                  onPressed: onZoomIn,
                  child: Text(FmwStrings.zoomIn),
                ),
                FilledButton(
                  onPressed: onReset,
                  child: Text(FmwStrings.reset),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  static String _spacingLabel(double v) {
    if (v == 0) return '0 (∞)';
    if ((v - math.pi).abs() < 1e-9) return 'π';
    if ((v - math.pi / 2).abs() < 1e-9) return 'π/2';
    if ((v - math.pi / 4).abs() < 1e-9) return 'π/4';
    return v.toStringAsFixed(3);
  }
}
