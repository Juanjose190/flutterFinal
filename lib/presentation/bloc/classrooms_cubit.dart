import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_classroom_repository.dart';

class ClassroomsState extends Equatable {
  final List<Classroom> items;
  final bool loading;
  const ClassroomsState({this.items = const [], this.loading = false});
  ClassroomsState copyWith({List<Classroom>? items, bool? loading}) =>
      ClassroomsState(items: items ?? this.items, loading: loading ?? this.loading);
  @override
  List<Object> get props => [items, loading];
}

class ClassroomsCubit extends Cubit<ClassroomsState> {
  late final ClassroomRepository repo;
  ClassroomsCubit() : super(const ClassroomsState()) {
    final client = SupabaseService().client;
    repo = SupabaseClassroomRepository(client);
  }
  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final items = await repo.list();
      emit(ClassroomsState(items: items, loading: false));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
  Future<void> add(String name, {bool isSpecial = false}) async { await repo.create(name, isSpecial: isSpecial); await load(); }
  Future<void> update(String id, String name, {bool isSpecial = false}) async { await repo.update(id, name, isSpecial: isSpecial); await load(); }
  Future<void> remove(String id) async { await repo.delete(id); await load(); }
}
