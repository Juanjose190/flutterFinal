import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';
import '../ui/widgets/glass_card.dart';

class DocenteFormScreen extends StatefulWidget {
  final Docente? docente;
  const DocenteFormScreen({super.key, this.docente});

  @override
  State<DocenteFormScreen> createState() => _DocenteFormScreenState();
}

class _DocenteFormScreenState extends State<DocenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _emailCtrl;
  final repo = DataRepository.instance;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.docente?.nombre ?? '');
    _emailCtrl = TextEditingController(text: widget.docente?.email ?? '');
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.docente == null) {
        repo.addDocente(_nombreCtrl.text.trim(), _emailCtrl.text.trim());
      } else {
        repo.updateDocente(widget.docente!.id, _nombreCtrl.text.trim(), _emailCtrl.text.trim());
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
    final editing = widget.docente != null;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(editing ? 'Editar docente' : 'Nuevo docente')),
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
                        decoration: _decoration(label: 'Nombre', icon: CupertinoIcons.person),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _decoration(label: 'Email', icon: CupertinoIcons.at),
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