import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

String formatRangeLocalized(DateTime startLocal, DateTime endLocal, Locale locale) {
  final isSpanish = locale.languageCode.toLowerCase().startsWith('es');
  if (isSpanish) {
    // Custom compact Spanish format: 7:00a.m. a 2:00p.m.
    final hStart = _formatHourCompact(startLocal);
    final hEnd = _formatHourCompact(endLocal);
    return '$hStart a $hEnd';
  } else {
    // English: 7:00 AM to 2:00 PM
    final hStart = intl.DateFormat('h:mm a').format(startLocal);
    final hEnd = intl.DateFormat('h:mm a').format(endLocal);
    return '$hStart to $hEnd';
  }
}

String _formatHourCompact(DateTime dt) {
  final hourMinute = intl.DateFormat('H:mm').format(dt);
  final h = int.parse(hourMinute.split(':')[0]);
  final m = hourMinute.split(':')[1];
  final isPm = dt.hour >= 12;
  final hour12 = ((h + 11) % 12) + 1; // convert to 12-hour
  final suffix = isPm ? 'p.m.' : 'a.m.';
  return '$hour12:$m$suffix';
}

