import 'package:flutter/material.dart';

import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';

/// PHASE 9 Android Runtime harness — Simulation Runtime only.
/// NOT KartosLab Home / Registry / category navigation.
///
/// One screen mounted at a time (leave = dispose) for lifecycle fidelity.
///
/// Run:
/// `flutter run -t lib/quantum_measurement/debug_quantum_measurement_main.dart -d emulator-5554`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuantumMeasurementAndroidRuntimeApp());
}

class QuantumMeasurementAndroidRuntimeApp extends StatelessWidget {
  const QuantumMeasurementAndroidRuntimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quantum Measurement (PHASE 9 Runtime)',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
      ),
      home: const QmRuntimeShell(),
    );
  }
}

/// Temporary runtime chrome — not product Home.
class QmRuntimeShell extends StatefulWidget {
  const QmRuntimeShell({super.key});

  @override
  State<QmRuntimeShell> createState() => QmRuntimeShellState();
}

class QmRuntimeShellState extends State<QmRuntimeShell> {
  static const screenNames = ['Coins', 'Photons', 'Spin', 'Bloch'];
  int index = 0;

  void selectScreen(int i) {
    if (i == index) return;
    setState(() => index = i);
  }

  Widget get _active {
    switch (index) {
      case 1:
        return const QuantumMeasurementPhotonsScreen(
          key: Key('qm_screen_photons'),
        );
      case 2:
        return const QuantumMeasurementSpinScreen(
          key: Key('qm_screen_spin'),
        );
      case 3:
        return const QuantumMeasurementBlochScreen(
          key: Key('qm_screen_bloch'),
        );
      case 0:
      default:
        return const QuantumMeasurementCoinsScreen(
          key: Key('qm_screen_coins'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: const Color(0xFF1565C0),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    for (var i = 0; i < screenNames.length; i++)
                      Expanded(
                        child: TextButton(
                          key: Key('qm_tab_${screenNames[i].toLowerCase()}'),
                          onPressed: () => selectScreen(i),
                          child: Text(
                            screenNames[i],
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: i == index ? 1 : 0.65),
                              fontWeight: i == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _active),
        ],
      ),
    );
  }
}
