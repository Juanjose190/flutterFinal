import '../../domain/entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> list({String? teacherId, String? subjectId, String? classroomId, DateTime? date});
  Future<Schedule?> getById(String id);
  Future<Schedule> create(Schedule schedule);
  Future<Schedule> update(String id, Schedule schedule);
  Future<void> delete(String id);
}
