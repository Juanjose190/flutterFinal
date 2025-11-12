class Teacher {
  final String id;
  final String name;
  final String? subjectId;
  const Teacher({required this.id, required this.name, this.subjectId});
  factory Teacher.fromMap(Map<String, dynamic> m) => Teacher(
        id: m['id'].toString(),
        name: m['name'] ?? '',
        subjectId: m['subject_id'] == null ? null : m['subject_id'].toString(),
      );
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subject_id': subjectId,
      };
}
