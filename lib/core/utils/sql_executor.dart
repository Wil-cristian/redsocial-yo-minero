import 'package:supabase_flutter/supabase_flutter.dart';

/// Herramienta para ejecutar scripts SQL en Supabase
class SQLExecutor {
  static final _supabase = Supabase.instance.client;

  /// Ejecuta el script para agregar soporte de respuestas anidadas
  static Future<void> enableNestedResponses() async {
    try {
      print('🔧 Ejecutando script para habilitar respuestas anidadas...');
      
      // 1. Agregar columna parent_response_id
      await _supabase.rpc('exec_sql', params: {
        'query': '''
          ALTER TABLE responses 
          ADD COLUMN IF NOT EXISTS parent_response_id UUID 
          REFERENCES responses(id) ON DELETE CASCADE;
        '''
      });
      print('✅ Columna parent_response_id agregada');

      // 2. Crear índices
      await _supabase.rpc('exec_sql', params: {
        'query': '''
          CREATE INDEX IF NOT EXISTS idx_responses_parent_response_id 
          ON responses(parent_response_id);
        '''
      });
      print('✅ Índice para parent_response_id creado');

      await _supabase.rpc('exec_sql', params: {
        'query': '''
          CREATE INDEX IF NOT EXISTS idx_responses_post_parent 
          ON responses(post_id, parent_response_id);
        '''
      });
      print('✅ Índice compuesto creado');

      print('🎉 Respuestas anidadas habilitadas exitosamente');
    } catch (e) {
      print('❌ Error ejecutando script SQL: $e');
      
      // Fallback: Intentar con método alternativo
      try {
        print('🔄 Intentando método alternativo...');
        await _alternativeMethod();
      } catch (e2) {
        print('❌ Error en método alternativo: $e2');
      }
    }
  }

  static Future<void> _alternativeMethod() async {
    // Intentar crear directamente en la tabla
    try {
      await _supabase
          .from('responses')
          .select('parent_response_id')
          .limit(1);
      print('✅ Columna parent_response_id ya existe');
    } catch (e) {
      print('ℹ️ Columna parent_response_id no existe, el schema debe ser actualizado manualmente');
      throw Exception('Schema de BD debe ser actualizado manualmente en Supabase Dashboard');
    }
  }

  /// Prueba la funcionalidad de respuestas anidadas
  static Future<void> testNestedResponses() async {
    try {
      print('🧪 Probando funcionalidad de respuestas anidadas...');
      
      // Intentar insertar una respuesta anidada de prueba
      final result = await _supabase
          .from('responses')
          .insert({
            'post_id': 'test-post-id',
            'author_id': _supabase.auth.currentUser?.id,
            'content': 'Respuesta de prueba anidada',
            'parent_response_id': 'test-parent-id',
          })
          .select()
          .single();
      
      print('✅ Respuesta anidada creada exitosamente: ${result['id']}');
      
      // Limpiar respuesta de prueba
      await _supabase
          .from('responses')
          .delete()
          .eq('id', result['id']);
      
      print('✅ Prueba completada y limpiada');
    } catch (e) {
      if (e.toString().contains('parent_response_id')) {
        print('ℹ️ Columna parent_response_id no existe en el schema');
        print('💡 Ejecuta el SQL manualmente en Supabase Dashboard:');
        print('ALTER TABLE responses ADD COLUMN parent_response_id UUID REFERENCES responses(id) ON DELETE CASCADE;');
      } else {
        print('❌ Error en prueba: $e');
      }
    }
  }
}