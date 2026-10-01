/// Session persistence boundary — NOT IMPLEMENTED for product storage.
///
/// Interfaces exist so Platform can later plug restore without coupling
/// Home to full Model serialization.
library;

/// Opaque session blob owned by Platform — Simulation does not interpret
/// platform user accounts here.
abstract class SimulationSessionStore {
  Future<void> saveSessionState(String simulationId, Map<String, Object?> data);

  Future<Map<String, Object?>?> restoreSessionState(String simulationId);
}

/// Default: no persistence.
class NoOpSimulationSessionStore implements SimulationSessionStore {
  const NoOpSimulationSessionStore();

  @override
  Future<void> saveSessionState(
    String simulationId,
    Map<String, Object?> data,
  ) async {}

  @override
  Future<Map<String, Object?>?> restoreSessionState(String simulationId) async =>
      null;
}

SimulationSessionStore simulationSessionStore =
    const NoOpSimulationSessionStore();
