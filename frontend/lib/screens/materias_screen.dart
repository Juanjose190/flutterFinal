import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Materias')),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.builder(
              itemCount: repo.materias.length,
              itemBuilder: (context, index) {
                final m = repo.materias[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Dismissible(
                    key: ValueKey(m.id),
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
                    onDismissed: (_) => repo.deleteMateria(m.id),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(m.nombre),
                        subtitle: Text('Horas/sem: ${m.horas}'),
                        leading: const CircleAvatar(child: Icon(Icons.book_outlined)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/materia_form', extra: m),
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
        onPressed: () => context.push('/materia_form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),
    );
  }
}