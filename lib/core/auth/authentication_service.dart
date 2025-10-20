import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'user_storage_service.dart';

/// Servicio de autenticación simplificado con JSON
class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._();
  static AuthenticationService get instance => _instance;
  
  AuthenticationService._();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inicializar el servicio y cargar sesión existente
  Future<void> initialize() async {
    _currentUser = await UserStorageService.getCurrentUserSession();
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
      // Validar si el email ya existe
      final existingUser = await UserStorageService.findUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.error('Email ya está registrado');
      }
      
      // Validar si el username ya existe
      final existingUsername = await UserStorageService.findUserByUsername(username);
      if (existingUsername != null) {
        return AuthResult.error('Username ya está registrado');
      }
      
      // Crear información de organización si es empresa o trabajador
      Map<String, dynamic>? orgInfo;
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
      
      // Crear nuevo usuario
      final userData = {
        'id': _generateUserId(),
        'name': name,
        'username': username,
        'email': email,
        'accountType': accountType,
        'organizationInfo': orgInfo,
        'bio': '',
        'profileImageUrl': null,
        'isVerified': false,
        'followersCount': 0,
        'followingCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Guardar usuario
      final success = await UserStorageService.saveUser(userData);
      if (!success) {
        return AuthResult.error('Error al guardar el usuario');
      }
      
      // Guardar contraseña hasheada
      await _savePasswordHash(userData['id'] as String, password);
      
      // Establecer como usuario actual y guardar sesión
      _currentUser = userData;
      await UserStorageService.saveCurrentUserSession(userData);
      
      return AuthResult.success(userData);
    } catch (e) {
      return AuthResult.error('Error en el registro: ${e.toString()}');
    }
  }

  /// Iniciar sesión
  Future<AuthResult> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      // Buscar usuario por email o username
      Map<String, dynamic>? userData = await UserStorageService.findUserByEmail(emailOrUsername);
      userData ??= await UserStorageService.findUserByUsername(emailOrUsername);
      
      if (userData == null) {
        return AuthResult.error('Usuario no encontrado');
      }
      
      // Verificar contraseña
      final isValid = await _verifyPassword(userData['id'] as String, password);
      if (!isValid) {
        return AuthResult.error('Contraseña incorrecta');
      }
      
      // Establecer como usuario actual y guardar sesión
      _currentUser = userData;
      await UserStorageService.saveCurrentUserSession(userData);
      
      return AuthResult.success(userData);
    } catch (e) {
      return AuthResult.error('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _currentUser = null;
    await UserStorageService.clearCurrentUserSession();
  }

  /// Actualizar información del usuario actual
  Future<AuthResult> updateCurrentUser(Map<String, dynamic> updatedUserData) async {
    if (_currentUser == null) {
      return AuthResult.error('No hay usuario logueado');
    }
    
    try {
      // Actualizar datos locales
      _currentUser!.addAll(updatedUserData);
      
      // Guardar en storage
      final success = await UserStorageService.updateUser(_currentUser!);
      if (!success) {
        return AuthResult.error('Error al actualizar usuario');
      }
      
      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.error('Error al actualizar: ${e.toString()}');
    }
  }

  /// Cambiar contraseña
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return AuthResult.error('No hay usuario logueado');
    }
    
    try {
      // Verificar contraseña actual
      final isValid = await _verifyPassword(_currentUser!['id'] as String, currentPassword);
      if (!isValid) {
        return AuthResult.error('Contraseña actual incorrecta');
      }
      
      // Guardar nueva contraseña
      await _savePasswordHash(_currentUser!['id'] as String, newPassword);
      
      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.error('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  /// Verificar si un email está disponible
  Future<bool> isEmailAvailable(String email) async {
    final user = await UserStorageService.findUserByEmail(email);
    return user == null;
  }

  /// Verificar si un username está disponible
  Future<bool> isUsernameAvailable(String username) async {
    final user = await UserStorageService.findUserByUsername(username);
    return user == null;
  }

  // Métodos privados

  /// Generar ID único para usuario
  String _generateUserId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Guardar hash de contraseña
  Future<void> _savePasswordHash(String userId, String password) async {
    final hashedPassword = _hashPassword(password);
    html.window.localStorage['password_$userId'] = hashedPassword;
  }

  /// Verificar contraseña
  Future<bool> _verifyPassword(String userId, String password) async {
    final storedHash = html.window.localStorage['password_$userId'];
    if (storedHash == null) return false;
    
    final hashedPassword = _hashPassword(password);
    return storedHash == hashedPassword;
  }

  /// Hash simple de contraseña (para demo)
  String _hashPassword(String password) {
    return base64Encode(utf8.encode(password + 'salt_yominero'));
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