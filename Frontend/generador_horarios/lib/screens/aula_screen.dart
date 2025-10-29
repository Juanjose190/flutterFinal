import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/aula.dart';
import '../services/aula_service.dart';

class AulaScreen extends StatefulWidget {
  final Aula? aula;

  const AulaScreen({super.key, this.aula});

  @override
  State<AulaScreen> createState() => _AulaScreenState();
}

class _AulaScreenState extends State<AulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _capacidadController = TextEditingController();
  bool _esEspecial = false;
  String _tipoAula = '';

  final AulaService _aulaService = GetIt.instance<AulaService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.aula != null) {
      _nombreController.text = widget.aula!.nombre;
      _capacidadController.text = widget.aula!.capacidad.toString();
      _esEspecial = widget.aula!.esEspecial;
      _tipoAula = widget.aula!.tipoAula ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _saveAula() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final aula = Aula(
          id: widget.aula?.id ?? 0,
          nombre: _nombreController.text,
          capacidad: int.parse(_capacidadController.text),
          esEspecial: _esEspecial,
          tipoAula: _tipoAula,
        );

        if (widget.aula == null) {
          await _aulaService.createAula(aula);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aula creada en Supabase'),
              ),
            );
          }
        } else {
          await _aulaService.updateAula(aula);
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
        title: Text(widget.aula == null ? 'Nueva Aula' : 'Editar Aula'),
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
                      controller: _capacidadController,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la capacidad';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Es Aula Especial'),
                      value: _esEspecial,
                      onChanged: (bool value) {
                        setState(() {
                          _esEspecial = value;
                          if (!value) {
                            _tipoAula = '';
                          }
                        });
                      },
                    ),
                    if (_esEspecial) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Aula',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _tipoAula.isNotEmpty ? _tipoAula : null,
                        items: const [
                          DropdownMenuItem(
                            value: 'Laboratorio',
                            child: Text('Laboratorio'),
                          ),
                          DropdownMenuItem(
                            value: 'Taller',
                            child: Text('Taller'),
                          ),
                          DropdownMenuItem(
                            value: 'Auditorio',
                            child: Text('Auditorio'),
                          ),
                          DropdownMenuItem(
                            value: 'Sala de Computación',
                            child: Text('Sala de Computación'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _tipoAula = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (_esEspecial && (value == null || value.isEmpty)) {
                            return 'Por favor seleccione un tipo de aula';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAula,
                      child: Text(
                        widget.aula == null ? 'Crear Aula' : 'Actualizar Aula',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
