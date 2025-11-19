import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class NamesCacheService {
  NamesCacheService(this.client);
  final SupabaseClient client;

  static const _ttl = Duration(minutes: 10);
  Map<String, String>? _teacherNames;
  Map<String, String>? _subjectNames;
  Map<String, String>? _classroomNames;
  DateTime? _teachersAt;
  DateTime? _subjectsAt;
  DateTime? _classroomsAt;

  bool _isFresh(DateTime? at) => at != null && DateTime.now().difference(at) < _ttl;

  Future<Map<String, String>> teacherNames() async {
    if (_teacherNames != null && _isFresh(_teachersAt)) return _teacherNames!;
    final res = await client.from('teachers').select('id,name');
    final names = {for (final m in (res as List)) m['id'].toString(): (m['name'] ?? '').toString()};
    _teacherNames = names;
    _teachersAt = DateTime.now();
    return names;
  }

  Future<Map<String, String>> subjectNames() async {
    if (_subjectNames != null && _isFresh(_subjectsAt)) return _subjectNames!;
    final res = await client.from('subjects').select('id,name');
    final names = {for (final m in (res as List)) m['id'].toString(): (m['name'] ?? '').toString()};
    _subjectNames = names;
    _subjectsAt = DateTime.now();
    return names;
  }

  Future<Map<String, String>> classroomNames() async {
    if (_classroomNames != null && _isFresh(_classroomsAt)) return _classroomNames!;
    final res = await client.from('classrooms').select('id,name');
    final names = {for (final m in (res as List)) m['id'].toString(): (m['name'] ?? '').toString()};
    _classroomNames = names;
    _classroomsAt = DateTime.now();
    return names;
  }
}

