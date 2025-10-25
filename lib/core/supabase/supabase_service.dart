import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Cliente singleton de Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  bool _initialized = false;

  /// Inicializar Supabase
  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    _initialized = true;
    print('✅ Supabase inicializado correctamente');
  }

  /// Obtener el cliente de Supabase
  SupabaseClient get client {
    if (!_initialized) {
      throw Exception(
        'Supabase no ha sido inicializado. '
        'Llama a SupabaseService.instance.initialize() primero',
      );
    }
    return Supabase.instance.client;
  }
}

/// Shortcut para acceder al cliente de Supabase
SupabaseClient get supabase => SupabaseService.instance.client;
