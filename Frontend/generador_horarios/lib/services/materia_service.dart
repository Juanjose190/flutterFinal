import '../models/materia.dart';
import 'api_service.dart';

class MateriaService {
  final ApiService _apiService = ApiService();
  final String endpoint = 'materias';

  Future<List<Materia>> getAllMaterias() async {
    final jsonData = await _apiService.getAll(endpoint);
    return jsonData.map((json) => Materia.fromJson(json)).toList();
  }

  Future<Materia> getMateriaById(int id) async {
    final jsonData = await _apiService.getById(endpoint, id);
    return Materia.fromJson(jsonData);
  }

  Future<Materia> createMateria(Materia materia) async {
    final jsonData = await _apiService.create(endpoint, materia.toJson());
    return Materia.fromJson(jsonData);
  }

  Future<Materia> updateMateria(Materia materia) async {
    if (materia.id == null) {
      throw Exception('No se puede actualizar una materia sin ID');
    }
    final jsonData = await _apiService.update(endpoint, materia.id!, materia.toJson());
    return Materia.fromJson(jsonData);
  }

  Future<void> deleteMateria(int id) async {
    await _apiService.delete(endpoint, id);
  }
}
