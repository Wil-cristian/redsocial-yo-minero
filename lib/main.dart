import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routing/app_router.dart';
import 'core/di/locator.dart';
import 'core/supabase/supabase_service.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/theme/theme.dart';
import 'core/theme/colors.dart';
import 'login_page.dart';
import 'main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  
  // Inicializar Supabase
  await SupabaseService.instance.initialize();
  
  // Inicializar el servicio de autenticación
  await SupabaseAuthService.instance.initialize();
  
  // Configurar inyección de dependencias
  setupLocator();
  
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
    return StreamBuilder<AuthState>(
      stream: SupabaseService.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mostrar loading mientras se verifica la autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // Si hay un usuario logueado, mostrar el navigation shell
        if (snapshot.hasData && snapshot.data?.session != null) {
          final userProfile = SupabaseAuthService.instance.currentUserProfile;
          return MainNavigationShell(currentUser: userProfile);
        }
        
        // Si no hay usuario logueado, mostrar login
        return const LoginPage();
      },
    );
  }
}

 
