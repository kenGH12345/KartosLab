/// Platform-facing Quantum Measurement entry (Home → this → internal screens).
///
/// Home must not know Coins/Photons/Spin/Bloch Models.
/// System Back exits this route (Simulation), not internal tab history.
library;

import 'package:flutter/material.dart';

import 'package:kratos/common/simulation/simulation_event.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/qm_assets.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

/// Formal KartosLab Home entry for Simulation ID `quantum-measurement`.
class QuantumMeasurementHome extends StatefulWidget {
  const QuantumMeasurementHome({super.key});

  static const String simulationId = 'quantum-measurement';
  static const String title = QmStrings.title;
  static const String subtitle = QmStrings.subtitle;
  static const Color accentColor = Color(0xFF5B21B6);
  static const String homeIconAsset = QmAssets.spinScreenIcon;

  static const List<String> screenIds = [
    'coins',
    'photons',
    'spin',
    'bloch-sphere',
  ];

  @override
  State<QuantumMeasurementHome> createState() => _QuantumMeasurementHomeState();
}

class _QuantumMeasurementHomeState extends State<QuantumMeasurementHome> {
  @override
  void initState() {
    super.initState();
    simulationEventSink.emit(
      const SimulationEvent(
        simulationId: QuantumMeasurementHome.simulationId,
        kind: SimulationEventKind.opened,
      ),
    );
  }

  @override
  void dispose() {
    simulationEventSink.emit(
      const SimulationEvent(
        simulationId: QuantumMeasurementHome.simulationId,
        kind: SimulationEventKind.closed,
      ),
    );
    super.dispose();
  }

  void _onTabChanged(int index) {
    final screen = QuantumMeasurementHome.screenIds[
        index.clamp(0, QuantumMeasurementHome.screenIds.length - 1)];
    simulationEventSink.emit(
      SimulationEvent(
        simulationId: QuantumMeasurementHome.simulationId,
        kind: SimulationEventKind.screenChanged,
        screenId: screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: QuantumMeasurementHome.title,
      accentColor: QuantumMeasurementHome.accentColor,
      tabBarIsScrollable: true,
      onTabChanged: _onTabChanged,
      tabs: const [
        KratosTab(
          label: QmStrings.coins,
          icon: Icons.monetization_on_outlined,
          color: QuantumMeasurementHome.accentColor,
          child: QuantumMeasurementCoinsScreen(
            key: Key('qm_runtime_coins'),
          ),
        ),
        KratosTab(
          label: QmStrings.photons,
          icon: Icons.light_mode_outlined,
          color: QuantumMeasurementHome.accentColor,
          child: QuantumMeasurementPhotonsScreen(
            key: Key('qm_runtime_photons'),
          ),
        ),
        KratosTab(
          label: QmStrings.spin,
          icon: Icons.sync_alt_rounded,
          color: QuantumMeasurementHome.accentColor,
          child: QuantumMeasurementSpinScreen(
            key: Key('qm_runtime_spin'),
          ),
        ),
        KratosTab(
          label: QmStrings.blochSphere,
          icon: Icons.public_outlined,
          color: QuantumMeasurementHome.accentColor,
          child: QuantumMeasurementBlochScreen(
            key: Key('qm_runtime_bloch'),
          ),
        ),
      ],
    );
  }
}

/// Alias matching Entry Wrapper naming in PHASE 10 spec.
typedef QuantumMeasurementEntry = QuantumMeasurementHome;
