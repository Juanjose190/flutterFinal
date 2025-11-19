import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/teacher_repository.dart';

class SupabaseTeacherRepository implements TeacherRepository {
  final SupabaseClient client;
  SupabaseTeacherRepository(this.client);

  @override
  Future<Teacher> create(String name, {required String subjectId}) async {
    final res = await client.from('teachers').insert({'name': name, 'subject_id': subjectId}).select().single();
    return Teacher.fromMap(res);
  }

  @override
  Future<void> delete(String id) async {
    await client.from('teachers').delete().eq('id', id);
  }

  @override
  Future<Teacher?> getById(String id) async {
    final res = await client
        .from('teachers')
        .select('id,name,subject_id')
        .eq('id', id)
        .maybeSingle();
    return res == null ? null : Teacher.fromMap(res);
  }

  @override
  Future<List<Teacher>> list() async {
    final res = await client
        .from('teachers')
        .select('id,name,subject_id')
        .order('name', ascending: true);
    return (res as List).map((e) => Teacher.fromMap(e)).toList();
  }

  @override
  Future<Teacher> update(String id, String name, {required String subjectId}) async {
    final res = await client.from('teachers').update({'name': name, 'subject_id': subjectId}).eq('id', id).select().single();
    return Teacher.fromMap(res);
  }
}
