import '../masb_constants.dart';
import 'masb_drag_logic.dart';
import 'mass.dart';
import 'period_trace.dart';
import 'spring.dart';

enum MasbTimeSpeed { normal, slow }

enum MasbScene { bounce, stretch, lab }

/// PhET `Body` presets (GravityComboBox).
enum MasbBody {
  earth(MasbConstants.earthGravity),
  moon(MasbConstants.moonGravity),
  jupiter(MasbConstants.jupiterGravity),
  planetX(MasbConstants.planetX),
  custom(MasbConstants.earthGravity);

  const MasbBody(this.gravity);
  final double gravity;
}

/// Shared MASB model — scene selects Stretch / Bounce / Lab layout.
class MasbModel with MasbDragLogic {
  MasbModel({
    this.scene = MasbScene.bounce,
    double? damping,
    this.gravity = MasbConstants.earthGravity,
  }) : damping = damping ?? defaultDampingFor(scene) {
    switch (scene) {
      case MasbScene.lab:
        _initLab();
      case MasbScene.bounce:
      case MasbScene.stretch:
        _initTwoSpringBasics();
    }
    if (scene == MasbScene.stretch) {
      movableLineVisible = true;
    }
  }

  factory MasbModel.stretch() => MasbModel(scene: MasbScene.stretch);
  factory MasbModel.lab() => MasbModel(scene: MasbScene.lab);
  factory MasbModel.bounce() => MasbModel(scene: MasbScene.bounce);

  static double defaultDampingFor(MasbScene scene) => switch (scene) {
        MasbScene.bounce => 0,
        MasbScene.stretch => 0.7,
        MasbScene.lab => MasbConstants.dampingDefault,
      };

  final MasbScene scene;

  void _initTwoSpringBasics() {
    firstSpring = MasbSpring(
      positionX: MasbConstants.leftSpringX,
      positionY: MasbConstants.ceilingY,
      initialNaturalRestingLength: MasbConstants.defaultSpringLength,
      dampingGetter: () => damping,
      gravityGetter: () => gravity,
    )..forcesOrientation = -1;
    secondSpring = MasbSpring(
      positionX: MasbConstants.rightSpringX,
      positionY: MasbConstants.ceilingY,
      initialNaturalRestingLength: MasbConstants.defaultSpringLength,
      dampingGetter: () => damping,
      gravityGetter: () => gravity,
    )..forcesOrientation = 1;
    springs = [firstSpring, secondSpring!];

    masses = [
      MasbMass(
        massKg: 0.250,
        xPosition: 0.12,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.250,
        xPosition: 0.16,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.100,
        xPosition: 0.30,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.100,
        xPosition: 0.33,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.050,
        xPosition: 0.425,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.050,
        xPosition: 0.445,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.labeledMassArgb,
      ),
      MasbMass(
        massKg: 0.200,
        xPosition: 0.76,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.largeMysteryMassArgb,
      ),
      MasbMass(
        massKg: 0.100,
        xPosition: 0.69,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.mediumMysteryMassArgb,
      ),
      MasbMass(
        massKg: 0.075,
        xPosition: 0.62,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.smallMysteryMassArgb,
      ),
    ];
  }

  void _initLab() {
    // PhET Lab = OneSpringScreenView (single spring at SPRING_X).
    firstSpring = MasbSpring(
      positionX: MasbConstants.springX,
      positionY: MasbConstants.ceilingY,
      initialNaturalRestingLength: MasbConstants.defaultSpringLength,
      dampingGetter: () => damping,
      gravityGetter: () => gravity,
    );
    secondSpring = null;
    springs = [firstSpring];
    firstSpring.periodTrace = PeriodTrace(firstSpring);

    const massX = 0.13;
    const massOffset = 0.15;
    masses = [
      MasbMass(
        massKg: 0.100,
        xPosition: massX,
        gravityGetter: () => gravity,
        colorArgb: MasbConstants.adjustableMassArgb,
        adjustable: true,
      ),
      MasbMass(
        massKg: 0.060,
        xPosition: massX + massOffset,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.labSmallMysteryArgb,
      ),
      MasbMass(
        massKg: 0.120,
        xPosition: massX + massOffset * 1.5,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.labMediumMysteryArgb,
      ),
      MasbMass(
        massKg: 0.180,
        xPosition: massX + massOffset * 2,
        gravityGetter: () => gravity,
        mysteryLabel: true,
        colorArgb: MasbConstants.labLargeMysteryArgb,
      ),
    ];
  }

  late final MasbSpring firstSpring;
  MasbSpring? secondSpring;

  MasbSpring get spring => firstSpring;

  late final List<MasbMass> masses;
  @override
  late final List<MasbSpring> springs;

  double damping;
  @override
  double gravity;
  MasbBody body = MasbBody.earth;
  bool playing = true;
  MasbTimeSpeed timeSpeed = MasbTimeSpeed.normal;
  double simTime = 0;

  bool naturalLengthVisible = false;
  bool equilibriumPositionVisible = false;
  bool movableLineVisible = false;
  double movableLineY = 0.7;

  // Lab VectorVisibilityControlNode (basics: forces off)
  bool velocityVectorVisible = false;
  bool accelerationVectorVisible = false;

  MasbMass? draggingMass;

  MasbMass get mass =>
      springs.map((s) => s.massAttached).whereType<MasbMass>().firstOrNull ??
      masses.first;

  void step(double dt) {
    if (dt > 0.3) return;
    if (!playing) return;
    modelStep(dt);
  }

  void stepForward(double dt) => modelStep(dt);

  void modelStep(double dt) {
    var physicsDt = dt;
    if (timeSpeed == MasbTimeSpeed.slow && playing) {
      physicsDt = dt / MasbConstants.slowSimDtRatio;
    }
    simTime += physicsDt;

    for (final m in masses) {
      m.step(
        gravity,
        MasbConstants.floorY + MasbConstants.shelfHeight,
        physicsDt,
        dt,
      );
    }
    for (final s in springs) {
      s.step(physicsDt);
      _stepPeriodTrace(s, physicsDt);
    }
  }

  void _stepPeriodTrace(MasbSpring s, double dt) {
    final trace = s.periodTrace;
    if (trace == null) return;
    final mass = s.massAttached;
    if (mass == null ||
        mass.userControlled ||
        !s.periodTraceVisible ||
        mass.verticalVelocity == 0) {
      if (mass == null || mass.userControlled || !s.periodTraceVisible) {
        trace.onFaded();
      }
      return;
    }
    if ((trace.state == 4 || trace.alpha != 1) && playing) {
      trace.fade(dt);
    }
    if (trace.thresholdReached) {
      trace.lineWidth = (trace.lineWidth - 0.025).clamp(0.5, 2.5);
    } else {
      trace.lineWidth = 2.5;
    }
  }

  void attachMassToSpring(MasbMass mass, MasbSpring target) {
    mass.positionX = target.positionX;
    mass.positionY =
        target.positionY - target.naturalRestingLength + MasbConstants.hookCenter;
    mass.onShelf = false;
    target.setMass(mass);
  }

  bool beginDrag(double modelX, double modelY) {
    for (final m in masses.reversed) {
      if (_hitTestMass(m, modelX, modelY)) {
        m.userControlled = true;
        m.verticalVelocity = 0;
        m.onShelf = false;
        m.isAnimating = false;
        if (m.spring != null) {
          m.spring!.massEquilibriumDisplacement = null;
        }
        draggingMass = m;
        return true;
      }
    }
    return false;
  }

  void updateDrag(double modelX, double modelY) {
    final m = draggingMass;
    if (m == null) return;
    final minY = MasbConstants.floorY + m.height;
    final maxY = MasbConstants.ceilingY - 0.02;
    m.positionX = modelX;
    m.positionY = modelY.clamp(minY, maxY);
    adjustDraggedMassPosition(m);
  }

  void endDrag() {
    final m = draggingMass;
    if (m == null) return;
    m.userControlled = false;
    if (m.spring != null) {
      m.initialTotalEnergy = m.totalEnergy;
    }
    draggingMass = null;
  }

  bool _hitTestMass(MasbMass m, double x, double y) {
    final dx = x - m.positionX;
    final top = m.positionY;
    final bottom = m.positionY - m.height;
    final hitRadius = m.radius * 1.4;
    return dx.abs() <= hitRadius && y <= top + 0.02 && y >= bottom - 0.02;
  }

  void setSpringConstant(double kNewtonsPerMeter) {
    final k = kNewtonsPerMeter.clamp(
      MasbConstants.springConstantMin,
      MasbConstants.springConstantMax,
    );
    for (final s in springs) {
      s.springConstant = k.toDouble();
      s.updateThickness(s.naturalRestingLength, s.springConstant);
      s.updateEquilibriumFromMass();
    }
  }

  /// Per-spring k (PhET Spring Strength 1 / 2).
  void setSpringConstantAt(int springIndex, double kNewtonsPerMeter) {
    if (springIndex < 0 || springIndex >= springs.length) return;
    final k = kNewtonsPerMeter.clamp(
      MasbConstants.springConstantMin,
      MasbConstants.springConstantMax,
    );
    final s = springs[springIndex];
    s.springConstant = k.toDouble();
    s.updateThickness(s.naturalRestingLength, s.springConstant);
    s.updateEquilibriumFromMass();
  }

  void stopSpringAt(int springIndex) {
    if (springIndex < 0 || springIndex >= springs.length) return;
    springs[springIndex].stopSpring();
  }

  void setGravity(double g) {
    gravity = g.clamp(MasbConstants.gravityMin, MasbConstants.gravityMax);
    final match = MasbBody.values.where(
      (b) => b != MasbBody.custom && (b.gravity - gravity).abs() < 1e-9,
    );
    body = match.isEmpty ? MasbBody.custom : match.first;
    for (final s in springs) {
      s.syncFromSystem();
      s.updateEquilibriumFromMass();
    }
  }

  void setBody(MasbBody newBody) {
    body = newBody;
    if (newBody != MasbBody.custom) {
      gravity = newBody.gravity;
      for (final s in springs) {
        s.syncFromSystem();
        s.updateEquilibriumFromMass();
      }
    }
  }

  void setNaturalLengthVisible(bool v) => naturalLengthVisible = v;
  void setEquilibriumPositionVisible(bool v) => equilibriumPositionVisible = v;
  void setMovableLineVisible(bool v) => movableLineVisible = v;
  void setMovableLineY(double y) =>
      movableLineY = y.clamp(MasbConstants.floorY, MasbConstants.ceilingY);

  void setPeriodTraceVisible(bool v) {
    spring.periodTraceVisible = v;
    if (!v) spring.periodTrace?.onFaded();
  }

  /// PhET MassValueControlPanel range ~50–300 g typically; clamp 0.05–0.30 kg.
  void setAttachedMassKg(double kg) {
    final attached = spring.massAttached;
    if (attached == null || !attached.adjustable) return;
    attached.setMassKg(kg.clamp(0.05, 0.30));
  }

  void reset() {
    draggingMass = null;
    damping = defaultDampingFor(scene);
    gravity = MasbConstants.earthGravity;
    body = MasbBody.earth;
    playing = true;
    timeSpeed = MasbTimeSpeed.normal;
    simTime = 0;
    naturalLengthVisible = false;
    equilibriumPositionVisible = false;
    movableLineVisible = scene == MasbScene.stretch;
    movableLineY = 0.7;
    velocityVectorVisible = false;
    accelerationVectorVisible = false;
    for (final s in springs) {
      s.reset();
    }
    for (final m in masses) {
      m.reset();
    }
  }
}
