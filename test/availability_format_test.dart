import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedules_flutter/core/time_utils.dart';

void main() {
  test('English format 7:00 AM to 2:00 PM', () {
    final start = DateTime(2024, 1, 1, 7, 0);
    final end = DateTime(2024, 1, 1, 14, 0);
    final s = formatRangeLocalized(start, end, const Locale('en'));
    expect(s, '7:00 AM to 2:00 PM');
  });

  test('Spanish compact format 7:00a.m. a 2:00p.m.', () {
    final start = DateTime(2024, 1, 1, 7, 0);
    final end = DateTime(2024, 1, 1, 14, 0);
    final s = formatRangeLocalized(start, end, const Locale('es'));
    expect(s, '7:00a.m. a 2:00p.m.');
  });

  test('UTC conversion preserves hours when location not initialized', () {
    final local = DateTime(2024, 1, 1, 7, 0);
    final utc = DateTime.utc(local.year, local.month, local.day, local.hour, local.minute);
    expect(utc.hour, 7);
  });
}
