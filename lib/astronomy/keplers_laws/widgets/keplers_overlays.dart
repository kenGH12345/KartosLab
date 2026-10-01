import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
import '../model/period_tracker.dart';

/// Draggable period timer for Third Law.
///
/// [已确认] PeriodTimerNode + PeriodTracker.periodStopwatch
class PeriodTimerOverlay extends StatelessWidget {
  const PeriodTimerOverlay({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    final running =
        controller.periodTracker.trackingState == TrackingState.running;
    final t = controller.periodTracker.periodStopwatchTime;
    return Positioned(
      right: 16,
      top: 80,
      child: Material(
        color: const Color(0xFF333333),
        elevation: 4,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  running ? Icons.pause : Icons.play_arrow,
                  color: KeplersLawsColors.playBlue,
                ),
                onPressed: () => controller.setPeriodTracking(!running),
              ),
              Text(
                '${t.toStringAsFixed(2)} ${KeplersLawsStrings.unitsYears}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic years stopwatch.
///
/// [已确认] StopwatchNode, 2 decimal years
class YearsStopwatchOverlay extends StatelessWidget {
  const YearsStopwatchOverlay({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Material(
        color: const Color(0xFF333333),
        elevation: 4,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  controller.stopwatchRunning ? Icons.pause : Icons.play_arrow,
                  color: KeplersLawsColors.playBlue,
                ),
                onPressed: () =>
                    controller.setStopwatchRunning(!controller.stopwatchRunning),
              ),
              Text(
                '${controller.stopwatchTime.toStringAsFixed(2)} ${KeplersLawsStrings.unitsYears}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
