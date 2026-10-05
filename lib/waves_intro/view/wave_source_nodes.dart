import 'package:flutter/material.dart';

import '../../../chemistry/ph_scale/ph_scale_assets.dart';
import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';

/// Green wave-generator button — [已确认] WaveGeneratorNode button color.
class WaveSourceButton extends StatelessWidget {
  const WaveSourceButton({
    super.key,
    required this.model,
    this.size = 28,
  });

  final WavesIntroModel model;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pressed = model.scene.buttonPressed;
    return GestureDetector(
      onTap: () {
        final scene = model.scene;
        if (scene.disturbanceType == DisturbanceType.pulse) {
          if (!scene.pulseFiring && !scene.isAboutToFire) {
            model.setButtonPressed(true);
          }
        } else {
          model.setButtonPressed(!scene.buttonPressed);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(WavesIntroConstants.waveGeneratorButtonColor),
          border: Border.all(
            color: pressed ? Colors.black87 : Colors.black38,
            width: pressed ? 3 : 1.5,
          ),
          boxShadow: pressed
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
      ),
    );
  }
}

/// Water faucet — scenery-phet `FaucetNode` sprites (no shooter: amplitude is
/// the right-column slider). Green control is `WaveGeneratorNode`.
class WaterFaucetSource extends StatelessWidget {
  const WaterFaucetSource({
    super.key,
    required this.model,
    this.pipeWidth = 118,
  });

  final WavesIntroModel model;
  final double pipeWidth;

  @override
  Widget build(BuildContext context) {
    final width = pipeWidth + 48;
    return SizedBox(
      width: width,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 28,
            child: Image.asset(
              PhScaleAssets.faucetHorizontalPipe,
              height: 16,
              width: pipeWidth,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: pipeWidth - 18,
            top: 10,
            child: Image.asset(
              PhScaleAssets.faucetBody,
              width: 52,
              height: 42,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: pipeWidth + 4,
            top: 40,
            child: Image.asset(
              PhScaleAssets.faucetSpout,
              width: 30,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 62,
            top: 16,
            child: IgnorePointer(
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.35, -0.45),
                    colors: [
                      Color(0xFFE8E8E8),
                      Color(0xFFB1B1B1),
                      Color(0xFF6A6A6A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 66,
            top: 20,
            child: WaveSourceButton(model: model, size: 28),
          ),
        ],
      ),
    );
  }
}

/// Sound speaker — PhET `images/speaker/speaker_MID.png` @ lock `31ebfd7`.
class SoundSpeakerSource extends StatelessWidget {
  const SoundSpeakerSource({super.key, required this.model});

  final WavesIntroModel model;

  static const asset = 'assets/phet/waves_intro/speaker_MID.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 18,
            top: 4,
            child: Image.asset(
              asset,
              width: 76,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                size: const Size(76, 72),
                painter: _SpeakerFallbackPainter(),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 26,
            child: WaveSourceButton(model: model, size: 24),
          ),
        ],
      ),
    );
  }
}

class _SpeakerFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFF6A6A6A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.15, size.width * 0.45, size.height * 0.7),
        const Radius.circular(4),
      ),
      body,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.28,
      Paint()..color = const Color(0xFFE8C84A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Light laser pointer — geometric stand-in for scenery-phet LaserPointerNode.
class LightLaserSource extends StatelessWidget {
  const LightLaserSource({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final wavelengthNm = model.scene.wavelength;
    final color = Color(WavesIntroConstants.wavelengthToArgb(wavelengthNm));
    return SizedBox(
      width: 96,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            top: 6,
            child: Image.asset(
              'assets/simulations/bending_light/laser.png',
              width: 86,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                size: const Size(86, 32),
                painter: _LaserPainter(accent: color),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 8,
            child: WaveSourceButton(model: model, size: 26),
          ),
        ],
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFF8A8A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 6, size.width * 0.72, size.height - 12),
        const Radius.circular(4),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, 2, size.width * 0.28, size.height - 4),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5A5A5A),
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height / 2),
      4,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _LaserPainter old) => old.accent != accent;
}
