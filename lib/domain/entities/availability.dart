class AvailabilityPeriod {
  final String id; // db id (optional for new)
  final String teacherId;
  final int dayOfWeek; // 0=Mon .. 6=Sun
  final DateTime startUtc;
  final DateTime endUtc;
  final String? tz;

  const AvailabilityPeriod({
    required this.id,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startUtc,
    required this.endUtc,
    this.tz,
  });

  factory AvailabilityPeriod.fromMap(Map<String, dynamic> m) {
    // Supabase returns range as text or Postgres range object depending on client; we expect separate start/end
    return AvailabilityPeriod(
      id: m['id'].toString(),
      teacherId: m['teacher_id'].toString(),
      dayOfWeek: int.parse(m['day_of_week'].toString()),
      startUtc: DateTime.parse(m['start_utc']).toUtc(),
      endUtc: DateTime.parse(m['end_utc']).toUtc(),
      tz: m['tz'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'teacher_id': teacherId,
        'day_of_week': dayOfWeek,
        'start_utc': startUtc.toIso8601String(),
        'end_utc': endUtc.toIso8601String(),
        'tz': tz,
      };
}

