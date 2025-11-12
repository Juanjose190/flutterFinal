import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/teachers_cubit.dart';
import '../../../domain/entities/subject.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';

class TeachersListPage extends StatefulWidget {
  const TeachersListPage({super.key});
  @override
  State<TeachersListPage> createState() => _TeachersListPageState();
}

class _TeachersListPageState extends State<TeachersListPage> {
  late final TeachersCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = TeachersCubit()..load();
  }
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.teachers),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlobBackground(
        topLeftColor: const Color(0xFF3F51B5),
        bottomRightColor: const Color(0xFF0D47A1),
        child: Column(
          children: [
            const CurvedHeader(height: 150),
            Expanded(child: _buildTeachersList(context, t)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreate, child: const Icon(Icons.add)),
    );
  }

  Widget _buildTeachersList(BuildContext context, AppLocalizations t) {
    return BlocBuilder<TeachersCubit, TeachersState>(
      bloc: cubit,
      builder: (context, s) {
        if (s.loading) return const Center(child: CircularProgressIndicator());
        if (s.error != null && s.error!.isNotEmpty) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${s.error}', textAlign: TextAlign.center),
          ));
        }
        if (s.items.isEmpty) return Center(child: Text(t.noData));
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: s.items.length,
            itemBuilder: (_, i) {
              final item = s.items[i];
              final subjName = s.subjects.any((subj) => subj.id == (item.subjectId ?? ''))
                  ? s.subjects.firstWhere((subj) => subj.id == (item.subjectId ?? '')).name
                  : '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GlassContainer(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ]),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                        if (subjName.isNotEmpty)
                          Text('${t.subject}: $subjName', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEdit(item.id, item.name, item.subjectId)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => cubit.remove(item.id)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreate() {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? selectedSubjectId = cubit.state.subjects.isNotEmpty ? cubit.state.subjects.first.id : null;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.create),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSubjectId,
            items: cubit.state.subjects
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => selectedSubjectId = v,
            decoration: InputDecoration(labelText: t.subject),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              if (selectedSubjectId != null) {
                cubit.add(controller.text, subjectId: selectedSubjectId!);
              }
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _showEdit(String id, String name, String? subjectId) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: name);
    String? selectedSubjectId = subjectId ?? (cubit.state.subjects.isNotEmpty ? cubit.state.subjects.first.id : null);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.edit),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSubjectId,
            items: cubit.state.subjects
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => selectedSubjectId = v,
            decoration: InputDecoration(labelText: t.subject),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () { if (selectedSubjectId != null) { cubit.update(id, controller.text, subjectId: selectedSubjectId!); } Navigator.pop(context); }, child: Text(t.save)),
        ],
      ),
    );
  }
}
