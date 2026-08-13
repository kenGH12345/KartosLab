import 'forces_simulation.dart';
import 'forces_item.dart';
import '../config/forces_scenario.dart';
import '../../common/chart/chart_series.dart';

/// Motion/Friction/Acceleration 三屏幕共用模型
/// 管理物品堆叠 + 推力者状态 + 物理引擎
class MotionModel {
  MotionModel({
    double friction = 0,
    this.showAccelerometer = false,
    double initialMass = 0,
    double initialPosition = 0,
    double initialVelocity = 0,
    double initialAppliedForce = 0,
  }) : sim = ForcesSimulation(mass: initialMass > 0 ? initialMass : 50) {
    sim.frictionCoeff = friction;
    sim.position = initialPosition;
    sim.velocity = initialVelocity;
    sim.appliedForce = initialAppliedForce;
  }

  /// 从 scenario JSON 构建（§C1 合规）
  factory MotionModel.fromScenario(ForcesScenario s, {double? overrideFriction}) {
    return MotionModel(
      friction: overrideFriction ?? s.frictionCoeff,
      showAccelerometer: s.showAccelerometer,
      initialMass: s.mass,
      initialPosition: s.position,
      initialVelocity: s.velocity,
      initialAppliedForce: s.appliedForce,
    );
  }

  final ForcesSimulation sim;
  bool showAccelerometer;

  // 图表数据源（可用于 KratosChart）
  final MemorySeriesDataProvider posData = MemorySeriesDataProvider();
  final MemorySeriesDataProvider velData = MemorySeriesDataProvider();

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

  void tick(double dt, double totalTime) {
    sim.tick(dt);
    // 记录 chart 数据
    posData.add(TimeDataPoint(totalTime, sim.position));
    velData.add(TimeDataPoint(totalTime, sim.velocity));
  }
  void reset() { sim.reset(); posData.clear(); velData.clear(); clearStack(); }
}
