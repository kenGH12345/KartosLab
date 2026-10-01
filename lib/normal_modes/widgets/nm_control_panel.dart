import 'package:flutter/material.dart';

import '../model/time_speed.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import 'nm_time_control.dart';

class NmControlPanel extends StatelessWidget {
  const NmControlPanel({
    super.key,
    required this.numberOfMasses,
    required this.numberOfMassesDisplay,
    required this.springsVisible,
    required this.playing,
    required this.speed,
    required this.onInitialPositions,
    required this.onZeroPositions,
    required this.onNumberOfMasses,
    required this.onSpringsVisible,
    required this.onPlayPause,
    required this.onStep,
    required this.onSpeed,
    this.phasesVisible,
    this.onPhasesVisible,
  });

  final int numberOfMasses;
  final String numberOfMassesDisplay;
  final bool springsVisible;
  final bool playing;
  final NmTimeSpeed speed;
  final VoidCallback onInitialPositions;
  final VoidCallback onZeroPositions;
  final ValueChanged<int> onNumberOfMasses;
  final ValueChanged<bool> onSpringsVisible;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final ValueChanged<NmTimeSpeed> onSpeed;
  final bool? phasesVisible;
  final ValueChanged<bool>? onPhasesVisible;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: NormalModesColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: NormalModesColors.panelStroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FlatButton(
            label: NormalModesStrings.initialPositions,
            onTap: onInitialPositions,
          ),
          const SizedBox(height: 12),
          _FlatButton(
            label: NormalModesStrings.zeroPositions,
            onTap: onZeroPositions,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Flexible(
                child: Text(
                  NormalModesStrings.numberOfMasses,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: NormalModesConstants.generalFontSize),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                numberOfMassesDisplay,
                style: const TextStyle(
                  fontSize: NormalModesConstants.generalFontSize,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              min: NormalModesConstants.minMassesPerRow.toDouble(),
              max: NormalModesConstants.maxMassesPerRow.toDouble(),
              divisions: NormalModesConstants.maxMassesPerRow -
                  NormalModesConstants.minMassesPerRow,
              value: numberOfMasses.toDouble(),
              onChanged: (v) => onNumberOfMasses(v.round()),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: springsVisible,
                onChanged: (v) => onSpringsVisible(v ?? true),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Flexible(
                child: Text(
                  NormalModesStrings.showSprings,
                  style: TextStyle(fontSize: NormalModesConstants.generalFontSize),
                ),
              ),
            ],
          ),
          if (phasesVisible != null)
            Row(
              children: [
                Checkbox(
                  value: phasesVisible!,
                  onChanged: (v) => onPhasesVisible?.call(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Flexible(
                  child: Text(
                    NormalModesStrings.showPhases,
                    style: TextStyle(fontSize: NormalModesConstants.generalFontSize),
                  ),
                ),
              ],
            ),
          const Divider(color: Color(0xFFB4B4B4)),
          NmTimeControl(
            playing: playing,
            speed: speed,
            onPlayPause: onPlayPause,
            onStep: onStep,
            onSpeed: onSpeed,
          ),
        ],
      ),
    );
  }
}

class _FlatButton extends StatelessWidget {
  const _FlatButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: NormalModesColors.buttonBase,
        side: const BorderSide(color: NormalModesColors.buttonStroke, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: NormalModesConstants.generalFontSize),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(label),
    );
  }
}

class NmResetButton extends StatelessWidget {
  const NmResetButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NormalModesColors.resetOrange,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.refresh, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
