import 'vec2.dart';

class MeasuringTapeModel {
  CafVec2 basePosition = CafVec2.zero;
  CafVec2 tipPosition = const CafVec2(0.2, 0);
  bool isActive = false;

  void Function()? onChanged;

  double get lengthMeters => basePosition.distance(tipPosition);
  double get lengthCm => lengthMeters * 100;

  void reset() {
    basePosition = CafVec2.zero;
    tipPosition = const CafVec2(0.2, 0);
    isActive = false;
    onChanged?.call();
  }

  void notify() => onChanged?.call();
}
