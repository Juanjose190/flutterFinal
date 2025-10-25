import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_repository.dart';

class AulasScreen extends StatelessWidget {
  const AulasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Aulas')),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.builder(
              itemCount: repo.aulas.length,
              itemBuilder: (context, index) {
                final a = repo.aulas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Dismissible(
                    key: ValueKey(a.id),
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
                    onDismissed: (_) => repo.deleteAula(a.id),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(a.nombre),
                        subtitle: Text('Capacidad: ${a.capacidad}')
                        ,
                        leading: const CircleAvatar(child: Icon(Icons.meeting_room)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/aula_form', extra: a),
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
        onPressed: () => context.push('/aula_form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva aula'),
      ),
    );
  }
}