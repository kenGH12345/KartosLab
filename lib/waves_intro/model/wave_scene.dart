import 'dart:math' as math;

import '../waves_intro_constants.dart';
import 'lattice.dart';
import 'scene_kind.dart';
import 'sound_particle.dart';
import 'temporal_mask.dart';
import 'water_drop.dart';
import 'intensity_sample.dart';

/// Point-source wave scene — PhET `Scene` + water `WaterScene` @ lock `31ebfd7`.
///
/// Lattice FDTD / point-source sine formula unchanged.
/// Water: sliders set desiredAmplitude/desiredFrequency; drops deliver to lattice.
class WaveScene {
  WaveScene({
    required this.config,
    this.initialAmplitude = WavesIntroConstants.initialAmplitude,
    math.Random? particleRandom,
  })  : frequency = config.defaultFrequency,
        amplitude = initialAmplitude,
        desiredFrequency = config.defaultFrequency,
        desiredAmplitude = initialAmplitude,
        lattice = Lattice(
          width: WavesIntroConstants.latticeSize,
          height: WavesIntroConstants.latticeSize,
          dampX: WavesIntroConstants.latticePadding,
          dampY: WavesIntroConstants.latticePadding,
        ),
        _particleRng = particleRandom ??
            math.Random(WavesIntroConstants.soundParticleSeed) {
    if (config.kind == SceneKind.sound) {
      _initSoundParticles();
    }
    if (config.kind == SceneKind.light) {
      intensitySample = IntensitySample(lattice);
    }
  }

  final SceneConfig config;
  final double initialAmplitude;
  final Lattice lattice;
  final TemporalMask _temporalMask = TemporalMask();
  final math.Random _particleRng;

  /// Lattice oscillator frequency / amplitude (set immediately for sound/light;
  /// for water, set when a drop is absorbed).
  double frequency;
  double amplitude;

  /// Water control-panel targets — [已确认] WaterScene.desired*Property
  double desiredFrequency;
  double desiredAmplitude;

  DisturbanceType disturbanceType = DisturbanceType.continuous;
  SoundViewType soundViewType = SoundViewType.waves;

  bool buttonPressed = false;
  bool continuousOscillating = false;
  bool pulseFiring = false;
  bool _pulseJustCompleted = false;

  double time = 0;
  double phase = 0;
  double _pulseStartTime = 0;
  int _stepIndex = 0;
  double oscillatorValue = 0;

  /// [已确认] WaterScene.waterDrops / lastDropTime
  final List<WaterDrop> waterDrops = [];
  double? _lastDropTime;
  /// Optional UI/audio hook when a water drop hits — [已确认] waterDropAbsorbedEmitter
  void Function(double amplitude)? onWaterDropAbsorbed;

  bool isAboutToFire = false;

  final List<SoundParticle> soundParticles = [];

  /// Light only — [已确认] LightScene.intensitySample
  IntensitySample? intensitySample;

  bool get isWater => config.kind == SceneKind.water;
  bool get isLight => config.kind == SceneKind.light;

  /// Model→lattice scale: visible lattice width in cells / waveAreaWidth.
  double get _modelToLatticeScale {
    final visible = lattice.width - lattice.dampX * 2;
    return visible / config.waveAreaWidth;
  }

  double modelToLatticeX(double modelX) =>
      lattice.dampX + modelX * _modelToLatticeScale;

  double modelToLatticeY(double modelY) =>
      lattice.dampY + modelY * _modelToLatticeScale;

  /// Display λ: water uses desired frequency — [已确认] getDesiredWavelength
  double get wavelength {
    final f = isWater ? desiredFrequency : frequency;
    return WavesIntroConstants.wavelength(
      waveSpeedValue: config.waveSpeed,
      frequency: f,
    );
  }

  /// Amplitude shown/edited in controls.
  double get controlAmplitude => isWater ? desiredAmplitude : amplitude;

  /// Frequency shown/edited in controls.
  double get controlFrequency => isWater ? desiredFrequency : frequency;

  void setFrequency(double value) {
    final clamped =
        value.clamp(config.frequencyMin, config.frequencyMax).toDouble();
    if (isWater) {
      desiredFrequency = clamped;
      return;
    }
    final old = frequency;
    if ((clamped - old).abs() < 1e-15) return;
    _updatePhaseForFrequencyChange(clamped, old);
    frequency = clamped;
  }

  void setAmplitude(double value) {
    final clamped = value
        .clamp(
          WavesIntroConstants.amplitudeMin,
          WavesIntroConstants.amplitudeMax,
        )
        .toDouble();
    if (isWater) {
      desiredAmplitude = clamped;
    } else {
      amplitude = clamped;
    }
  }

  void setDisturbanceType(DisturbanceType type) {
    if (disturbanceType == type) return;
    disturbanceType = type;
    buttonPressed = false;
    continuousOscillating = false;
    pulseFiring = false;
    if (isWater) {
      removeAllDrops();
    }
  }

  void setButtonPressed(bool pressed) {
    if (buttonPressed == pressed) return;
    buttonPressed = pressed;
    _handleButtonToggled(pressed);
  }

  void _handleButtonToggled(bool isPressed) {
    // Water: button only arms drops — [已确认] handleButton1Toggled no-op + lastDropTime
    if (isWater) {
      if (isPressed) {
        _lastDropTime = null;
      }
      return;
    }
    if (isPressed) {
      _resetPhase();
    }
    if (isPressed && disturbanceType == DisturbanceType.pulse) {
      _startPulse();
    } else {
      continuousOscillating = isPressed;
    }
  }

  void _startPulse() {
    if (pulseFiring) return;
    _resetPhase();
    pulseFiring = true;
    _pulseStartTime = time;
  }

  void _resetPhase() {
    final angularFrequency = math.pi * 2 * frequency;
    phase = -time * angularFrequency;
  }

  void _updatePhaseForFrequencyChange(double newFreq, double oldFreq) {
    final oldAngular = oldFreq * math.pi * 2;
    final newAngular = newFreq * math.pi * 2;
    final oldValue = math.sin(time * oldAngular + phase);
    var proposedPhase = math.asin(oldValue.clamp(-1.0, 1.0)) - time * newAngular;
    final oldDerivative = math.cos(time * oldAngular + phase);
    final newDerivative = math.cos(time * newAngular + proposedPhase);
    if (oldDerivative * newDerivative < 0) {
      proposedPhase =
          math.asin((-oldValue).clamp(-1.0, 1.0)) - time * newAngular + math.pi;
    }
    phase = proposedPhase;
  }

  /// Point-source sine — [已确认] Scene.setPointSourceValues
  static double computePointSourceValue({
    required double time,
    required double frequency,
    required double phase,
    required double amplitude,
    bool forceZero = false,
  }) {
    if (forceZero) return 0;
    final angularFrequency = math.pi * 2 * frequency;
    return -math.sin(time * angularFrequency + phase) *
        amplitude *
        WavesIntroConstants.amplitudeCalibrationScale;
  }

  void _setPointSourceValues() {
    final period = 1 / frequency;
    final timeSincePulseStarted = time - _pulseStartTime;
    final isContinuous = disturbanceType == DisturbanceType.continuous;
    final continuous = isContinuous && continuousOscillating;
    var maskEmpty = true;

    if (continuous || pulseFiring || _pulseJustCompleted) {
      final forceZero = pulseFiring && timeSincePulseStarted > period;
      final waveValue = computePointSourceValue(
        time: time,
        frequency: frequency,
        phase: phase,
        amplitude: amplitude,
        forceZero: forceZero,
      );

      final latticeCenterJ = lattice.height ~/ 2;
      if (continuousOscillating || pulseFiring || _pulseJustCompleted) {
        lattice.setCurrentValue(
          WavesIntroConstants.pointSourceHorizontal,
          latticeCenterJ,
          waveValue,
        );
        oscillatorValue = waveValue;
        if (amplitude > 0) {
          _temporalMask.set(
            isSourceOn: true,
            numberOfSteps: _stepIndex,
            verticalLatticeCoordinate: latticeCenterJ,
          );
          maskEmpty = false;
        }
      }
      _pulseJustCompleted = false;
    }

    if (maskEmpty) {
      _temporalMask.set(
        isSourceOn: false,
        numberOfSteps: _stepIndex,
        verticalLatticeCoordinate: 0,
      );
    }
  }

  void _applyTemporalMask() {
    for (var i = 0; i < lattice.width; i++) {
      for (var j = 0; j < lattice.height; j++) {
        final allowed = _temporalMask.matches(
          horizontalLatticeCoordinate: i,
          verticalLatticeCoordinate: j,
          numberOfSteps: _stepIndex,
        );
        lattice.setAllowed(i, j, allowed);
      }
    }
    _temporalMask.prune(
      math.sqrt(2) * lattice.width,
      _stepIndex,
    );
  }

  /// Advance scene by wall DT (seconds), scaled by [SceneConfig.timeScaleFactor].
  void advanceTime(double wallDT, {required bool manualStep}) {
    final period = 1 / frequency;
    var dt = wallDT * config.timeScaleFactor;

    final exceededPulse =
        pulseFiring && (time + dt - _pulseStartTime >= period);
    if (exceededPulse) {
      dt = _pulseStartTime + period - time;
    }

    time += dt;

    if (exceededPulse) {
      pulseFiring = false;
      _pulseStartTime = 0;
      _pulseJustCompleted = true;
      buttonPressed = false;
      continuousOscillating = false;
    }

    lattice.step();
    _setPointSourceValues();

    if (isWater) {
      _stepWater(dt);
    }

    if (config.kind == SceneKind.sound) {
      _stepSoundParticles(dt);
    }

    _applyTemporalMask();
    _stepIndex++;

    // [已确认] LightScene.advanceTime → intensitySample.step after lattice
    intensitySample?.step();
  }

  /// [已确认] WaterScene.step / launchWaterDrop @ 31ebfd7
  void _stepWater(double dt) {
    final period = 1 / frequency;
    final timeSinceLastDrop =
        _lastDropTime == null ? double.infinity : time - _lastDropTime!;

    if ((_lastDropTime == null || timeSinceLastDrop > period)) {
      _launchWaterDrop(sign: 1);
    }

    final toRemove = <WaterDrop>[];
    for (final drop in waterDrops) {
      drop.step(dt);
      if (drop.y < 0) {
        toRemove.add(drop);
      }
    }
    for (final drop in toRemove) {
      waterDrops.remove(drop);
    }
    _updateIsAboutToFire();
  }

  void _launchWaterDrop({required int sign}) {
    // [已确认] WaterScene.launchWaterDrop @ 31ebfd7
    final isPulseMode = disturbanceType == DisturbanceType.pulse;
    final firePulseDrop =
        isPulseMode && !pulseFiring && buttonPressed;
    if (!isPulseMode || firePulseDrop) {
      final buttonWasPressed = buttonPressed;
      final freq = desiredFrequency;
      final amp = desiredAmplitude;
      final isPulse = disturbanceType == DisturbanceType.pulse;

      waterDrops.add(
        WaterDrop(
          amplitude: amp,
          startsOscillation: buttonWasPressed,
          sourceSeparation: 0,
          sign: sign,
          onAbsorption: () {
            if (isPulse && pulseFiring) {
              return;
            }
            amplitude = amp;
            final oldF = frequency;
            if ((freq - oldF).abs() > 1e-15) {
              _updatePhaseForFrequencyChange(freq, oldF);
            }
            frequency = freq;
            _resetPhase();
            if (isPulse) {
              _startPulse();
            } else {
              continuousOscillating = buttonWasPressed;
            }
            if (buttonWasPressed && amp > 0) {
              onWaterDropAbsorbed?.call(amp);
            }
          },
        ),
      );
      _updateIsAboutToFire();
      _lastDropTime = time;
    }
  }

  void _updateIsAboutToFire() {
    var about = false;
    for (final d in waterDrops) {
      if (d.amplitude > 0 && d.startsOscillation) {
        about = true;
        break;
      }
    }
    isAboutToFire = about;
  }

  void removeAllDrops() {
    waterDrops.clear();
    isAboutToFire = false;
  }

  void _initSoundParticles() {
    soundParticles.clear();
    const rows = WavesIntroConstants.soundParticleRows;
    const cols = WavesIntroConstants.soundParticleColumns;
    const r = WavesIntroConstants.soundParticleRandomRadius;
    for (var i = 0; i <= rows; i++) {
      for (var k = 0; k <= cols; k++) {
        soundParticles.add(
          SoundParticle(
            i: i,
            j: k,
            x: i * config.waveAreaWidth / rows +
                WavesIntroConstants.gaussian(_particleRng) * r,
            y: k * config.waveAreaWidth / cols +
                WavesIntroConstants.gaussian(_particleRng) * r,
          ),
        );
      }
    }
  }

  void _stepSoundParticles(double dt) {
    final k = WavesIntroConstants.linear(
          config.frequencyMin,
          config.frequencyMax,
          130,
          76,
          frequency,
        ) *
        WavesIntroConstants.soundParticleGradientForceScale;

    for (final p in soundParticles) {
      final lx = modelToLatticeX(p.x).round();
      final ly = modelToLatticeY(p.y).round();
      final fx2 = lattice.getCurrentValue(lx + 1, ly);
      final fx1 = lattice.getCurrentValue(lx - 1, ly);
      final fy2 = lattice.getCurrentValue(lx, ly + 1);
      final fy1 = lattice.getCurrentValue(lx, ly - 1);
      final gradientX = (fx2 - fx1) / 2;
      final gradientY = (fy2 - fy1) / 2;
      final fx = gradientX * k * WavesIntroConstants.calibrationScale;
      final fy = gradientY * k * WavesIntroConstants.calibrationScale;
      if (!fx.isNaN && !fy.isNaN) {
        p.applyForce(
          fx: fx,
          fy: fy,
          dt: dt,
          frequency: frequency,
          frequencyMin: config.frequencyMin,
          frequencyMax: config.frequencyMax,
          random: _particleRng,
        );
      }
    }
  }

  void clear() {
    lattice.clear();
    _temporalMask.clear();
    intensitySample?.clear();
  }

  void reset() {
    clear();
    frequency = config.defaultFrequency;
    amplitude = initialAmplitude;
    desiredFrequency = config.defaultFrequency;
    desiredAmplitude = initialAmplitude;
    disturbanceType = DisturbanceType.continuous;
    soundViewType = SoundViewType.waves;
    buttonPressed = false;
    continuousOscillating = false;
    pulseFiring = false;
    _pulseJustCompleted = false;
    time = 0;
    phase = 0;
    _pulseStartTime = 0;
    _stepIndex = 0;
    oscillatorValue = 0;
    lattice.interpolationRatio = 0;
    removeAllDrops();
    _lastDropTime = null;
    intensitySample?.clear();
    if (config.kind == SceneKind.sound) {
      _initSoundParticles();
    }
  }
}
