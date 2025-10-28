import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  static Uri uri(String path) {
    return Uri.parse('$baseUrl$path');
  }
}
