import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Supabase obtenida desde variables de entorno
class SupabaseConfig {
  /// URL del proyecto Supabase
  static String get url {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL no está configurada. '
        'Crea un archivo .env con tu URL de Supabase',
      );
    }
    return url;
  }

  /// Llave anónima (pública) de Supabase
  static String get anonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY no está configurada. '
        'Crea un archivo .env con tu llave anónima de Supabase',
      );
    }
    return key;
  }
}
