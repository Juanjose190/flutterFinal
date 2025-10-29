import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/horario.dart';

class GeminiService {
  late GenerativeModel _model;
  late final String _apiKey;
  late final List<String> _fallbackModels;
  late String _currentModelName;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('No se encontró GEMINI_API_KEY en el archivo .env');
    }

    final configuredModel = dotenv.env['GEMINI_MODEL']?.trim();
    // Lista de fallback priorizando versiones flash y compatibilidad amplia
    _fallbackModels = [
      if (configuredModel != null && configuredModel.isNotEmpty)
        configuredModel,
      // Preferir modelos flash (sin costo pro) si están disponibles
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      // Alternativas pro/legacy si flash no está disponible
      'gemini-1.0-pro',
      'gemini-pro',
      'gemini-1.5-pro',
    ];

    _currentModelName = _fallbackModels.first;
    _model = _buildModel(_currentModelName);
  }

  GenerativeModel _buildModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
        // Fuerza respuesta como JSON para simplificar el parseo
        responseMimeType: 'application/json',
      ),
    );
  }

  // Genera un horario en formato JSON y lo parsea a modelo Horario.
  // El prompt debe llevar contexto suficiente para que el modelo devuelva
  // el JSON con esta estructura:
  // {
  //   "nombre": string,
  //   "descripcion": string,
  //   "fechaCreacion": ISO8601 string,
  //   "asignaciones": [
  //     {"materiaId": int, "profesorId": int, "aulaId": int, "dia": string, "horaInicio": "HH:mm", "horaFin": "HH:mm"}
  //   ]
  // }
  Future<Horario> generarHorarioDesdePrompt({
    required String nombre,
    String? descripcion,
    String contexto = '',
  }) async {
    final systemInstructions = _buildSystemInstructions();
    final userPrompt = _buildUserPrompt(
      nombre: nombre,
      descripcion: descripcion,
      contexto: contexto,
    );
    // Algunos endpoints no aceptan rol "system"; enviamos todo como mensaje de usuario.
    final combinedPrompt = [systemInstructions, userPrompt].join('\n\n');
    GenerateContentResponse? response;
    try {
      response = await _model.generateContent([Content.text(combinedPrompt)]);
    } catch (e) {
      // Intentar con modelos alternativos si el actual no está soportado
      final err = e.toString();
      final needsFallback =
          err.contains('not found') ||
          err.contains('is not supported') ||
          err.contains('ListModels') ||
          // SDK antiguo: error al parsear respuestas con role:model o nuevos parts
          err.contains('Unhandled format for Content') ||
          err.contains('role: model') ||
          err.contains('format for Content');
      if (!needsFallback) rethrow;

      Object lastError = e;
      for (final candidate in _fallbackModels) {
        if (candidate == _currentModelName) continue;
        try {
          _currentModelName = candidate;
          _model = _buildModel(candidate);
          response = await _model.generateContent([
            Content.text(combinedPrompt),
          ]);
          // éxito con fallback
          break;
        } catch (err) {
          // probar siguiente
          lastError = err;
          continue;
        }
      }
      // Si no se asignó response, relanzar el último error
      if (response == null) {
        throw lastError;
      }
    }

    // Recogemos la salida del modelo desde las parts/text y extraemos el JSON.
    final jsonStr = _jsonFromResponse(response).trim();
    if (jsonStr.isEmpty) {
      throw Exception('Respuesta vacía del modelo Gemini');
    }

    // Si por algún motivo entró texto con fences/markdown, intentamos extraer el objeto.
    final maybeCleanJson = _extractJson(jsonStr);
    final Map<String, dynamic> data = json.decode(maybeCleanJson);
    return Horario.fromJson(data);
  }

  // Obtiene JSON crudo desde las parts de la respuesta, soportando DataPart (application/json)
  // y haciendo fallback a texto cuando sea necesario.
  String _jsonFromResponse(GenerateContentResponse response) {
    // Recorremos candidatos y sus partes para localizar JSON binario.
    final candidates = response.candidates;
    for (final cand in candidates) {
      final content = cand.content;
      final parts = content.parts;
      for (final part in parts) {
        // Soporte de DataPart con mimeType JSON (modo responseMimeType: application/json)
        if (part is DataPart) {
          final mt = part.mimeType.toLowerCase();
          if (mt.contains('json')) {
            final bytes = part.bytes;
            if (bytes.isNotEmpty) {
              return utf8.decode(bytes);
            }
          }
        }
        // Fallback: TextPart por si el modelo devolvió texto plano
        if (part is TextPart) {
          final t = part.text.trim();
          if (t.isNotEmpty) return t;
        }
      }
    }
    // Último recurso: el agregador de texto.
    return response.text ?? '';
  }

  String _buildSystemInstructions() {
    return [
      'Eres un asistente que diseña horarios académicos óptimos.',
      'Devuelve únicamente JSON válido (sin texto adicional, sin markdown).',
      'Usa exclusivamente los IDs proporcionados en el contexto para materiaId, profesorId y aulaId.',
      'Esquema exacto requerido: {nombre, descripcion, fechaCreacion (ISO8601), asignaciones:[{materiaId, profesorId, aulaId, dia, horaInicio (HH:mm), horaFin (HH:mm)}]}.',
      'Evita solapamientos y respeta disponibilidad y capacidades de aula si están indicadas.',
    ].join(' ');
  }

  String _buildUserPrompt({
    required String nombre,
    String? descripcion,
    String contexto = '',
  }) {
    final desc = descripcion?.trim().isNotEmpty == true
        ? descripcion!.trim()
        : 'Generación automática con IA.';
    return [
      'Genera un horario con el nombre "$nombre" y descripción "$desc".',
      if (contexto.trim().isNotEmpty)
        'Contexto (IDs disponibles en cada entidad): $contexto',
      'Salida requerida: SOLO JSON válido con claves nombre, descripcion, fechaCreacion, asignaciones.',
      'No incluyas comentarios ni texto fuera del objeto JSON.',
    ].join('\n');
  }

  // Extrae JSON de la respuesta: intenta parsear directo, luego fence, luego delimitadores.
  String _extractJson(String raw) {
    String s = raw.trim();

    // 1) Intento directo
    try {
      json.decode(s);
      return s;
    } catch (_) {}

    // 2) Fences ```json ... ```
    final fenceRegex = RegExp(
      r"```(?:json)?\s*([\s\S]*?)\s*```",
      multiLine: true,
    );
    final fenceMatch = fenceRegex.firstMatch(s);
    if (fenceMatch != null) {
      final fenced = fenceMatch.group(1)!.trim();
      try {
        json.decode(fenced);
        return fenced;
      } catch (_) {}
    }

    // 3) Delimitado por llaves: primera '{' hasta última '}'
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      final candidate = s.substring(start, end + 1);
      try {
        json.decode(candidate);
        return candidate;
      } catch (_) {}
    }

    throw Exception('No se encontró un objeto JSON válido en la respuesta');
  }
}
