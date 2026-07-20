import 'circuit_state.dart';

class CircuitHistory {
  final List<CircuitState> _past = [];
  final List<CircuitState> _future = [];
  static const _maxSize = 100;

  void push(CircuitState state) {
    _past.add(state);
    if (_past.length > _maxSize) _past.removeAt(0);
    _future.clear();
  }

  CircuitState? undo(CircuitState current) {
    if (_past.isEmpty) return null;
    _future.add(current);
    return _past.removeLast();
  }

  CircuitState? redo(CircuitState current) {
    if (_future.isEmpty) return null;
    _past.add(current);
    return _future.removeLast();
  }

  void clear() { _past.clear(); _future.clear(); }

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;
}
