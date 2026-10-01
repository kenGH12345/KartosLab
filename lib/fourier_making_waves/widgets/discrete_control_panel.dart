import 'package:flutter/material.dart';

import '../../common/controls/kratos_radio_group.dart';
import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../model/domain.dart';
import '../model/equation_form.dart';
import '../model/series_type.dart';
import '../model/waveform_kind.dart';
import '../solver/equation_markup.dart';

/// Discrete screen right-hand controls.
class DiscreteControlPanel extends StatelessWidget {
  const DiscreteControlPanel({
    super.key,
    required this.waveform,
    required this.numberOfHarmonics,
    required this.domain,
    required this.seriesType,
    required this.equationForm,
    required this.infiniteHarmonicsVisible,
    required this.wavelengthSelected,
    required this.periodSelected,
    required this.wavelengthOrder,
    required this.periodOrder,
    required this.onWaveform,
    required this.onHarmonics,
    required this.onDomain,
    required this.onSeriesType,
    required this.onEquationForm,
    required this.onInfiniteHarmonics,
    required this.onWavelengthSelected,
    required this.onPeriodSelected,
    required this.onWavelengthOrder,
    required this.onPeriodOrder,
    required this.onErase,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final WaveformKind waveform;
  final int numberOfHarmonics;
  final Domain domain;
  final SeriesType seriesType;
  final EquationForm equationForm;
  final bool infiniteHarmonicsVisible;
  final bool wavelengthSelected;
  final bool periodSelected;
  final int wavelengthOrder;
  final int periodOrder;
  final ValueChanged<WaveformKind> onWaveform;
  final ValueChanged<int> onHarmonics;
  final ValueChanged<Domain> onDomain;
  final ValueChanged<SeriesType> onSeriesType;
  final ValueChanged<EquationForm> onEquationForm;
  final ValueChanged<bool> onInfiniteHarmonics;
  final ValueChanged<bool> onWavelengthSelected;
  final ValueChanged<bool> onPeriodSelected;
  final ValueChanged<int> onWavelengthOrder;
  final ValueChanged<int> onPeriodOrder;
  final VoidCallback onErase;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  bool get _wavelengthEnabled =>
      domain == Domain.space || domain == Domain.spaceAndTime;
  bool get _periodEnabled =>
      domain == Domain.time || domain == Domain.spaceAndTime;

  @override
  Widget build(BuildContext context) {
    final equationForms = EquationMarkup.formsForDomain(domain);
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FmwColors.panelFill,
        border: Border.all(color: FmwColors.panelStroke),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(FmwStrings.waveform,
                style: Theme.of(context).textTheme.labelLarge),
            DropdownButton<WaveformKind>(
              value: waveform,
              isExpanded: true,
              items: [
                for (final w in WaveformKind.values)
                  DropdownMenuItem(
                    value: w,
                    child: Text(FmwStrings.waveformName(w)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onWaveform(v);
              },
            ),
            const SizedBox(height: 8),
            Text(FmwStrings.harmonicsCount,
                style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: [
                IconButton(
                  onPressed: numberOfHarmonics > 1
                      ? () => onHarmonics(numberOfHarmonics - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    '$numberOfHarmonics',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: numberOfHarmonics < FmwConstants.maxHarmonics
                      ? () => onHarmonics(numberOfHarmonics + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            KratosRadioGroup<Domain>(
              label: FmwStrings.domain,
              items: Domain.values,
              itemLabels: [
                for (final d in Domain.values) FmwStrings.domainLabel(d),
              ],
              value: domain,
              onChanged: onDomain,
            ),
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
            Text(FmwStrings.equation,
                style: Theme.of(context).textTheme.labelLarge),
            DropdownButton<EquationForm>(
              value: equationForms.contains(equationForm)
                  ? equationForm
                  : EquationForm.hidden,
              isExpanded: true,
              items: [
                for (final f in equationForms)
                  DropdownMenuItem(
                    value: f,
                    child: Text(FmwStrings.equationFormName(f)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onEquationForm(v);
              },
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.infiniteHarmonics),
              value: infiniteHarmonicsVisible,
              onChanged: (v) => onInfiniteHarmonics(v ?? false),
            ),
            const Divider(),
            Text(FmwStrings.measurementTools,
                style: Theme.of(context).textTheme.labelLarge),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.wavelength),
              value: wavelengthSelected,
              onChanged: _wavelengthEnabled
                  ? (v) => onWavelengthSelected(v ?? false)
                  : null,
            ),
            if (wavelengthSelected && _wavelengthEnabled)
              _OrderSpinner(
                label: 'n (λₙ)',
                value: wavelengthOrder,
                max: numberOfHarmonics,
                onChanged: onWavelengthOrder,
              ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(FmwStrings.period),
              value: periodSelected,
              onChanged:
                  _periodEnabled ? (v) => onPeriodSelected(v ?? false) : null,
            ),
            if (periodSelected && _periodEnabled)
              _OrderSpinner(
                label: 'n (Tₙ)',
                value: periodOrder,
                max: numberOfHarmonics,
                onChanged: onPeriodOrder,
              ),
            const Divider(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  onPressed: onErase,
                  child: Text(FmwStrings.erase),
                ),
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
    );
  }
}

class _OrderSpinner extends StatelessWidget {
  const _OrderSpinner({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove, size: 18),
        ),
        Text('$value'),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add, size: 18),
        ),
      ],
    );
  }
}
