class Aula {
  final int? id;
  final String nombre;
  final int? capacidad;
  final bool esEspecial;
  final String? tipoAula;

  Aula({
    this.id,
    required this.nombre,
    this.capacidad,
    this.esEspecial = false,
    this.tipoAula,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['id'],
      nombre: json['nombre'],
      capacidad: json['capacidad'],
      // Backend usa camelCase: esEspecial y tipoAula
      esEspecial: json['esEspecial'] ?? false,
      tipoAula: json['tipoAula'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'capacidad': capacidad,
      // Enviar camelCase hacia el backend
      'esEspecial': esEspecial,
      'tipoAula': tipoAula,
    };
  }
}
