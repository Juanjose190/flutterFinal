import '../models/profesor.dart';
import 'api_service.dart';

class ProfesorService {
  final ApiService _apiService = ApiService();
  final String endpoint = 'profesores';

  Future<List<Profesor>> getAllProfesores() async {
    final jsonData = await _apiService.getAll(endpoint);
    return jsonData.map((json) => Profesor.fromJson(json)).toList();
  }

  Future<Profesor> getProfesorById(int id) async {
    final jsonData = await _apiService.getById(endpoint, id);
    return Profesor.fromJson(jsonData);
  }

  Future<Profesor> createProfesor(
    Profesor profesor, {
    List<int>? materiaIds,
    List<Map<String, dynamic>>? disponibilidad,
  }) async {
    final payload = Map<String, dynamic>.from(profesor.toJson());
    if (materiaIds != null) payload['materias'] = materiaIds;
    if (disponibilidad != null) payload['disponibilidad'] = disponibilidad;
    final jsonData = await _apiService.create(endpoint, payload);
    return Profesor.fromJson(jsonData);
  }

  Future<Profesor> updateProfesor(
    Profesor profesor, {
    List<int>? materiaIds,
    List<Map<String, dynamic>>? disponibilidad,
  }) async {
    if (profesor.id == null) {
      throw Exception('No se puede actualizar un profesor sin ID');
    }
    final payload = Map<String, dynamic>.from(profesor.toJson());
    if (materiaIds != null) payload['materias'] = materiaIds;
    if (disponibilidad != null) payload['disponibilidad'] = disponibilidad;
    final jsonData = await _apiService.update(endpoint, profesor.id!, payload);
    return Profesor.fromJson(jsonData);
  }

  Future<void> deleteProfesor(int id) async {
    await _apiService.delete(endpoint, id);
  }

  // ---- Relaciones y disponibilidad auxiliares ----
  Future<List<int>> getMateriasByProfesor(int profesorId) async {
    final data = await _apiService.getAll('$endpoint/$profesorId/materias');
    // El endpoint devuelve lista de enteros
    return (data as List).map((e) => (e as num).toInt()).toList();
  }

  Future<void> replaceMateriasByProfesor(int profesorId, List<int> materiaIds) async {
    await _apiService.put('$endpoint/$profesorId/materias', materiaIds);
  }

  Future<List<Map<String, dynamic>>> getDisponibilidadByProfesor(int profesorId) async {
    final data = await _apiService.getAll('$endpoint/$profesorId/disponibilidad');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> replaceDisponibilidadByProfesor(
    int profesorId,
    List<Map<String, dynamic>> disponibilidad,
  ) async {
    await _apiService.put('$endpoint/$profesorId/disponibilidad', disponibilidad);
  }
}
