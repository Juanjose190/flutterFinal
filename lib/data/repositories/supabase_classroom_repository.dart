import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';

class SupabaseClassroomRepository implements ClassroomRepository {
  final SupabaseClient client;
  SupabaseClassroomRepository(this.client);

  @override
  Future<Classroom> create(String name, {bool isSpecial = false}) async {
    final res = await client.from('classrooms').insert({'name': name, 'is_special': isSpecial}).select().single();
    return Classroom.fromMap(res);
  }

  @override
  Future<void> delete(String id) async {
    await client.from('classrooms').delete().eq('id', id);
  }

  @override
  Future<Classroom?> getById(String id) async {
    final res = await client
        .from('classrooms')
        .select('id,name,is_special')
        .eq('id', id)
        .maybeSingle();
    return res == null ? null : Classroom.fromMap(res);
  }

  @override
  Future<List<Classroom>> list() async {
    final res = await client
        .from('classrooms')
        .select('id,name,is_special')
        .order('name', ascending: true);
    return (res as List).map((e) => Classroom.fromMap(e)).toList();
  }

  @override
  Future<Classroom> update(String id, String name, {bool isSpecial = false}) async {
    final res = await client
        .from('classrooms')
        .update({'name': name, 'is_special': isSpecial}).eq('id', id).select().single();
    return Classroom.fromMap(res);
  }
}
