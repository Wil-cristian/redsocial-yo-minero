// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Crear cuentas de prueba para testing - PERMANENTES
void createTestAccounts() {
  // Verificar si ya existen usuarios
  final existingUsers = html.window.localStorage['yominero_registered_users'];
  
  // Solo crear cuentas si no existen usuarios
  if (existingUsers != null && existingUsers.isNotEmpty) {
    debugPrint('✅ Cuentas de prueba ya existen en localStorage');
    return;
  }

  debugPrint('🔄 Creando cuentas de prueba...');

  // 1. Crear empresa de prueba
  final testCompany = {
    'id': 'company_test_001',
    'name': 'Minera Test S.A.',
    'username': 'minera_test',
    'email': 'empresa@test.com',
    'accountType': 'company',
    'organizationInfo': {
      'companyName': 'Minera Test S.A.',
      'companyRole': 'owner',
    },
    'bio': 'Empresa minera de prueba',
    'profileImageUrl': null,
    'isVerified': true,
    'followersCount': 150,
    'followingCount': 80,
    'createdAt': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
  };

  // 2. Crear empleado de prueba (Técnico) - Ya cambió contraseña
  final testEmployee = {
    'id': 'employee_test_001',
    'name': 'Carlos Técnico',
    'username': 'carlos_tecnico',
    'email': 'carlos.tecnico@test.com',
    'accountType': 'worker',
    'organizationInfo': {
      'companyId': 'company_test_001',
      'companyName': 'Minera Test S.A.',
      'roleId': 'technician',
      'department': 'Operaciones - Zona Norte',
      'companyRole': 'employee',
    },
    'mustChangePassword': false, // Ya cambió su contraseña
    'bio': 'Técnico operativo en minera',
    'profileImageUrl': null,
    'isVerified': false,
    'followersCount': 45,
    'followingCount': 60,
    'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
  };

  // 3. Crear empleado CEO (debe cambiar contraseña en primer login)
  final testEmployeeCEO = {
    'id': 'employee_test_002',
    'name': 'María Gerente',
    'username': 'maria_gerente',
    'email': 'maria.gerente@test.com',
    'accountType': 'worker',
    'organizationInfo': {
      'companyId': 'company_test_001',
      'companyName': 'Minera Test S.A.',
      'roleId': 'ceo',
      'department': 'Gerencia General',
      'companyRole': 'employee',
    },
    'mustChangePassword': true, // DEBE cambiar contraseña
    'bio': 'CEO de Minera Test',
    'profileImageUrl': null,
    'isVerified': true,
    'followersCount': 200,
    'followingCount': 50,
    'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
  };

  // 4. Crear usuario individual de prueba
  final testIndividual = {
    'id': 'individual_test_001',
    'name': 'Juan Minero',
    'username': 'juan_minero',
    'email': 'juan@test.com',
    'accountType': 'individual',
    'organizationInfo': null,
    'bio': 'Minero independiente',
    'profileImageUrl': null,
    'isVerified': false,
    'followersCount': 85,
    'followingCount': 120,
    'createdAt': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
  };

  // Guardar todos los usuarios en localStorage
  final users = [testCompany, testEmployee, testEmployeeCEO, testIndividual];
  html.window.localStorage['yominero_registered_users'] = jsonEncode(users);

  // Guardar contraseñas (todas son "test123" para facilitar testing)
  final testPassword = base64Encode(utf8.encode('test123salt_yominero'));
  html.window.localStorage['password_company_test_001'] = testPassword;
  html.window.localStorage['password_employee_test_001'] = testPassword;
  html.window.localStorage['password_employee_test_002'] = testPassword;
  html.window.localStorage['password_individual_test_001'] = testPassword;

  debugPrint('');
  debugPrint('✅ ═══════════════════════════════════════════════════════════');
  debugPrint('✅ CUENTAS DE PRUEBA CREADAS EXITOSAMENTE');
  debugPrint('✅ ═══════════════════════════════════════════════════════════');
  debugPrint('');
  debugPrint('🏢 EMPRESA (Admin):');
  debugPrint('   📧 Email: empresa@test.com');
  debugPrint('   🔑 Password: test123');
  debugPrint('   👤 Tipo: Company');
  debugPrint('   ✓ Puede crear empleados');
  debugPrint('');
  debugPrint('👷 EMPLEADO TÉCNICO:');
  debugPrint('   📧 Email: carlos.tecnico@test.com');
  debugPrint('   🔑 Password: test123');
  debugPrint('   👤 Rol: Técnico');
  debugPrint('   ✓ Ya cambió su contraseña');
  debugPrint('   📊 Dashboard limitado (solo tareas)');
  debugPrint('');
  debugPrint('👔 EMPLEADO CEO - PRIMER LOGIN:');
  debugPrint('   📧 Email: maria.gerente@test.com');
  debugPrint('   🔑 Password: test123');
  debugPrint('   👤 Rol: CEO');
  debugPrint('   ⚠️  DEBE CAMBIAR CONTRASEÑA AL INICIAR SESIÓN');
  debugPrint('   📊 Dashboard completo (acceso total)');
  debugPrint('');
  debugPrint('🧑 USUARIO INDIVIDUAL:');
  debugPrint('   📧 Email: juan@test.com');
  debugPrint('   🔑 Password: test123');
  debugPrint('   👤 Tipo: Individual');
  debugPrint('');
  debugPrint('✅ ═══════════════════════════════════════════════════════════');
}

/// Eliminar cuentas de prueba
void clearTestAccounts() {
  html.window.localStorage.remove('yominero_registered_users');
  html.window.localStorage.remove('password_company_test_001');
  html.window.localStorage.remove('password_employee_test_001');
  html.window.localStorage.remove('password_employee_test_002');
  html.window.localStorage.remove('password_individual_test_001');
  
  debugPrint('🗑️  Cuentas de prueba eliminadas');
}

/// Verificar si las cuentas de prueba existen
bool testAccountsExist() {
  final users = html.window.localStorage['yominero_registered_users'];
  return users != null && users.isNotEmpty;
}

/// Mostrar información de las cuentas de prueba
void showTestAccountsInfo() {
  if (!testAccountsExist()) {
    debugPrint('❌ No hay cuentas de prueba creadas');
    return;
  }

  final usersJson = html.window.localStorage['yominero_registered_users'];
  if (usersJson == null) return;

  final List<dynamic> users = jsonDecode(usersJson);
  
  debugPrint('');
  debugPrint('📋 CUENTAS DE PRUEBA DISPONIBLES: ${users.length}');
  debugPrint('═══════════════════════════════════════════════════════════');
  
  for (final user in users) {
    debugPrint('');
    debugPrint('👤 ${user['name']}');
    debugPrint('   📧 ${user['email']}');
    debugPrint('   🔑 test123');
    debugPrint('   📁 ${user['accountType']}');
    if (user['organizationInfo'] != null && user['organizationInfo']['roleId'] != null) {
      debugPrint('   👔 ${user['organizationInfo']['roleId']}');
      if (user['mustChangePassword'] == true) {
        debugPrint('   ⚠️  Debe cambiar contraseña');
      }
    }
  }
  
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════════════');
}

