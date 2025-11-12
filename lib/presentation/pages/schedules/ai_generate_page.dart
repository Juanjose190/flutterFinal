import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/ai_generate_cubit.dart';
import '../../bloc/teachers_cubit.dart';
import '../../bloc/subjects_cubit.dart';
import '../../bloc/classrooms_cubit.dart';
import '../../bloc/schedules_cubit.dart';
import '../../../domain/entities/schedule.dart';

class AIGeneratePage extends StatefulWidget {
  const AIGeneratePage({super.key});
  @override
  State<AIGeneratePage> createState() => _AIGeneratePageState();
}

class _AIGeneratePageState extends State<AIGeneratePage> {
  final aiCubit = AIGenerateCubit();
  final teachersCubit = TeachersCubit();
  final subjectsCubit = SubjectsCubit();
  final classroomsCubit = ClassroomsCubit();
  final schedulesCubit = SchedulesCubit();

  @override
  void initState() {
    super.initState();
    teachersCubit.load();
    subjectsCubit.load();
    classroomsCubit.load();
    schedulesCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.aiGenerateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.aiInstructions),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _generateFromSupabase,
                  child: Text(t.aiGenerate),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveAll,
                  child: const Text('Save All'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/schedules'),
                  child: const Text('Go to Schedules'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<AIGenerateCubit, AIGenerateState>(
                bloc: aiCubit,
                builder: (context, s) {
                  if (s.loading)
                    return const Center(child: CircularProgressIndicator());
                  if (s.error != null) return Center(child: Text(s.error!));
                  if (s.suggestions.isEmpty)
                    return Center(child: Text(t.noData));
                  final tmap = {
                    for (final t in teachersCubit.state.items) t.id: t.name,
                  };
                  final smap = {
                    for (final s0 in subjectsCubit.state.items) s0.id: s0.name,
                  };
                  final cmap = {
                    for (final c in classroomsCubit.state.items) c.id: c.name,
                  };
                  return ListView.builder(
                    itemCount: s.suggestions.length,
                    itemBuilder: (_, i) {
                      final item = s.suggestions[i];
                      final teacherName =
                          tmap[item.teacherId] ?? item.teacherId;
                      final subjectName =
                          smap[item.subjectId] ?? item.subjectId;
                      final classroomName =
                          cmap[item.classroomId] ?? item.classroomId;
                      return ListTile(
                        leading: const Icon(Icons.auto_awesome),
                        title: Text(_formatDate(item.date)),
                        subtitle: Text(
                          'T:$teacherName  S:$subjectName  C:$classroomName',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () => _save(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFromSupabase() async {
    await aiCubit.generateUsingSupabase();
  }

  Future<void> _save(Schedule s) async {
    // Reuse schedules cubit repository
    final repo = schedulesCubit.repo;
    if (!_ensureAuthReady()) return;
    try {
      final normalized = _normalizeToIds(s);
      await repo.create(normalized);
      await schedulesCubit.load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  Future<void> _saveAll() async {
    final repo = schedulesCubit.repo;
    final items = aiCubit.state.suggestions;
    if (!_ensureAuthReady()) return;
    int ok = 0;
    int fail = 0;
    for (final s in items) {
      try {
        final normalized = _normalizeToIds(s);
        await repo.create(normalized);
        ok++;
      } catch (_) {
        fail++;
      }
    }
    await schedulesCubit.load();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved $ok, failed $fail')));
    }
  }

  bool _ensureAuthReady() {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save schedules.')),
      );
      return false;
    }
    return true;
  }

  // Map any teacher/subject/classroom names to their IDs before saving
  Schedule _normalizeToIds(Schedule s) {
    String teacherId = s.teacherId;
    String subjectId = s.subjectId;
    String classroomId = s.classroomId;

    final teachers = teachersCubit.state.items;
    final subjects = subjectsCubit.state.items;
    final classrooms = classroomsCubit.state.items;

    // Resolve teacherId
    final teacherIdExists = teachers.any((t) => t.id == teacherId);
    if (!teacherIdExists) {
      for (final t in teachers) {
        if (t.name.toLowerCase() == teacherId.toLowerCase()) {
          teacherId = t.id;
          break;
        }
      }
    }

    // Resolve subjectId
    final subjectIdExists = subjects.any((x) => x.id == subjectId);
    if (!subjectIdExists) {
      for (final x in subjects) {
        if (x.name.toLowerCase() == subjectId.toLowerCase()) {
          subjectId = x.id;
          break;
        }
      }
    }

    // Resolve classroomId
    final classroomIdExists = classrooms.any((c) => c.id == classroomId);
    if (!classroomIdExists) {
      for (final c in classrooms) {
        if (c.name.toLowerCase() == classroomId.toLowerCase()) {
          classroomId = c.id;
          break;
        }
      }
    }

    return Schedule(
      id: s.id,
      teacherId: teacherId,
      subjectId: subjectId,
      classroomId: classroomId,
      date: s.date,
      notes: s.notes,
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final dayName = intl.DateFormat('EEEE').format(local);
    final datePart = intl.DateFormat('dd/MM/yyyy').format(local);
    final timePart = intl.DateFormat('HH:mm').format(local);
    return '$dayName - $datePart - $timePart';
  }
}
