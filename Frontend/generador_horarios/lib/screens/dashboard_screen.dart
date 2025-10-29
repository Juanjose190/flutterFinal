import 'package:flutter/material.dart';
import 'generar_horario_screen.dart';

// Importa tus tabs reales aquí, por ahora las defino vacías.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildHomeTab(context);
  }
}

class MateriasTab extends StatelessWidget {
  const MateriasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Materias"));
  }
}

class ProfesoresTab extends StatelessWidget {
  const ProfesoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profesores"));
  }
}

class AulasTab extends StatelessWidget {
  const AulasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Aulas"));
  }
}

class HorariosTab extends StatelessWidget {
  const HorariosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Horarios"));
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = const [
      HomeTab(),
      MateriasTab(),
      ProfesoresTab(),
      AulasTab(),
      HorariosTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Horarios'),
        backgroundColor: Colors.blue,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materias'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profesores',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: 'Aulas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

Widget _buildHomeTab(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.schedule, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Bienvenido al Generador de Horarios',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Esta aplicación te permite gestionar materias, profesores, aulas y generar horarios optimizados automáticamente.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generar Horario con IA'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GenerarHorarioScreen(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
