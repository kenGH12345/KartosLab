/// 核子与衰变产物的模型。
///
/// 对标 shred `Particle` / `ParticleTypeEnum` 与 build-a-nucleus `BANParticle`。
/// 运动模型（position/destination/speed/step）在 [MovingParticle] 基类。
///
/// 坐标约定：核中心为模型原点 (0,0)，y 向下。
/// [已确认] BANScreenView: particleTransform 以原子中心为 (0,0)。
library;

import '../data/decay_type.dart';
import 'moving_particle.dart';

/// 核子类型。对标 ParticleTypeEnum 中的 PROTON / NEUTRON。
enum NucleonType { proton, neutron }

/// 衰变时发射出的粒子类型。
///
/// 对标 ParticleTypeEnum（PROTON/NEUTRON/ELECTRON/POSITRON）+ AlphaParticle。
/// 本实现 α 合并为一条 [EmittedParticleType.alpha] 记录（渲染为 2p2n 菱形簇，
/// 对标 AlphaParticle extends ParticleAtom 的内部排布）。
enum EmittedParticleType { proton, neutron, electron, positron, alpha }

/// 一个核子。位置属于模型状态（捕获半径判定与渲染都需要）。
class Nucleon extends MovingParticle {
  Nucleon({required this.id, required this.type, super.x, super.y});

  final int id;

  /// β 衰变时原位换型（[已确认] ParticleAtom.changeNucleonType）。
  NucleonType type;

  /// 绘制层级：数值越大越靠后（先绘制）。拖拽中的核子为 0（最前）。
  /// [已确认] shred Particle.zLayerProperty（higher means further back；
  /// 拖拽为 0）与 reconfigureNucleus 的 topLayer/level 赋值。
  int zLayer = 0;

  /// β 换色动画（render-only）：非 null 表示处于换色上下文（从该类型色过渡
  /// 到当前 [type] 色）；[colorProgress] 0→1。
  /// [已确认] changeNucleonType：0.5s 线性插值 base color
  /// （Color.interpolateRGBA），渐变随基色同步（ParticleNode 由基色重建填充）。
  ///
  /// [colorAnimationRunning]=false 且上下文非 null = 冻结（对标原版 undo/reset
  /// 时 clearAnimations 停掉动画、颜色定格在中间值的语义）。
  NucleonType? colorAnimatingFrom;
  double colorProgress = 1.0;
  bool colorAnimationRunning = false;

  /// 正在播放换色动画（冻结不算）。拖拽禁用判定用此。
  bool get isColorAnimating =>
      colorAnimatingFrom != null && colorAnimationRunning;

  /// 到核中心（原点）的距离平方，用于「离中心最近」选择，避免开方。
  double get distanceSquaredToCenter => x * x + y * y;
}

/// 衰变发射出的粒子（对标 outgoingParticles 中的飞行粒子：
/// 创建即在核内对应位置，以 300 px/s 飞向屏外随机点，到达后移除）。
class EmittedParticle extends MovingParticle {
  EmittedParticle(this.type, {super.x, super.y}) : super(speed: 300);

  final EmittedParticleType type;

  /// 绘制层级（β 衰变发射粒子置于换型核子之后：原核子 zLayer + 1）。
  /// [已确认] BANScreenView.betaDecay
  int zLayer = 0;

  /// 起飞前滞留时间（秒）。β 衰变的发射粒子在换色动画完成后才开始飞出。
  /// [已确认] BANScreenView.betaDecay：animateAndRemoveParticle 在
  /// changeNucleonType 的 onChangeComplete 回调中启动
  double holdTime = 0;
}

/// 一次衰变的事件记录（对标 DecayScreenView 的 oldProtonNumber/
/// oldNeutronNumber 快照 + 衰变类型上下文）。undo 依赖 parent 计数。
class DecayEvent {
  const DecayEvent({
    required this.type,
    required this.parentProtons,
    required this.parentNeutrons,
    required this.daughterProtons,
    required this.daughterNeutrons,
  });

  final NucleusDecayType type;
  final int parentProtons;
  final int parentNeutrons;
  final int daughterProtons;
  final int daughterNeutrons;
}
