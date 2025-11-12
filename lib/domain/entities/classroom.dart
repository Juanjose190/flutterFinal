class Classroom {
  final String id;
  final String name;
  final bool isSpecial;
  const Classroom({required this.id, required this.name, this.isSpecial = false});
  factory Classroom.fromMap(Map<String, dynamic> m) => Classroom(
        id: m['id'].toString(),
        name: m['name'] ?? '',
        isSpecial: (m['is_special'] ?? false) == true,
      );
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'is_special': isSpecial};
}
