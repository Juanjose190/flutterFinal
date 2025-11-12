import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';
import '../../data/supabase/supabase_service.dart';
import '../../data/repositories/supabase_teacher_repository.dart';
import '../../data/repositories/supabase_subject_repository.dart';
import '../../data/repositories/supabase_classroom_repository.dart';
import '../../data/services/gemini_service.dart';

class AIGenerateState extends Equatable {
  final bool loading;
  final List<Schedule> suggestions;
  final String? error;
  const AIGenerateState({
    this.loading = false,
    this.suggestions = const [],
    this.error,
  });
  AIGenerateState copyWith({
    bool? loading,
    List<Schedule>? suggestions,
    String? error,
  }) => AIGenerateState(
    loading: loading ?? this.loading,
    suggestions: suggestions ?? this.suggestions,
    error: error,
  );
  @override
  List<Object?> get props => [loading, suggestions, error];
}

class AIGenerateCubit extends Cubit<AIGenerateState> {
  AIGenerateCubit() : super(const AIGenerateState());

  /// Fetches teachers, subjects, and classrooms from Supabase,
  /// then calls `generate(...)` to request suggestions from Gemini.
  Future<void> generateUsingSupabase() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final supa = SupabaseService();
      final envErr = supa.validationError;
      if (envErr != null) {
        emit(state.copyWith(loading: false, error: envErr));
        return;
      }

      final client = supa.client;
      final teachers = await SupabaseTeacherRepository(client).list();
      final subjects = await SupabaseSubjectRepository(client).list();
      final classrooms = await SupabaseClassroomRepository(client).list();

      await generate(
        teachers: teachers.map((e) => e.toMap()).toList(),
        subjects: subjects.map((e) => e.toMap()).toList(),
        classrooms: classrooms.map((e) => e.toMap()).toList(),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> generate({
    required List<Map<String, dynamic>> teachers,
    required List<Map<String, dynamic>> subjects,
    required List<Map<String, dynamic>> classrooms,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      if ((teachers.isEmpty || subjects.isEmpty || classrooms.isEmpty)) {
        // Proceed but warn: Gemini will have limited context
        final missing = [
          if (teachers.isEmpty) 'teachers',
          if (subjects.isEmpty) 'subjects',
          if (classrooms.isEmpty) 'classrooms',
        ].join(', ');
        emit(
          state.copyWith(error: 'Warning: missing $missing data from Supabase'),
        );
      }

      final gemini = GeminiService();
      final parsed = await gemini.generateSchedulesFromContext(
        teachers: teachers,
        subjects: subjects,
        classrooms: classrooms,
      );
      emit(state.copyWith(loading: false, suggestions: parsed));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
