import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';
import '../ui/widgets/glass_card.dart';

class MateriaFormScreen extends StatefulWidget {
  final Materia? materia;
  const MateriaFormScreen({super.key, this.materia});

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _horasCtrl;
  final repo = DataRepository.instance;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.materia?.nombre ?? '');
    _horasCtrl = TextEditingController(
      text: widget.materia?.horas.toString() ?? '',
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final horas = int.tryParse(_horasCtrl.text.trim()) ?? 0;
      if (widget.materia == null) {
        repo.addMateria(_nombreCtrl.text.trim(), horas);
      } else {
        repo.updateMateria(widget.materia!.id, _nombreCtrl.text.trim(), horas);
      }
      context.pop();
    }
  }

  InputDecoration _decoration({required String label, IconData? icon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.materia != null;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(editing ? 'Editar materia' : 'Nueva materia'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverToBoxAdapter(
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: _decoration(
                          label: 'Nombre',
                          icon: CupertinoIcons.book,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _horasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          label: 'Horas por semana',
                          icon: CupertinoIcons.timer,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: _save,
                          icon: const Icon(CupertinoIcons.check_mark),
                          label: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
