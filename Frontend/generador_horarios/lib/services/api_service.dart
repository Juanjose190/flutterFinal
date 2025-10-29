import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8081/api';
  final String geminiApiKey = 'AIzaSyCaa_sM_mKU0xSc5tPMKanperYFD7Ox-yw';
  final String supabaseUrl =
      'postgresql://postgres:Juanes25!@db.gyddufkyfhxuvyvhiewp.supabase.co:5432/postgres';

  // Método genérico para obtener datos
  Future<List<dynamic>> getAll(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  // Método genérico para obtener un elemento por ID
  Future<dynamic> getById(String endpoint, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  // Método genérico para crear un elemento
  Future<dynamic> create(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear: ${response.statusCode}');
    }
  }

  // Variante que retorna también si se sincronizó con Supabase, leyendo el header
  Future<(dynamic jsonBody, bool supabaseSynced)> createWithInfo(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    final syncedHeader = response.headers['x-supabase-sync'] ?? '';
    final supabaseSynced = syncedHeader.toLowerCase() == 'ok';

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      return (body, supabaseSynced);
    } else {
      throw Exception('Error al crear: ${response.statusCode}');
    }
  }

  // Método genérico para actualizar un elemento
  Future<dynamic> update(
    String endpoint,
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar: ${response.statusCode}');
    }
  }

  // PUT genérico a una ruta arbitraria (sin ID implícito)
  Future<void> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error en PUT $endpoint: ${response.statusCode}');
    }
  }

  // Método genérico para eliminar un elemento
  Future<void> delete(String endpoint, int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar: ${response.statusCode}');
    }
  }

  // Método específico para generar horarios con IA
  Future<dynamic> generarHorario(Map<String, dynamic> parametros) async {
    final response = await http.post(
      Uri.parse('$baseUrl/horarios/generar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(parametros),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al generar horario: ${response.statusCode}');
    }
  }
}
