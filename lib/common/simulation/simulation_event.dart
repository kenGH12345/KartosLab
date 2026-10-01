/// Platform event boundary — Simulation emits; Platform adapts.
///
/// Adapters must be non-blocking and failure-isolated.
/// A failing sink must never prevent measurement / animation / physics.
library;

/// Simulation-defined event kinds (stable vocabulary).
enum SimulationEventKind {
  opened,
  screenChanged,
  action,
  reset,
  closed,
}

class SimulationEvent {
  const SimulationEvent({
    required this.simulationId,
    required this.kind,
    this.screenId,
    this.actionId,
    this.payload = const {},
  });

  final String simulationId;
  final SimulationEventKind kind;
  final String? screenId;
  final String? actionId;
  final Map<String, Object?> payload;
}

/// Platform-facing sink. Default is a no-op.
abstract class SimulationEventSink {
  void emit(SimulationEvent event);
}

class NoOpSimulationEventSink implements SimulationEventSink {
  const NoOpSimulationEventSink();

  @override
  void emit(SimulationEvent event) {
    // Intentionally empty — analytics / upload must not be required.
  }
}

/// Failure-isolated wrapper: never throws into simulation call sites.
class IsolatingSimulationEventSink implements SimulationEventSink {
  IsolatingSimulationEventSink(this.inner);

  final SimulationEventSink inner;

  @override
  void emit(SimulationEvent event) {
    try {
      inner.emit(event);
    } catch (_) {
      // Swallow — platform telemetry must not break the sim.
    }
  }
}

/// Process-wide sink (replace when product analytics exists).
SimulationEventSink simulationEventSink =
    IsolatingSimulationEventSink(const NoOpSimulationEventSink());
