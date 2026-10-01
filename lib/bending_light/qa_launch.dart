import 'model/enums.dart';
import 'model/more_tools_model.dart';
import 'model/prisms_model.dart';

/// Query `?qa=` used only to reproduce official screenshot states.
/// Absent on a normal launch. Not a product control.
String? get qaCapture => Uri.base.queryParameters['qa'];

void applyWhiteLightCapture(PrismsModel model) {
  model.setLightType(LightType.white);
  model.setLaserOn(true);
}

void applyGraphCapture(MoreToolsModel model) {
  model.setLaserView(LaserViewEnum.wave);
  model.setLaserOn(true);
  model.waveSensor.enabled = true;
  // Official graph frame: paused at t = 5.375e-13 (NORMAL dt = 1e-16).
  const target = 5.375e-13;
  var guard = 0;
  while (model.time < target && guard < 20000) {
    model.stepOnce();
    guard++;
  }
  model.isPlaying = false;
  model.updateModel();
}

void applySensorsCapture(MoreToolsModel model) {
  model.setLaserOn(true);
  model.intensityMeter.enabled = true;
  model.velocitySensor.enabled = true;
  model.isPlaying = false;
  model.updateModel();
}
