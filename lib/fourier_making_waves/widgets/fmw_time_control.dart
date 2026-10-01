import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../model/domain.dart';

/// Play / pause / step — enabled only for [Domain.spaceAndTime].
class FmwTimeControl extends StatelessWidget {
  const FmwTimeControl({
    super.key,
    required this.domain,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onStep,
  });

  final Domain domain;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;

  @override
  Widget build(BuildContext context) {
    final enabled = domain == Domain.spaceAndTime;
    return Material(
      color: FmwColors.panelFill,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: isPlaying ? FmwStrings.pause : FmwStrings.play,
              onPressed: enabled ? onPlayPause : null,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              tooltip: FmwStrings.step,
              onPressed: enabled ? onStep : null,
              icon: const Icon(Icons.skip_next),
            ),
            const SizedBox(width: 12),
            Text(
              enabled
                  ? FmwStrings.domainLabel(Domain.spaceAndTime)
                  : '${FmwStrings.domain}: ${FmwStrings.domainLabel(domain)}',
              style: TextStyle(
                color: enabled ? Colors.black87 : Colors.black45,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'dt=${FmwConstants.stepDt.toStringAsFixed(0)}ms',
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
