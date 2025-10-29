import '../models/horario.dart';
import 'api_service.dart';

class HorarioService {
  final ApiService _apiService = ApiService();
  final String endpoint = 'horarios';

  Future<List<Horario>> getAllHorarios() async {
    final jsonData = await _apiService.getAll(endpoint);
    return jsonData.map((json) => Horario.fromJson(json)).toList();
  }

  Future<Horario> getHorarioById(int id) async {
    final jsonData = await _apiService.getById(endpoint, id);
    return Horario.fromJson(jsonData);
  }

  Future<Horario> createHorario(Horario horario) async {
    final jsonData = await _apiService.create(endpoint, horario.toJson());
    return Horario.fromJson(jsonData);
  }

  Future<Horario> updateHorario(Horario horario) async {
    if (horario.id == null) {
      throw Exception('No se puede actualizar un horario sin ID');
    }
    final jsonData = await _apiService.update(endpoint, horario.id!, horario.toJson());
    return Horario.fromJson(jsonData);
  }

  Future<void> deleteHorario(int id) async {
    await _apiService.delete(endpoint, id);
  }
  
  Future<Horario> generarHorarioConIA(Map<String, dynamic> parametros) async {
    final jsonData = await _apiService.generarHorario(parametros);
    return Horario.fromJson(jsonData);
  }
}
