import 'package:flutter/material.dart';

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

/// Water faucet — geometric stand-in for scenery-phet FaucetNode (no PNG in WI images).
class WaterFaucetSource extends StatelessWidget {
  const WaterFaucetSource({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 18,
            child: CustomPaint(
              size: const Size(56, 28),
              painter: _FaucetPainter(),
            ),
          ),
          Positioned(
            left: 22,
            top: 0,
            child: WaveSourceButton(model: model, size: 26),
          ),
        ],
      ),
    );
  }
}

class _FaucetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final metal = Paint()..color = const Color(0xFFB0B0B0);
    final dark = Paint()..color = const Color(0xFF707070);
    // Horizontal pipe from left
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.35, size.width * 0.7, 10),
        const Radius.circular(2),
      ),
      metal,
    );
    // Spout down
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.35, 12, size.height * 0.55),
        const Radius.circular(2),
      ),
      metal,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.9),
      5,
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sound speaker — PhET `images/speaker/speaker_MID.png` @ lock `31ebfd7`.
class SoundSpeakerSource extends StatelessWidget {
  const SoundSpeakerSource({super.key, required this.model});

  final WavesIntroModel model;

  static const asset = 'assets/phet/waves_intro/speaker_MID.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: Image.asset(
              asset,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                size: const Size(54, 54),
                painter: _SpeakerFallbackPainter(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 22,
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
      width: 88,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 18,
            top: 8,
            child: CustomPaint(
              size: const Size(70, 32),
              painter: _LaserPainter(accent: color),
            ),
          ),
          Positioned(
            left: 28,
            top: 0,
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
