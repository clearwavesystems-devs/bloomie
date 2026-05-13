import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class Throttle {
  final Duration delay;
  DateTime? _lastRun;

  Throttle({required this.delay});

  void call(VoidCallback action) {
    if (_lastRun == null ||
        DateTime.now().difference(_lastRun!) > delay) {
      action();
      _lastRun = DateTime.now();
    }
  }
}
