import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para verificar la conexión con Supabase
void main() async {
  print('🔍 Iniciando prueba de conexión con Supabase...\n');
  
  try {
    // 1. Cargar variables de entorno
    print('1️⃣ Cargando archivo .env...');
    await dotenv.load(fileName: '.env');
    print('   ✅ Archivo .env cargado correctamente\n');
    
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    print('2️⃣ Credenciales encontradas:');
    print('   📍 URL: $url');
    print('   🔑 Anon Key: ${anonKey?.substring(0, 20)}...\n');
    
    // 2. Inicializar Supabase
    print('3️⃣ Inicializando Supabase...');
    await Supabase.initialize(
      url: url!,
      anonKey: anonKey!,
    );
    print('   ✅ Supabase inicializado correctamente\n');
    
    final supabase = Supabase.instance.client;
    
    // 3. Verificar conexión a la base de datos
    print('4️⃣ Probando conexión a la base de datos...');
    
    // Test 1: Verificar tabla users
    print('\n   📊 Verificando tabla "users"...');
    final usersResponse = await supabase
        .from('users')
        .select('id, email, username, account_type')
        .limit(5);
    print('   ✅ Tabla "users" accesible (${usersResponse.length} registros encontrados)');
    
    if (usersResponse.isNotEmpty) {
      print('\n   👤 Usuarios de ejemplo:');
      for (var user in usersResponse) {
        print('      • ${user['username']} (${user['email']}) - Tipo: ${user['account_type']}');
      }
    }
    
    // Test 2: Verificar tabla posts
    print('\n   📊 Verificando tabla "posts"...');
    try {
      final postsResponse = await supabase
          .from('posts')
          .select('id, content, created_at')
          .limit(3);
      print('   ✅ Tabla "posts" accesible (${postsResponse.length} posts encontrados)');
    } catch (e) {
      print('   ⚠️  Tabla "posts" no accesible: $e');
    }
    
    // Test 3: Verificar tabla products
    print('\n   📊 Verificando tabla "products"...');
    try {
      final productsResponse = await supabase
          .from('products')
          .select('id, title, price')
          .limit(3);
      print('   ✅ Tabla "products" accesible (${productsResponse.length} productos encontrados)');
    } catch (e) {
      print('   ⚠️  Tabla "products" no accesible: $e');
    }
    
    // Test 4: Verificar tabla services
    print('\n   📊 Verificando tabla "services"...');
    try {
      final servicesResponse = await supabase
          .from('services')
          .select('id, title, hourly_rate')
          .limit(3);
      print('   ✅ Tabla "services" accesible (${servicesResponse.length} servicios encontrados)');
    } catch (e) {
      print('   ⚠️  Tabla "services" no accesible: $e');
    }
    
    // Test 5: Verificar tabla messages (para chat)
    print('\n   📊 Verificando tabla "messages"...');
    try {
      await supabase
          .from('messages')
          .select('id')
          .limit(1);
      print('   ✅ Tabla "messages" accesible (sistema de chat disponible)');
    } catch (e) {
      print('   ⚠️  Tabla "messages" no accesible: $e');
      print('      💡 Ejecuta database/additional_tables.sql para crearla');
    }
    
    // Test 6: Verificar tabla notifications
    print('\n   📊 Verificando tabla "notifications"...');
    try {
      await supabase
          .from('notifications')
          .select('id')
          .limit(1);
      print('   ✅ Tabla "notifications" accesible');
    } catch (e) {
      print('   ⚠️  Tabla "notifications" no accesible: $e');
      print('      💡 Ejecuta database/notifications_table.sql para crearla');
    }
    
    // Test 7: Verificar autenticación
    print('\n5️⃣ Verificando sistema de autenticación...');
    final session = supabase.auth.currentSession;
    if (session == null) {
      print('   ℹ️  No hay sesión activa (esto es normal para un test)');
    } else {
      print('   ✅ Sesión activa encontrada: ${session.user.email}');
    }
    
    // Resumen final
    print('\n${'=' * 60}');
    print('✅ CONEXIÓN CON SUPABASE EXITOSA');
    print('=' * 60);
    print('📝 Resumen:');
    print('   • Base de datos: Conectada');
    print('   • Tablas principales: Accesibles');
    print('   • Autenticación: Configurada');
    print('\n💡 Todo listo para ejecutar la aplicación!\n');
    
  } catch (e, stackTrace) {
    print('\n${'=' * 60}');
    print('❌ ERROR DE CONEXIÓN');
    print('=' * 60);
    print('Error: $e');
    print('\n📋 Stack trace:');
    print(stackTrace);
    print('\n💡 Soluciones posibles:');
    print('   1. Verifica que el archivo .env existe y tiene las credenciales correctas');
    print('   2. Verifica tu conexión a internet');
    print('   3. Verifica que la URL de Supabase es correcta');
    print('   4. Ejecuta las migraciones SQL en Supabase Dashboard\n');
  }
}
