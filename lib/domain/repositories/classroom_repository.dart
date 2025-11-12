import '../../domain/entities/classroom.dart';

abstract class ClassroomRepository {
  Future<List<Classroom>> list();
  Future<Classroom?> getById(String id);
  Future<Classroom> create(String name, {bool isSpecial});
  Future<Classroom> update(String id, String name, {bool isSpecial});
  Future<void> delete(String id);
}
