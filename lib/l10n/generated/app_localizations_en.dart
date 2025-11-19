// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Schedules';

  @override
  String welcomeUser(Object user) {
    return 'Welcome $user';
  }

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get teachers => 'Teachers';

  @override
  String get subjects => 'Subjects';

  @override
  String get classrooms => 'Classrooms';

  @override
  String get schedules => 'Schedules';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get name => 'Name';

  @override
  String get specialClassroom => 'Special Classroom';

  @override
  String get filters => 'Filters';

  @override
  String get teacher => 'Teacher';

  @override
  String get subject => 'Subject';

  @override
  String get classroom => 'Classroom';

  @override
  String get date => 'Date';

  @override
  String get apply => 'Apply';

  @override
  String get notes => 'Notes';

  @override
  String get scheduleDetails => 'Schedule Details';

  @override
  String get close => 'Close';

  @override
  String get none => 'None';

  @override
  String get id => 'ID';

  @override
  String get fullscreen => 'Full screen';

  @override
  String get fullscreenEnabled =>
      'Full screen enabled. Press Esc or tap again to exit.';

  @override
  String get aiGenerate => 'AI Generate';

  @override
  String get aiGenerateTitle => 'AI Generate Schedules';

  @override
  String get aiInstructions =>
      'Provide constraints and preferences to generate suggestions.';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get saveSchedule => 'Save Schedule';

  @override
  String get noData => 'No data';

  @override
  String get signInError => 'Sign in failed';

  @override
  String get missingEnv => 'Missing environment configuration';
}
