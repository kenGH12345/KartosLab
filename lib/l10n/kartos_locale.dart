/// Supported UI locales for KartosLab.
///
/// Default product language is Simplified Chinese ([zhCN]).
/// English remains available for future bilingual switching / archaeology.
enum KartosLocale {
  zhCN,
  en,
}

extension KartosLocaleX on KartosLocale {
  String get languageCode => switch (this) {
        KartosLocale.zhCN => 'zh',
        KartosLocale.en => 'en',
      };

  String get scriptCode => switch (this) {
        KartosLocale.zhCN => 'Hans',
        KartosLocale.en => 'Latn',
      };

  String get tag => switch (this) {
        KartosLocale.zhCN => 'zh-CN',
        KartosLocale.en => 'en',
      };
}
