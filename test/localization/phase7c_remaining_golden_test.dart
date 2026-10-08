import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/cck_ac_virtual_lab/screens/cck_ac_virtual_lab_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/molarity/audio/molarity_audio.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/chemistry/states_of_matter/controller/states_of_matter_controller.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_screen.dart';
import 'package:kratos/chemistry/states_of_matter/som_strings.dart';
import 'package:kratos/circuit/screens/circuit_screen.dart';
import 'package:kratos/collision_lab/screens/collision_lab_home.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/fourier_making_waves/screens/fourier_making_waves_home.dart';
import 'package:kratos/friction/view/friction_screen.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/quantum_coin_toss/screens/quantum_coin_toss_home.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';

/// PHASE 7C — remediate remaining LOCALIZED sims' ZH goldens.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_installAudioplayerMocks);

  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  const layout = Size(1024, 768);

  Future<void> capture(
    WidgetTester tester, {
    required String id,
    required Widget child,
    Size size = layout,
    int settleMs = 200,
    bool freezeTickers = false,
  }) async {
    // Install after binding.runTest overwrites onError in setUp.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('ListTile background color') ||
          msg.contains('ink splashes may be invisible') ||
          msg.contains('A RenderFlex overflowed')) {
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget body = child;
    if (freezeTickers) {
      body = TickerMode(enabled: false, child: body);
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1,
            textScaler: TextScaler.noScaling,
          ),
          child: body,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(Duration(milliseconds: settleMs));
    await tester.pump();

    final path = '../goldens/zh/home/${id}_default.png';
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(path));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(path));
  }

  testWidgets('7C ZH · collision-lab', (tester) async {
    await capture(tester, id: 'collision-lab', child: const CollisionLabHome());
  });

  testWidgets('7C ZH · friction', (tester) async {
    await capture(
      tester,
      id: 'friction',
      child: const FrictionScreen(enableAudio: false, autoStartClock: false),
    );
  });

  testWidgets('7C ZH · resistance-in-a-wire', (tester) async {
    await capture(
      tester,
      id: 'resistance-in-a-wire',
      child: ResistanceInAWireScreen(
        // Deterministic impurity dots (same seed as visual golden suite).
        dotRandom: math.Random(0x52494157),
      ),
    );
  });

  testWidgets('7C ZH · circuit', (tester) async {
    await capture(tester, id: 'circuit', child: const CircuitScreen());
  });

  testWidgets('7C ZH · cck-ac-virtual-lab', (tester) async {
    await capture(
      tester,
      id: 'cck-ac-virtual-lab',
      child: const CckAcVirtualLabScreen(),
      settleMs: 300,
    );
  });

  testWidgets('7C ZH · beers-law-lab', (tester) async {
    await capture(
      tester,
      id: 'beers-law-lab',
      child: const BeersLawLabHome(
        concentrationAudio: _SilentConcentrationAudio(),
      ),
    );
  });

  testWidgets('7C ZH · molarity', (tester) async {
    await capture(
      tester,
      id: 'molarity',
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(loc.sim.title('molarity')),
          backgroundColor: const Color(0xFF0891B2),
          foregroundColor: Colors.white,
        ),
        body: MolarityScreen(audio: RecordingMolarityAudio()),
      ),
    );
  });

  testWidgets('7C ZH · fourier-making-waves', (tester) async {
    await capture(
      tester,
      id: 'fourier-making-waves',
      child: const FourierMakingWavesHome(),
      settleMs: 200,
      freezeTickers: true,
    );
  });

  testWidgets('7C ZH · quantum-coin-toss', (tester) async {
    await capture(
      tester,
      id: 'quantum-coin-toss',
      child: const QuantumCoinTossHome(),
      settleMs: 200,
      freezeTickers: true,
    );
  });

  testWidgets('7C ZH · acid-base-solutions', (tester) async {
    final intro = IntroController(random: math.Random(0x41425331));
    addTearDown(intro.dispose);
    await capture(
      tester,
      id: 'acid-base-solutions',
      freezeTickers: true,
      settleMs: 100,
      child: KratosTabbedScreen(
        title: AbsStrings.title,
        accentColor: const Color(0xFF155E75),
        tabs: [
          KratosTab(
            label: AbsStrings.intro,
            child: AbsIntroScreen(controller: intro),
          ),
        ],
      ),
    );
  });

  testWidgets('7C ZH · states-of-matter', (tester) async {
    await capture(
      tester,
      id: 'states-of-matter',
      freezeTickers: true,
      settleMs: 100,
      child: const _FrozenSomGoldenHost(),
    );
  });
}

/// Seeded + paused SoM States tab for deterministic ZH goldens.
class _FrozenSomGoldenHost extends StatefulWidget {
  const _FrozenSomGoldenHost();

  @override
  State<_FrozenSomGoldenHost> createState() => _FrozenSomGoldenHostState();
}

class _FrozenSomGoldenHostState extends State<_FrozenSomGoldenHost>
    with TickerProviderStateMixin {
  late final StatesOfMatterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StatesOfMatterController(
      model: MultipleParticleModel(
        random: SomRandom(0x534F4D31),
        validSubstances: const {
          SubstanceType.neon,
          SubstanceType.argon,
          SubstanceType.diatomicOxygen,
          SubstanceType.water,
        },
      ),
    );
    _controller.attach(this);
    _controller.setPlaying(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: '物质状态',
      accentColor: const Color(0xFF1177AA),
      tabs: [
        KratosTab(
          label: SomStrings.states,
          child: StatesScreen(controller: _controller),
        ),
      ],
    );
  }
}

void _installAudioplayerMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<Object?> handler(MethodCall call) async {
    switch (call.method) {
      case 'create':
      case 'init':
      case 'dispose':
      case 'stop':
      case 'pause':
      case 'resume':
      case 'release':
      case 'seek':
      case 'setVolume':
      case 'setReleaseMode':
      case 'setSourceUrl':
      case 'setSourceAsset':
      case 'play':
      case 'setPlaybackRate':
      case 'getCurrentPosition':
      case 'getDuration':
      case 'listen':
      case 'cancel':
        return 1;
      default:
        return null;
    }
  }

  for (final name in const [
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
    'xyz.luan/audioplayers.global/events',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), handler);
  }

  // Dynamic per-player EventChannels (UUID suffix) — swallow listen/cancel.
  messenger.setMockMessageHandler(
    'xyz.luan/audioplayers/events',
    (ByteData? message) async => null,
  );
}

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
