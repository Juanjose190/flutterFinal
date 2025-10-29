import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/horario.dart';
import '../services/horario_service.dart';
import '../services/materia_service.dart';
import '../services/profesor_service.dart';
import '../services/aula_service.dart';

class HorarioDetailScreen extends StatefulWidget {
  final Horario horario;

  const HorarioDetailScreen({super.key, required this.horario});

  @override
  State<HorarioDetailScreen> createState() => _HorarioDetailScreenState();
}

class _HorarioDetailScreenState extends State<HorarioDetailScreen> {
  final _materiaService = GetIt.instance<MateriaService>();
  final _profesorService = GetIt.instance<ProfesorService>();
  final _aulaService = GetIt.instance<AulaService>();
  final _horarioService = GetIt.instance<HorarioService>();

  Map<int, String> _materiasMap = {};
  Map<int, String> _profesoresMap = {};
  Map<int, String> _aulasMap = {};
  bool _isLoading = true;
  Horario? _horarioCompleto;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Obtener el horario actualizado con asignaciones desde el backend
      final horario = await _horarioService.getHorarioById(widget.horario.id!);
      final materias = await _materiaService.getAllMaterias();
      final profesores = await _profesorService.getAllProfesores();
      final aulas = await _aulaService.getAllAulas();

      setState(() {
        _horarioCompleto = horario;
        _materiasMap = {for (var m in materias) m.id!: m.nombre};
        _profesoresMap = {
          for (var p in profesores) p.id!: '${p.nombre} ${p.apellido}',
        };
        _aulasMap = {for (var a in aulas) a.id!: a.nombre};
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.horario.nombre)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_horarioCompleto?.asignaciones ?? []).isEmpty
          ? const Center(child: Text('No hay asignaciones para este horario.'))
          : ListView.builder(
              itemCount: (_horarioCompleto?.asignaciones ?? []).length,
              itemBuilder: (context, index) {
                final asignaciones = _horarioCompleto?.asignaciones ?? [];
                final asignacion = asignaciones[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _materiasMap[asignacion.materiaId] ??
                              'Materia desconocida',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Profesor: ${_profesoresMap[asignacion.profesorId] ?? 'Profesor desconocido'}',
                        ),
                        Text(
                          'Aula: ${_aulasMap[asignacion.aulaId] ?? 'Aula desconocida'}',
                        ),
                        Text('Día: ${asignacion.dia}'),
                        Text(
                          'Hora: ${asignacion.horaInicio} - ${asignacion.horaFin}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
