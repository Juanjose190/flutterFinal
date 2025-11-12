import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/schedule.dart';

class GeminiService {
  late GenerativeModel _model;
  late final String _apiKey;
  late final List<String> _fallbackModels;
  late String _currentModelName;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Missing GEMINI_API_KEY in .env');
    }

    final configuredModel = dotenv.env['GEMINI_MODEL']?.trim();
    _fallbackModels = [
      if (configuredModel != null && configuredModel.isNotEmpty)
        configuredModel,
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
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
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<List<Schedule>> generateSchedulesFromContext({
    required List<Map<String, dynamic>> teachers,
    required List<Map<String, dynamic>> subjects,
    required List<Map<String, dynamic>> classrooms,
  }) async {
    final system = _buildSystemInstructions();
    final user = _buildUserPrompt(
      teachers: teachers,
      subjects: subjects,
      classrooms: classrooms,
    );
    final combinedPrompt = [system, user].join('\n\n');

    GenerateContentResponse? response;
    try {
      response = await _model.generateContent([Content.text(combinedPrompt)]);
    } catch (e) {
      final err = e.toString();
      final needsFallback =
          err.contains('not found') ||
          err.contains('is not supported') ||
          err.contains('ListModels') ||
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
          break;
        } catch (err) {
          lastError = err;
          continue;
        }
      }
      if (response == null) {
        throw lastError;
      }
    }

    final jsonStr = _jsonFromResponse(response).trim();
    if (jsonStr.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    final clean = _extractJson(jsonStr);
    final decoded = json.decode(clean);
    if (decoded is! List) {
      throw Exception('Expected JSON array of schedules');
    }
    final list = decoded.cast<Map<String, dynamic>>();
    return list.map((m) => Schedule.fromMap(m)).toList();
  }

  String _jsonFromResponse(GenerateContentResponse response) {
    for (final cand in response.candidates) {
      final parts = cand.content.parts;
      for (final part in parts) {
        if (part is DataPart) {
          final mt = part.mimeType.toLowerCase();
          if (mt.contains('json')) {
            final bytes = part.bytes;
            if (bytes.isNotEmpty) return utf8.decode(bytes);
          }
        }
        if (part is TextPart) {
          final t = part.text.trim();
          if (t.isNotEmpty) return t;
        }
      }
    }
    return response.text ?? '';
  }

  String _buildSystemInstructions() {
    return [
      'You design academic schedules. Output valid JSON only (no extra text).',
      'Use exclusively the provided IDs for teacher_id, subject_id, classroom_id.',
      'Return an array of schedule objects with fields: id, teacher_id, subject_id, classroom_id, date (ISO8601), notes.',
    ].join('\n');
  }

  String _buildUserPrompt({
    required List<Map<String, dynamic>> teachers,
    required List<Map<String, dynamic>> subjects,
    required List<Map<String, dynamic>> classrooms,
  }) {
    return [
      'Context:',
      'teachers: ${jsonEncode(teachers)}',
      'subjects: ${jsonEncode(subjects)}',
      'classrooms: ${jsonEncode(classrooms)}',
      'Task: Propose feasible schedules using only the given IDs. Avoid overlaps; prefer special classrooms for special subjects. Generate 3-8 suggestions.',
      'Output: JSON array of {id, teacher_id, subject_id, classroom_id, date, notes}',
    ].join('\n');
  }

  String _extractJson(String raw) {
    // If fenced or mixed content, try to extract the JSON object/array.
    final start = raw.indexOf('{');
    final altStart = raw.indexOf('[');
    int s = -1;
    bool isArray = false;
    if (start == -1 && altStart == -1) return raw;
    if (altStart != -1 && (start == -1 || altStart < start)) {
      s = altStart;
      isArray = true;
    } else {
      s = start;
    }
    // naive bracket matching to find the end
    int depth = 0;
    int i = s;
    final endChar = isArray ? ']' : '}';
    for (; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == (isArray ? '[' : '{')) depth++;
      if (ch == endChar) {
        depth--;
        if (depth == 0) {
          return raw.substring(s, i + 1);
        }
      }
    }
    return raw.substring(s);
  }
}
