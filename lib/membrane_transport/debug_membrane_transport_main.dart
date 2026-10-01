import 'package:flutter/material.dart';

import 'package:kratos/membrane_transport/screens/membrane_transport_home.dart';

/// Phase 7 Android / desktop smoke entry — NOT KartosLab Home.
///
/// Run:
/// `flutter run -t lib/membrane_transport/debug_membrane_transport_main.dart -d emulator-5554`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MembraneTransportDebugApp());
}

class MembraneTransportDebugApp extends StatelessWidget {
  const MembraneTransportDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Membrane Transport (Phase 7 Debug)',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0288D1),
      ),
      home: const Scaffold(
        body: SafeArea(child: MembraneTransportHome()),
      ),
    );
  }
}
