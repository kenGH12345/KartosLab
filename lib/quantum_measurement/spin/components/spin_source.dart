/// Particle source — ParticleSourceNode.ts
/// Body: barrel + pink fire / continuous slider; mode radios BELOW apparatus.
library;

import 'package:flutter/material.dart';

import '../model/spin_model.dart';

class SpinSourceNode extends StatelessWidget {
  const SpinSourceNode({
    super.key,
    required this.sourceMode,
    required this.particleAmount,
    required this.onFireSingle,
    required this.onSourceModeChanged,
    required this.onParticleAmountChanged,
  });

  final SourceMode sourceMode;
  final double particleAmount;
  final VoidCallback onFireSingle;
  final ValueChanged<SourceMode> onSourceModeChanged;
  final ValueChanged<double> onParticleAmountChanged;

  /// Apparatus body only (excludes label + mode radios).
  static const bodySize = Size(108, 108); // 0.6 * 180

  /// Height of title above body (label + gap) — for centering on model point.
  static const labelAboveHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label ABOVE apparatus (ParticleSourceNode.ts)
        const SizedBox(
          width: 108,
          height: labelAboveHeight - 4,
          child: Text(
            'Spin-1/2 Source',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        // Apparatus body
        SizedBox(
          width: bodySize.width,
          height: bodySize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main housing
              Container(
                width: bodySize.width,
                height: bodySize.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black54, width: 0.5),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFBFBEBE),
                      Color(0xFF878787),
                    ],
                    stops: [0.0, 0.2, 1.0],
                  ),
                ),
              ),
              // Barrel (rotated square on right)
              Positioned(
                right: -10,
                top: bodySize.height / 2 - 14,
                child: Transform.rotate(
                  angle: 0.785398, // π/4
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black54, width: 0.5),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFFBFBEBE),
                          Color(0xFF878787),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Fire button / continuous slider
              Center(
                child: sourceMode == SourceMode.single
                    ? Material(
                        color: const Color(0xFFCC00CC),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onFireSingle,
                          child: const SizedBox(width: 42, height: 42),
                        ),
                      )
                    : SizedBox(
                        width: bodySize.width - 20,
                        child: Slider(
                          value: particleAmount.clamp(0, 1),
                          onChanged: onParticleAmountChanged,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Source mode — AquaRadioButtonGroup below apparatus (ParticleSourceNode.ts)
        _ModeRadio(
          label: 'Single Particle',
          selected: sourceMode == SourceMode.single,
          onTap: () => onSourceModeChanged(SourceMode.single),
        ),
        const SizedBox(height: 6),
        _ModeRadio(
          label: 'Continuous',
          selected: sourceMode == SourceMode.continuous,
          onTap: () => onSourceModeChanged(SourceMode.continuous),
        ),
      ],
    );
  }
}

class _ModeRadio extends StatelessWidget {
  const _ModeRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
