import 'package:flutter/widgets.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TimezoneInit {
  static bool _initialized = false;
  static tz.Location? _location;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final name = await FlutterNativeTimezone.getLocalTimezone();
    _location = tz.getLocation(name);
    _initialized = true;
  }

  static tz.Location? get location => _location;

  static DateTime toLocalFromUtc(DateTime utc) {
    if (!_initialized || _location == null) return utc.toLocal();
    final tzDt = tz.TZDateTime.from(utc, tz.UTC);
    final local = tz.TZDateTime.from(tzDt, _location!);
    return DateTime(local.year, local.month, local.day, local.hour, local.minute, local.second);
  }

  static DateTime toUtcFromLocal(DateTime local) {
    if (!_initialized || _location == null) return local.toUtc();
    final tzLocal = tz.TZDateTime(
      _location!,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
    );
    final utc = tz.TZDateTime.from(tzLocal, tz.UTC);
    return DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second);
  }
}

