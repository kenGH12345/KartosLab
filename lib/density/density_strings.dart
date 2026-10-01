/// PhET Density strings (en). Keys are stable for later l10n.
class DensityStrings {
  DensityStrings._();

  static const String title = 'Density';
  static const String intro = 'Introduction';
  static const String compare = 'Compare';
  static const String mystery = 'Mystery';
  static const String mass = 'Mass';
  static const String volume = 'Volume';
  static const String density = 'Density';
  static const String material = 'Material';
  static const String resetAll = 'Reset All';
  static const String oneBlock = 'One Block';
  static const String twoBlocks = 'Two Blocks';
  static const String sameMass = 'Same Mass';
  static const String sameVolume = 'Same Volume';
  static const String sameDensity = 'Same Density';
  static const String set1 = 'Set 1';
  static const String set2 = 'Set 2';
  static const String set3 = 'Set 3';
  static const String random = 'Random';
  static const String densityTable = 'Density Table';
  static const String kg = 'kg';
  static const String liters = 'L';
  static const String kgPerL = 'kg/L';
  static const String refreshRandom = 'Refresh';
  static const String grabHint = 'Grab';
  static const String aboutTitle = 'About Density';
  static const String aboutBody =
      'Adapted from PhET Interactive Simulations\n'
      'https://phet.colorado.edu/en/simulations/density\n\n'
      'Density simulation source: GPL-3.0\n'
      'Shared model/view (density-buoyancy-common): GPL-3.0\n\n'
      'Material textures: CC0 (cc0textures.com)\n\n'
      'This Flutter port is not a PhET official application.';

  static String materialName(String stringKey) {
    const names = <String, String>{
      'density.material.styrofoam': 'Styrofoam',
      'density.material.wood': 'Wood',
      'density.material.ice': 'Ice',
      'density.material.pvc': 'PVC',
      'density.material.brick': 'Brick',
      'density.material.aluminum': 'Aluminum',
      'density.material.custom': 'Custom',
      'density.material.gasoline': 'Gasoline',
      'density.material.apple': 'Apple',
      'density.material.human': 'Human',
      'density.material.water': 'Water',
      'density.material.glass': 'Glass',
      'density.material.diamond': 'Diamond',
      'density.material.titanium': 'Titanium',
      'density.material.steel': 'Steel',
      'density.material.copper': 'Copper',
      'density.material.lead': 'Lead',
      'density.material.gold': 'Gold',
    };
    return names[stringKey] ?? stringKey;
  }

  static String grabMass(String tag) => 'Grab Mass $tag';
}
