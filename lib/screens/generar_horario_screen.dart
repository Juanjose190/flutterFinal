import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';

class GenerarHorarioScreen extends StatefulWidget {
  const GenerarHorarioScreen({super.key});

  @override
  State<GenerarHorarioScreen> createState() => _GenerarHorarioScreenState();
}

class _GenerarHorarioScreenState extends State<GenerarHorarioScreen> {
  final repo = DataRepository.instance;
  final Set<String> _docenteIds = {};
  final Set<String> _materiaIds = {};
  final Set<String> _aulaIds = {};

  bool _evitarConflictos = true;
  bool _respetarCapacidad = true;

  void _toggle(Set<String> set, String id) {
    set.contains(id) ? set.remove(id) : set.add(id);
    setState(() {});
  }

  Future<void> _generar() async {
    if (_docenteIds.isEmpty || _materiaIds.isEmpty || _aulaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona docentes, materias y aulas.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Generando horario...'),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop(); // cerrar loading

    final horario = await repo.createHorario(
      docenteIds: _docenteIds.toList(),
      materiaIds: _materiaIds.toList(),
      aulaIds: _aulaIds.toList(),
      status: HorarioStatus.borrador,
    );

    if (mounted) {
      context.push('/ver_horario', extra: horario.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar horario con IA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona docentes'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in repo.docentes)
                  FilterChip(
                    label: Text(d.nombre),
                    selected: _docenteIds.contains(d.id),
                    onSelected: (_) => _toggle(_docenteIds, d.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Selecciona materias'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in repo.materias)
                  FilterChip(
                    label: Text(m.nombre),
                    selected: _materiaIds.contains(m.id),
                    onSelected: (_) => _toggle(_materiaIds, m.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Selecciona aulas'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in repo.aulas)
                  FilterChip(
                    label: Text(a.nombre),
                    selected: _aulaIds.contains(a.id),
                    onSelected: (_) => _toggle(_aulaIds, a.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Restricciones adicionales'),
            SwitchListTile(
              value: _evitarConflictos,
              onChanged: (v) => setState(() => _evitarConflictos = v),
              title: const Text('Evitar conflictos de horario'),
            ),
            SwitchListTile(
              value: _respetarCapacidad,
              onChanged: (v) => setState(() => _respetarCapacidad = v),
              title: const Text('Respetar capacidad del aula'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generar,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generar horario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}