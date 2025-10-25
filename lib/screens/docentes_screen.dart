import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';

class DocentesScreen extends StatelessWidget {
  const DocentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
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
                    onDismissed: (_) => repo.deleteDocente(d.id),
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