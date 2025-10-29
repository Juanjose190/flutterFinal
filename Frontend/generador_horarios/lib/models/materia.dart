class Materia {
  final int? id;
  final String nombre;
  final int horasSemanales;
  final String? descripcion;
  final bool requiereAulaEspecial;
  final String? tipoAulaEspecial;

  Materia({
    this.id,
    required this.nombre,
    required this.horasSemanales,
    this.descripcion,
    this.requiereAulaEspecial = false,
    this.tipoAulaEspecial,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nombre: json['nombre'],
      // Backend usa camelCase: horasSemanales
      horasSemanales: json['horasSemanales'],
      descripcion: json['descripcion'],
      // Backend usa camelCase: requiereAulaEspecial y tipoAulaEspecial
      requiereAulaEspecial: json['requiereAulaEspecial'] ?? false,
      tipoAulaEspecial: json['tipoAulaEspecial'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      // Enviar camelCase hacia el backend
      'horasSemanales': horasSemanales,
      'descripcion': descripcion,
      'requiereAulaEspecial': requiereAulaEspecial,
      'tipoAulaEspecial': tipoAulaEspecial,
    };
  }
}
