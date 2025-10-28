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
  DataRepository._internal();

  // Listas vacías para mantener la estructura pero sin datos locales
  final List<Docente> docentes = [];
  final List<Materia> materias = [];
  final List<Aula> aulas = [];
  final List<Horario> horarios = [];

  // Genera un ID único (temporal hasta implementar backend)
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // Docentes
  Future<void> addDocente(String nombre, String email) async {
    // Aquí se implementará la conexión con el backend
    final id = _id(); // Temporal hasta implementar backend
    docentes.add(Docente(id: id, nombre: nombre, email: email));
  }

  Future<void> updateDocente(String id, String nombre, String email) async {
    // Aquí se implementará la conexión con el backend
    final i = docentes.indexWhere((d) => d.id == id);
    if (i >= 0) {
      docentes[i] = Docente(id: id, nombre: nombre, email: email);
    }
  }

  Future<void> deleteDocente(String id) async {
    // Aquí se implementará la conexión con el backend
    docentes.removeWhere((d) => d.id == id);
  }

  // Materias
  Future<void> addMateria(String nombre, int horas) async {
    // Aquí se implementará la conexión con el backend
    final id = _id(); // Temporal hasta implementar backend
    materias.add(Materia(id: id, nombre: nombre, horas: horas));
  }

  Future<void> updateMateria(String id, String nombre, int horas) async {
    // Aquí se implementará la conexión con el backend
    final i = materias.indexWhere((m) => m.id == id);
    if (i >= 0) {
      materias[i] = Materia(id: id, nombre: nombre, horas: horas);
    }
  }

  Future<void> deleteMateria(String id) async {
    // Aquí se implementará la conexión con el backend
    materias.removeWhere((m) => m.id == id);
  }

  // Aulas
  Future<void> addAula(String nombre, int capacidad) async {
    // Aquí se implementará la conexión con el backend
    final id = _id(); // Temporal hasta implementar backend
    aulas.add(Aula(id: id, nombre: nombre, capacidad: capacidad));
  }

  Future<void> updateAula(String id, String nombre, int capacidad) async {
    // Aquí se implementará la conexión con el backend
    final i = aulas.indexWhere((a) => a.id == id);
    if (i >= 0) {
      aulas[i] = Aula(id: id, nombre: nombre, capacidad: capacidad);
    }
  }

  Future<void> deleteAula(String id) async {
    // Aquí se implementará la conexión con el backend
    aulas.removeWhere((a) => a.id == id);
  }

  // Horarios
  Future<Horario> createHorario({
    required List<String> docenteIds,
    required List<String> materiaIds,
    required List<String> aulaIds,
    HorarioStatus status = HorarioStatus.borrador,
  }) async {
    // Aquí se implementará la conexión con el backend
    final id = _id(); // Temporal hasta implementar backend
    final h = Horario(
      id: id,
      docenteIds: docenteIds,
      materiaIds: materiaIds,
      aulaIds: aulaIds,
      status: status,
    );
    horarios.add(h);
    return h;
  }

  Future<void> updateHorarioStatus(String id, HorarioStatus status) async {
    // Aquí se implementará la conexión con el backend
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

  Future<int> countByStatus(HorarioStatus status) async {
    // Aquí se implementará la conexión con el backend
    return horarios.where((h) => h.status == status).length;
  }
}