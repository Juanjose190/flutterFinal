import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/app_theme.dart';
import 'ui/theme_controller.dart';
import 'data_repository.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/docentes_screen.dart';
import 'screens/docente_form_screen.dart';
import 'screens/materias_screen.dart';
import 'screens/materia_form_screen.dart';
import 'screens/aulas_screen.dart';
import 'screens/aula_form_screen.dart';
import 'screens/generar_horario_screen.dart';
import 'screens/ver_horario_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'login',
          pageBuilder: (context, state) => _fadeSlide(const LoginScreen()),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _fadeSlide(const HomeScreen()),
        ),
        GoRoute(
          path: '/docentes',
          name: 'docentes',
          pageBuilder: (context, state) => _fadeSlide(const DocentesScreen()),
        ),
        GoRoute(
          path: '/docente_form',
          name: 'docente_form',
          pageBuilder: (context, state) =>
              _fadeSlide(DocenteFormScreen(docente: state.extra as Docente?)),
        ),
        GoRoute(
          path: '/materias',
          name: 'materias',
          pageBuilder: (context, state) => _fadeSlide(const MateriasScreen()),
        ),
        GoRoute(
          path: '/materia_form',
          name: 'materia_form',
          pageBuilder: (context, state) =>
              _fadeSlide(MateriaFormScreen(materia: state.extra as Materia?)),
        ),
        GoRoute(
          path: '/aulas',
          name: 'aulas',
          pageBuilder: (context, state) => _fadeSlide(const AulasScreen()),
        ),
        GoRoute(
          path: '/aula_form',
          name: 'aula_form',
          pageBuilder: (context, state) =>
              _fadeSlide(AulaFormScreen(aula: state.extra as Aula?)),
        ),
        GoRoute(
          path: '/generar',
          name: 'generar',
          pageBuilder: (context, state) =>
              _fadeSlide(const GenerarHorarioScreen()),
        ),
        GoRoute(
          path: '/horario',
          name: 'horario',
          pageBuilder: (context, state) =>
              _fadeSlide(VerHorarioScreen(horario: state.extra as Horario?)),
        ),
      ],
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'Planificador Escolar',
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final brightness = MediaQuery.of(context).platformBrightness;
            return AnimatedTheme(
              data: Theme.of(context),
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeInOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 460),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (c, anim) {
                  final fade = CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeInOutCubic,
                  );
                  final scale = Tween<double>(
                    begin: 0.98,
                    end: 1.0,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(scale: scale, child: c),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(brightness),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

CustomTransitionPage _fadeSlide(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
