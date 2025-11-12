// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Horarios';

  @override
  String welcomeUser(Object user) {
    return 'Bienvenido $user';
  }

  @override
  String get login => 'Iniciar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get settings => 'Configuración';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get teachers => 'Profesores';

  @override
  String get subjects => 'Asignaturas';

  @override
  String get classrooms => 'Aulas';

  @override
  String get schedules => 'Horarios';

  @override
  String get create => 'Crear';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get name => 'Nombre';

  @override
  String get specialClassroom => 'Aula especial';

  @override
  String get filters => 'Filtros';

  @override
  String get teacher => 'Profesor';

  @override
  String get subject => 'Asignatura';

  @override
  String get classroom => 'Aula';

  @override
  String get date => 'Fecha';

  @override
  String get apply => 'Aplicar';

  @override
  String get notes => 'Notas';

  @override
  String get scheduleDetails => 'Detalles del horario';

  @override
  String get close => 'Cerrar';

  @override
  String get none => 'Ninguno';

  @override
  String get id => 'ID';

  @override
  String get fullscreen => 'Pantalla completa';

  @override
  String get fullscreenEnabled =>
      'Pantalla completa activada. Presiona Esc o toca de nuevo para salir.';

  @override
  String get aiGenerate => 'Generar con IA';

  @override
  String get aiGenerateTitle => 'Generación de horarios con IA';

  @override
  String get aiInstructions =>
      'Indique restricciones y preferencias para generar sugerencias.';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get saveSchedule => 'Guardar horario';

  @override
  String get noData => 'Sin datos';

  @override
  String get signInError => 'Error al iniciar sesión';

  @override
  String get missingEnv => 'Falta configuración de entorno';
}
