/// Electron depiction mode — shred `ElectronShellDepiction` / `AtomViewProperties`.
///
/// Switching mode must NOT change electron counts or shell occupancy.
library;

/// How electrons are depicted in the View.
enum ElectronModelType {
  /// Localized particles on shell slots (default).
  shells,

  /// Schrödinger-style cloud radius grown by electron count (no random dots).
  cloud,
}

/// View-facing electron model state owned by exploration screens.
class ElectronModel {
  ElectronModel({ElectronModelType type = ElectronModelType.shells})
      : _type = type;

  ElectronModelType _type;

  ElectronModelType get type => _type;

  set type(ElectronModelType value) {
    if (_type == value) return;
    _type = value;
  }

  bool get isShells => _type == ElectronModelType.shells;
  bool get isCloud => _type == ElectronModelType.cloud;

  void reset() {
    _type = ElectronModelType.shells;
  }

  /// Cloud radius formula from shred `ElectronCloudView.update`
  /// (model units, before MVT):
  /// `minR + (maxR - minR) / MAX_ELECTRONS * numElectrons`.
  static double cloudRadius({
    required int electronCount,
    required double innerShellRadius,
    required double outerShellRadius,
    required int maxElectrons,
  }) {
    if (electronCount <= 0) return 0;
    final minR = innerShellRadius * 0.5;
    final maxR = outerShellRadius;
    return minR + (maxR - minR) / maxElectrons * electronCount;
  }
}
