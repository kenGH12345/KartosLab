import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../view/experiment/experiment_screen.dart';
import '../view/high_intensity/high_intensity_screen.dart';
import '../view/single_particles/single_particles_screen.dart';

/// Phase 7 Android technical-gate harness.
///
/// **Not** Home Integration — temporary launcher so the three QWI screens can
/// be installed/run/touched on a real Android runtime before Phase 8.
///
/// Entry: `flutter run -t lib/physics/quantum_wave_interference/debug/qwi_android_gate_app.dart`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const QwiAndroidGateApp());
}

class QwiAndroidGateApp extends StatelessWidget {
  const QwiAndroidGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QWI Android Gate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1177AA)),
        useMaterial3: true,
      ),
      home: const QwiAndroidGateHub(),
      builder: (context, child) {
        final app = child ?? const SizedBox.shrink();
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
          return ExcludeSemantics(child: app);
        }
        return app;
      },
    );
  }
}

/// Hub with Back-capable routes to each independent QWI screen.
class QwiAndroidGateHub extends StatelessWidget {
  const QwiAndroidGateHub({super.key});

  static const Key hubKey = Key('qwi_android_gate_hub');
  static const Key experimentNavKey = Key('qwi_gate_nav_experiment');
  static const Key hiNavKey = Key('qwi_gate_nav_hi');
  static const Key spNavKey = Key('qwi_gate_nav_sp');

  Future<void> _open(BuildContext context, String title, Widget screen) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: const BackButton(key: Key('qwi_gate_back')),
          ),
          body: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: hubKey,
      appBar: AppBar(title: const Text('QWI Android Gate (Phase 7)')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Temporary technical-gate launcher — not Home Integration.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: experimentNavKey,
            onPressed: () => _open(
              context,
              'Experiment',
              const ExperimentScreen(seed: 7, autoStartClock: true),
            ),
            child: const Text('Open Experiment'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: hiNavKey,
            onPressed: () => _open(
              context,
              'High Intensity',
              // Gate re-entry uses live clock; wave sampling is dirty-flagged.
              const HighIntensityScreen(seed: 7, autoStartClock: true),
            ),
            child: const Text('Open High Intensity'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: spNavKey,
            onPressed: () => _open(
              context,
              'Single Particles',
              const SingleParticlesScreen(seed: 7, autoStartClock: true),
            ),
            child: const Text('Open Single Particles'),
          ),
        ],
      ),
    );
  }
}
