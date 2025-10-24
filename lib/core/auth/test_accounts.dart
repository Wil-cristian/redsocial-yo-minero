import 'dart:html' as html;
import 'dart:convert';

/// Crear cuentas de prueba para testing - PERMANENTES
void createTestAccounts() {
  // Verificar si ya existen usuarios
  final existingUsers = html.window.localStorage['yominero_registered_users'];
  
  // Solo crear cuentas si no existen usuarios
  if (existingUsers != null && existingUsers.isNotEmpty) {
    print('✅ Cuentas de prueba ya existen en localStorage');
    return;
  }

  print('🔄 Creando cuentas de prueba...');

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

  print('');
  print('✅ ═══════════════════════════════════════════════════════════');
  print('✅ CUENTAS DE PRUEBA CREADAS EXITOSAMENTE');
  print('✅ ═══════════════════════════════════════════════════════════');
  print('');
  print('🏢 EMPRESA (Admin):');
  print('   📧 Email: empresa@test.com');
  print('   🔑 Password: test123');
  print('   👤 Tipo: Company');
  print('   ✓ Puede crear empleados');
  print('');
  print('👷 EMPLEADO TÉCNICO:');
  print('   📧 Email: carlos.tecnico@test.com');
  print('   🔑 Password: test123');
  print('   👤 Rol: Técnico');
  print('   ✓ Ya cambió su contraseña');
  print('   📊 Dashboard limitado (solo tareas)');
  print('');
  print('👔 EMPLEADO CEO - PRIMER LOGIN:');
  print('   📧 Email: maria.gerente@test.com');
  print('   🔑 Password: test123');
  print('   👤 Rol: CEO');
  print('   ⚠️  DEBE CAMBIAR CONTRASEÑA AL INICIAR SESIÓN');
  print('   📊 Dashboard completo (acceso total)');
  print('');
  print('🧑 USUARIO INDIVIDUAL:');
  print('   📧 Email: juan@test.com');
  print('   🔑 Password: test123');
  print('   👤 Tipo: Individual');
  print('');
  print('✅ ═══════════════════════════════════════════════════════════');
}

/// Eliminar cuentas de prueba
void clearTestAccounts() {
  html.window.localStorage.remove('yominero_registered_users');
  html.window.localStorage.remove('password_company_test_001');
  html.window.localStorage.remove('password_employee_test_001');
  html.window.localStorage.remove('password_employee_test_002');
  html.window.localStorage.remove('password_individual_test_001');
  
  print('🗑️  Cuentas de prueba eliminadas');
}

/// Verificar si las cuentas de prueba existen
bool testAccountsExist() {
  final users = html.window.localStorage['yominero_registered_users'];
  return users != null && users.isNotEmpty;
}

/// Mostrar información de las cuentas de prueba
void showTestAccountsInfo() {
  if (!testAccountsExist()) {
    print('❌ No hay cuentas de prueba creadas');
    return;
  }

  final usersJson = html.window.localStorage['yominero_registered_users'];
  if (usersJson == null) return;

  final List<dynamic> users = jsonDecode(usersJson);
  
  print('');
  print('📋 CUENTAS DE PRUEBA DISPONIBLES: ${users.length}');
  print('═══════════════════════════════════════════════════════════');
  
  for (final user in users) {
    print('');
    print('👤 ${user['name']}');
    print('   📧 ${user['email']}');
    print('   🔑 test123');
    print('   📁 ${user['accountType']}');
    if (user['organizationInfo'] != null && user['organizationInfo']['roleId'] != null) {
      print('   👔 ${user['organizationInfo']['roleId']}');
      if (user['mustChangePassword'] == true) {
        print('   ⚠️  Debe cambiar contraseña');
      }
    }
  }
  
  print('');
  print('═══════════════════════════════════════════════════════════');
}

