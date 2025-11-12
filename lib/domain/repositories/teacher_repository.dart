import '../../domain/entities/teacher.dart';

abstract class TeacherRepository {
  Future<List<Teacher>> list();
  Future<Teacher?> getById(String id);
  Future<Teacher> create(String name, {required String subjectId});
  Future<Teacher> update(String id, String name, {required String subjectId});
  Future<void> delete(String id);
}
