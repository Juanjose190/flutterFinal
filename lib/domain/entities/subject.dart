class Subject {
  final String id;
  final String name;
  final String? classroomId;
  const Subject({required this.id, required this.name, this.classroomId});
  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
        id: m['id'].toString(),
        name: m['name'] ?? '',
        classroomId: m['classroom_id'] == null ? null : m['classroom_id'].toString(),
      );
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'classroom_id': classroomId,
      };
}
