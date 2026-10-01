import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kratos/buoyancy/buoyancy_sim_host.dart';

/// PHASE 7 Android Runtime harness — Simulation Runtime only.
/// NOT KartosLab Home / Registry / category navigation.
///
/// Run:
/// `flutter run -t lib/buoyancy/debug_buoyancy_main.dart -d emulator-5554`
/// `flutter test integration_test/buoyancy_android_runtime_test.dart -d emulator-5554`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BuoyancyAndroidRuntimeApp());
}

class BuoyancyAndroidRuntimeApp extends StatelessWidget {
  const BuoyancyAndroidRuntimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buoyancy (PHASE 7 Runtime)',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1177AA),
        scaffoldBackgroundColor: const Color.fromARGB(255, 19, 165, 224),
      ),
      home: const Scaffold(
        backgroundColor: Color.fromARGB(255, 19, 165, 224),
        body: BuoyancySimHost(
          key: Key('buoyancy_sim_host'),
        ),
      ),
    );
  }
}
