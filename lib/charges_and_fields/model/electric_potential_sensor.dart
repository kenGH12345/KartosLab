import 'vec2.dart';

typedef ElectricPotentialComputer = double Function(CafVec2 position);

class ElectricPotentialSensor {
  ElectricPotentialSensor(this.computeElectricPotential);

  final ElectricPotentialComputer computeElectricPotential;

  CafVec2 position = CafVec2.zero;
  double electricPotential = 0;
  bool isActive = false;

  void Function()? onChanged;

  void update() {
    electricPotential = computeElectricPotential(position);
    onChanged?.call();
  }

  void setPosition(CafVec2 p) {
    position = p;
    update();
  }

  void reset() {
    position = CafVec2.zero;
    electricPotential = 0;
    isActive = false;
    onChanged?.call();
  }
}
