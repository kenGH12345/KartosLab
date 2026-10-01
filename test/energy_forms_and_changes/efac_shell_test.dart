import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/nine_grid_layout.dart';
import 'package:kratos/energy_forms_and_changes/common/layout/efac_viewport_layout.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/screens/energy_forms_and_changes_home.dart';
import 'package:kratos/energy_forms_and_changes/widgets/efac_simulation_shell.dart';

void main() {
  testWidgets('Home bypasses NineGrid and uses EfacSimulationShell',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EnergyFormsAndChangesHome()),
    );
    await tester.pump();

    expect(find.byType(NineGridLayout), findsNothing);
    expect(find.byType(EfacSimulationShell), findsWidgets);
    expect(find.text(EfacStrings.intro), findsOneWidget);
  });

  testWidgets('Live shell width-limited uses bottomCenter FittedBox',
      (tester) async {
    // After AppBar+TabBar, body is shorter than 618 aspect → often width-limited.
    await tester.binding.setSurfaceSize(const Size(1024, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EnergyFormsAndChangesHome()),
    );
    await tester.pump();

    final shellFinder = find.byType(EfacSimulationShell).first;
    final shellContext = tester.element(shellFinder);
    final box = shellContext.findRenderObject()! as RenderBox;
    final viewport = box.size;
    final layout = EfacViewportLayout.compute(viewport);

    final fitted = tester.widget<FittedBox>(
      find.descendant(
        of: shellFinder,
        matching: find.byType(FittedBox),
      ),
    );
    expect(fitted.fit, BoxFit.contain);
    expect(fitted.alignment, layout.fittedAlignment);
    if (layout.widthLimited) {
      expect(layout.offsetY, greaterThanOrEqualTo(0));
      expect(fitted.alignment, Alignment.bottomCenter);
    } else {
      expect(fitted.alignment, Alignment.topCenter);
      expect(layout.dx, greaterThanOrEqualTo(0));
    }
  });
}
