import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ProfesorService {
  final _basePath = '/api/profesores';

  Future<List<dynamic>> getAll() async {
    final res = await http.get(ApiClient.uri(_basePath));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al obtener profesores');
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(ApiClient.uri('$_basePath/$id'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Profesor no encontrado');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await http.post(
      ApiClient.uri(_basePath),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al crear profesor');
    }
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      ApiClient.uri('$_basePath/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al actualizar profesor');
    }
  }

  Future<void> delete(int id) async {
    final res = await http.delete(ApiClient.uri('$_basePath/$id'));
    if (res.statusCode != 200) {
      throw Exception('Error al eliminar profesor');
    }
  }
}
