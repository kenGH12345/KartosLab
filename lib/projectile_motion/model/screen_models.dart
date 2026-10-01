import 'projectile_motion_model.dart';
import 'projectile_object_type.dart';

/// IntroModel.ts — 默认 PUMPKIN（types[5]），h=10，θ=0°，v=15，阻力 off
class IntroModel extends ProjectileMotionModel {
  factory IntroModel() {
    final types = PmProjectileObjectType.createIntroTypes();
    return IntroModel._(types);
  }

  IntroModel._(List<PmProjectileObjectType> types)
      : super(
          defaultObjectType: types[5],
          defaultAirResistanceOn: false,
          objectTypes: types,
          defaultCannonHeight: 10,
          defaultCannonAngle: 0,
          defaultInitialSpeed: 15,
        );
}

/// VectorsModel.ts — COMPANIONLESS，阻力 on，基类默认 h=0/θ=80°/v=18
class VectorsModel extends ProjectileMotionModel {
  factory VectorsModel() {
    final type = PmProjectileObjectType.companionless.clone();
    return VectorsModel._(type);
  }

  VectorsModel._(PmProjectileObjectType type)
      : super(
          defaultObjectType: type,
          defaultAirResistanceOn: true,
          objectTypes: [type],
        );
}

/// DragModel.ts — COMPANIONLESS，阻力恒 on（无开关）
class DragModel extends ProjectileMotionModel {
  factory DragModel() {
    final type = PmProjectileObjectType.companionless.clone();
    return DragModel._(type);
  }

  DragModel._(PmProjectileObjectType type)
      : super(
          defaultObjectType: type,
          defaultAirResistanceOn: true,
          objectTypes: [type],
        );
}

/// LabModel.ts — 默认 CANNONBALL（types[1]），阻力 off，
/// 编辑 mass/diameter/Cd 写回当前类型（LabModel.ts:53-62）
class LabModel extends ProjectileMotionModel {
  factory LabModel() {
    final types = PmProjectileObjectType.createLabTypes();
    return LabModel._(types);
  }

  LabModel._(List<PmProjectileObjectType> types)
      : super(
          defaultObjectType: types[1],
          defaultAirResistanceOn: false,
          objectTypes: types,
        ) {
    syncEditsToObjectType = true;
  }

  @override
  void resetObjectTypes() {
    for (final type in objectTypes) {
      type.reset();
    }
  }
}
