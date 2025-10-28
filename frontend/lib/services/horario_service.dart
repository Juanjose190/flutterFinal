import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class HorarioService {
  final _basePath = '/api/horarios';

  Future<List<dynamic>> getAll() async {
    final res = await http.get(ApiClient.uri(_basePath));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al obtener horarios');
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(ApiClient.uri('$_basePath/$id'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Horario no encontrado');
    }
  }

  Future<Map<String, dynamic>> generar(Map<String, dynamic> data) async {
    final res = await http.post(
      ApiClient.uri('$_basePath/generar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al generar horario');
    }
  }

  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    final res = await http.put(
      ApiClient.uri('$_basePath/$id/estado'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estado': nuevoEstado}),
    );
    if (res.statusCode != 200) {
      throw Exception('Error al actualizar estado');
    }
  }
}
