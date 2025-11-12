import '../../domain/entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> list();
  Future<Subject?> getById(String id);
  Future<Subject> create(String name, {String? classroomId});
  Future<Subject> update(String id, String name, {String? classroomId});
  Future<void> delete(String id);
}
