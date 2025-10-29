import '../models/aula.dart';
import 'api_service.dart';

class AulaService {
  final ApiService _apiService = ApiService();
  final String endpoint = 'aulas';

  Future<List<Aula>> getAllAulas() async {
    final jsonData = await _apiService.getAll(endpoint);
    return jsonData.map((json) => Aula.fromJson(json)).toList();
  }

  Future<Aula> getAulaById(int id) async {
    final jsonData = await _apiService.getById(endpoint, id);
    return Aula.fromJson(jsonData);
  }

  Future<Aula> createAula(Aula aula) async {
    final jsonData = await _apiService.create(endpoint, aula.toJson());
    return Aula.fromJson(jsonData);
  }

  Future<Aula> updateAula(Aula aula) async {
    if (aula.id == null) {
      throw Exception('No se puede actualizar un aula sin ID');
    }
    final jsonData = await _apiService.update(endpoint, aula.id!, aula.toJson());
    return Aula.fromJson(jsonData);
  }

  Future<void> deleteAula(int id) async {
    await _apiService.delete(endpoint, id);
  }
}
