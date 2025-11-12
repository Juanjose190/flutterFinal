class Schedule {
  final String id;
  final String teacherId;
  final String subjectId;
  final String classroomId;
  final DateTime date;
  final String? notes;
  const Schedule({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.classroomId,
    required this.date,
    this.notes,
  });
  factory Schedule.fromMap(Map<String, dynamic> m) => Schedule(
        id: m['id'].toString(),
        teacherId: m['teacher_id'].toString(),
        subjectId: m['subject_id'].toString(),
        classroomId: m['classroom_id'].toString(),
        date: DateTime.parse(m['date']),
        notes: m['notes'],
      );
  Map<String, dynamic> toMap() => {
        'id': id,
        'teacher_id': teacherId,
        'subject_id': subjectId,
        'classroom_id': classroomId,
        'date': date.toIso8601String(),
        'notes': notes,
      };
}
