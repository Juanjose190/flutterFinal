class TimezoneInit {
  static bool _initialized = false;
  static String? _tzName;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _tzName = DateTime.now().timeZoneName;
    _initialized = true;
  }

  static String? get tzName => _tzName;

  static DateTime toLocalFromUtc(DateTime utc) => utc.toLocal();

  static DateTime toUtcFromLocal(DateTime local) => local.toUtc();
}
