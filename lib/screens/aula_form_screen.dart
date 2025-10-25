import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';
import '../ui/widgets/glass_card.dart';

class AulaFormScreen extends StatefulWidget {
  final Aula? aula;
  const AulaFormScreen({super.key, this.aula});

  @override
  State<AulaFormScreen> createState() => _AulaFormScreenState();
}

class _AulaFormScreenState extends State<AulaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _capacidadCtrl;
  final repo = DataRepository.instance;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.aula?.nombre ?? '');
    _capacidadCtrl = TextEditingController(text: widget.aula?.capacidad.toString() ?? '');
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final capacidad = int.tryParse(_capacidadCtrl.text.trim()) ?? 0;
      if (widget.aula == null) {
        repo.addAula(_nombreCtrl.text.trim(), capacidad);
      } else {
        repo.updateAula(widget.aula!.id, _nombreCtrl.text.trim(), capacidad);
      }
      context.pop();
    }
  }

  InputDecoration _decoration({required String label, IconData? icon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(0.4),
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.aula != null;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(editing ? 'Editar aula' : 'Nueva aula')),
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
                        decoration: _decoration(label: 'Nombre', icon: CupertinoIcons.building_2_fill),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _capacidadCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(label: 'Capacidad', icon: CupertinoIcons.number),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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