import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/teachers_cubit.dart';
import '../../../domain/entities/subject.dart';
import '../../widgets/blob_background.dart';
import '../../widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/teacher_availability_cubit.dart';
import '../../../core/time_utils.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/tz_init.dart';
import '../../../domain/entities/availability.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTeachersList(BuildContext context, AppLocalizations t) {
    return BlocBuilder<TeachersCubit, TeachersState>(
      bloc: cubit,
      builder: (context, s) {
        if (s.loading) return const Center(child: CircularProgressIndicator());
        if (s.error != null && s.error!.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${s.error}', textAlign: TextAlign.center),
            ),
          );
        }
        if (s.items.isEmpty) return Center(child: Text(t.noData));
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: s.items.length,
            itemBuilder: (_, i) {
              final item = s.items[i];
              final subjName =
                  s.subjects.any((subj) => subj.id == (item.subjectId ?? ''))
                  ? s.subjects
                        .firstWhere((subj) => subj.id == (item.subjectId ?? ''))
                        .name
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
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (subjName.isNotEmpty)
                              Text(
                                '${t.subject}: $subjName',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.schedule),
                        tooltip: t.edit,
                        onPressed: () => _showAvailability(item.id, item.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEdit(item.id, item.name, item.subjectId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cubit.remove(item.id),
                      ),
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
    String? selectedSubjectId = cubit.state.subjects.isNotEmpty
        ? cubit.state.subjects.first.id
        : null;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.create),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: t.name),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubjectId,
              items: cubit.state.subjects
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => selectedSubjectId = v,
              decoration: InputDecoration(labelText: t.subject),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
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
    String? selectedSubjectId =
        subjectId ??
        (cubit.state.subjects.isNotEmpty
            ? cubit.state.subjects.first.id
            : null);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.edit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: t.name),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubjectId,
              items: cubit.state.subjects
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => selectedSubjectId = v,
              decoration: InputDecoration(labelText: t.subject),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              if (selectedSubjectId != null) {
                cubit.update(
                  id,
                  controller.text,
                  subjectId: selectedSubjectId!,
                );
              }
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _showAvailability(String teacherId, String teacherName) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider(
          create: (_) => TeacherAvailabilityCubit(teacherId)..load(),
          child: _AvailabilityDialog(title: '${t.edit} - $teacherName'),
        );
      },
    );
  }
}

class _AvailabilityDialog extends StatefulWidget {
  final String title;
  const _AvailabilityDialog({required this.title});
  @override
  State<_AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<_AvailabilityDialog> {
  // Local UI state per day
  final Map<int, bool> _enabled = {for (var d = 0; d < 7; d++) d: false};
  final Map<int, TimeOfDay> _start = {
    for (var d = 0; d < 7; d++) d: const TimeOfDay(hour: 7, minute: 0),
  };
  final Map<int, TimeOfDay> _end = {
    for (var d = 0; d < 7; d++) d: const TimeOfDay(hour: 14, minute: 0),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final screenW = MediaQuery.of(context).size.width;
    final maxDialogW = screenW * 0.9; // keep dialog within viewport
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogW.clamp(280.0, 500.0)),
        child: BlocBuilder<TeacherAvailabilityCubit, TeacherAvailabilityState>(
          builder: (context, s) {
            if (s.loading)
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            if (s.error != null) return Text('Error: ${s.error}');
            // hydrate UI from existing periods
            for (final p in s.periods) {
              final localStart = TimezoneInit.toLocalFromUtc(p.startUtc);
              final localEnd = TimezoneInit.toLocalFromUtc(p.endUtc);
              _enabled[p.dayOfWeek] = true;
              _start[p.dayOfWeek] = TimeOfDay(
                hour: localStart.hour,
                minute: localStart.minute,
              );
              _end[p.dayOfWeek] = TimeOfDay(
                hour: localEnd.hour,
                minute: localEnd.minute,
              );
            }

            final dayNames = <int, String>{
              for (var d = 0; d < 7; d++)
                d: intl.DateFormat(
                  'EEE',
                  locale.toLanguageTag(),
                ).format(DateTime.utc(2024, 1, 1 + d)),
            };

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = true; // compact layout to avoid overflow
                Widget buildDayRow(int d) {
                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dayNames[d] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch(
                              value: _enabled[d]!,
                              onChanged: (v) => setState(() => _enabled[d] = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _timeButton(
                                context,
                                _start[d]!,
                                (tod) => setState(() => _start[d] = tod),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _timeButton(
                                context,
                                _end[d]!,
                                (tod) => setState(() => _end[d] = tod),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(child: Text(dayNames[d] ?? '')),
                        Switch(
                          value: _enabled[d]!,
                          onChanged: (v) => setState(() => _enabled[d] = v),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _timeButton(
                            context,
                            _start[d]!,
                            (tod) => setState(() => _start[d] = tod),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(' - '),
                        const SizedBox(width: 4),
                        Flexible(
                          child: _timeButton(
                            context,
                            _end[d]!,
                            (tod) => setState(() => _end[d] = tod),
                          ),
                        ),
                      ],
                    );
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var d = 0; d < 7; d++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: buildDayRow(d),
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Preview',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (var d = 0; d < 7; d++)
                            if (_enabled[d]!)
                              Chip(
                                label: Text(
                                  formatRangeLocalized(
                                    _anchorLocal(_start[d]!),
                                    _anchorLocal(_end[d]!),
                                    locale,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () async {
            final cubit = context.read<TeacherAvailabilityCubit>();
            final periods = <AvailabilityPeriod>[];
            // Allowed time window in minutes from midnight (inclusive)
            const minMinutes = 7 * 60; // 07:00
            const maxMinutes = 14 * 60; // 14:00
            int toMinutes(TimeOfDay tod) => tod.hour * 60 + tod.minute;
            for (var d = 0; d < 7; d++) {
              if (_enabled[d]!) {
                final startLocal = _anchorLocal(_start[d]!);
                final endLocal = _anchorLocal(_end[d]!);
                final startM = toMinutes(_start[d]!);
                final endM = toMinutes(_end[d]!);
                // Validate time range bounds
                if (startM < minMinutes ||
                    startM > maxMinutes ||
                    endM < minMinutes ||
                    endM > maxMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Time must be between 07:00 and 14:00.'),
                    ),
                  );
                  return;
                }
                if (!startLocal.isBefore(endLocal)) {
                  // Basic validation: start must be before end
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Start time must be before end time'),
                    ),
                  );
                  return;
                }
                final startUtc = TimezoneInit.toUtcFromLocal(startLocal);
                final endUtc = TimezoneInit.toUtcFromLocal(endLocal);
                periods.add(
                  AvailabilityPeriod(
                    id: '0',
                    teacherId: cubit.state.teacherId,
                    dayOfWeek: d,
                    startUtc: startUtc,
                    endUtc: endUtc,
                    tz: TimezoneInit.location?.name,
                  ),
                );
              }
            }
            await cubit.save(periods);
            if (mounted) Navigator.pop(context);
          },
          child: Text(t.save),
        ),
      ],
    );
  }

  Widget _timeButton(
    BuildContext context,
    TimeOfDay value,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) {
          // Enforce allowed window 07:00–14:00 inclusive
          int toMinutes(TimeOfDay tod) => tod.hour * 60 + tod.minute;
          final m = toMinutes(picked);
          if (m < 7 * 60 || m > 14 * 60) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a time between 07:00 and 14:00.'),
              ),
            );
            return; // reject out-of-range selection
          }
          onChanged(picked);
        }
      },
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 36),
      ),
      child: Text(value.format(context)),
    );
  }

  // Anchors the selected time to a stable date for display/serialization
  DateTime _anchorLocal(TimeOfDay tod) {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1, tod.hour, tod.minute);
  }
}
