import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  /// Times a future and logs the duration. If [slowThresholdMs] is exceeded,
  /// logs a SLOW marker and optionally triggers [onSlow]. Returns the future result.
  static Future<T> time<T>(String label, Future<T> future,
      {int slowThresholdMs = 600,
      void Function(Duration dur)? onSlow}) async {
    final start = DateTime.now();
    try {
      final result = await future;
      final dur = DateTime.now().difference(start);
      _log(label, dur);
      if (dur.inMilliseconds >= slowThresholdMs) {
        _log('SLOW $label', dur, slow: true);
        if (onSlow != null) onSlow(dur);
      }
      return result;
    } catch (e) {
      final dur = DateTime.now().difference(start);
      _log('ERROR $label: $e', dur);
      rethrow;
    }
  }

  static void _log(String label, Duration dur, {bool slow = false}) {
    final msg = '[perf] $label took ${dur.inMilliseconds}ms${slow ? ' (slow)' : ''}';
    if (kDebugMode) {
      dev.log(msg, name: 'app.perf');
      // Also print for quick visibility in debug consoles
      // ignore: avoid_print
      print(msg);
    }
  }
}

