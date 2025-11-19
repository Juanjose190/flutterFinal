import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_teacher_repository.dart';
import '../../data/repositories/supabase_subject_repository.dart';
import '../../core/perf_monitor.dart';

class TeachersState extends Equatable {
  final List<Teacher> items;
  final bool loading;
  final String? error;
  final List<Subject> subjects; // for selection and name mapping
  const TeachersState({this.items = const [], this.loading = false, this.error, this.subjects = const []});
  TeachersState copyWith({List<Teacher>? items, bool? loading, String? error, List<Subject>? subjects}) =>
      TeachersState(items: items ?? this.items, loading: loading ?? this.loading, error: error, subjects: subjects ?? this.subjects);
  @override
  List<Object?> get props => [items, loading, error, subjects];
}

class TeachersCubit extends Cubit<TeachersState> {
  late final TeacherRepository repo;
  TeachersCubit() : super(const TeachersState()) {
    final client = SupabaseService().client;
    repo = SupabaseTeacherRepository(client);
  }
  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final client = SupabaseService().client;
      final results = await PerformanceMonitor.time('teachers+subjects.load', Future.wait([
        repo.list(),
        SupabaseSubjectRepository(client).list(),
      ]));
      final items = results[0] as List<Teacher>;
      final subjects = results[1] as List<Subject>;
      emit(TeachersState(items: items, loading: false, subjects: subjects));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
  Future<void> add(String name, {required String subjectId}) async { await repo.create(name, subjectId: subjectId); await load(); }
  Future<void> update(String id, String name, {required String subjectId}) async { await repo.update(id, name, subjectId: subjectId); await load(); }
  Future<void> remove(String id) async { await repo.delete(id); await load(); }
}
