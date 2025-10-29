import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/materia.dart';
import '../services/materia_service.dart';

class MateriaScreen extends StatefulWidget {
  final Materia? materia;

  const MateriaScreen({super.key, this.materia});

  @override
  State<MateriaScreen> createState() => _MateriaScreenState();
}

class _MateriaScreenState extends State<MateriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _horasSemanalesController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _requiereAulaEspecial = false;
  String _tipoAulaEspecial = '';

  final MateriaService _materiaService = GetIt.instance<MateriaService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.materia != null) {
      _nombreController.text = widget.materia!.nombre;
      _horasSemanalesController.text = widget.materia!.horasSemanales
          .toString();
      _descripcionController.text = widget.materia!.descripcion ?? '';
      _requiereAulaEspecial = widget.materia!.requiereAulaEspecial;
      _tipoAulaEspecial = widget.materia!.tipoAulaEspecial ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _horasSemanalesController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveMateria() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final materia = Materia(
          id: widget.materia?.id ?? 0,
          nombre: _nombreController.text,
          horasSemanales: int.parse(_horasSemanalesController.text),
          descripcion: _descripcionController.text,
          requiereAulaEspecial: _requiereAulaEspecial,
          tipoAulaEspecial: _tipoAulaEspecial,
        );

        if (widget.materia == null) {
          await _materiaService.createMateria(materia);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Materia creada en Supabase'),
              ),
            );
          }
        } else {
          await _materiaService.updateMateria(materia);
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
          widget.materia == null ? 'Nueva Materia' : 'Editar Materia',
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
                      controller: _horasSemanalesController,
                      decoration: const InputDecoration(
                        labelText: 'Horas Semanales',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese las horas semanales';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Requiere Aula Especial'),
                      value: _requiereAulaEspecial,
                      onChanged: (bool value) {
                        setState(() {
                          _requiereAulaEspecial = value;
                          if (!value) {
                            _tipoAulaEspecial = '';
                          }
                        });
                      },
                    ),
                    if (_requiereAulaEspecial) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Aula Especial',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _tipoAulaEspecial.isNotEmpty
                            ? _tipoAulaEspecial
                            : null,
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
                            _tipoAulaEspecial = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (_requiereAulaEspecial &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor seleccione un tipo de aula';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveMateria,
                      child: Text(
                        widget.materia == null
                            ? 'Crear Materia'
                            : 'Actualizar Materia',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
