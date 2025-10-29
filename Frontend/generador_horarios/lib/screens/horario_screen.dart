import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/horario.dart';
import '../services/horario_service.dart';

class HorarioScreen extends StatefulWidget {
  final Horario? horario;

  const HorarioScreen({super.key, this.horario});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  final HorarioService _horarioService = GetIt.instance<HorarioService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.horario != null) {
      _nombreController.text = widget.horario!.nombre;
      _descripcionController.text = widget.horario!.descripcion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveHorario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final horario = Horario(
          id: widget.horario?.id ?? 0,
          nombre: _nombreController.text,
          descripcion: _descripcionController.text,
          fechaCreacion: DateTime.now(),
          asignaciones: widget.horario?.asignaciones ?? [],
        );

        if (widget.horario == null) {
          await _horarioService.createHorario(horario);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Horario creado en Supabase'),
              ),
            );
          }
        } else {
          await _horarioService.updateHorario(horario);
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
          widget.horario == null ? 'Nuevo Horario' : 'Editar Horario',
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
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveHorario,
                      child: Text(
                        widget.horario == null
                            ? 'Crear Horario'
                            : 'Actualizar Horario',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
