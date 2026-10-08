import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_phet_time_control.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/common/widgets/time_control_bar.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/common/simulation_clock.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('shared chrome strings are Chinese', () {
    expect(loc.shared.resetAll, '全部重置');
    expect(loc.shared.play, '播放');
    expect(loc.shared.pause, '暂停');
    expect(loc.shared.stepForward, '前进一帧');
    expect(loc.shared.back, '返回');
  });

  testWidgets('KratosResetAllButton defaults to Chinese tooltip/semantics',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KratosResetAllButton(onPressed: () {}),
        ),
      ),
    );
    final semantics = tester.getSemantics(find.byType(KratosResetAllButton));
    expect(semantics.label, loc.shared.resetAllSemantics);
  });

  testWidgets('TimeControlBar tooltips are localized', (tester) async {
    final clock = SimulationClock();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TimeControlBar(clock: clock)),
      ),
    );
    expect(find.byTooltip(loc.shared.play), findsOneWidget);
    expect(find.byTooltip(loc.shared.stepForward), findsOneWidget);
    expect(find.byTooltip(loc.shared.reset), findsOneWidget);
  });

  testWidgets('KratosPhetTimeControl exposes Chinese semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KratosPhetTimeControl(
            isPlaying: false,
            onPlayPause: () {},
            onStep: () {},
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel(loc.shared.playSemantics), findsOneWidget);
    expect(
      find.bySemanticsLabel(loc.shared.stepForwardSemantics),
      findsOneWidget,
    );
  });
}
