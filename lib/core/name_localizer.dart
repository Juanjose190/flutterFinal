import 'package:flutter/material.dart';

enum EntityKind { subject, classroom }

// Bidirectional dictionaries for common names. Extend as needed.
const Map<String, String> _subjectsEnToEs = {
  'Mathematics': 'Matemáticas',
  'Physics': 'Física',
  'Chemistry': 'Química',
  'Biology': 'Biología',
  'History': 'Historia',
  'Geography': 'Geografía',
  'English': 'Inglés',
  'Spanish': 'Español',
  'Computer Science': 'Informática',
  'Art': 'Arte',
  'Music': 'Música',
};

const Map<String, String> _subjectsEsToEn = {
  'Matemáticas': 'Mathematics',
  'Física': 'Physics',
  'Química': 'Chemistry',
  'Biología': 'Biology',
  'Historia': 'History',
  'Geografía': 'Geography',
  'Inglés': 'English',
  'Español': 'Spanish',
  'Informática': 'Computer Science',
  'Arte': 'Art',
  'Música': 'Music',
};

const Map<String, String> _classroomsEnToEs = {
  'Laboratory': 'Laboratorio',
  'Library': 'Biblioteca',
  'Auditorium': 'Auditorio',
  'Computer Room': 'Sala de informática',
  'Gym': 'Gimnasio',
  'Music Room': 'Sala de música',
  'Art Room': 'Sala de arte',
  'Science Lab': 'Laboratorio de ciencias',
};

const Map<String, String> _classroomsEsToEn = {
  'Laboratorio': 'Laboratory',
  'Biblioteca': 'Library',
  'Auditorio': 'Auditorium',
  'Sala de informática': 'Computer Room',
  'Gimnasio': 'Gym',
  'Sala de música': 'Music Room',
  'Sala de arte': 'Art Room',
  'Laboratorio de ciencias': 'Science Lab',
};

String localizeEntityName(BuildContext context, String name, EntityKind kind) {
  final locale = Localizations.localeOf(context);
  final lang = locale.languageCode.toLowerCase();
  if (name.isEmpty) return name;
  Map<String, String> forward;
  Map<String, String> backward;
  switch (kind) {
    case EntityKind.subject:
      forward = lang.startsWith('es') ? _subjectsEnToEs : _subjectsEsToEn;
      backward = lang.startsWith('es') ? _subjectsEsToEn : _subjectsEnToEs;
      break;
    case EntityKind.classroom:
      forward = lang.startsWith('es') ? _classroomsEnToEs : _classroomsEsToEn;
      backward = lang.startsWith('es') ? _classroomsEsToEn : _classroomsEnToEs;
      break;
  }
  // If name seems already in target language, return as-is
  if (forward.containsValue(name)) return name;
  // Translate when exact match exists; otherwise keep original
  return forward[name] ?? name;
}

