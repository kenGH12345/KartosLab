import 'detector_mode.dart';
import 'hit.dart';
import 'slit_configuration.dart';
import 'source_type.dart';

/// PhET `Snapshot` schema (pure data).
class QwiSnapshot {
  QwiSnapshot({
    required this.snapshotNumber,
    required this.hits,
    required this.detectionMode,
    required this.sourceType,
    required this.wavelengthNm,
    required this.slitSeparationMm,
    required this.screenDistanceM,
    required this.screenHalfWidthM,
    required this.effectiveWavelengthM,
    required this.slitSetting,
    required this.envelopeCategory,
    required this.isEmitting,
    required this.brightness,
    required this.intensity,
    required this.slitWidthMm,
    required this.intensityDistribution,
  });

  final int snapshotNumber;
  final List<DetectorHit> hits;
  final DetectorMode detectionMode;
  final SourceType sourceType;
  final double wavelengthNm;
  final double slitSeparationMm;
  final double screenDistanceM;
  final double screenHalfWidthM;
  final double effectiveWavelengthM;
  final SlitConfiguration slitSetting;
  final String envelopeCategory;
  final bool isEmitting;
  final double brightness;
  final double intensity;
  final double slitWidthMm;
  final List<double> intensityDistribution;

  QwiSnapshot copyWithNumber(int number) {
    return QwiSnapshot(
      snapshotNumber: number,
      hits: List<DetectorHit>.from(hits),
      detectionMode: detectionMode,
      sourceType: sourceType,
      wavelengthNm: wavelengthNm,
      slitSeparationMm: slitSeparationMm,
      screenDistanceM: screenDistanceM,
      screenHalfWidthM: screenHalfWidthM,
      effectiveWavelengthM: effectiveWavelengthM,
      slitSetting: slitSetting,
      envelopeCategory: envelopeCategory,
      isEmitting: isEmitting,
      brightness: brightness,
      intensity: intensity,
      slitWidthMm: slitWidthMm,
      intensityDistribution: List<double>.from(intensityDistribution),
    );
  }
}

class SnapshotStore {
  SnapshotStore({this.maxSnapshots = 4});

  final int maxSnapshots;
  final List<QwiSnapshot> _snapshots = <QwiSnapshot>[];

  List<QwiSnapshot> get snapshots => List<QwiSnapshot>.unmodifiable(_snapshots);

  int get length => _snapshots.length;

  bool get isFull => _snapshots.length >= maxSnapshots;

  /// PhET: when full, takeSnapshot is a no-op.
  bool tryAdd(QwiSnapshot snapshot) {
    if (isFull) {
      return false;
    }
    _snapshots.add(snapshot.copyWithNumber(_snapshots.length + 1));
    return true;
  }

  void deleteAt(int index) {
    if (index < 0 || index >= _snapshots.length) {
      return;
    }
    _snapshots.removeAt(index);
    for (var i = 0; i < _snapshots.length; i++) {
      _snapshots[i] = _snapshots[i].copyWithNumber(i + 1);
    }
  }

  void clear() => _snapshots.clear();
}
