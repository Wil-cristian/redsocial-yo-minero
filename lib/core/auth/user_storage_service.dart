import 'dart:convert';
import 'dart:html' as html;

/// Servicio para almacenamiento local de usuarios registrados (versión simplificada)
class UserStorageService {
  static const String _usersKey = 'yominero_registered_users';
  static const String _currentUserKey = 'yominero_current_user';

  /// Guardar un nuevo usuario registrado
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final usersData = html.window.localStorage[_usersKey];
      List<dynamic> users = [];
      
      if (usersData != null) {
        users = jsonDecode(usersData);
      }
      
      // Verificar si el usuario ya existe
      final email = userData['email'];
      final username = userData['username'];
      
      for (final existingUser in users) {
        if (existingUser['email'] == email || existingUser['username'] == username) {
          return false; // Usuario ya existe
        }
      }
      
      users.add(userData);
      html.window.localStorage[_usersKey] = jsonEncode(users);
      
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  /// Obtener todos los usuarios registrados
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersData = html.window.localStorage[_usersKey];
      if (usersData == null) return [];
      
      final List<dynamic> usersJson = jsonDecode(usersData);
      return List<Map<String, dynamic>>.from(usersJson);
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  /// Buscar usuario por email
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  /// Buscar usuario por username
  static Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user['username'] == username);
    } catch (e) {
      return null;
    }
  }

  /// Guardar sesión del usuario actual
  static Future<void> saveCurrentUserSession(Map<String, dynamic> userData) async {
    try {
      html.window.localStorage[_currentUserKey] = jsonEncode(userData);
    } catch (e) {
      print('Error saving current user session: $e');
    }
  }

  /// Obtener sesión del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUserSession() async {
    try {
      final userData = html.window.localStorage[_currentUserKey];
      if (userData == null) return null;
      
      return Map<String, dynamic>.from(jsonDecode(userData));
    } catch (e) {
      print('Error loading current user session: $e');
      return null;
    }
  }

  /// Limpiar sesión actual
  static Future<void> clearCurrentUserSession() async {
    html.window.localStorage.remove(_currentUserKey);
  }

  /// Actualizar información de usuario existente
  static Future<bool> updateUser(Map<String, dynamic> updatedUserData) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u['id'] == updatedUserData['id']);
      
      if (index == -1) return false;
      
      users[index] = updatedUserData;
      html.window.localStorage[_usersKey] = jsonEncode(users);
      
      // Si es el usuario actual, actualizar la sesión también
      final currentUser = await getCurrentUserSession();
      if (currentUser?['id'] == updatedUserData['id']) {
        await saveCurrentUserSession(updatedUserData);
      }
      
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Eliminar todos los datos (para desarrollo/testing)
  static Future<void> clearAllData() async {
    html.window.localStorage.remove(_usersKey);
    html.window.localStorage.remove(_currentUserKey);
  }

  /// Verificar si un email ya está registrado
  static Future<bool> isEmailTaken(String email) async {
    final user = await findUserByEmail(email);
    return user != null;
  }

  /// Verificar si un username ya está registrado
  static Future<bool> isUsernameTaken(String username) async {
    final user = await findUserByUsername(username);
    return user != null;
  }
}