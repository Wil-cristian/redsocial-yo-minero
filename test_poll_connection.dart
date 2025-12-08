import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script de diagnóstico para verificar encuestas
/// Ejecutar: dart run test_poll_connection.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase (usar tus credenciales del .env)
  await Supabase.initialize(
    url: 'TU_SUPABASE_URL',
    anonKey: 'TU_SUPABASE_ANON_KEY',
  );

  final supabase = Supabase.instance.client;

  print('🔍 DIAGNÓSTICO DE ENCUESTAS\n');

  // Test 1: Verificar si existe la tabla poll_votes
  print('📋 Test 1: Verificando tabla poll_votes...');
  try {
    final result = await supabase.from('poll_votes').select('id').limit(1);
    print('✅ Tabla poll_votes existe y es accesible');
    print('   Registros de muestra: ${result.length}');
  } catch (e) {
    print('❌ ERROR: Tabla poll_votes no existe o no es accesible');
    print('   $e');
    print('   👉 SOLUCIÓN: Ejecutar database/create_poll_votes_table.sql');
  }

  print('');

  // Test 2: Verificar encuestas existentes
  print('📊 Test 2: Buscando posts de tipo poll...');
  try {
    final polls = await supabase
        .from('posts')
        .select('id, title, poll_options, poll_ends_at, created_at')
        .eq('post_type', 'poll')
        .order('created_at', ascending: false)
        .limit(5);
    
    if (polls.isEmpty) {
      print('⚠️  No hay encuestas en la base de datos');
      print('   👉 SOLUCIÓN: Crear encuestas de prueba con database/insert_test_polls.sql');
    } else {
      print('✅ Encontradas ${polls.length} encuestas:');
      for (var poll in polls) {
        print('');
        print('   📝 ${poll['title']}');
        print('      ID: ${poll['id']}');
        print('      Opciones: ${poll['poll_options']}');
        
        final endsAt = poll['poll_ends_at'];
        if (endsAt != null) {
          final endDate = DateTime.parse(endsAt);
          final isExpired = DateTime.now().isAfter(endDate);
          print('      Termina: $endsAt ${isExpired ? '⏰ EXPIRADA' : '✅ ACTIVA'}');
        } else {
          print('      Termina: Sin fecha límite');
        }
      }
    }
  } catch (e) {
    print('❌ ERROR al buscar encuestas: $e');
  }

  print('');

  // Test 3: Verificar votos existentes
  print('🗳️  Test 3: Verificando votos registrados...');
  try {
    final votes = await supabase
        .from('poll_votes')
        .select('poll_id, selected_option')
        .limit(10);
    
    print('✅ Total de votos registrados: ${votes.length}');
    
    if (votes.isNotEmpty) {
      // Agrupar por poll
      final Map<String, int> votesByPoll = {};
      for (var vote in votes) {
        final pollId = vote['poll_id'] as String;
        votesByPoll[pollId] = (votesByPoll[pollId] ?? 0) + 1;
      }
      
      print('   Distribución por encuesta:');
      for (var entry in votesByPoll.entries) {
        print('   - Poll ${entry.key.substring(0, 8)}...: ${entry.value} votos');
      }
    }
  } catch (e) {
    print('❌ ERROR al verificar votos: $e');
  }

  print('');

  // Test 4: Verificar políticas RLS
  print('🔒 Test 4: Verificando políticas RLS...');
  try {
    // Intentar leer sin autenticación
    final result = await supabase.from('poll_votes').select().limit(1);
    print('✅ RLS permite lectura pública (correcto para contar votos)');
  } catch (e) {
    if (e.toString().contains('policy')) {
      print('⚠️  RLS está bloqueando lecturas públicas');
      print('   👉 SOLUCIÓN: Revisar política "Cualquiera puede ver votos"');
    } else {
      print('❌ ERROR: $e');
    }
  }

  print('\n═══════════════════════════════════════');
  print('✅ Diagnóstico completado');
  print('═══════════════════════════════════════\n');
}
