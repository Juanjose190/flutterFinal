import '../entities/availability.dart';

abstract class TeacherAvailabilityRepository {
  Future<List<AvailabilityPeriod>> listByTeacher(String teacherId);
  Future<void> upsertPeriods(String teacherId, List<AvailabilityPeriod> periods);
  Future<void> deletePeriod(String periodId);
}

