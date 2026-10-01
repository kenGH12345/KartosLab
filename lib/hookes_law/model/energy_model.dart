import 'single_spring_system.dart';
import 'spring.dart';

/// Energy screen. One spring whose displacement is the independent control.
/// `js/energy/model/EnergyModel.ts`.
class EnergyModel {
  EnergyModel() : system = SingleSpringSystem.energy();

  final SingleSpringSystem system;

  Spring get spring => system.spring;

  void reset() {
    system.reset();
  }
}
