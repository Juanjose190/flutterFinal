import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class SupabaseScheduleRepository implements ScheduleRepository {
  final SupabaseClient client;
  SupabaseScheduleRepository(this.client);

  @override
  Future<Schedule> create(Schedule schedule) async {
    final payload = {
      'teacher_id': schedule.teacherId,
      'subject_id': schedule.subjectId,
      'classroom_id': schedule.classroomId,
      'date': schedule.date.toIso8601String(),
      'notes': schedule.notes,
    };
    final res = await client
        .from('schedules')
        .insert(payload)
        .select('id,teacher_id,subject_id,classroom_id,date,notes')
        .single();
    return Schedule.fromMap(res);
  }

  @override
  Future<void> delete(String id) async {
    await client.from('schedules').delete().eq('id', id);
  }

  @override
  Future<Schedule?> getById(String id) async {
    final res = await client
        .from('schedules')
        .select('id,teacher_id,subject_id,classroom_id,date,notes')
        .eq('id', id)
        .maybeSingle();
    return res == null ? null : Schedule.fromMap(res);
  }

  @override
  Future<List<Schedule>> list({
    String? teacherId,
    String? subjectId,
    String? classroomId,
    DateTime? date,
    int? limit,
    int? offset,
  }) async {
    dynamic query = client
        .from('schedules')
        .select('id,teacher_id,subject_id,classroom_id,date,notes');

    if (teacherId != null) {
      query = query.eq('teacher_id', teacherId);
    }
    if (subjectId != null) {
      query = query.eq('subject_id', subjectId);
    }
    if (classroomId != null) {
      query = query.eq('classroom_id', classroomId);
    }
    if (date != null) {
      query = query.eq('date', date.toIso8601String());
    }

    query = query.order('date', ascending: true);

    if (limit != null && offset != null) {
      query = query.range(offset, offset + limit - 1);
    }

    final res = await query;
    return (res as List).map((e) => Schedule.fromMap(e)).toList();
  }

  @override
  Future<Schedule> update(String id, Schedule schedule) async {
    final payload = {
      'teacher_id': schedule.teacherId,
      'subject_id': schedule.subjectId,
      'classroom_id': schedule.classroomId,
      'date': schedule.date.toIso8601String(),
      'notes': schedule.notes,
    };
    final res = await client
        .from('schedules')
        .update(payload)
        .eq('id', id)
        .select('id,teacher_id,subject_id,classroom_id,date,notes')
        .single();
    return Schedule.fromMap(res);
  }
}
