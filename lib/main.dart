import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/bloc/settings_cubit.dart';
import 'presentation/bloc/auth_cubit.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/tz_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
  final supabaseAnon = dotenv.maybeGet('SUPABASE_ANON_KEY');

  if (supabaseUrl != null &&
      supabaseAnon != null &&
      supabaseUrl.isNotEmpty &&
      supabaseAnon.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnon);
  }

  // Initialize timezone database for accurate conversions and DST handling
  await TimezoneInit.ensureInitialized();

  runApp(const SchedulesApp());
}

class SchedulesApp extends StatelessWidget {
  const SchedulesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final router = AppRouter.router(context.read<AuthCubit>());
          return MaterialApp.router(
            title: 'Schedules',
            debugShowCheckedModeBanner: false,
            theme: settings.style == ThemeStyle.purpleClean
                ? AppTheme.purpleLight
                : AppTheme.light,
            darkTheme: settings.style == ThemeStyle.purpleClean
                ? AppTheme.purpleDark
                : AppTheme.dark,
            themeMode: settings.themeMode,
            routerConfig: router,
            locale: settings.locale,
            supportedLocales: const [Locale('en'), Locale('es')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
