import 'package:intl/intl.dart';

class Horario {
  final int? id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaCreacion;
  final List<AsignacionHoraria>? asignaciones;

  Horario({
    this.id,
    required this.nombre,
    this.descripcion,
    DateTime? fechaCreacion,
    this.asignaciones,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      // Backend usa camelCase: fechaCreacion
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      asignaciones: json['asignaciones'] != null
          ? List<AsignacionHoraria>.from(
              json['asignaciones'].map((x) => AsignacionHoraria.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      // Enviar camelCase hacia el backend en formato ISO-8601 para LocalDateTime
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'asignaciones': asignaciones?.map((x) => x.toJson()).toList(),
    };
  }
}

class AsignacionHoraria {
  final int? id;
  final int horarioId;
  final int materiaId;
  final int profesorId;
  final int aulaId;
  final String dia;
  final String horaInicio;
  final String horaFin;

  AsignacionHoraria({
    this.id,
    required this.horarioId,
    required this.materiaId,
    required this.profesorId,
    required this.aulaId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  factory AsignacionHoraria.fromJson(Map<String, dynamic> json) {
    return AsignacionHoraria(
      id: json['id'],
      // Backend devuelve objetos relacionados o ids; soportar ambos
      horarioId:
          json['horario_id'] ??
          json['horarioId'] ??
          json['horario']?['id'] ??
          0,
      materiaId:
          json['materia_id'] ??
          json['materiaId'] ??
          json['materia']?['id'] ??
          0,
      profesorId:
          json['profesor_id'] ??
          json['profesorId'] ??
          json['profesor']?['id'] ??
          0,
      aulaId: json['aula_id'] ?? json['aulaId'] ?? json['aula']?['id'] ?? 0,
      dia: json['dia'],
      // Backend usa camelCase: horaInicio y horaFin
      horaInicio: json['hora_inicio'] ?? json['horaInicio'],
      horaFin: json['hora_fin'] ?? json['horaFin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Enviar camelCase hacia el backend
      'horarioId': horarioId,
      'materiaId': materiaId,
      'profesorId': profesorId,
      'aulaId': aulaId,
      // Además, enviar objetos anidados {id} que el backend Java entiende
      'materia': {'id': materiaId},
      'profesor': {'id': profesorId},
      'aula': {'id': aulaId},
      'dia': dia,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
    };
  }
}
