import '../pm_constants.dart';
import '../pm_strings.dart';

/// PhET `ProjectileObjectType.ts` 的 Flutter 等价。
/// 预设数值逐行来自 ProjectileObjectType.ts:193-369。
class PmProjectileObjectType {
  PmProjectileObjectType({
    required this.name,
    required this.benchmark,
    required double mass,
    required double diameter,
    required double dragCoefficient,
    required this.rotates,
    this.massMin = 1,
    this.massMax = 10,
    this.massRound = 1,
    this.diameterMin = 0.1,
    this.diameterMax = 1,
    this.diameterRound = 0.1,
    this.dragCoefficientMin = PmConstants.dragCoefficientMin,
    this.dragCoefficientMax = 1,
  })  : mass = mass,
        diameter = diameter,
        dragCoefficient = dragCoefficient,
        initialMass = mass,
        initialDiameter = diameter,
        initialDragCoefficient = dragCoefficient;

  final String? name;
  final String? benchmark;
  final bool rotates;

  /// Lab 屏可编辑（EditableProjectileObjectType）
  double mass;
  double diameter;
  double dragCoefficient;

  final double initialMass;
  final double initialDiameter;
  final double initialDragCoefficient;

  final double massMin;
  final double massMax;
  final double massRound;
  final double diameterMin;
  final double diameterMax;
  final double diameterRound;
  final double dragCoefficientMin;
  final double dragCoefficientMax;

  void reset() {
    mass = initialMass;
    diameter = initialDiameter;
    dragCoefficient = initialDragCoefficient;
  }

  /// 每个 model 实例需要独立副本（Lab 会写回编辑值，不能污染静态预设）
  PmProjectileObjectType clone() => PmProjectileObjectType(
        name: name,
        benchmark: benchmark,
        mass: initialMass,
        diameter: initialDiameter,
        dragCoefficient: initialDragCoefficient,
        rotates: rotates,
        massMin: massMin,
        massMax: massMax,
        massRound: massRound,
        diameterMin: diameterMin,
        diameterMax: diameterMax,
        diameterRound: diameterRound,
        dragCoefficientMin: dragCoefficientMin,
        dragCoefficientMax: dragCoefficientMax,
      );

  // ── 预设（ProjectileObjectType.ts:193-369）────────────────────────────

  static final cannonball = PmProjectileObjectType(
    name: PmStrings.cannonball,
    benchmark: 'cannonball',
    mass: PmConstants.cannonballMass,
    diameter: PmConstants.cannonballDiameter,
    dragCoefficient: PmConstants.cannonballDragCoefficient,
    rotates: false,
    massMin: 1, massMax: 31, massRound: 0.01,
    diameterMin: 0.1, diameterMax: 1, diameterRound: 0.01,
  );

  static final pumpkin = PmProjectileObjectType(
    name: PmStrings.pumpkin,
    benchmark: 'pumpkin',
    mass: 5, diameter: 0.37, dragCoefficient: 0.6,
    rotates: false,
    massMin: 1, massMax: 1000, massRound: 1,
    diameterMin: 0.1, diameterMax: 3, diameterRound: 0.01,
  );

  static final baseball = PmProjectileObjectType(
    name: PmStrings.baseball,
    benchmark: 'baseball',
    mass: 0.15, diameter: 0.07, dragCoefficient: 0.35,
    rotates: false,
    massMin: 0.01, massMax: 5, massRound: 0.01,
    diameterMin: 0.01, diameterMax: 1, diameterRound: 0.01,
  );

  static final car = PmProjectileObjectType(
    name: PmStrings.car,
    benchmark: 'car',
    mass: 2000, diameter: 2, dragCoefficient: 0.55,
    rotates: true,
    massMin: 100, massMax: 5000, massRound: 1,
    diameterMin: 0.5, diameterMax: 3, diameterRound: 0.1,
  );

  static final football = PmProjectileObjectType(
    name: PmStrings.football,
    benchmark: 'football',
    mass: 0.41, diameter: 0.17, dragCoefficient: 0.05,
    rotates: true,
    massMin: 0.01, massMax: 5, massRound: 0.01,
    diameterMin: 0.01, diameterMax: 1, diameterRound: 0.01,
  );

  static final human = PmProjectileObjectType(
    name: PmStrings.human,
    benchmark: 'human',
    mass: 70, diameter: 0.5, dragCoefficient: 0.6,
    rotates: true,
    massMin: 10, massMax: 200, massRound: 1,
    diameterMin: 0.1, diameterMax: 1.5, diameterRound: 0.1,
  );

  static final piano = PmProjectileObjectType(
    name: PmStrings.piano,
    benchmark: 'piano',
    mass: 400, diameter: 2.2,
    dragCoefficient: PmConstants.dragCoefficientMax,
    rotates: false,
    massMin: 50, massMax: 1000, massRound: 1,
    diameterMin: 0.5, diameterMax: 3, diameterRound: 0.1,
    dragCoefficientMin: PmConstants.dragCoefficientMin,
    dragCoefficientMax: PmConstants.dragCoefficientMax,
  );

  static final golfBall = PmProjectileObjectType(
    name: PmStrings.golfBall,
    benchmark: 'golfBall',
    mass: 0.05, diameter: 0.04, dragCoefficient: 0.25,
    rotates: false,
    massMin: 0.01, massMax: 5, massRound: 0.01,
    diameterMin: 0.01, diameterMax: 1, diameterRound: 0.01,
  );

  static final tankShell = PmProjectileObjectType(
    name: PmStrings.tankShell,
    benchmark: 'tankShell',
    mass: 42, diameter: 0.15, dragCoefficient: 0.06,
    rotates: true,
    massMin: 5, massMax: 200, massRound: 1,
    diameterMin: 0.1, diameterMax: 1, diameterRound: 0.01,
  );

  static final custom = PmProjectileObjectType(
    name: PmStrings.custom,
    benchmark: 'custom',
    mass: 100, diameter: 1,
    dragCoefficient: PmConstants.cannonballDragCoefficient,
    rotates: true,
    massMin: 1, massMax: 5000, massRound: 0.01,
    diameterMin: 0.01, diameterMax: 3, diameterRound: 0.01,
    dragCoefficientMin: 0.04, dragCoefficientMax: 1,
  );

  /// 无物体选择屏的通用类型（ProjectileObjectType.ts:358-368）
  static final companionless = PmProjectileObjectType(
    name: null,
    benchmark: null,
    mass: 5, diameter: 0.8,
    dragCoefficient: PmConstants.cannonballDragCoefficient,
    rotates: true,
  );

  /// Intro 屏 9 种，默认 index 5 = pumpkin（IntroModel.ts:19-31）。
  /// 每次调用返回全新实例，避免跨 model 共享可变状态。
  static List<PmProjectileObjectType> createIntroTypes() => [
        cannonball, tankShell, golfBall, baseball, football,
        pumpkin, human, piano, car,
      ].map((t) => t.clone()).toList();

  /// Lab 屏 10 种，默认 index 1 = cannonball（LabModel.ts:27-49）
  static List<PmProjectileObjectType> createLabTypes() => [
        custom, cannonball, tankShell, golfBall, baseball,
        football, pumpkin, human, piano, car,
      ].map((t) => t.clone()).toList();
}
