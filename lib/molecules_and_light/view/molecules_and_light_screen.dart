import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/simulation_clock.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/molecule_geometry.dart';
import '../model/molecules_and_light_model.dart';
import '../molecules_and_light_constants.dart';
import 'molecules_and_light_mvt.dart';
import 'observation_window_painter.dart';
import 'spectrum_diagram_painter.dart';

/// Single Molecules and Light simulation screen (PhET `MicroScreenView`).
///
/// Official Home entry — no demo hub / QA shell.
class MoleculesAndLightScreen extends StatefulWidget {
  const MoleculesAndLightScreen({super.key});

  static const String title = 'Molecules and Light';
  static const String subtitle = '光子吸收 · 分子振动 · 光谱';
  static const Color accentColor = Color(0xFF4070CE);

  @override
  State<MoleculesAndLightScreen> createState() =>
      MoleculesAndLightScreenState();
}

class MoleculesAndLightScreenState extends State<MoleculesAndLightScreen>
    with SingleTickerProviderStateMixin {
  final SimulationClock _clock = SimulationClock(fps: 60);
  final MoleculesAndLightMvt _mvt = MoleculesAndLightMvt();
  late final MoleculesAndLightModel model;

  final Map<LightType, ui.Image?> _photonImages = {};
  final Map<LightType, ui.Image?> _emitterOn = {};
  final Map<LightType, ui.Image?> _emitterOff = {};

  bool _spectrumOpen = false;

  /// Test / lifecycle: whether the spectrum overlay is showing.
  bool get spectrumOpen => _spectrumOpen;

  /// Test / lifecycle: the physics clock driving this screen.
  SimulationClock get clock => _clock;

  @override
  void initState() {
    super.initState();
    model = MoleculesAndLightModel();
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      model.step(dt);
      if (mounted) {
        setState(() {});
      }
    };
    _clock.play();
    unawaited(_loadAssets());
  }

  Future<void> _loadAssets() async {
    Future<ui.Image?> load(String name) async {
      try {
        final data =
            await rootBundle.load('assets/molecules_and_light/$name');
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        return (await codec.getNextFrame()).image;
      } catch (_) {
        return null;
      }
    }

    _photonImages[LightType.microwave] = await load('microwavePhoton.png');
    _photonImages[LightType.infrared] = await load('infraredPhoton.png');
    _photonImages[LightType.visible] = await load('visiblePhoton.png');
    _photonImages[LightType.ultraviolet] = await load('ultravioletPhoton.png');

    _emitterOn[LightType.microwave] = await load('microwaveSource.png');
    _emitterOn[LightType.infrared] = await load('infraredSource.png');
    _emitterOn[LightType.visible] = await load('flashlight.png');
    _emitterOn[LightType.ultraviolet] = await load('uvSource.png');

    _emitterOff[LightType.infrared] = await load('infraredSourceOff.png');
    _emitterOff[LightType.visible] = await load('flashlightOff.png');
    _emitterOff[LightType.ultraviolet] = await load('uvSourceOff.png');

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _clock.pause();
    _clock.onTick = null;
    _clock.dispose();
    super.dispose();
  }

  void _reset() {
    model.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      backgroundColor: const Color(0xFFC5D6E8),
      appBar: AppBar(
        title: const Text(
          MoleculesAndLightScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: MoleculesAndLightScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
        automaticallyImplyLeading: canPop,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MoleculesAndLightMvt.layoutWidth,
                    height: MoleculesAndLightMvt.layoutHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 15,
                          top: 15,
                          width: MoleculesAndLightMvt.observationWidth,
                          height: MoleculesAndLightMvt.observationHeight,
                          child: _observationWindow(),
                        ),
                        Positioned(
                          left: 15,
                          top: 350,
                          child: _lightSelector(),
                        ),
                        Positioned(
                          left: 530,
                          top: 15,
                          child: _moleculeSelector(),
                        ),
                        Positioned(
                          left: 530,
                          top: 340,
                          width: 220,
                          child: _timeControls(),
                        ),
                        Positioned(
                          left: 530,
                          top: 420,
                          width: 220,
                          child: _spectrumButton(),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 15,
                          child: KratosResetAllButton(
                            onPressed: _reset,
                            radius: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_spectrumOpen) _spectrumDialog(),
        ],
      ),
    );
  }

  Widget _observationWindow() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF4070CE), width: 5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: GestureDetector(
          onTap: () => setState(() => model.setEmitterOn(!model.emitterOn)),
          child: CustomPaint(
            painter: ObservationWindowPainter(
              model: model,
              mvt: _mvt,
              photonImages: _photonImages,
              emitterOnImages: _emitterOn,
              emitterOffImages: _emitterOff,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _lightSelector() {
    Widget chip(LightType type, String label, String asset) {
      final selected = model.light == type;
      return GestureDetector(
        key: Key('light-$label'),
        onTap: () => setState(() => model.setLight(type)),
        child: Container(
          width: 118,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3A7BD5) : const Color(0xFFE8F0F8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF2C3E50)),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/molecules_and_light/$asset',
                height: 36,
                errorBuilder: (_, error, stack) => const SizedBox(height: 36),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: const Key('light-selector'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF888888)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Light Sources', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              chip(LightType.microwave, 'Microwave', 'microwaveSource.png'),
              chip(LightType.infrared, 'Infrared', 'infraredSource.png'),
              chip(LightType.visible, 'Visible', 'flashlight.png'),
              chip(LightType.ultraviolet, 'Ultraviolet', 'uvSource.png'),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Higher Energy →', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _moleculeSelector() {
    const items = <(MoleculeType, String, String)>[
      (MoleculeType.carbonMonoxide, 'Carbon Monoxide', 'CO'),
      (MoleculeType.nitrogen, 'Nitrogen', 'N₂'),
      (MoleculeType.oxygen, 'Oxygen', 'O₂'),
      (MoleculeType.carbonDioxide, 'Carbon Dioxide', 'CO₂'),
      (MoleculeType.methane, 'Methane', 'CH₄'),
      (MoleculeType.water, 'Water', 'H₂O'),
      (MoleculeType.nitrogenDioxide, 'Nitrogen Dioxide', 'NO₂'),
      (MoleculeType.ozone, 'Ozone', 'O₃'),
    ];

    return Container(
      key: const Key('molecule-selector'),
      width: 220,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5C80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B334D)),
      ),
      child: Column(
        children: [
          for (final item in items)
            GestureDetector(
              key: Key('molecule-${item.$3}'),
              onTap: () => setState(() => model.setMolecule(item.$1)),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: model.moleculeType == item.$1
                      ? const Color(0xFF5A8AB8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          children: [
                            TextSpan(text: '${item.$2} '),
                            TextSpan(
                              text: item.$3,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(40, 24),
                      painter: _MiniMoleculePainter(geometryFor(item.$1)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _timeControls() {
    final playing = model.running;
    final slow = model.timeSpeed == TimeSpeed.slow;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip(slow ? 'Slow' : 'Normal', () {
            setState(() {
              model.timeSpeed =
                  slow ? TimeSpeed.normal : TimeSpeed.slow;
            });
          }, keyName: 'speed-toggle'),
          const SizedBox(width: 8),
          _chip(playing ? 'Pause' : 'Play', () {
            setState(() => model.running = !playing);
          }, keyName: 'play-pause'),
          const SizedBox(width: 8),
          _chip('Step', () {
            if (!model.running) {
              model.manualStep();
              setState(() {});
            }
          }, keyName: 'step-forward'),
        ],
      ),
    );
  }

  Widget _spectrumButton() {
    return GestureDetector(
      key: const Key('spectrum-button'),
      onTap: () => setState(() => _spectrumOpen = true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF62ADCD),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF1B4F72)),
        ),
        child: const Text(
          'Light Spectrum Diagram',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _spectrumDialog() {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth.clamp(320.0, 720.0);
            final maxH = (constraints.maxHeight * 0.95).clamp(280.0, 560.0);
            return Center(
              child: SizedBox(
                width: maxW,
                height: maxH,
                child: Container(
                  key: const Key('spectrum-dialog'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF333333)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 12,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Light Spectrum',
                        key: Key('spectrum-title'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SizedBox(
                          key: const Key('spectrum-strip'),
                          width: double.infinity,
                          child: const CustomPaint(
                            painter: SpectrumDiagramPainter(),
                            child: SizedBox.expand(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          key: const Key('spectrum-close'),
                          onPressed: () =>
                              setState(() => _spectrumOpen = false),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap, {required String keyName}) {
    return GestureDetector(
      key: Key(keyName),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF62ADCD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1B4F72)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _MiniMoleculePainter extends CustomPainter {
  _MiniMoleculePainter(this.geometry);
  final MoleculeGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const s = 0.06;
    for (final bond in geometry.bonds) {
      final a = geometry.atoms[bond.a];
      final b = geometry.atoms[bond.b];
      canvas.drawLine(
        Offset(cx + a.offsetX * s, cy - a.offsetY * s),
        Offset(cx + b.offsetX * s, cy - b.offsetY * s),
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1.5,
      );
    }
    for (final atom in geometry.atoms) {
      canvas.drawCircle(
        Offset(cx + atom.offsetX * s, cy - atom.offsetY * s),
        atom.radius * s,
        Paint()..color = atom.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMoleculePainter oldDelegate) => false;
}
