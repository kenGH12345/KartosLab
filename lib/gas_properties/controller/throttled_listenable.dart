import 'dart:async';

import 'package:flutter/foundation.dart';

/// Forwards [source] notifications at most once per [interval].
class ThrottledListenable extends ChangeNotifier {
  ThrottledListenable(this.source, {this.interval = const Duration(milliseconds: 100)}) {
    source.addListener(_onSource);
  }

  final Listenable source;
  final Duration interval;
  bool _pending = false;
  Timer? _timer;

  void _onSource() {
    if (_pending) return;
    _pending = true;
    _timer = Timer(interval, () {
      _pending = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    source.removeListener(_onSource);
    super.dispose();
  }
}
