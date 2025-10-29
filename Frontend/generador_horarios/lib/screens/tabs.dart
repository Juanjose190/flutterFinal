import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/materia.dart';
import '../models/profesor.dart';
import '../models/aula.dart';
import '../models/horario.dart';
import '../services/materia_service.dart';
import '../services/profesor_service.dart';
import '../services/aula_service.dart';
import '../services/horario_service.dart';
import 'materia_screen.dart';
import 'profesor_screen.dart';
import 'aula_screen.dart';
import 'horario_screen.dart';
import 'generar_horario_screen.dart';
import 'horario_detail_screen.dart';

// Tab de Materias
class MateriasTab extends StatefulWidget {
  const MateriasTab({super.key});

  @override
  State<MateriasTab> createState() => _MateriasTabState();
}

class _MateriasTabState extends State<MateriasTab> {
  final _materiaService = GetIt.instance<MateriaService>();
  List<Materia> _materias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  Future<void> _loadMaterias() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final materias = await _materiaService.getAllMaterias();
      setState(() {
        _materias = materias;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar materias: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materias.isEmpty
          ? const Center(child: Text('No hay materias registradas'))
          : ListView.builder(
              itemCount: _materias.length,
              itemBuilder: (context, index) {
                final materia = _materias[index];
                return ListTile(
                  title: Text(materia.nombre),
                  subtitle: Text('${materia.horasSemanales} horas semanales'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MateriaScreen(materia: materia),
                            ),
                          );
                          if (result == true) {
                            _loadMaterias();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Materia'),
                              content: Text(
                                '¿Está seguro de eliminar ${materia.nombre}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await _materiaService.deleteMateria(
                                        materia.id!,
                                      );
                                      _loadMaterias();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Ver detalles de la materia
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MateriaScreen()),
          );
          if (result == true) {
            _loadMaterias();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tab de Profesores
class ProfesoresTab extends StatefulWidget {
  const ProfesoresTab({super.key});

  @override
  State<ProfesoresTab> createState() => _ProfesoresTabState();
}

class _ProfesoresTabState extends State<ProfesoresTab> {
  final _profesorService = GetIt.instance<ProfesorService>();
  List<Profesor> _profesores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profesores = await _profesorService.getAllProfesores();
      setState(() {
        _profesores = profesores;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar profesores: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profesores.isEmpty
          ? const Center(child: Text('No hay profesores registrados'))
          : ListView.builder(
              itemCount: _profesores.length,
              itemBuilder: (context, index) {
                final profesor = _profesores[index];
                return ListTile(
                  title: Text('${profesor.nombre} ${profesor.apellido}'),
                  subtitle: Text(profesor.email ?? 'Sin email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfesorScreen(profesor: profesor),
                            ),
                          );
                          if (result == true) {
                            _loadProfesores();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Profesor'),
                              content: Text(
                                '¿Está seguro de eliminar a ${profesor.nombre} ${profesor.apellido}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await _profesorService.deleteProfesor(
                                        profesor.id!,
                                      );
                                      _loadProfesores();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfesorScreen()),
          );
          if (result == true) {
            _loadProfesores();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tab de Aulas
class AulasTab extends StatefulWidget {
  const AulasTab({super.key});

  @override
  State<AulasTab> createState() => _AulasTabState();
}

class _AulasTabState extends State<AulasTab> {
  final _aulaService = GetIt.instance<AulaService>();
  List<Aula> _aulas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAulas();
  }

  Future<void> _loadAulas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final aulas = await _aulaService.getAllAulas();
      setState(() {
        _aulas = aulas;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar aulas: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _aulas.isEmpty
          ? const Center(child: Text('No hay aulas registradas'))
          : ListView.builder(
              itemCount: _aulas.length,
              itemBuilder: (context, index) {
                final aula = _aulas[index];
                return ListTile(
                  title: Text(aula.nombre),
                  subtitle: Text('Capacidad: ${aula.capacidad} estudiantes'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AulaScreen(aula: aula),
                            ),
                          );
                          if (result == true) {
                            _loadAulas();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Aula'),
                              content: Text(
                                '¿Está seguro de eliminar ${aula.nombre}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await _aulaService.deleteAula(aula.id!);
                                      _loadAulas();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AulaScreen()),
          );
          if (result == true) {
            _loadAulas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tab de Horarios
class HorariosTab extends StatefulWidget {
  const HorariosTab({super.key});

  @override
  State<HorariosTab> createState() => _HorariosTabState();
}

class _HorariosTabState extends State<HorariosTab> {
  final _horarioService = GetIt.instance<HorarioService>();
  List<Horario> _horarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final horarios = await _horarioService.getAllHorarios();
      setState(() {
        _horarios = horarios;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horarios: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para generar horario con IA
  void _generarHorario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GenerarHorarioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
        actions: [
          IconButton(
            tooltip: 'Generar con IA',
            icon: const Icon(Icons.auto_awesome),
            onPressed: _generarHorario,
          ),
          IconButton(
            tooltip: 'Ver horarios generados',
            icon: const Icon(Icons.list),
            onPressed: () {
              _loadHorarios();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mostrando horarios existentes')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay horarios registrados'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generar Horario con IA'),
                    onPressed: _generarHorario,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _horarios.length,
              itemBuilder: (context, index) {
                final horario = _horarios[index];
                return ListTile(
                  title: Text(horario.nombre),
                  subtitle: Text(horario.descripcion ?? 'Sin descripción'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HorarioScreen(horario: horario),
                            ),
                          );
                          if (result == true) {
                            _loadHorarios();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Horario'),
                              content: Text(
                                '¿Está seguro de eliminar ${horario.nombre}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await _horarioService.deleteHorario(
                                        horario.id!,
                                      );
                                      _loadHorarios();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    // Abrir detalle del horario (obtendrá asignaciones del backend)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HorarioDetailScreen(
                          horario: horario,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'generateBtn',
            onPressed: _generarHorario,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addBtn',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HorarioScreen()),
              );
              if (result == true) {
                _loadHorarios();
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
