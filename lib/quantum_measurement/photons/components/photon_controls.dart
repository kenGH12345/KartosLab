/// Photons controls: Behavior, PhotonPolarizationAngleControl, TimeControlNode.
/// Sources: PhotonPolarizationAngleControl.ts, PhotonsExperimentSceneView.ts
library;

import 'package:flutter/material.dart';

import '../../common/qm_typography.dart';
import '../../common/qm_visual.dart';
import '../../common/system_type.dart';
import '../model/photons_model.dart';
import '../qm_photons_colors.dart';
import 'flat_polarization_indicator.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class PhotonBehaviorControls extends StatelessWidget {
  const PhotonBehaviorControls({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final SystemType mode;
  final ValueChanged<SystemType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(QmStrings.behavior, style: QmTypography.boldTitle),
        const SizedBox(height: 8),
        _RadioRow(
          label: QmStrings.classical,
          selected: mode == SystemType.classical,
          onTap: () => onChanged(SystemType.classical),
        ),
        const SizedBox(height: 8),
        _RadioRow(
          label: QmStrings.quantum,
          selected: mode == SystemType.quantum,
          onTap: () => onChanged(SystemType.quantum),
        ),
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.labelColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0094BD), width: 2),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0094BD),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: labelColor ?? Colors.black87),
          ),
        ],
      ),
    );
  }
}

/// PhotonPolarizationAngleControl — grey panel: radios + Flat indicator.
class PhotonPolarizationAnglePanel extends StatelessWidget {
  const PhotonPolarizationAnglePanel({
    super.key,
    required this.preset,
    required this.customAngle,
    required this.onPresetChanged,
    required this.onCustomAngleChanged,
  });

  final PolarizationPreset preset;
  final double customAngle;
  final ValueChanged<PolarizationPreset> onPresetChanged;
  final ValueChanged<double> onCustomAngleChanged;

  double? get _displayAngle {
    switch (preset) {
      case PolarizationPreset.vertical:
        return 90;
      case PolarizationPreset.horizontal:
        return 0;
      case PolarizationPreset.fortyFiveDegrees:
        return 45;
      case PolarizationPreset.custom:
        return customAngle;
      case PolarizationPreset.unpolarized:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF777777)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                QmStrings.photonPolarizationAngle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _RadioRow(
                label: QmStrings.verticalV,
                selected: preset == PolarizationPreset.vertical,
                labelColor: QmPhotonsColors.verticalPolarization,
                onTap: () => onPresetChanged(PolarizationPreset.vertical),
              ),
              const SizedBox(height: 6),
              _RadioRow(
                label: QmStrings.horizontalH,
                selected: preset == PolarizationPreset.horizontal,
                labelColor: QmPhotonsColors.horizontalPolarization,
                onTap: () => onPresetChanged(PolarizationPreset.horizontal),
              ),
              const SizedBox(height: 6),
              _RadioRow(
                label: '45°',
                selected: preset == PolarizationPreset.fortyFiveDegrees,
                onTap: () =>
                    onPresetChanged(PolarizationPreset.fortyFiveDegrees),
              ),
              const SizedBox(height: 6),
              _RadioRow(
                label: QmStrings.unpolarized,
                selected: preset == PolarizationPreset.unpolarized,
                onTap: () => onPresetChanged(PolarizationPreset.unpolarized),
              ),
              const SizedBox(height: 6),
              _RadioRow(
                label: QmStrings.custom,
                selected: preset == PolarizationPreset.custom,
                onTap: () => onPresetChanged(PolarizationPreset.custom),
              ),
              if (preset == PolarizationPreset.custom) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: 160,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Slider(
                      value: customAngle.clamp(0, 90),
                      min: 0,
                      max: 90,
                      divisions: 18,
                      label: '${customAngle.round()}°',
                      onChanged: onCustomAngleChanged,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0°', style: TextStyle(fontSize: 10)),
                      Text('90°', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlatPolarizationAngleIndicator(
                angleDegrees: _displayAngle,
                scale: 1.15,
              ),
              const SizedBox(height: 2),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⊗', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 4),
                  Text(
                    QmStrings.propagationIntoPage,
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// TimeControlNode — Pause/Play + Step + Normal/Slow radios.
class PhotonTimeControls extends StatelessWidget {
  const PhotonTimeControls({
    super.key,
    required this.isPlaying,
    required this.slowMotion,
    required this.onPlayPause,
    required this.onSlowMotionChanged,
    required this.onStep,
  });

  final bool isPlaying;
  final bool slowMotion;
  final VoidCallback onPlayPause;
  final ValueChanged<bool> onSlowMotionChanged;
  final VoidCallback onStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        QmTimeControlButton(
          kind: isPlaying ? QmTimeControlKind.pause : QmTimeControlKind.play,
          onPressed: onPlayPause,
        ),
        const SizedBox(width: 8),
        QmTimeControlButton(
          kind: QmTimeControlKind.step,
          onPressed: onStep,
        ),
        const SizedBox(width: 14),
        _RadioRow(
          label: QmStrings.normal,
          selected: !slowMotion,
          onTap: () => onSlowMotionChanged(false),
        ),
        const SizedBox(width: 10),
        _RadioRow(
          label: QmStrings.slow,
          selected: slowMotion,
          onTap: () => onSlowMotionChanged(true),
        ),
      ],
    );
  }
}

/// Kept for older imports that still reference the previous name.
typedef PhotonPolarizationControls = PhotonPolarizationAnglePanel;
