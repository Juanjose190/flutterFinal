class Profesor {
  final int? id;
  final String nombre;
  final String apellido;
  final String? email;
  final int? horasDisponibles;

  Profesor({
    this.id,
    required this.nombre,
    required this.apellido,
    this.email,
    this.horasDisponibles,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) {
    return Profesor(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      // Backend usa camelCase: horasDisponibles
      horasDisponibles: json['horasDisponibles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      // Enviar camelCase hacia el backend
      'horasDisponibles': horasDisponibles,
    };
  }
}
