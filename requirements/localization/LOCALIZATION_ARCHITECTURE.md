# LOCALIZATION_ARCHITECTURE

> PHASE 1

## Goal

Decouple **language** from Model / Physics / Renderer.

```
PhET English Source (archaeology, untouched)
        ↓
Semantic meaning + glossary
        ↓
KartosLocalization (lib/l10n)
        ↓
Composer / Widgets consume loc.*
```

## Runtime entry

```dart
import 'package:kratos/l10n/kartos_localization.dart';

Text(loc.common.resetAll);
Text(loc.home.appTitle);
Text(loc.sim.title('bending-light'));
Text(loc.physics.massWithValue(2));
```

- Default locale: `KartosLocale.zhCN`
- Switch: `KartosLocalization.setLocale(KartosLocale.en)`

## Layout

```
lib/l10n/
  kartos_localization.dart      # loc façade
  kartos_locale.dart
  localization_format.dart      # {param} formatting
  namespaces/
    common_l10n.dart
    home_l10n.dart
    physics_l10n.dart
    accessibility_l10n.dart
    sim_titles_l10n.dart
    shared_chrome_l10n.dart
  legacy/
    legacy_strings_adapter.dart
    migration_status.dart
  scan/
    english_residue_classifier.dart

resources/localization/
  meta.json
  migration_status.json
  zh_CN/*.json                  # human-readable catalog (mirror)
```

## Rules

| Do | Don't |
|---|---|
| `Text(loc.common.resetAll)` | `Text('全部重置')` in new code |
| Keep sim id `bending-light` | Rename routes/IDs for Chinese |
| Migrate via adapter | Delete all `*Strings` in one PR |
| Touch LayoutSpec only for overflow | Page-level magic `Positioned` for one string |

## Migration states

`LOCALIZED` | `PARTIAL` | `NOT STARTED` — see `migration_status.dart` / JSON.
