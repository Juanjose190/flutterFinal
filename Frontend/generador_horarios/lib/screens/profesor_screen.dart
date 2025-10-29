import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/profesor.dart';
import '../models/materia.dart';
import '../services/profesor_service.dart';
import '../services/materia_service.dart';

class ProfesorScreen extends StatefulWidget {
  final Profesor? profesor;

  const ProfesorScreen({super.key, this.profesor});

  @override
  State<ProfesorScreen> createState() => _ProfesorScreenState();
}

class _ProfesorScreenState extends State<ProfesorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _horasDisponiblesController = TextEditingController();

  final ProfesorService _profesorService = GetIt.instance<ProfesorService>();
  final MateriaService _materiaService = GetIt.instance<MateriaService>();
  bool _isLoading = false;

  // Datos de relaciones
  List<Materia> _materias = [];
  final List<int> _selectedMateriaIds = [];
  final List<Map<String, String>> _disponibilidad = [];

  @override
  void initState() {
    super.initState();
    if (widget.profesor != null) {
      _nombreController.text = widget.profesor!.nombre;
      _apellidoController.text = widget.profesor!.apellido;
      _emailController.text = widget.profesor!.email ?? '';
      if (widget.profesor!.horasDisponibles != null) {
        _horasDisponiblesController.text =
            widget.profesor!.horasDisponibles.toString();
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _horasDisponiblesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _materias = await _materiaService.getAllMaterias();
      if (widget.profesor?.id != null) {
        final id = widget.profesor!.id!;
        try {
          final mids = await _profesorService.getMateriasByProfesor(id);
          _selectedMateriaIds
            ..clear()
            ..addAll(mids);
        } catch (_) {}
        try {
          final disp = await _profesorService.getDisponibilidadByProfesor(id);
          _disponibilidad
            ..clear()
            ..addAll(disp.map((e) => {
                  'dia': (e['dia'] ?? '').toString(),
                  'horaInicio': (e['horaInicio'] ?? '').toString(),
                  'horaFin': (e['horaFin'] ?? '').toString(),
                }));
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfesor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final profesor = Profesor(
          id: widget.profesor?.id,
          nombre: _nombreController.text,
          apellido: _apellidoController.text,
          email: _emailController.text,
          horasDisponibles: int.parse(_horasDisponiblesController.text),
        );

        if (widget.profesor == null) {
          await _profesorService.createProfesor(
            profesor,
            materiaIds: _selectedMateriaIds,
            disponibilidad: _disponibilidad,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profesor creado en Supabase'),
              ),
            );
          }
        } else {
          await _profesorService.updateProfesor(
            profesor,
            materiaIds: _selectedMateriaIds,
            disponibilidad: _disponibilidad,
          );
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.profesor == null ? 'Nuevo Profesor' : 'Editar Profesor',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un email';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _horasDisponiblesController,
                      decoration: const InputDecoration(
                        labelText: 'Horas Disponibles Semanales',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese las horas disponibles';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Materias
                    Text('Materias asignadas',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _materias.isEmpty
                        ? const Text('No hay materias disponibles')
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _materias.map((m) {
                              final selected =
                                  _selectedMateriaIds.contains(m.id);
                              return FilterChip(
                                label: Text(m.nombre),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    if (selected) {
                                      _selectedMateriaIds.remove(m.id);
                                    } else if (m.id != null) {
                                      _selectedMateriaIds.add(m.id!);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 16),
                    // Disponibilidad
                    Text('Disponibilidad horaria',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._disponibilidad.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: item['dia']?.isNotEmpty == true
                                          ? item['dia']
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Día',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        'Lunes',
                                        'Martes',
                                        'Miércoles',
                                        'Jueves',
                                        'Viernes',
                                        'Sábado',
                                      ]
                                          .map((d) => DropdownMenuItem(
                                                value: d,
                                                child: Text(d),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(() {
                                        _disponibilidad[index]['dia'] = v ?? '';
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item['horaInicio'] ?? '',
                                      decoration: const InputDecoration(
                                        labelText: 'Hora inicio (HH:mm)',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) =>
                                          _disponibilidad[index]['horaInicio'] =
                                              v,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item['horaFin'] ?? '',
                                      decoration: const InputDecoration(
                                        labelText: 'Hora fin (HH:mm)',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) =>
                                          _disponibilidad[index]['horaFin'] = v,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => setState(() {
                                      _disponibilidad.removeAt(index);
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar franja'),
                        onPressed: () {
                          setState(() {
                            _disponibilidad.add(
                              {'dia': '', 'horaInicio': '', 'horaFin': ''},
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProfesor,
                      child: Text(
                        widget.profesor == null
                            ? 'Crear Profesor'
                            : 'Actualizar Profesor',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
