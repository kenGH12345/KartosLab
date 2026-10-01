/// Lab Bodies spinner. [MSS-SOURCE] `NumberOfBodiesControl.ts`
library;

import 'package:flutter/material.dart';

import '../controller/my_solar_system_controller.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';

class MssBodiesControl extends StatelessWidget {
  const MssBodiesControl({super.key, required this.controller});

  final MySolarSystemController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isLab) return const SizedBox.shrink();
    final n = controller.numberOfActiveBodies;
    return Material(
      key: const ValueKey('mss-bodies-control'),
      color: MySolarSystemColors.panel,
      borderRadius:
          BorderRadius.circular(MySolarSystemConstants.panelCornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              MySolarSystemStrings.bodies,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const ValueKey('mss-bodies-dec'),
                  onPressed: n > MySolarSystemConstants.labBodiesMin
                      ? () => controller.setNumberOfActiveBodies(n - 1)
                      : null,
                  icon: const Icon(Icons.remove, color: Colors.white),
                ),
                Text(
                  '$n',
                  key: const ValueKey('mss-bodies-count'),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                IconButton(
                  key: const ValueKey('mss-bodies-inc'),
                  onPressed: n < MySolarSystemConstants.labBodiesMax
                      ? () => controller.setNumberOfActiveBodies(n + 1)
                      : null,
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
