import 'package:yominero/core/supabase/supabase_service.dart';

/// Utilidad para ejecutar comandos SQL directamente
class SQLExecutor {
  static final _supabase = SupabaseService.instance.client;

  /// Habilita respuestas anidadas en la base de datos
  static Future<void> enableNestedResponses() async {
    print('🔧 Ejecutando SQL para habilitar respuestas anidadas...');
    
    try {
      // Intentar insertar una respuesta de prueba para verificar si la columna existe
      print('🔍 Verificando si la columna parent_response_id existe...');
      
      await _supabase
          .from('post_responses')
          .select('id, parent_response_id')
          .limit(1);
      
      print('✅ Columna parent_response_id ya existe!');
      print('🎉 Sistema de respuestas anidadas ya está habilitado');
      
    } catch (e) {
      if (e.toString().contains('parent_response_id')) {
        print('❌ La columna parent_response_id no existe');
        print('🔧 Intentando crear la columna...');
        await _createNestedResponsesSchema();
      } else {
        print('❌ Error inesperado: $e');
        rethrow;
      }
    }
  }

  /// Crea el schema de respuestas anidadas usando SQL directo
  static Future<void> _createNestedResponsesSchema() async {
    try {
      // Como no tenemos acceso directo al SQL, vamos a usar un enfoque creativo
      // Vamos a intentar hacer la alteración usando el cliente de Supabase
      
      print('⚠️ No puedo ejecutar ALTER TABLE directamente desde Flutter');
      print('📋 EJECUTA MANUALMENTE EN SUPABASE DASHBOARD:');
      print('');
      print('-- Copia y pega esto en el SQL Editor de Supabase:');
      print('ALTER TABLE responses ADD COLUMN parent_response_id UUID REFERENCES responses(id) ON DELETE CASCADE;');
      print('CREATE INDEX IF NOT EXISTS idx_responses_parent_response_id ON responses(parent_response_id);');
      print('');
      print('💡 Después de ejecutar el SQL, la funcionalidad estará completa');
      
    } catch (e) {
      print('❌ Error creando schema: $e');
      rethrow;
    }
  }

  /// Prueba las respuestas anidadas
  static Future<void> testNestedResponses() async {
    print('🧪 Probando respuestas anidadas...');
    
    try {
      // Buscar un post con respuestas
      final posts = await _supabase
          .from('posts')
          .select('id')
          .eq('type', 'question')
          .limit(1);
      
      if (posts.isEmpty) {
        print('❌ No hay posts de tipo pregunta para probar');
        return;
      }
      
      final postId = posts.first['id'];
      print('📍 Usando post: $postId');
      
      // Buscar respuestas en ese post
      final responses = await _supabase
          .from('post_responses')
          .select('id')
          .eq('post_id', postId)
          .limit(1);
      
      if (responses.isEmpty) {
        print('❌ No hay respuestas en el post para probar');
        return;
      }
      
      final parentResponseId = responses.first['id'];
      print('📍 Usando respuesta padre: $parentResponseId');
      
      // Intentar crear respuesta anidada
      final result = await _supabase
          .from('post_responses')
          .insert({
            'post_id': postId,
            'author_id': _supabase.auth.currentUser?.id,
            'content': 'Esta es una respuesta anidada de prueba - ${DateTime.now()}',
            'parent_response_id': parentResponseId,
          })
          .select()
          .single();
      
      print('✅ Respuesta anidada creada: ${result['id']}');
      print('🎉 Sistema de respuestas anidadas funcionando correctamente!');
      
    } catch (e) {
      print('❌ Error en prueba: $e');
      if (e.toString().contains('parent_response_id')) {
        print('💡 La columna parent_response_id no existe todavía');
        print('📋 Ejecuta el SQL manualmente en Supabase Dashboard');
      }
    }
  }
}