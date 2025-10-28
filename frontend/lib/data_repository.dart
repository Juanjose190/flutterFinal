enum HorarioStatus { aprobado, pendiente, borrador }

extension HorarioStatusX on HorarioStatus {
  String get label {
    switch (this) {
      case HorarioStatus.aprobado:
        return 'aprobado';
      case HorarioStatus.pendiente:
        return 'pendiente';
      case HorarioStatus.borrador:
        return 'borrador';
    }
  }
}

class Docente {
  final String id;
  final String nombre;
  final String email;
  Docente({required this.id, required this.nombre, required this.email});
}

class Materia {
  final String id;
  final String nombre;
  final int horas;
  Materia({required this.id, required this.nombre, required this.horas});
}

class Aula {
  final String id;
  final String nombre;
  final int capacidad;
  Aula({required this.id, required this.nombre, required this.capacidad});
}

class Horario {
  final String id;
  final List<String> docenteIds;
  final List<String> materiaIds;
  final List<String> aulaIds;
  final HorarioStatus status;
  Horario({
    required this.id,
    required this.docenteIds,
    required this.materiaIds,
    required this.aulaIds,
    required this.status,
  });
}

class DataRepository {
  static final DataRepository instance = DataRepository._internal();
  DataRepository._internal() {
    _seed();
  }

  final List<Docente> docentes = [];
  final List<Materia> materias = [];
  final List<Aula> aulas = [];
  final List<Horario> horarios = [];

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void _seed() {
    docentes.addAll([
      Docente(id: _id(), nombre: 'Ana López', email: 'ana@colegio.com'),
      Docente(id: _id(), nombre: 'Carlos Pérez', email: 'carlos@colegio.com'),
      Docente(id: _id(), nombre: 'María Gómez', email: 'maria@colegio.com'),
    ]);
    materias.addAll([
      Materia(id: _id(), nombre: 'Matemáticas', horas: 5),
      Materia(id: _id(), nombre: 'Lengua', horas: 4),
      Materia(id: _id(), nombre: 'Historia', horas: 3),
    ]);
    aulas.addAll([
      Aula(id: _id(), nombre: 'Aula 101', capacidad: 30),
      Aula(id: _id(), nombre: 'Aula 202', capacidad: 25),
      Aula(id: _id(), nombre: 'Laboratorio', capacidad: 20),
    ]);
  }

  // Docentes
  void addDocente(String nombre, String email) {
    docentes.add(Docente(id: _id(), nombre: nombre, email: email));
  }

  void updateDocente(String id, String nombre, String email) {
    final i = docentes.indexWhere((d) => d.id == id);
    if (i >= 0) {
      docentes[i] = Docente(id: id, nombre: nombre, email: email);
    }
  }

  void deleteDocente(String id) {
    docentes.removeWhere((d) => d.id == id);
  }

  // Materias
  void addMateria(String nombre, int horas) {
    materias.add(Materia(id: _id(), nombre: nombre, horas: horas));
  }

  void updateMateria(String id, String nombre, int horas) {
    final i = materias.indexWhere((m) => m.id == id);
    if (i >= 0) {
      materias[i] = Materia(id: id, nombre: nombre, horas: horas);
    }
  }

  void deleteMateria(String id) {
    materias.removeWhere((m) => m.id == id);
  }

  // Aulas
  void addAula(String nombre, int capacidad) {
    aulas.add(Aula(id: _id(), nombre: nombre, capacidad: capacidad));
  }

  void updateAula(String id, String nombre, int capacidad) {
    final i = aulas.indexWhere((a) => a.id == id);
    if (i >= 0) {
      aulas[i] = Aula(id: id, nombre: nombre, capacidad: capacidad);
    }
  }

  void deleteAula(String id) {
    aulas.removeWhere((a) => a.id == id);
  }

  // Horarios
  Horario createHorario({
    required List<String> docenteIds,
    required List<String> materiaIds,
    required List<String> aulaIds,
    HorarioStatus status = HorarioStatus.borrador,
  }) {
    final h = Horario(
      id: _id(),
      docenteIds: docenteIds,
      materiaIds: materiaIds,
      aulaIds: aulaIds,
      status: status,
    );
    horarios.add(h);
    return h;
  }

  void updateHorarioStatus(String id, HorarioStatus status) {
    final i = horarios.indexWhere((h) => h.id == id);
    if (i >= 0) {
      final h = horarios[i];
      horarios[i] = Horario(
        id: h.id,
        docenteIds: h.docenteIds,
        materiaIds: h.materiaIds,
        aulaIds: h.aulaIds,
        status: status,
      );
    }
  }

  int countByStatus(HorarioStatus status) =>
      horarios.where((h) => h.status == status).length;
}