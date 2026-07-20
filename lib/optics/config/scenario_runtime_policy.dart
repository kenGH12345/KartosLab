import '../models/optical_element.dart';
import '../models/optics_world.dart';
import '../models/light_source_element.dart';
import 'lab_scenario.dart';

class ScenarioRuntimePolicy {
  final LabScenario? scenario;

  ScenarioRuntimePolicy({this.scenario});

  bool canAdd(OpticalElementType type, OpticsWorld world) {
    if (scenario == null) return true;
    if (!scenario!.ui.allowAddComponent) return false;

    final spec = scenario!.inventory.availableComponents[type];
    if (spec == null) return false;

    final current = world.elements.where((e) => e.type == type).length;
    return current < spec.maxCount;
  }

  bool canMove(OpticalElement element) {
    if (element is LightSourceElement && scenario != null) {
      final placement = scenario!.initialLayout.where((p) => p.id == element.id).firstOrNull;
      if (placement != null && placement.locked) return false;
    }
    if (scenario != null && !scenario!.ui.allowMoveComponent) return false;
    return true;
  }

  bool canRemove(OpticalElement element) {
    if (element is LightSourceElement && scenario != null) {
      final placement = scenario!.initialLayout.where((p) => p.id == element.id).firstOrNull;
      if (placement != null && placement.locked) return false;
    }
    if (scenario != null && !scenario!.ui.allowRemoveComponent) return false;
    return true;
  }
}
