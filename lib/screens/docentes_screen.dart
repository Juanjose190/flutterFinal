import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';

class DocentesScreen extends StatefulWidget {
  const DocentesScreen({super.key});

  @override
  State<DocentesScreen> createState() => _DocentesScreenState();
}

class _DocentesScreenState extends State<DocentesScreen> {
  final repo = DataRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Docentes')),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.builder(
              itemCount: repo.docentes.length,
              itemBuilder: (context, index) {
                final d = repo.docentes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Dismissible(
                    key: ValueKey(d.id),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      await repo.deleteDocente(d.id);
                      setState(() {}); // Actualizar UI después de eliminar
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(d.nombre),
                        subtitle: Text(d.email),
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/docente_form', extra: d),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/docente_form'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo docente'),
      ),
    );
  }
}