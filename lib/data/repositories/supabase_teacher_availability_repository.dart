// Removed unused supabase_flutter import to fix analyzer issue at line 1.
import '../../data/supabase/supabase_service.dart';
import '../../domain/entities/availability.dart';
import '../../domain/repositories/teacher_availability_repository.dart';

class SupabaseTeacherAvailabilityRepository
    implements TeacherAvailabilityRepository {
  final SupabaseService _svc;
  SupabaseTeacherAvailabilityRepository(this._svc);

  @override
  Future<List<AvailabilityPeriod>> listByTeacher(String teacherId) async {
    final res = await _svc.client
        .from('teacher_availability')
        .select('id, teacher_id, day_of_week, period, tz')
        .eq('teacher_id', int.parse(teacherId))
        .order('day_of_week', ascending: true);
    final list = (res as List<dynamic>).cast<Map<String, dynamic>>();
    return list
        .map(
          (m) => AvailabilityPeriod(
            id: m['id'].toString(),
            teacherId: m['teacher_id'].toString(),
            dayOfWeek: int.parse(m['day_of_week'].toString()),
            startUtc: _parseRangeStart(m['period']).toUtc(),
            endUtc: _parseRangeEnd(m['period']).toUtc(),
            tz: m['tz'],
          ),
        )
        .toList();
  }

  @override
  Future<void> deletePeriod(String periodId) async {
    await _svc.client
        .from('teacher_availability')
        .delete()
        .eq('id', int.parse(periodId));
  }

  @override
  Future<void> upsertPeriods(
    String teacherId,
    List<AvailabilityPeriod> periods,
  ) async {
    final tid = int.parse(teacherId);
    // Strategy: remove existing rows for teacher, then insert provided periods
    await _svc.client
        .from('teacher_availability')
        .delete()
        .eq('teacher_id', tid);

    if (periods.isEmpty) return;

    final rows = periods.map((p) {
      // period as text range in UTC: [start,end)
      final startIso = p.startUtc.toIso8601String();
      final endIso = p.endUtc.toIso8601String();
      final rangeText = '[$startIso,$endIso)';
      return {
        'teacher_id': tid,
        'day_of_week': p.dayOfWeek,
        'period': rangeText,
        'tz': p.tz,
      };
    }).toList();

    await _svc.client.from('teacher_availability').insert(rows);
  }
}

DateTime _parseRangeStart(dynamic cell) {
  final pair = _parseRange(cell);
  return pair.$1;
}

DateTime _parseRangeEnd(dynamic cell) {
  final pair = _parseRange(cell);
  return pair.$2;
}

/// Parses a PostgREST `tstzrange` cell which may come as a Map or string.
/// Examples:
/// - Map form: {"lower":"2024-11-12T10:00:00+00","upper":"2024-11-12T12:00:00+00","lowerInclusive":true,"upperInclusive":false}
/// - Text form: "[2024-11-12 10:00:00+00,2024-11-12 12:00:00+00)"
/// Returns (start, end) as DateTime in UTC.
(DateTime, DateTime) _parseRange(dynamic cell) {
  if (cell == null) {
    throw StateError('Availability period cell is null');
  }
  // Map/object form
  if (cell is Map) {
    final lower = cell['lower'] ?? cell['start'] ?? cell['begin'];
    final upper = cell['upper'] ?? cell['end'] ?? cell['finish'];
    if (lower == null || upper == null) {
      throw StateError('Invalid range map: missing lower/upper');
    }
    final start = DateTime.parse(lower.toString()).toUtc();
    final end = DateTime.parse(upper.toString()).toUtc();
    return (start, end);
  }
  // String form: [start,end)
  final text = cell.toString().trim();
  final cleaned = text.replaceAll('"', '');
  final body = cleaned.substring(
    1,
    cleaned.length - 1,
  ); // drop [ and ) / ] and )
  final commaIdx = body.indexOf(',');
  if (commaIdx <= 0) {
    throw StateError('Invalid range string: $text');
  }
  final startStr = body.substring(0, commaIdx).trim();
  final endStr = body.substring(commaIdx + 1).trim();
  final start = DateTime.parse(startStr).toUtc();
  final end = DateTime.parse(endStr).toUtc();
  return (start, end);
}
