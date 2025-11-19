import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/schedules_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/schedule.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';
import '../../../core/name_localizer.dart';
import '../../../core/fullscreen.dart';

class SchedulesViewPage extends StatefulWidget {
  const SchedulesViewPage({super.key});
  @override
  State<SchedulesViewPage> createState() => _SchedulesViewPageState();
}

class _SchedulesViewPageState extends State<SchedulesViewPage> {
  late final SchedulesCubit cubit;
  final _teacherCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _classroomCtrl = TextEditingController();
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    cubit = SchedulesCubit()..load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.schedules),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: t.fullscreen,
            onPressed: () async {
              await enterFullscreen();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.fullscreenEnabled)));
              }
            },
            icon: const Icon(Icons.fullscreen),
          ),
          IconButton(onPressed: () => context.push('/schedules/ai'), icon: const Icon(Icons.auto_awesome))
        ],
      ),
      body: BlobBackground(
        topLeftColor: const Color(0xFF3F51B5),
        bottomRightColor: const Color(0xFF0D47A1),
        child: Column(children: [
          CurvedHeader(height: 150),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassContainer(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.filters, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  final itemWidth = isWide ? (constraints.maxWidth - 36) / 4 : constraints.maxWidth - 24;
                  final localeTag = Localizations.localeOf(context).toLanguageTag();
                  return Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        controller: _teacherCtrl,
                        decoration: InputDecoration(labelText: t.teacher, hintText: t.id, prefixIcon: const Icon(Icons.person_outline)),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        controller: _subjectCtrl,
                        decoration: InputDecoration(labelText: t.subject, hintText: t.id, prefixIcon: const Icon(Icons.menu_book_outlined)),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        controller: _classroomCtrl,
                        decoration: InputDecoration(labelText: t.classroom, hintText: t.id, prefixIcon: const Icon(Icons.meeting_room_outlined)),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: t.date,
                          hintText: _date == null ? intl.DateFormat('dd/MM/yyyy', localeTag).format(DateTime.now()) : intl.DateFormat('dd/MM/yyyy', localeTag).format(_date!),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: _date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                          setState(() { _date = picked; });
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWide ? itemWidth : double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          cubit.setFilters(
                            teacherId: _teacherCtrl.text.isEmpty ? null : _teacherCtrl.text,
                            subjectId: _subjectCtrl.text.isEmpty ? null : _subjectCtrl.text,
                            classroomId: _classroomCtrl.text.isEmpty ? null : _classroomCtrl.text,
                            date: _date,
                          );
                        },
                        child: Text(t.apply),
                      ),
                    ),
                  ]);
                })
              ]),
            ),
          ),
          Expanded(
            child: BlocBuilder<SchedulesCubit, SchedulesState>(
              bloc: cubit,
              builder: (context, s) {
                if (s.loading) return const Center(child: CircularProgressIndicator());
                if (s.items.isEmpty) return Center(child: Text(t.noData));
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(t.date)),
                            DataColumn(label: Text(t.teacher)),
                            DataColumn(label: Text(t.subject)),
                            DataColumn(label: Text(t.classroom)),
                            DataColumn(label: Text(t.notes)),
                          ],
                          rows: s.items.map((item) {
                            final teacherName = s.teacherNames[item.teacherId] ?? item.teacherId;
                            final subjectRaw = s.subjectNames[item.subjectId] ?? item.subjectId;
                            final classroomRaw = s.classroomNames[item.classroomId] ?? item.classroomId;
                            final subjectName = localizeEntityName(context, subjectRaw, EntityKind.subject);
                            final classroomName = localizeEntityName(context, classroomRaw, EntityKind.classroom);
                            return DataRow(
                              cells: [
                                DataCell(Text(_formatDate(context, item.date))),
                                DataCell(Text(teacherName)),
                                DataCell(Text(subjectName)),
                                DataCell(Text(classroomName)),
                                DataCell(Text(item.notes ?? '')),
                              ],
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  _showDetailsDialog(context, item, teacherName, subjectName, classroomName);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Schedule item, String teacherName, String subjectName, String classroomName) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.scheduleDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.date}: ${_formatDate(context, item.date)}'),
            Text('${t.teacher}: $teacherName'),
            Text('${t.subject}: $subjectName'),
            Text('${t.classroom}: $classroomName'),
            if ((item.notes ?? '').isNotEmpty) Text('${t.notes}: ${item.notes}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.close)),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context);
    final local = dt.toLocal();
    final dayName = intl.DateFormat('EEEE', locale.toLanguageTag()).format(local);
    final datePart = intl.DateFormat('dd/MM/yyyy', locale.toLanguageTag()).format(local);
    final timePart = intl.DateFormat('HH:mm', locale.toLanguageTag()).format(local);
    return '$dayName - $datePart - $timePart';
  }
}
