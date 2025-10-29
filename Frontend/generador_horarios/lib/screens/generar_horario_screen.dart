import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/horario_service.dart';
import '../services/gemini_service.dart';
import '../services/materia_service.dart';
import '../services/profesor_service.dart';
import '../services/aula_service.dart';
import '../models/horario.dart';
import '../models/materia.dart';
import '../models/profesor.dart';
import '../models/aula.dart';

class GenerarHorarioScreen extends StatefulWidget {
  const GenerarHorarioScreen({super.key});

  @override
  State<GenerarHorarioScreen> createState() => _GenerarHorarioScreenState();
}

class _GenerarHorarioScreenState extends State<GenerarHorarioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos y selecciones
  bool _isLoadingData = true;
  List<Materia> _materias = const [];
  List<Profesor> _profesores = const [];
  List<Aula> _aulas = const [];
  final Set<int> _materiasSeleccionadas = <int>{};
  final Set<int> _profesoresSeleccionados = <int>{};
  final Set<int> _aulasSeleccionadas = <int>{};

  // Mapas para mostrar nombres en lugar de IDs
  final Map<int, String> _mapNombreMateria = {};
  final Map<int, String> _mapNombreProfesor = {};
  final Map<int, String> _mapNombreAula = {};

  final HorarioService _horarioService = GetIt.instance<HorarioService>();
  bool _isGenerating = false;
  Horario? _horarioGenerado;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoadingData = true);
    try {
      final materiaService = GetIt.instance<MateriaService>();
      final profesorService = GetIt.instance<ProfesorService>();
      final aulaService = GetIt.instance<AulaService>();

      final materias = await materiaService.getAllMaterias();
      final profesores = await profesorService.getAllProfesores();
      final aulas = await aulaService.getAllAulas();

      setState(() {
        _materias = materias.cast<Materia>();
        _profesores = profesores.cast<Profesor>();
        _aulas = aulas.cast<Aula>();
        // Construir mapas de nombres
        for (final m in _materias) {
          if (m.id != null) _mapNombreMateria[m.id!] = m.nombre;
        }
        for (final p in _profesores) {
          if (p.id != null) {
            _mapNombreProfesor[p.id!] = '${p.nombre} ${p.apellido}'.trim();
          }
        }
        for (final a in _aulas) {
          if (a.id != null) _mapNombreAula[a.id!] = a.nombre;
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos (backend): $e')),
      );
    }
  }

  Future<void> _generarHorario() async {
    if (_isLoadingData) return;
    if (_materiasSeleccionadas.isEmpty ||
        _profesoresSeleccionados.isEmpty ||
        _aulasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Seleccione al menos una materia, un profesor y un aula.'),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    // Filtrar las entidades seleccionadas
    final materiasSel = _materias
        .where((m) => m.id != null && _materiasSeleccionadas.contains(m.id!))
        .toList();
    final profesoresSel = _profesores
        .where((p) => p.id != null && _profesoresSeleccionados.contains(p.id!))
        .toList();
    final aulasSel = _aulas
        .where((a) => a.id != null && _aulasSeleccionadas.contains(a.id!))
        .toList();

    try {
      // Nombre y descripción generados automáticamente
      final nombreAuto = 'Horario IA';
      final descripcionAuto = 'Generado automáticamente con IA.';

      final geminiService = GetIt.instance<GeminiService>();
      final contexto = _buildContexto(
        materias: materiasSel,
        profesores: profesoresSel,
        aulas: aulasSel,
      );

      final horarioGenerado = await geminiService.generarHorarioDesdePrompt(
        nombre: nombreAuto,
        descripcion: descripcionAuto,
        contexto: contexto,
      );

      setState(() {
        _horarioGenerado = horarioGenerado;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Horario generado con éxito con IA (Gemini)!'),
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error IA (Gemini): $e')));
    }
  }

  String _buildContexto({
    required List<dynamic> materias,
    required List<dynamic> profesores,
    required List<dynamic> aulas,
  }) {
    final materiasStr = materias
        .map((m) {
          try {
            return 'Materia(id=${m.id}, nombre=${m.nombre}, horasSemanales=${m.horasSemanales}, requiereAulaEspecial=${m.requiereAulaEspecial}, tipo=${m.tipoAulaEspecial ?? 'N/A'})';
          } catch (_) {
            return m.toString();
          }
        })
        .join('; ');

    final profesoresStr = profesores
        .map((p) {
          try {
            final nombreCompleto = '${p.nombre} ${p.apellido}'.trim();
            return 'Profesor(id=${p.id}, nombre=$nombreCompleto, horasDisponibles=${p.horasDisponibles ?? 'N/A'})';
          } catch (_) {
            return p.toString();
          }
        })
        .join('; ');

    final aulasStr = aulas
        .map((a) {
          try {
            return 'Aula(id=${a.id}, nombre=${a.nombre}, capacidad=${a.capacidad}, esEspecial=${a.esEspecial}, tipo=${a.tipoAula ?? 'N/A'})';
          } catch (_) {
            return a.toString();
          }
        })
        .join('; ');

    return [
      'Materias: $materiasStr',
      'Profesores: $profesoresStr',
      'Aulas: $aulasStr',
      'Usa días Lunes a Viernes y franjas tipo HH:mm.',
    ].join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Horario con IA')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isGenerating
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generando horario con IA (Gemini)...'),
                    SizedBox(height: 8),
                    Text('Esto puede tomar unos momentos'),
                  ],
                ),
              )
            : _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : _horarioGenerado != null
            ? _buildHorarioGenerado()
            : _buildFormulario(),
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generar Horario Optimizado',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSelectorMaterias(),
          const SizedBox(height: 16),
          _buildSelectorProfesores(),
          const SizedBox(height: 16),
          _buildSelectorAulas(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generarHorario,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generar Horario con IA'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorMaterias() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Seleccionar Materias'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _materias.map((m) {
            final selected = m.id != null && _materiasSeleccionadas.contains(m.id!);
            return FilterChip(
              label: Text('${m.nombre} (id:${m.id})'),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (m.id == null) return;
                  if (val) {
                    _materiasSeleccionadas.add(m.id!);
                  } else {
                    _materiasSeleccionadas.remove(m.id!);
                  }
                });
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _materiasSeleccionadas
                  ..clear()
                  ..addAll(_materias.where((m) => m.id != null).map((m) => m.id!));
              }),
              child: const Text('Seleccionar todas'),
            ),
            TextButton(
              onPressed: () => setState(() => _materiasSeleccionadas.clear()),
              child: const Text('Limpiar selección'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectorProfesores() {
    return ExpansionTile(
      title: const Text('Seleccionar Profesores'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _profesores.map((p) {
            final selected = p.id != null && _profesoresSeleccionados.contains(p.id!);
            final nombreCompleto = '${p.nombre} ${p.apellido}'.trim();
            return FilterChip(
              label: Text('$nombreCompleto (id:${p.id})'),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (p.id == null) return;
                  if (val) {
                    _profesoresSeleccionados.add(p.id!);
                  } else {
                    _profesoresSeleccionados.remove(p.id!);
                  }
                });
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _profesoresSeleccionados
                  ..clear()
                  ..addAll(_profesores.where((p) => p.id != null).map((p) => p.id!));
              }),
              child: const Text('Seleccionar todos'),
            ),
            TextButton(
              onPressed: () => setState(() => _profesoresSeleccionados.clear()),
              child: const Text('Limpiar selección'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectorAulas() {
    return ExpansionTile(
      title: const Text('Seleccionar Aulas'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _aulas.map((a) {
            final selected = a.id != null && _aulasSeleccionadas.contains(a.id!);
            final etiqueta = a.capacidad != null
                ? '${a.nombre} (${a.capacidad}) id:${a.id}'
                : '${a.nombre} id:${a.id}';
            return FilterChip(
              label: Text(etiqueta),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (a.id == null) return;
                  if (val) {
                    _aulasSeleccionadas.add(a.id!);
                  } else {
                    _aulasSeleccionadas.remove(a.id!);
                  }
                });
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _aulasSeleccionadas
                  ..clear()
                  ..addAll(_aulas.where((a) => a.id != null).map((a) => a.id!));
              }),
              child: const Text('Seleccionar todas'),
            ),
            TextButton(
              onPressed: () => setState(() => _aulasSeleccionadas.clear()),
              child: const Text('Limpiar selección'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorarioGenerado() {
    final asignaciones = _horarioGenerado?.asignaciones ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _horarioGenerado!.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _horarioGenerado = null),
              child: const Text('Generar Otro'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _horarioGenerado!.descripcion ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Asignaciones:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: asignaciones.isEmpty
              ? const Center(child: Text('No hay asignaciones en este horario'))
              : ListView.builder(
                  itemCount: asignaciones.length,
                  itemBuilder: (context, index) {
                    final asignacion = asignaciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Materia: '
                              '${_mapNombreMateria[asignacion.materiaId] ?? 'ID ${asignacion.materiaId}'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                'Profesor: '
                                '${_mapNombreProfesor[asignacion.profesorId] ?? 'ID ${asignacion.profesorId}'}'),
                            Text(
                                'Aula: '
                                '${_mapNombreAula[asignacion.aulaId] ?? 'ID ${asignacion.aulaId}'}'),
                            Text('Día: ${asignacion.dia}'),
                            Text(
                              'Horario: ${asignacion.horaInicio} - ${asignacion.horaFin}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              // Persistir el horario generado antes de cerrar
              await _horarioService.createHorario(_horarioGenerado!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Horario guardado en Supabase'),
                  ),
                );
              }
              if (mounted) {
                Navigator.pop(context, true);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
              }
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Guardar Horario'),
        ),
      ],
    );
  }
}
