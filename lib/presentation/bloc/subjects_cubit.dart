import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/classroom.dart';
import '../../domain/repositories/subject_repository.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_subject_repository.dart';
import '../../data/repositories/supabase_classroom_repository.dart';

class SubjectsState extends Equatable {
  final List<Subject> items;
  final bool loading;
  final List<Classroom> classrooms; // for selection and name mapping
  const SubjectsState({this.items = const [], this.loading = false, this.classrooms = const []});
  SubjectsState copyWith({List<Subject>? items, bool? loading, List<Classroom>? classrooms}) =>
      SubjectsState(items: items ?? this.items, loading: loading ?? this.loading, classrooms: classrooms ?? this.classrooms);
  @override
  List<Object> get props => [items, loading, classrooms];
}

class SubjectsCubit extends Cubit<SubjectsState> {
  late final SubjectRepository repo;
  SubjectsCubit() : super(const SubjectsState()) {
    final client = SupabaseService().client;
    repo = SupabaseSubjectRepository(client);
  }
  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final items = await repo.list();
      final client = SupabaseService().client;
      final classrooms = await SupabaseClassroomRepository(client).list();
      emit(SubjectsState(items: items, loading: false, classrooms: classrooms));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
  Future<void> add(String name, {String? classroomId}) async { await repo.create(name, classroomId: classroomId); await load(); }
  Future<void> update(String id, String name, {String? classroomId}) async { await repo.update(id, name, classroomId: classroomId); await load(); }
  Future<void> remove(String id) async { await repo.delete(id); await load(); }
}
