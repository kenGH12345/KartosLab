import '../masb_constants.dart';
import 'mass.dart';
import 'spring.dart';

/// PhET `MassesAndSpringsModel.adjustDraggedMassPosition` (M2).
mixin MasbDragLogic {
  List<MasbSpring> get springs;
  double get gravity;

  void adjustDraggedMassPosition(MasbMass mass) {
    final massX = mass.positionX;
    final massY = mass.positionY;

    // Attempt to detach
    final attached = mass.spring;
    if (attached != null &&
        (attached.positionX - massX).abs() > MasbConstants.releaseDistance) {
      attached.removeMass();
      mass.detach();
    }

    // Update mass position and spring length if attached
    if (mass.spring != null) {
      final spring = mass.spring!;
      if (mass.positionX != spring.positionX) {
        mass.positionX = spring.positionX;
      }
      spring.updateDisplacement(massY, factorNaturalLength: false);

      // Coil compression clamp (PhET UPPER_CONSTRAINT approx for default coils).
      // MAP_NUMBER_OF_LOOPS(0.5)=12, thickness~3 → view maxY mapped ≈ 1.353 model.
      const modelMaxY = 1.353;
      if (mass.positionY > modelMaxY) {
        mass.positionY = modelMaxY;
        spring.updateDisplacement(modelMaxY, factorNaturalLength: false);
      }
    } else {
      // Attempt to attach to a free spring within grabbing distance.
      for (final spring in springs) {
        if ((massX - spring.positionX).abs() < MasbConstants.grabbingDistance &&
            (massY - spring.bottom).abs() < MasbConstants.grabbingDistance &&
            spring.massAttached == null) {
          spring.setMass(mass);
          break;
        }
      }
    }
  }
}
