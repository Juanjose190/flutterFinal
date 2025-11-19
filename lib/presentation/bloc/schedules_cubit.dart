import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_schedule_repository.dart';
import '../../core/perf_monitor.dart';
import '../../core/names_cache.dart';

class SchedulesState extends Equatable {
  final List<Schedule> items;
  final bool loading;
  final String? teacherId;
  final String? subjectId;
  final String? classroomId;
  final DateTime? date;
  final Map<String, String> teacherNames;
  final Map<String, String> subjectNames;
  final Map<String, String> classroomNames;
  const SchedulesState({
    this.items = const [],
    this.loading = false,
    this.teacherId,
    this.subjectId,
    this.classroomId,
    this.date,
    this.teacherNames = const {},
    this.subjectNames = const {},
    this.classroomNames = const {},
  });
  SchedulesState copyWith({
    List<Schedule>? items,
    bool? loading,
    String? teacherId,
    String? subjectId,
    String? classroomId,
    DateTime? date,
    Map<String, String>? teacherNames,
    Map<String, String>? subjectNames,
    Map<String, String>? classroomNames,
  }) => SchedulesState(
    items: items ?? this.items,
    loading: loading ?? this.loading,
    teacherId: teacherId ?? this.teacherId,
    subjectId: subjectId ?? this.subjectId,
    classroomId: classroomId ?? this.classroomId,
    date: date ?? this.date,
    teacherNames: teacherNames ?? this.teacherNames,
    subjectNames: subjectNames ?? this.subjectNames,
    classroomNames: classroomNames ?? this.classroomNames,
  );
  @override
  List<Object?> get props => [
    items,
    loading,
    teacherId,
    subjectId,
    classroomId,
    date,
    teacherNames,
    subjectNames,
    classroomNames,
  ];
}

class SchedulesCubit extends Cubit<SchedulesState> {
  late final ScheduleRepository repo;
  SchedulesCubit() : super(const SchedulesState()) {
    final client = SupabaseService().client;
    repo = SupabaseScheduleRepository(client);
  }
  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final client = SupabaseService().client;
      final cache = NamesCacheService(client);
      final items = await PerformanceMonitor.time(
        'schedules.list',
        repo
            .list(
              teacherId: state.teacherId,
              subjectId: state.subjectId,
              classroomId: state.classroomId,
              date: state.date,
            )
            .timeout(const Duration(seconds: 8)),
      );
      // Fetch names in parallel with cache
      final results = await PerformanceMonitor.time(
        'names.batch',
        Future.wait([
          cache.teacherNames(),
          cache.subjectNames(),
          cache.classroomNames(),
        ]).timeout(const Duration(seconds: 8)),
      );
      final teacherNames = results[0];
      final subjectNames = results[1];
      final classroomNames = results[2];
      emit(
        state.copyWith(
          items: items,
          teacherNames: teacherNames,
          subjectNames: subjectNames,
          classroomNames: classroomNames,
          loading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  void setFilters({
    String? teacherId,
    String? subjectId,
    String? classroomId,
    DateTime? date,
  }) {
    emit(
      state.copyWith(
        teacherId: teacherId,
        subjectId: subjectId,
        classroomId: classroomId,
        date: date,
      ),
    );
    load();
  }
}
