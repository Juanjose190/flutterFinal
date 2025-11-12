import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/availability.dart';
import '../../domain/repositories/teacher_availability_repository.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_teacher_availability_repository.dart';

class TeacherAvailabilityState extends Equatable {
  final String teacherId;
  final List<AvailabilityPeriod> periods;
  final bool loading;
  final String? error;
  const TeacherAvailabilityState({
    required this.teacherId,
    this.periods = const [],
    this.loading = false,
    this.error,
  });
  TeacherAvailabilityState copyWith({
    String? teacherId,
    List<AvailabilityPeriod>? periods,
    bool? loading,
    String? error,
  }) =>
      TeacherAvailabilityState(
        teacherId: teacherId ?? this.teacherId,
        periods: periods ?? this.periods,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [teacherId, periods, loading, error];
}

class TeacherAvailabilityCubit extends Cubit<TeacherAvailabilityState> {
  late final TeacherAvailabilityRepository repo;
  TeacherAvailabilityCubit(String teacherId)
      : super(TeacherAvailabilityState(teacherId: teacherId)) {
    repo = SupabaseTeacherAvailabilityRepository(SupabaseService());
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.listByTeacher(state.teacherId);
      emit(state.copyWith(periods: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> save(List<AvailabilityPeriod> periods) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.upsertPeriods(state.teacherId, periods);
      await load();
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> delete(String periodId) async {
    try {
      await repo.deletePeriod(periodId);
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

