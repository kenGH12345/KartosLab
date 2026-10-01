/// Source-aligned audio *event* hooks for Ohm's Law (PhET `OhmsLawScreenView`).
///
/// Source wiring:
/// - `DiscreteSoundGenerator` on `voltageProperty` / `resistanceProperty` (click)
/// - `CurrentSoundGenerator` on `currentProperty` (loop + fade; needs `step(dt)`)
///
/// This class records events for runtime tests. Actual sample playback is optional
/// and environment-dependent → report Audio as PARTIAL until heard on device.
class OhmsLawAudioHooks {
  OhmsLawAudioHooks();

  int voltageClickEvents = 0;
  int resistanceClickEvents = 0;
  int currentChangeEvents = 0;
  int resetEvents = 0;
  bool disposed = false;

  void onVoltageChanged() {
    if (disposed) return;
    voltageClickEvents++;
  }

  void onResistanceChanged() {
    if (disposed) return;
    resistanceClickEvents++;
  }

  void onCurrentChanged() {
    if (disposed) return;
    currentChangeEvents++;
  }

  void onReset() {
    if (disposed) return;
    resetEvents++;
  }

  void dispose() {
    disposed = true;
  }
}
