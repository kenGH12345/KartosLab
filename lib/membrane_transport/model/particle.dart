import '../membrane_transport_constants.dart';
import 'membrane_transport_model.dart';
import 'mt_vec2.dart';
import 'particle_mode.dart';
import 'solute_type.dart';

/// Membrane transport particle — PhET `Particle` / `Solute` / `Ligand`.
class MtParticle {
  MtParticle({
    required this.type,
    required this.position,
    required MembraneTransportModel model,
    ParticleMode? mode,
  })  : dimension = ParticleModelDimensions.of(type.name),
        mode = mode ??
            RandomWalkMode.create(
              model.random,
              allowImmediateInteraction: true,
            );

  final ParticleType type;
  final MtVec2 position;
  final MtSize dimension;
  ParticleMode mode;

  double opacity = 1;
  double timeSinceCrossedMembrane = double.infinity;
  bool manuallyBound = false;
  bool focused = false;

  MembraneTransportModel? _model;

  bool get isLigand => type.isLigand;

  bool get isSolute => type.asSolute != null;

  MtBounds get bounds => MtBounds(
        position.x - dimension.width / 2,
        position.y - dimension.height / 2,
        position.x + dimension.width / 2,
        position.y + dimension.height / 2,
      );

  void attachModel(MembraneTransportModel model) => _model = model;

  void startRandomWalk({bool allowImmediateInteraction = true}) {
    mode = RandomWalkMode.create(
      _model!.random,
      allowImmediateInteraction: allowImmediateInteraction,
    );
  }

  void moveInDirection(MtVec2 direction, double duration) {
    mode = RandomWalkMode(
      currentDirection: direction,
      timeUntilNextDirection: duration,
      timeElapsedSinceMembraneCrossing: 0,
    );
  }

  void releaseFromInteraction(double y) {
    position.y = y;
    if (_model != null) {
      startRandomWalk();
    }
  }

  void step(double dt, MembraneTransportModel model) {
    _model = model;
    timeSinceCrossedMembrane += dt;
    final wasOutside = position.y > 0;

    if (_updateAbsorption(dt, model)) return;

    mode.step(dt, this, model);

    final nowOutside = position.y > 0;
    if (wasOutside != nowOutside) {
      timeSinceCrossedMembrane = 0;
    }
  }

  bool _updateAbsorption(double dt, MembraneTransportModel model) {
    if (type == ParticleType.glucose &&
        model.glucoseMetabolism &&
        position.y < MembraneTransportConstants.membraneMinY) {
      opacity -= dt / 10;
      if (opacity <= 0) {
        model.removeSolute(this);
        return true;
      }
    }
    if (type == ParticleType.adp) {
      opacity -= dt / 10;
      if (opacity <= 0) {
        model.removeSolute(this);
        return true;
      }
    }
    if (type == ParticleType.phosphate && mode is RandomWalkMode) {
      final rw = mode as RandomWalkMode;
      if (rw.timeElapsedSinceMembraneCrossing > 3) {
        opacity -= dt / 5;
        if (opacity <= 0) {
          model.removeSolute(this);
          return true;
        }
      }
    }
    return false;
  }
}
