import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/layout/efac_viewport_layout.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// EFAC-only viewport shell: full available tab body → PhET layout() fit.
///
/// Bypasses NineGrid. Does not rescale or re-layout design-space children;
/// [child] is always laid out at 1024×618, then uniformly transformed.
class EfacSimulationShell extends StatelessWidget {
  const EfacSimulationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = EfacViewportLayout.compute(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return RepaintBoundary(
          key: const ValueKey<String>('efac_simulation_shell_boundary'),
          child: ColoredBox(
            color: EfacColors.screenBackground,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: layout.fittedAlignment,
              child: SizedBox(
                width: EfacConstants.layoutWidth,
                height: EfacConstants.layoutHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
