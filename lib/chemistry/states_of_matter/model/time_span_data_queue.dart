import '../som_constants.dart';

/// Queue of (value, dt) samples over a rolling time window — PhET TimeSpanDataQueue.
class TimeSpanDataQueue {
  TimeSpanDataQueue(
    this.maxTimeSpan, {
    double minExpectedDt = SomConstants.nominalTimeStep,
  }) {
    final maxExpectedLength = (maxTimeSpan / minExpectedDt * 1.1).ceil();
    for (var i = 0; i < maxExpectedLength; i++) {
      _unused.add(_DataQueueEntry(0, null));
    }
  }

  double total = 0;
  double _timeSpan = 0;
  final double maxTimeSpan;
  final List<_DataQueueEntry> _dataQueue = [];
  final List<_DataQueueEntry> _unused = [];

  double get timeSpan => _timeSpan;

  void add(double value, double dt) {
    assert(dt < maxTimeSpan, 'dt value is greater than max time span');

    late final _DataQueueEntry entry;
    if (_unused.isNotEmpty) {
      entry = _unused.removeLast();
      entry.dt = dt;
      entry.value = value;
    } else {
      entry = _DataQueueEntry(dt, value);
    }
    _dataQueue.add(entry);
    _timeSpan += dt;
    total += value;

    while (_timeSpan > maxTimeSpan) {
      assert(_dataQueue.isNotEmpty, 'data queue empty but max time exceeded');
      final removed = _dataQueue.removeAt(0);
      _timeSpan -= removed.dt;
      total -= removed.value!;
      removed.value = null;
      _unused.add(removed);
    }
  }

  void clear() {
    total = 0;
    _timeSpan = 0;
    for (final item in _dataQueue) {
      item.value = null;
      _unused.add(item);
    }
    _dataQueue.clear();
  }
}

class _DataQueueEntry {
  _DataQueueEntry(this.dt, this.value);

  double dt;
  double? value;
}
