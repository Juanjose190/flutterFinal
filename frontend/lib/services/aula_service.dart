// frontend/lib/services/aula_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AulaService {
  final _basePath = '/api/aulas';

  // Métodos originales (en inglés)
  Future<List<dynamic>> getAll() async {
    final response = await http.get(ApiClient.uri(_basePath));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al obtener aulas: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final response = await http.get(ApiClient.uri('$_basePath/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Aula no encontrada: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await http.post(
      ApiClient.uri(_basePath),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al crear aula: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      ApiClient.uri('$_basePath/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar aula: ${response.body}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(ApiClient.uri('$_basePath/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar aula: ${response.statusCode}');
    }
  }

  // ---------- Aliases en español (para que cuadre con la UI) ----------
  Future<List<dynamic>> getAulas() => getAll();

  Future<void> deleteAula(int id) => delete(id);
}
