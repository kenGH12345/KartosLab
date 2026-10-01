import 'model_element.dart';
import 'vec2.dart';

typedef ElectricFieldComputer = CafVec2 Function(CafVec2 position);

class ElectricFieldSensor extends CafModelElement {
  ElectricFieldSensor({
    required this.computeElectricField,
    required CafVec2 initialPosition,
  }) : super(initialPosition);

  final ElectricFieldComputer computeElectricField;
  CafVec2 electricField = CafVec2.zero;

  @override
  void onPositionChanged() => update();

  void update() {
    electricField = computeElectricField(position);
    notify();
  }
}
