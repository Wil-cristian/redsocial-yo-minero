import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para verificar y configurar el sistema de mensajería en Supabase
Future<void> setupMessagingSystem() async {
  final supabase = Supabase.instance.client;
  
  print('🔧 Iniciando configuración del sistema de mensajería...\n');
  
  try {
    // 1. Verificar que las tablas existen
    print('📋 Verificando tablas...');
    
    final conversationsCheck = await supabase
        .from('conversations')
        .select('id')
        .limit(1);
    print('✅ Tabla conversations: OK');
    
    final messagesCheck = await supabase
        .from('messages')
        .select('id')
        .limit(1);
    print('✅ Tabla messages: OK\n');
    
    // 2. Verificar usuarios de prueba
    print('👥 Verificando usuarios de prueba...');
    
    final users = await supabase
        .from('users')
        .select('id, email, name, account_type')
        .inFilter('email', ['empresa@test.com', 'wil@test.com', 'juan@test.com']);
    
    print('Usuarios encontrados:');
    for (var user in users) {
      print('  - ${user['name']} (${user['email']}) - ${user['account_type']}');
    }
    print('');
    
    if (users.length < 2) {
      print('⚠️  Necesitas al menos 2 usuarios para probar el chat');
      print('   Ejecuta create_test_users.sql en Supabase SQL Editor\n');
      return;
    }
    
    // 3. Verificar conversaciones existentes
    print('💬 Verificando conversaciones...');
    final convCount = await supabase
        .from('conversations')
        .select('id')
        .count(CountOption.exact);
    print('   Total de conversaciones: $convCount\n');
    
    // 4. Verificar mensajes existentes
    print('📨 Verificando mensajes...');
    final msgCount = await supabase
        .from('messages')
        .select('id')
        .count(CountOption.exact);
    print('   Total de mensajes: $msgCount\n');
    
    print('✅ Sistema de mensajería configurado correctamente!');
    print('\n📱 Puedes usar la app para chatear entre:');
    for (var user in users) {
      print('   - ${user['name']} (${user['email']})');
    }
    
  } catch (e) {
    print('❌ Error durante la configuración:');
    print('   $e\n');
    print('🔧 Solución:');
    print('   1. Abre Supabase Dashboard');
    print('   2. Ve a SQL Editor');
    print('   3. Ejecuta: database/setup_messaging_complete.sql');
    print('   4. Ejecuta: database/create_test_users.sql\n');
  }
}

void main() async {
  // Inicializar Supabase (usa tu URL y anon key)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  await setupMessagingSystem();
}
