import 'package:flutter/material.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../bending_light_constants.dart';
import '../phet_font.dart';
import '../screens/stage_scale.dart';
import '../model/enums.dart';
import '../model/substance.dart';
import '../view/source_layout.dart';
import 'scenery_controls.dart';
import 'source_nodes.dart';

List<Substance> mediumChoices() => [
      Substance.air,
      Substance.water,
      Substance.glass,
      Substance.mysteryA,
      Substance.mysteryB,
    ];

/// Material combo + IOR slider/spinner (`MediumControlPanel.ts`).
class MediumControlPanel extends StatelessWidget {
  const MediumControlPanel({
    super.key,
    required this.title,
    required this.substance,
    required this.decimals,
    required this.onSubstance,
    required this.onCustomIndex,
    this.showReadout = true,
    this.yMargin = SourceLayout.mediumYMarginIntro,
    this.framed = true,
    this.width,
  });

  final String title;
  final Substance substance;
  final int decimals;
  final ValueChanged<Substance> onSubstance;
  final ValueChanged<double> onCustomIndex;
  final bool showReadout;
  final double yMargin;

  /// Prisms object controls sit inside the toolbox, so the source panel has
  /// `lineWidth: 0`. Other screens keep the framed panel.
  final bool framed;
  final double? width;

  static const double iorMin = 1.000293;
  static const double iorMax = 1.6;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final mystery = substance.mystery;
    final n = substance.indexForRed;
    final step = _pow10(-decimals);
    return Container(
      width: (width ?? SourceLayout.mediumPanelWidth) * view,
      padding: EdgeInsets.symmetric(
        horizontal: (framed ? SourceLayout.mediumXMargin : 4) * view,
        vertical: yMargin * view,
      ),
      decoration: framed
          ? BoxDecoration(
              color: SourceLayout.panelFill,
              borderRadius: BorderRadius.circular(SourceLayout.panelCornerRadius),
              border: Border.all(
                color: SourceLayout.panelStroke,
                width: SourceLayout.panelLineWidth,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PhetFont.of(12, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8 * view),
              PhetComboBox(
                value: substance.custom ? 'Custom' : substance.name,
                items: [
                  for (final s in mediumChoices()) s.name,
                  'Custom',
                ],
                onSelected: (name) {
                  if (name == 'Custom') {
                    final seed = mystery ? 1.33 : n;
                    onCustomIndex(seed.clamp(iorMin, iorMax));
                  } else {
                    onSubstance(mediumChoices().firstWhere((s) => s.name == name));
                  }
                },
              ),
            ],
          ),
          if (!mystery && showReadout) ...[
            SizedBox(height: 6 * view),
            Row(
              children: [
                Expanded(
                  child: Text('Index of Refraction (n)', style: PhetFont.of(12)),
                ),
                PhetArrowButton(
                  pointRight: false,
                  enabled: n > iorMin,
                  onPressed: () => onCustomIndex((n - step).clamp(iorMin, iorMax)),
                ),
                SizedBox(width: 4 * view),
                Container(
                  width: 45 * view,
                  height: 20 * view,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF000000)),
                  ),
                  child: Text(n.toStringAsFixed(decimals), style: PhetFont.of(12)),
                ),
                SizedBox(width: 4 * view),
                PhetArrowButton(
                  pointRight: true,
                  enabled: n < iorMax,
                  onPressed: () => onCustomIndex((n + step).clamp(iorMin, iorMax)),
                ),
              ],
            ),
          ],
          if (!mystery) ...[
            SizedBox(height: 4 * view),
            PhetHSlider(
              value: n.clamp(iorMin, iorMax),
              min: iorMin,
              max: iorMax,
              trackWidth: (showReadout ? SourceLayout.sliderTrackWidth : 160) * view,
              ticks: indexOfRefractionTicks(),
              onChanged: onCustomIndex,
            ),
          ] else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8 * view),
              child: Text('What is n?', style: PhetFont.of(16)),
            ),
        ],
      ),
    );
  }
}

double _pow10(int exp) {
  var v = 1.0;
  for (var i = 0; i < exp.abs(); i++) {
    v *= exp < 0 ? 0.1 : 10;
  }
  return v;
}

/// Wavelength nm control (`WavelengthControl.ts`). Range 380–700, step 1 nm.
class WavelengthControl extends StatelessWidget {
  const WavelengthControl({
    super.key,
    required this.wavelengthMeters,
    required this.enabled,
    required this.onChangedMeters,
    this.trackWidth = 120,
  });

  final double wavelengthMeters;
  final bool enabled;
  final ValueChanged<double> onChangedMeters;

  /// More Tools passes 120. Prisms passes 146 (`WavelengthControl.ts`).
  final double trackWidth;

  static const double minNm = BendingLightConstants.laserMinWavelengthNm;
  static const double maxNm = BendingLightConstants.laserMaxWavelengthNm;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final nm = (wavelengthMeters * 1e9).clamp(minNm, maxNm);
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhetArrowButton(
                  pointRight: false,
                  scale: 0.6,
                  enabled: nm > minNm,
                  onPressed: () =>
                      onChangedMeters(((nm - 1).clamp(minNm, maxNm)) * 1e-9),
                ),
                SizedBox(width: 4 * view),
                Container(
                  width: 60 * view,
                  height: 18 * view,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF000000)),
                  ),
                  child: Text('${nm.round()} nm', style: PhetFont.of(12)),
                ),
                SizedBox(width: 4 * view),
                PhetArrowButton(
                  pointRight: true,
                  scale: 0.6,
                  enabled: nm < maxNm,
                  onPressed: () =>
                      onChangedMeters(((nm + 1).clamp(minNm, maxNm)) * 1e-9),
                ),
              ],
            ),
            SizedBox(height: 5 * view),
            PhetSpectrumSlider(
              nm: nm,
              minNm: minNm,
              maxNm: maxNm,
              trackWidth: trackWidth * view,
              onChangedNm: (v) => onChangedMeters(v * 1e-9),
            ),
          ],
        ),
      ),
    );
  }
}

/// Time play/pause/step/speed bound to model (not a private Timer).
class BlTimeControl extends StatelessWidget {
  const BlTimeControl({
    super.key,
    required this.isPlaying,
    required this.speed,
    required this.onPlayPause,
    required this.onStep,
    required this.onSpeed,
  });

  final bool isPlaying;
  final TimeSpeed speed;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final ValueChanged<TimeSpeed> onSpeed;

  @override
  Widget build(BuildContext context) {
    return SourceTimeControl(
      isPlaying: isPlaying,
      speed: speed,
      onPlayPause: onPlayPause,
      onStep: onStep,
      onSpeed: onSpeed,
    );
  }
}

class RayViewRow extends StatelessWidget {
  const RayViewRow({
    super.key,
    required this.wave,
    required this.showNormal,
    required this.onRay,
    required this.onWave,
    required this.onNormal,
    this.showAngles = false,
    this.anglesValue = false,
    this.onAngles,
    this.includeViewButtons = true,
    this.includeChecks = true,
  });

  final bool wave;
  final bool showNormal;
  final VoidCallback onRay;
  final VoidCallback onWave;
  final ValueChanged<bool> onNormal;
  final bool showAngles;
  final bool anglesValue;
  final ValueChanged<bool>? onAngles;
  final bool includeViewButtons;
  final bool includeChecks;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * view, vertical: 6 * view),
      decoration: BoxDecoration(
        color: SourceLayout.panelFill,
        borderRadius: BorderRadius.circular(SourceLayout.panelCornerRadius),
        border: Border.all(
          color: SourceLayout.panelStroke,
          width: SourceLayout.panelLineWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (includeViewButtons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PhetAquaRadio(label: 'Ray', selected: !wave, onSelected: onRay),
                SizedBox(height: 10 * view),
                PhetAquaRadio(label: 'Wave', selected: wave, onSelected: onWave),
              ],
            ),
          if (includeChecks)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhetCheckbox(checked: showNormal, onChanged: onNormal),
                SizedBox(width: 5 * view),
                Text('Normal', style: PhetFont.of(12)),
                SizedBox(width: 12 * view),
                const NormalLineIcon(),
              ],
            ),
          if (includeChecks && showAngles) ...[
            SizedBox(height: 6 * view),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhetCheckbox(
                  checked: anglesValue,
                  onChanged: (v) => onAngles?.call(v),
                ),
                SizedBox(width: 5 * view),
                Text('Angles', style: PhetFont.of(12)),
                SizedBox(width: 12 * view),
                const AngleMarkIcon(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ToolBoxPanel extends StatelessWidget {
  const ToolBoxPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SourceLayout.toolboxXMargin * view,
        vertical: SourceLayout.toolboxYMargin * view,
      ),
      decoration: BoxDecoration(
        color: SourceLayout.panelFill,
        border: Border.all(
          color: SourceLayout.panelStroke,
          width: SourceLayout.panelLineWidth,
        ),
        borderRadius: BorderRadius.circular(SourceLayout.panelCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: SourceLayout.toolboxSpacing * view),
            children[i],
          ],
        ],
      ),
    );
  }
}

class ResetAllCorner extends StatelessWidget {
  const ResetAllCorner({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return KratosResetAllButton(
      onPressed: onPressed,
      radius: 19 * StageScale.of(context),
      tooltip: 'Reset All',
    );
  }
}
