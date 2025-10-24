import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/di/locator.dart';
import 'core/auth/authentication_service.dart';
import 'core/auth/test_accounts.dart';
import 'core/theme/theme.dart';
import 'login_page.dart';
import 'main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  
  // Inicializar el servicio de autenticación
  await AuthenticationService.instance.initialize();
  
  // TESTING: Crear cuentas de prueba (comentar en producción)
  createTestAccounts();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YoMinero App',
      theme: yoMineroTheme,
      onGenerateRoute: onGenerateRoute,
      home: const AuthWrapper(),
    );
  }
}

/// Widget que determina qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthenticationService.instance.currentUser != null
          ? Future.value(AuthenticationService.instance.currentUser)
          : null,
      builder: (context, snapshot) {
        // Si hay un usuario logueado, mostrar el navigation shell con todas las pantallas
        if (AuthenticationService.instance.isLoggedIn) {
          return MainNavigationShell(currentUser: AuthenticationService.instance.currentUser);
        }
        
        // Si no hay usuario logueado, mostrar login
        return const LoginPage();
      },
    );
  }
}

 
