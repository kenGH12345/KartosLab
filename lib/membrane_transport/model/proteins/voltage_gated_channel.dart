import '../particle_mode.dart';
import '../slot.dart';
import '../solute_type.dart';
import '../transport_protein_type.dart';
import 'transport_protein.dart';

/// Shared voltage-gated delay logic — PhET `VoltageGatedChannel.ts`.
abstract class VoltageGatedChannel extends TransportProtein {
  VoltageGatedChannel({
    required super.model,
    required super.type,
    required super.position,
    required super.initialState,
    required super.openStates,
  }) : _lastPotential = model.membranePotential {
    // track potential changes in step()
  }

  double? _timeSinceVoltageChanged;
  int _lastPotential;

  String stateForVoltage(int voltage);
  bool isStateOpen(String s);

  @override
  void step(double dt) {
    super.step(dt);

    if (model.membranePotential != _lastPotential) {
      _lastPotential = model.membranePotential;
      _timeSinceVoltageChanged = 0;
    }

    if (_timeSinceVoltageChanged != null) {
      _timeSinceVoltageChanged = _timeSinceVoltageChanged! + dt;
      if (_timeSinceVoltageChanged! > 0.25) {
        final wasOpen = isOpen;
        setState(stateForVoltage(model.membranePotential));
        _timeSinceVoltageChanged = null;
        if (wasOpen && !isOpen) {
          final s = slotOrNull;
          if (s != null) clearSolutes(s);
        }
      }
    }
  }

  @override
  bool isAvailableForPassiveTransport(
    SoluteType soluteType,
    MembraneSide location,
  ) {
    return isStateOpen(state) &&
        !hasSolutesMovingTowardOrThrough() &&
        model.checkGradientForCrossing(soluteType, location);
  }

  @override
  void clear(Slot slot) {
    clearSolutes(slot);
    setState(stateForVoltage(model.membranePotential));
  }
}

class SodiumVoltageGatedChannel extends VoltageGatedChannel {
  SodiumVoltageGatedChannel({
    required super.model,
    required super.position,
  }) : super(
          type: TransportProteinType.sodiumIonVoltageGatedChannel,
          initialState: 'closedNegative70mV',
          openStates: const ['openNegative50mV'],
        );

  @override
  String stateForVoltage(int voltage) {
    if (voltage == -70) return 'closedNegative70mV';
    if (voltage == -50) return 'openNegative50mV';
    return 'closed30mV';
  }

  @override
  bool isStateOpen(String s) => s == 'openNegative50mV';
}

class PotassiumVoltageGatedChannel extends VoltageGatedChannel {
  PotassiumVoltageGatedChannel({
    required super.model,
    required super.position,
  }) : super(
          type: TransportProteinType.potassiumIonVoltageGatedChannel,
          initialState: 'closedNegative70mV',
          openStates: const ['open30mV'],
        );

  @override
  String stateForVoltage(int voltage) {
    if (voltage == -70) return 'closedNegative70mV';
    if (voltage == -50) return 'closedNegative50mV';
    return 'open30mV';
  }

  @override
  bool isStateOpen(String s) => s == 'open30mV';
}
