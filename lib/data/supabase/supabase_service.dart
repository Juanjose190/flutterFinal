import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  /// Returns null when configuration is valid; otherwise a description of the issue.
  String? get validationError {
    final rawUrl = dotenv.maybeGet('SUPABASE_URL');
    final rawAnon = dotenv.maybeGet('SUPABASE_ANON_KEY');
    final url = rawUrl?.trim();
    final anon = rawAnon?.trim();
    if (url == null || url.isEmpty) return 'Missing SUPABASE_URL';
    if (anon == null || anon.isEmpty) return 'Missing SUPABASE_ANON_KEY';
    if (!url.startsWith('https://') || !url.contains('.supabase.co')) {
      return 'Invalid SUPABASE_URL; expected https://<project-ref>.supabase.co';
    }
    return null;
  }

  bool get isReady => validationError == null;
}
