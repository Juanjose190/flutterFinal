import 'package:go_router/go_router.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/teachers/teachers_list_page.dart';
import '../../presentation/pages/subjects/subjects_list_page.dart';
import '../../presentation/pages/classrooms/classrooms_list_page.dart';
import '../../presentation/pages/schedules/schedules_view_page.dart';
import '../../presentation/pages/schedules/ai_generate_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/pages/signup_page.dart';
import '../../presentation/bloc/auth_cubit.dart';

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authCubit,
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpPage()),
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
        GoRoute(
          path: '/teachers',
          builder: (_, __) => const TeachersListPage(),
        ),
        GoRoute(
          path: '/subjects',
          builder: (_, __) => const SubjectsListPage(),
        ),
        GoRoute(
          path: '/classrooms',
          builder: (_, __) => const ClassroomsListPage(),
        ),
        GoRoute(
          path: '/schedules',
          builder: (_, __) => const SchedulesViewPage(),
        ),
        GoRoute(
          path: '/schedules/ai',
          builder: (_, __) => const AIGeneratePage(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authCubit.state is Authenticated;
        final loggingIn = state.matchedLocation == '/login';
        if (!isLoggedIn) {
          return loggingIn ? null : '/login';
        }
        if (loggingIn && isLoggedIn) return '/';
        return null;
      },
    );
  }
}
