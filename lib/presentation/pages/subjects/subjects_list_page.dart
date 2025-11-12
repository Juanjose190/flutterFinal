import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/subjects_cubit.dart';
import '../../bloc/classrooms_cubit.dart';
import '../../../domain/entities/classroom.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';

class SubjectsListPage extends StatefulWidget {
  const SubjectsListPage({super.key});
  @override
  State<SubjectsListPage> createState() => _SubjectsListPageState();
}

class _SubjectsListPageState extends State<SubjectsListPage> {
  late final SubjectsCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = SubjectsCubit()..load();
  }
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.subjects),
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
            Expanded(child: _buildSubjectsList(context, t)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreate, child: const Icon(Icons.add)),
    );
  }

  Widget _buildSubjectsList(BuildContext context, AppLocalizations t) {
    return BlocBuilder<SubjectsCubit, SubjectsState>(
      bloc: cubit,
      builder: (context, s) {
        if (s.loading) return const Center(child: CircularProgressIndicator());
        if (s.items.isEmpty) return Center(child: Text(t.noData));
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: s.items.length,
            itemBuilder: (_, i) {
              final item = s.items[i];
              final classroomName = s.classrooms.any((c) => c.id == (item.classroomId ?? ''))
                  ? s.classrooms.firstWhere((c) => c.id == (item.classroomId ?? '')).name
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
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                          ]),
                        ),
                        child: const Icon(Icons.menu_book, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                        if (classroomName.isNotEmpty)
                          Text('${t.classroom}: $classroomName', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEdit(item.id, item.name, item.classroomId)),
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
    String? selectedClassroomId = cubit.state.classrooms.isNotEmpty ? cubit.state.classrooms.first.id : null;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.create),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedClassroomId,
            items: [
              DropdownMenuItem(value: null, child: Text('None')),
              ...cubit.state.classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            ],
            onChanged: (v) => selectedClassroomId = v,
            decoration: InputDecoration(labelText: t.classroom),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () { cubit.add(controller.text, classroomId: selectedClassroomId); Navigator.pop(context); }, child: Text(t.save)),
        ],
      ),
    );
  }

  void _showEdit(String id, String name, String? classroomId) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: name);
    String? selectedClassroomId = classroomId;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.edit),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedClassroomId,
            items: [
              DropdownMenuItem(value: null, child: Text('None')),
              ...cubit.state.classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            ],
            onChanged: (v) => selectedClassroomId = v,
            decoration: InputDecoration(labelText: t.classroom),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () { cubit.update(id, controller.text, classroomId: selectedClassroomId); Navigator.pop(context); }, child: Text(t.save)),
        ],
      ),
    );
  }
}
