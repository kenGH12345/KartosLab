/// Asset path helpers for States of Matter (images / mipmaps).
class SomAssets {
  SomAssets._();

  static const String imagesRoot = 'assets/states_of_matter/images/';
  static const String mipmapsRoot = 'assets/states_of_matter/mipmaps/';

  static String image(String name) => '$imagesRoot$name';
  static String mipmap(String name) => '$mipmapsRoot$name';

  /// Original PhET mipmap icons for States phase control.
  static String get solidIcon => mipmap('solidIcon.png');
  static String get liquidIcon => mipmap('liquidIcon.png');
  static String get gasIcon => mipmap('gasIcon.png');
  static String get pointingHand => mipmap('pointingHand.png');
  static String get pushPin => image('pushPin.png');

  /// scenery-phet `hand.png` — Interaction movable-atom hint (`HandNode`).
  static String get hand => image('hand.png');
}
