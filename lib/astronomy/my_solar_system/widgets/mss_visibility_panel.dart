/// Visibility + gravity scale — mirrors VisibilityControlPanel subset.
///
/// [MSS-SOURCE] `VisibilityControlPanel.ts`
library;

import 'package:flutter/material.dart';

import '../controller/my_solar_system_controller.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';

class MssVisibilityPanel extends StatelessWidget {
  const MssVisibilityPanel({
    super.key,
    required this.controller,
    this.maxWidth,
  });

  final MySolarSystemController controller;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('mss-visibility-panel'),
      color: MySolarSystemColors.panel,
      borderRadius:
          BorderRadius.circular(MySolarSystemConstants.panelCornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            _check(
              key: const ValueKey('mss-toggle-com'),
              value: controller.centerOfMassVisible,
              label: MySolarSystemStrings.centerOfMass,
              onChanged: controller.setCenterOfMassVisible,
            ),
            _check(
              key: const ValueKey('mss-toggle-velocity'),
              value: controller.velocityVisible,
              label: MySolarSystemStrings.velocityCheckbox,
              onChanged: controller.setVelocityVisible,
            ),
            _check(
              key: const ValueKey('mss-toggle-gravity'),
              value: controller.gravityVisible,
              label: MySolarSystemStrings.gravityForce,
              onChanged: controller.setGravityVisible,
            ),
            if (controller.gravityVisible)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const ValueKey('mss-gravity-zoom-out'),
                        iconSize: 16,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => controller.setGravityForceScalePower(
                          controller.gravityForceScalePower - 1,
                        ),
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Text(
                        controller.gravityForceScalePower.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      IconButton(
                        key: const ValueKey('mss-gravity-zoom-in'),
                        iconSize: 16,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => controller.setGravityForceScalePower(
                          controller.gravityForceScalePower + 1,
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            _check(
              key: const ValueKey('mss-toggle-path'),
              value: controller.pathVisible,
              label: MySolarSystemStrings.path,
              onChanged: controller.setPathVisible,
            ),
            _check(
              key: const ValueKey('mss-toggle-grid'),
              value: controller.gridVisible,
              label: MySolarSystemStrings.grid,
              onChanged: controller.setGridVisible,
            ),
            _check(
              key: const ValueKey('mss-toggle-tape'),
              value: controller.measuringTapeVisible,
              label: MySolarSystemStrings.measuringTape,
              onChanged: controller.setMeasuringTapeVisible,
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _check({
    required Key key,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          key: key,
          value: value,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
