/// Model-layer interaction commands (no GestureDetector).
/// UI Phase 3 will call these.
library;

import '../model/bl_vec2.dart';
import '../model/enums.dart';
import '../model/intro_model.dart';
import '../model/prisms_model.dart';
import '../model/substance.dart';

class IntroInteractionCommands {
  IntroInteractionCommands(this.model);
  final IntroModel model;

  void setLaserOn(bool on) => model.setLaserOn(on);

  void setLaserAngle(double radians) {
    model.laser.setAngle(radians);
    model.updateModel();
  }

  void setTopMedium(Substance s) => model.setTopSubstance(s);
  void setBottomMedium(Substance s) => model.setBottomSubstance(s);
  void setLaserView(LaserViewEnum v) => model.setLaserView(v);
  void setShowNormal(bool v) => model.setShowNormal(v);

  void setShowAngles(bool v) => model.setShowAngles(v);

  void resetAll() => model.reset();
}

class PrismsInteractionCommands {
  PrismsInteractionCommands(this.model);
  final PrismsModel model;

  void setLaserOn(bool on) => model.setLaserOn(on);

  void translateLaser(double dx, double dy) {
    model.laser.translate(dx, dy);
    model.updateModel();
  }

  void setLaserAngle(double radians) {
    model.laser.setAngle(radians);
    model.updateModel();
  }

  void setEnvironment(Substance s) => model.setEnvironmentSubstance(s);
  void setPrismMedium(Substance s) => model.setPrismSubstance(s);
  void setShowReflections(bool v) => model.setShowReflections(v);

  void movePrism(int index, BlVec2 position) {
    if (index < 0 || index >= model.prisms.length) return;
    model.prisms[index].setPosition(position);
    model.updateModel();
  }

  void resetAll() => model.reset();
}
