import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/api_service.dart';
import 'services/materia_service.dart';
import 'services/profesor_service.dart';
import 'services/aula_service.dart';
import 'services/horario_service.dart'; // opcional si quieres mover DashboardScreen a otro archivo
import 'services/gemini_service.dart';
import 'screens/tabs.dart';

// Si vas a dejar todo en este archivo, puedes ignorar la import de screens/dashboard_screen.dart
// y usar la clase DashboardScreen definida abajo.

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Registrar servicios con tipos explícitos
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<MateriaService>(() => MateriaService());
  getIt.registerLazySingleton<ProfesorService>(() => ProfesorService());
  getIt.registerLazySingleton<AulaService>(() => AulaService());
  getIt.registerLazySingleton<HorarioService>(() => HorarioService());
  // Registrar GeminiService (requiere que dotenv esté cargado)
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generador de Horarios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

/// -----------------------------------------------------------
/// DashboardScreen con BottomNavigation y pestañas (limpio)
/// -----------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    MateriasTab(),
    ProfesoresTab(),
    AulasTab(),
    HorariosTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Generador de Horarios'),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
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
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// -----------------------------------------------------------
/// Tabs (stubs) — reemplaza con tus implementaciones reales
/// -----------------------------------------------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 80, color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido al Generador de Horarios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gestiona materias, profesores, aulas y genera horarios con IA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            // Botón de generar nuevo horario eliminado a solicitud
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.wifi),
              label: const Text('Verificar conexión con backend'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onPressed: () async {
                final api = getIt<ApiService>();
                bool materiasOk = false;
                bool profesoresOk = false;
                bool aulasOk = false;
                String? errorDetalle;

                try {
                  await api.getAll('materias');
                  materiasOk = true;
                } catch (e) {
                  errorDetalle = e.toString();
                }
                try {
                  await api.getAll('profesores');
                  profesoresOk = true;
                } catch (e) {
                  errorDetalle ??= e.toString();
                }
                try {
                  await api.getAll('aulas');
                  aulasOk = true;
                } catch (e) {
                  errorDetalle ??= e.toString();
                }

                if (!context.mounted) return;

                if (materiasOk && profesoresOk && aulasOk) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Conexión: OK, Materias, Profesores, Aulas cargados con éxito',
                      ),
                    ),
                  );
                } else {
                  final cargados = <String>[];
                  final fallidos = <String>[];
                  if (materiasOk) {
                    cargados.add('Materias');
                  } else {
                    fallidos.add('Materias');
                  }
                  if (profesoresOk) {
                    cargados.add('Profesores');
                  } else {
                    fallidos.add('Profesores');
                  }
                  if (aulasOk) {
                    cargados.add('Aulas');
                  } else {
                    fallidos.add('Aulas');
                  }

                  final okPart = cargados.isNotEmpty
                      ? '${cargados.join(', ')} cargados con éxito'
                      : 'Ningún recurso cargado con éxito';
                  final errPart = fallidos.isNotEmpty
                      ? 'error al cargar: ${fallidos.join(', ')}'
                      : '';
                  final msg = errPart.isNotEmpty
                      ? '$okPart, $errPart'
                      : okPart;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Las clases de tabs reales están definidas en screens/tabs.dart
