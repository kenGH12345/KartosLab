import 'package:kratos/l10n/namespaces/accessibility_l10n.dart';
import 'package:kratos/l10n/namespaces/common_l10n.dart';

/// Shared chrome façade — Reset / Play / Pause / Step / dialogs.
///
/// Prefer `loc.shared.*` in L0 widgets so sims do not re-hardcode chrome text.
class SharedChromeL10n {
  const SharedChromeL10n({
    required this.common,
    required this.accessibility,
  });

  final CommonL10n common;
  final AccessibilityL10n accessibility;

  String get resetAll => common.resetAll;
  String get resetAllSemantics => accessibility.resetAll;
  String get reset => common.reset;
  String get play => common.play;
  String get pause => common.pause;
  String get playSemantics => accessibility.play;
  String get pauseSemantics => accessibility.pause;
  String get step => common.step;
  String get stepForward => common.stepForward;
  String get stepForwardSemantics => accessibility.stepForward;
  String get restart => common.restart;
  String get restartSemantics => accessibility.restart;
  String get back => common.back;
  String get close => common.close;
  String get ok => common.ok;
  String get cancel => common.cancel;
  String get normal => common.normal;
  String get slow => common.slow;
  String get fast => common.fast;
  String get stopwatch => common.stopwatch;
}
