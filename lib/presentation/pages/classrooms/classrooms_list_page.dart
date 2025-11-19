import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/classrooms_cubit.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../core/name_localizer.dart';

class ClassroomsListPage extends StatefulWidget {
  const ClassroomsListPage({super.key});
  @override
  State<ClassroomsListPage> createState() => _ClassroomsListPageState();
}

class _ClassroomsListPageState extends State<ClassroomsListPage> {
  late final ClassroomsCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = ClassroomsCubit()..load();
  }
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.classrooms),
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
            Expanded(child: _buildClassroomsList(context, t)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreate, child: const Icon(Icons.add)),
    );
  }

  Widget _buildClassroomsList(BuildContext context, AppLocalizations t) {
    return BlocBuilder<ClassroomsCubit, ClassroomsState>(
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
                            Theme.of(context).colorScheme.tertiary,
                            Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                          ]),
                        ),
                        child: const Icon(Icons.meeting_room, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(localizeEntityName(context, item.name, EntityKind.classroom), style: Theme.of(context).textTheme.titleMedium),
                        if (item.isSpecial) Text(t.specialClassroom, style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEdit(item.id, item.name, item.isSpecial)),
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
    bool isSpecial = false;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(t.create), content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          Row(children: [Checkbox(value: isSpecial, onChanged: (v) { setState(() { isSpecial = v ?? false; }); }), Text(t.specialClassroom)])
        ]), actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () { cubit.add(controller.text, isSpecial: isSpecial); Navigator.pop(context); }, child: Text(t.save)),
        ]));
  }

  void _showEdit(String id, String name, bool special) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: name);
    bool isSpecial = special;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(t.edit), content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(labelText: t.name)),
          Row(children: [Checkbox(value: isSpecial, onChanged: (v) { setState(() { isSpecial = v ?? false; }); }), Text(t.specialClassroom)])
        ]), actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () { cubit.update(id, controller.text, isSpecial: isSpecial); Navigator.pop(context); }, child: Text(t.save)),
        ]));
  }
}
