import 'dart:ui';
import '../solver/photon_beam.dart';
import '../../common/controls/spectrum_slider.dart';
import 'filter.dart';
import 'photon.dart';

/// Bulb source mode: white light or monochromatic (single wavelength).
enum BulbMode { white, mono }

/// Mutable state for the single-bulb simulation.
class SingleBulbState {
  final PhotonBeam beam;
  Filter filter;
  final double filterX;
  final double personPosition;
  BulbMode bulbMode;
  double bulbWavelength; // nm, 380-780
  Color bulbColor; // cached color for the current wavelength

  final List<Photon> filteredPhotons = [];

  SingleBulbState({
    required this.beam,
    this.filter = const Filter(type: FilterType.none),
    this.filterX = 200,
    this.personPosition = 300,
    this.bulbMode = BulbMode.white,
    this.bulbWavelength = 550,
  }) : bulbColor = wavelengthToColor(550) {
    if (bulbMode == BulbMode.mono) {
      beam.color = bulbColor;
    }
  }

  void setBulbMode(BulbMode mode) {
    bulbMode = mode;
    beam.color = mode == BulbMode.mono ? bulbColor : const Color(0xFFFFFFFF);
  }

  void setBulbWavelength(double nm) {
    bulbWavelength = nm;
    bulbColor = wavelengthToColor(nm);
    if (bulbMode == BulbMode.mono) {
      beam.color = bulbColor;
    }
  }

  void stepInTime(double dt) {
    beam.stepInTime(dt);

    for (int i = beam.alive.length - 1; i >= 0; i--) {
      final p = beam.alive[i];
      if (p.x >= filterX && !p.filtered) {
        p.filtered = true;
        final (pr, pg, pb) = filter.passRates;
        final r = ((p.color.r * 255.0).round() * pr).round();
        final g = ((p.color.g * 255.0).round() * pg).round();
        final b = ((p.color.b * 255.0).round() * pb).round();
        if (r == 0 && g == 0 && b == 0) {
          p.kill();
        } else {
          p.color = Color.fromARGB(255, r, g, b);
        }
      }
    }
    beam.alive.removeWhere((p) => !p.alive);
  }

  void setFilter(Filter f) {
    filter = f;
    // Reset filtered flag on all alive photons so new filter applies
    for (final p in beam.alive) {
      p.filtered = false;
    }
  }

  void dispose() {
    beam.clear();
    filteredPhotons.clear();
  }
}
