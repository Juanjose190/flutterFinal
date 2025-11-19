import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';

class SupabaseSubjectRepository implements SubjectRepository {
  final SupabaseClient client;
  SupabaseSubjectRepository(this.client);

  @override
  Future<Subject> create(String name, {String? classroomId}) async {
    final payload = {'name': name, if (classroomId != null) 'classroom_id': classroomId};
    final res = await client.from('subjects').insert(payload).select().single();
    return Subject.fromMap(res);
  }

  @override
  Future<void> delete(String id) async {
    await client.from('subjects').delete().eq('id', id);
  }

  @override
  Future<Subject?> getById(String id) async {
    final res = await client
        .from('subjects')
        .select('id,name,classroom_id')
        .eq('id', id)
        .maybeSingle();
    return res == null ? null : Subject.fromMap(res);
  }

  @override
  Future<List<Subject>> list() async {
    final res = await client
        .from('subjects')
        .select('id,name,classroom_id')
        .order('name', ascending: true);
    return (res as List).map((e) => Subject.fromMap(e)).toList();
  }

  @override
  Future<Subject> update(String id, String name, {String? classroomId}) async {
    final payload = {'name': name, 'classroom_id': classroomId};
    final res = await client.from('subjects').update(payload).eq('id', id).select().single();
    return Subject.fromMap(res);
  }
}
