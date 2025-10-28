import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/aula_service.dart'; // ✅ (1) Importar el servicio HTTP

class AulasScreen extends StatefulWidget {
  const AulasScreen({super.key});

  @override
  State<AulasScreen> createState() => _AulasScreenState();
}

class _AulasScreenState extends State<AulasScreen> {
  final AulaService _aulaService =
      AulaService(); // ✅ (2) Instancia del servicio
  List<dynamic> aulas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAulas(); // ✅ (3) Cargar aulas al iniciar la pantalla
  }

  Future<void> _loadAulas() async {
    try {
      final data = await _aulaService.getAulas(); // ✅ (4) Llamar al backend
      setState(() {
        aulas = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener aulas: $e')));
    }
  }

  Future<void> _deleteAula(int id) async {
    try {
      await _aulaService.deleteAula(id); // ✅ (5) Eliminar aula desde backend
      setState(() {
        aulas.removeWhere((a) => a['id'] == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar aula: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // ✅ (6) Mostrar indicador de carga mientras trae los datos
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Aulas')),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.builder(
              itemCount: aulas.length,
              itemBuilder: (context, index) {
                final a = aulas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Dismissible(
                    key: ValueKey(a['id']),
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
                    onDismissed: (_) =>
                        _deleteAula(a['id']), // ✅ (7) Usa delete del backend
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(a['nombre'] ?? 'Sin nombre'),
                        subtitle: Text('Capacidad: ${a['capacidad'] ?? 'N/A'}'),
                        leading: const CircleAvatar(
                          child: Icon(Icons.meeting_room),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        // Si usas navegación por rutas con objetos:
                        // onTap: () => context.push('/aula_form', extra: a),
                        onTap:
                            () {}, // ✅ (8) Pendiente de conectar con formulario
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
