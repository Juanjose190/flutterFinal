import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/schedules_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/schedule.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';

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
                Row(children: [
                  Expanded(child: TextField(controller: _teacherCtrl, decoration: InputDecoration(labelText: t.teacher))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _subjectCtrl, decoration: InputDecoration(labelText: t.subject))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _classroomCtrl, decoration: InputDecoration(labelText: t.classroom))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                    setState(() { _date = picked; });
                  }, child: Text(t.date)),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () {
                    cubit.setFilters(teacherId: _teacherCtrl.text.isEmpty ? null : _teacherCtrl.text, subjectId: _subjectCtrl.text.isEmpty ? null : _subjectCtrl.text, classroomId: _classroomCtrl.text.isEmpty ? null : _classroomCtrl.text, date: _date);
                  }, child: Text(t.apply)),
                ])
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
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Teacher')),
                            DataColumn(label: Text('Subject')),
                            DataColumn(label: Text('Classroom')),
                            DataColumn(label: Text('Notes')),
                          ],
                          rows: s.items.map((item) {
                            final teacherName = s.teacherNames[item.teacherId] ?? item.teacherId;
                            final subjectName = s.subjectNames[item.subjectId] ?? item.subjectId;
                            final classroomName = s.classroomNames[item.classroomId] ?? item.classroomId;
                            return DataRow(
                              cells: [
                                DataCell(Text(_formatDate(item.date))),
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(item.date)}'),
            Text('Teacher: $teacherName'),
            Text('Subject: $subjectName'),
            Text('Classroom: $classroomName'),
            if ((item.notes ?? '').isNotEmpty) Text('Notes: ${item.notes}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
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
