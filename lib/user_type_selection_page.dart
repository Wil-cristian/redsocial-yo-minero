import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'shared/models/user.dart';
import 'core/auth/authentication_service.dart';
import 'register_page.dart';
import 'main_navigation_shell.dart';

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  AccountType? _selectedType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTypeSelected(AccountType type) {
    setState(() {
      _selectedType = type;
    });
    
    // Mostrar opciones de navegación
    _showNavigationOptions(type);
  }

  void _showNavigationOptions(AccountType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrastre
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              '¿Cómo deseas continuar?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Seleccionaste: ${_getAccountTypeTitle(type)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Opción rápida
            _buildNavigationOption(
              icon: Icons.flash_on,
              title: 'Entrar directamente',
              subtitle: 'Crear perfil básico y empezar a usar la app',
              color: AppColors.primary,
              onTap: () => _quickEntry(type),
            ),
            
            const SizedBox(height: 16),
            
            // Opción completa
            _buildNavigationOption(
              icon: Icons.person_add,
              title: 'Crear cuenta completa',
              subtitle: 'Llenar información detallada del perfil',
              color: AppColors.secondary,
              onTap: () => _fullRegistration(type),
            ),
            
            const SizedBox(height: 16),
            
            // Botón cancelar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _quickEntry(AccountType type) async {
    Navigator.pop(context); // Cerrar el modal
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Crear un usuario básico con datos predeterminados
      final result = await AuthenticationService.instance.register(
        username: 'usuario_${DateTime.now().millisecondsSinceEpoch}',
        email: 'temp_${DateTime.now().millisecondsSinceEpoch}@temp.com',
        password: 'temp123',
        name: 'Usuario ${_getAccountTypeTitle(type)}',
        accountType: type.toString().split('.').last,
      );

      Navigator.pop(context); // Cerrar loading

      if (result.isSuccess && result.userData != null) {
        // Navegar directo al home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationShell(currentUser: result.userData)),
          (route) => false,
        );
      } else {
        _showError('Error al crear perfil básico');
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _showError('Error inesperado: $e');
    }
  }

  void _fullRegistration(AccountType type) {
    Navigator.pop(context); // Cerrar el modal
    
    // Pequeña animación antes de navegar a registro completo
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RegisterPage(accountType: type),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getAccountTypeTitle(AccountType type) {
    switch (type) {
      case AccountType.individual:
        return 'Minero Individual';
      case AccountType.worker:
        return 'Trabajador Minero';
      case AccountType.company:
        return 'Empresa Minera';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.warning,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header con animación
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.account_circle_outlined,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¿Qué tipo de cuenta quieres crear?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Escoge la opción que mejor se adapte a tus necesidades',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Opciones de cuenta con animación
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) => Opacity(
                        opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          _buildAccountTypeCard(
                            type: AccountType.individual,
                            title: 'Individual',
                            subtitle: 'Para mineros independientes y profesionales autónomos',
                            icon: Icons.person,
                            color: const Color(0xFF6C63FF),
                            delay: 0,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Nota: El tipo "worker" solo se crea desde el panel de empresa
                          // _buildAccountTypeCard(
                          //   type: AccountType.worker,
                          //   title: 'Trabajador',
                          //   subtitle: 'Para empleados que trabajan en una empresa',
                          //   icon: Icons.engineering,
                          //   color: const Color(0xFF4ECDC4),
                          //   delay: 200,
                          // ),
                          
                          _buildAccountTypeCard(
                            type: AccountType.company,
                            title: 'Empresa',
                            subtitle: 'Para organizaciones mineras y corporaciones',
                            icon: Icons.business,
                            color: const Color(0xFF45B7D1),
                            delay: 200,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Botón de regresar
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Regresar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required AccountType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    final isSelected = _selectedType == type;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        // Asegurar que el valor esté en el rango válido
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.8 + (0.2 * clampedValue),
          child: Opacity(
            opacity: clampedValue,
            child: GestureDetector(
              onTap: () => _onTypeSelected(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? color
                        : Colors.white.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? color.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected 
                                  ? Colors.grey[600]
                                  : Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                      color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
                      size: isSelected ? 28 : 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}