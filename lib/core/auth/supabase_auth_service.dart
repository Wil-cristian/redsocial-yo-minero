import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_service.dart';

/// Servicio de autenticación usando Supabase
/// Reemplaza el AuthenticationService anterior basado en localStorage
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._();
  static SupabaseAuthService get instance => _instance;
  
  SupabaseAuthService._();

  /// Cliente de Supabase
  SupabaseClient get _supabase => supabase;

  /// Usuario actual
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Datos del perfil del usuario actual (desde tabla users)
  Map<String, dynamic>? _currentUserProfile;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;

  /// Inicializar el servicio y cargar sesión existente
  Future<void> initialize() async {
    // Verificar si hay una sesión activa
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id);
    }

    // Escuchar cambios en la autenticación
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _loadUserProfile(data.session!.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUserProfile = null;
      }
    });
  }

  /// Cargar perfil del usuario desde la tabla users
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      _currentUserProfile = profile;
      print('✅ Perfil cargado: ${profile['name']}');
    } catch (e) {
      print('⚠️ Error al cargar perfil: $e');
      _currentUserProfile = null;
    }
  }

  /// Registrar un nuevo usuario
  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String accountType,
    String? organizationName,
  }) async {
    try {
      // 1. Crear usuario en Supabase Auth (sin verificación de email)
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Sin redirect de confirmación
        data: {'email_confirmed': true}, // Marcar como confirmado inmediatamente
      );

      if (authResponse.user == null) {
        return AuthResult.error('Error al crear usuario');
      }

      // 2. Crear información de organización si aplica
      Map<String, dynamic> orgInfo = {};
      if (accountType == 'company' && organizationName != null) {
        orgInfo = {
          'companyName': organizationName,
          'companyRole': 'owner',
        };
      } else if (accountType == 'worker' && organizationName != null) {
        orgInfo = {
          'companyName': organizationName,
          'companyRole': 'employee',
        };
      }

      // 3. Crear perfil en tabla users
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'username': username,
        'name': name,
        'account_type': accountType,
        'organization_info': orgInfo,
        'bio': '',
        'profile_image_url': null,
        'is_verified': false,
        'followers_count': 0,
        'following_count': 0,
      };

      await _supabase.from('users').insert(userData);

      // 4. Cargar perfil
      await _loadUserProfile(authResponse.user!.id);

      return AuthResult.success(_currentUserProfile!);
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error en el registro: ${e.toString()}');
    }
  }

  /// Iniciar sesión
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login en Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Credenciales inválidas');
      }

      // 2. Cargar perfil del usuario
      await _loadUserProfile(response.user!.id);

      // 3. Si no existe el perfil en la tabla users, crearlo automáticamente
      if (_currentUserProfile == null) {
        print('⚠️ Usuario sin perfil en tabla users, creando...');
        try {
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'name': email.split('@')[0], // Nombre temporal del email
            'username': email.split('@')[0],
            'account_type': 'individual',
            'organization_info': {},
            'bio': '',
            'must_change_password': false,
          });
          
          // Recargar perfil después de crearlo
          await _loadUserProfile(response.user!.id);
          print('✅ Perfil creado automáticamente');
        } catch (e) {
          print('❌ Error al crear perfil: $e');
          return AuthResult.error('Error al crear perfil de usuario');
        }
      }

      if (_currentUserProfile == null) {
        return AuthResult.error('Error al cargar datos del usuario');
      }

      return AuthResult.success(_currentUserProfile!);
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUserProfile = null;
  }

  /// Actualizar información del usuario actual
  Future<AuthResult> updateCurrentUser(Map<String, dynamic> updates) async {
    if (currentUser == null) {
      return AuthResult.error('No hay usuario logueado');
    }

    try {
      // Actualizar en la tabla users
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', currentUser!.id);

      // Recargar perfil
      await _loadUserProfile(currentUser!.id);

      return AuthResult.success(_currentUserProfile!);
    } catch (e) {
      return AuthResult.error('Error al actualizar: ${e.toString()}');
    }
  }

  /// Cambiar contraseña
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentUser == null) {
      return AuthResult.error('No hay usuario logueado');
    }

    try {
      // Supabase requiere reautenticación para cambiar contraseña
      // Primero verificamos que la contraseña actual sea correcta
      await _supabase.auth.signInWithPassword(
        email: currentUser!.email!,
        password: currentPassword,
      );

      // Cambiar contraseña
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Si el usuario debe cambiar contraseña, actualizar el flag
      if (_currentUserProfile?['must_change_password'] == true) {
        await _supabase
            .from('users')
            .update({'must_change_password': false})
            .eq('id', currentUser!.id);

        await _loadUserProfile(currentUser!.id);
      }

      return AuthResult.success(_currentUserProfile!);
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  /// Crear credenciales de empleado (solo para empresas)
  Future<AuthResult> createEmployeeCredentials({
    required String companyId,
    required String employeeName,
    required String employeeEmail,
    required String tempPassword,
    required String roleId,
    String? department,
  }) async {
    try {
      // 1. Crear usuario en Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: employeeEmail,
        password: tempPassword,
      );

      if (authResponse.user == null) {
        return AuthResult.error('Error al crear empleado');
      }

      // 2. Crear perfil del empleado en tabla users
      final employeeData = {
        'id': authResponse.user!.id,
        'email': employeeEmail,
        'username': employeeEmail.split('@')[0],
        'name': employeeName,
        'account_type': 'worker',
        'organization_info': {
          'companyId': companyId,
          'roleId': roleId,
          'department': department,
          'companyRole': 'employee',
        },
        'must_change_password': true, // Forzar cambio de contraseña
        'bio': '',
        'profile_image_url': null,
        'is_verified': false,
        'followers_count': 0,
        'following_count': 0,
      };

      await _supabase.from('users').insert(employeeData);

      return AuthResult.success(employeeData);
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return AuthResult.error('El email ya está registrado');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error al crear empleado: ${e.toString()}');
    }
  }

  /// Verificar si un email está disponible
  Future<bool> isEmailAvailable(String email) async {
    try {
      final result = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return result == null;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si un username está disponible
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final result = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      
      return result == null;
    } catch (e) {
      return false;
    }
  }
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? userData;

  AuthResult._(this.isSuccess, this.errorMessage, this.userData);

  factory AuthResult.success(Map<String, dynamic> userData) => 
      AuthResult._(true, null, userData);
  
  factory AuthResult.error(String message) => 
      AuthResult._(false, message, null);
}
