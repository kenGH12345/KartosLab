import 'forces_simulation.dart';
import 'forces_item.dart';

/// Motion/Friction/Acceleration 三屏幕共用模型
/// 管理物品堆叠 + 推力者状态 + 物理引擎
class MotionModel {
  MotionModel({
    double friction = 0,
    this.showAccelerometer = false,
  }) : sim = ForcesSimulation() {
    sim.frictionCoeff = friction;
  }

  final ForcesSimulation sim;
  bool showAccelerometer;

  // 物品堆叠（最多 3 个）
  final List<ForceItem> stack = [];

  double get totalMass => stack.fold<double>(0.0, (s, i) => s + i.mass);

  bool get canAdd => stack.length < ForceItem.maxStack;

  void addItem(ForceItem item) {
    if (stack.length >= ForceItem.maxStack) {
      // 移除最底部物品
      stack.removeAt(0);
    }
    stack.add(item);
    sim.mass = totalMass;
  }

  void removeItem(ForceItem item) {
    stack.remove(item);
    sim.mass = totalMass;
  }

  void clearStack() {
    stack.clear();
    sim.mass = 0;
  }

  void setAppliedForce(double f) {
    sim.appliedForce = f.clamp(-500, 500);
  }

  void setFriction(double mu) {
    sim.frictionCoeff = mu.clamp(0, ForcesSimulation.maxFriction);
  }

  void tick(double dt) => sim.tick(dt);
  void reset() { sim.reset(); clearStack(); }
}
