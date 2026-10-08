import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/screens/home_disciplines.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 7B — capture Chinese UI goldens under `test/goldens/zh/`.
///
/// ```
/// flutter test --update-goldens test/localization/global_zh_golden_capture_test.dart
/// flutter test test/localization/global_zh_golden_capture_test.dart
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  const layout = Size(1024, 768);

  /// Covered by `phase7c_remaining_golden_test.dart` (audio mock / seeded RNG /
  /// TickerMode freeze). Do not re-capture here without those harnesses.
  const skipIds = <String>{
    'circuit',
    'beers-law-lab',
    'collision-lab',
    'friction',
    'cck-ac-virtual-lab',
    'resistance-in-a-wire',
    'quantum-coin-toss',
    'fourier-making-waves',
    'acid-base-solutions',
    'states-of-matter',
    'molarity',
  };

  Future<void> pumpAndCapture(
    WidgetTester tester, {
    required String goldenRelPath,
    required Widget child,
    Size size = layout,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1,
            textScaler: TextScaler.noScaling,
          ),
          child: child,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(goldenRelPath),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(goldenRelPath),
    );
  }

  testWidgets('ZH golden · home default', (tester) async {
    await pumpAndCapture(
      tester,
      goldenRelPath: '../goldens/zh/global/home_default.png',
      child: const HomeScreen(),
    );
  });

  testWidgets('ZH golden · shared chrome reset', (tester) async {
    await pumpAndCapture(
      tester,
      goldenRelPath: '../goldens/zh/global/shared_reset_all.png',
      size: const Size(120, 120),
      child: const Scaffold(
        body: Center(
          child: KratosResetAllButton(onPressed: _noop, radius: 20.5),
        ),
      ),
    );
  });

  testWidgets('ZH golden · concentration default', (tester) async {
    final model = ConcentrationModel();
    addTearDown(model.dispose);
    await pumpAndCapture(
      tester,
      goldenRelPath: '../goldens/zh/phase6/concentration_default.png',
      size: ConcentrationLayout.layoutBounds,
      child: ConcentrationScreen(
        model: model,
        audio: const _SilentConcentrationAudio(),
        showAppBar: true,
      ),
    );
  });

  final entries = buildHomeDisciplines()
      .expand((d) => d.groups)
      .expand((g) => g.sims)
      .where((e) => !skipIds.contains(e.id))
      .toList();

  for (final e in entries) {
    testWidgets('ZH golden · home/${e.id}', (tester) async {
      await pumpAndCapture(
        tester,
        goldenRelPath: '../goldens/zh/home/${e.id}_default.png',
        child: Builder(builder: e.builder),
      );
    });
  }
}

void _noop() {}

class _SilentConcentrationAudio implements ConcentrationAudio {
  const _SilentConcentrationAudio();

  @override
  Future<void> onDragStart() async {}

  @override
  Future<void> onDragEnd({bool interrupted = false}) async {}

  @override
  Future<void> onFaucetClosed() async {}

  @override
  Future<void> stopAll() async {}

  @override
  Future<void> dispose() async {}

  @override
  bool get isDragging => false;

  @override
  bool get isDisposed => false;

  @override
  int get grabCount => 0;

  @override
  int get releaseCount => 0;
}
