/// Asset paths decoded from PhET `images/*_png.ts`.
class EfacAssets {
  EfacAssets._();

  static const String root = 'assets/energy_forms_and_changes';

  static String png(String nameWithoutExtension) =>
      '$root/$nameWithoutExtension.png';

  // Energy chunk icons
  static String get energyThermal => png('energyThermal');
  static String get energyElectrical => png('energyElectrical');
  static String get energyMechanical => png('energyMechanical');
  static String get energyLight => png('energyLight');
  static String get energyChemical => png('energyChemical');
  static String get energyHidden => png('energyHidden');

  // Intro
  static String get shelf => png('shelf');
  static String get gasPipeIntro => png('gasPipeIntro');
  static String get introScreenIcon => png('introScreenIcon');
  static String get brickTextureFront => png('brickTextureFront');
  static String get brickTextureRight => png('brickTextureRight');
  static String get brickTextureTop => png('brickTextureTop');
  static String get ironTextureFront => png('ironTextureFront');
  static String get ironTextureRight => png('ironTextureRight');
  static String get ironTextureTop => png('ironTextureTop');

  // scenery-phet (copied into this asset folder)
  static String get flame => png('flame');
  static String get iceCubeStack => png('iceCubeStack');
  static String get faucetBody => png('faucetBody');
  static String get faucetSpout => png('faucetSpout');

  // Systems icons / elements (subset — full set on disk)
  static String get systemsScreenIcon => png('systemsScreenIcon');
  static String get bicycleIcon => png('bicycleIcon');
  static String get faucetIcon => png('faucetIcon');
  static String get sunIcon => png('sunIcon');
  static String get teaKettleIcon => png('teaKettleIcon');
  static String get generatorIcon => png('generatorIcon');
  static String get solarPanelIcon => png('solarPanelIcon');
  static String get waterIcon => png('waterIcon');
  static String get incandescentIcon => png('incandescentIcon');
  static String get fluorescentIcon => png('fluorescentIcon');
  static String get fanIcon => png('fanIcon');
}
