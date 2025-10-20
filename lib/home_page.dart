import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/auth/authentication_service.dart';
import 'products_page.dart';
import 'services_page.dart';
import 'community_page.dart';
import 'groups_page.dart';
import 'profile_page.dart';
import 'messages_page.dart';
import 'login_page.dart';

/// Home adaptativo que muestra diferentes interfaces según el tipo de usuario.
/// - Individual: Dashboard personal con proyectos y oportunidades
/// - Trabajador: Panel de empleado con tareas y empresa
/// - Empresa: Panel de gestión con empleados y métricas
class HomePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser; // Usuario actualmente logueado

  const HomePage({
    super.key,
    this.currentUser,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    

    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay usuario, mostrar dashboard individual por defecto
    if (widget.currentUser == null) {
      return _buildIndividualDashboard(context);
    }
    
    // Mostrar interfaz específica según el tipo de usuario
    final accountType = widget.currentUser!['accountType'] as String;
    switch (accountType) {
      case 'individual':
        return _buildIndividualDashboard(context);
      case 'worker':
        return _buildWorkerDashboard(context);
      case 'company':
        return _buildCompanyDashboard(context);
      default:
        return _buildIndividualDashboard(context);
    }
  }

  /// Dashboard para usuarios individuales (mineros independientes)
  Widget _buildIndividualDashboard(BuildContext context) {
    final user = widget.currentUser;
    final userName = user?['name'] ?? 'Usuario';
    final accountType = user?['accountType'] ?? 'individual';
    final userTypeInfo = _getUserTypeInfo(accountType);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('¡Hola, $userName!'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => _openMessages(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showUserProfile(context);
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    const Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    const Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de bienvenida personalizada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52E3)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          userTypeInfo['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userTypeInfo['title'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chip del tipo de usuario
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userTypeInfo['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userTypeInfo['description'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Secciones de funcionalidades
            Text(
              'Oportunidades',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Grid de funcionalidades
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  'Proyectos',
                  Icons.construction,
                  const Color(0xFF4ECDC4),
                  'Encuentra proyectos mineros',
                  () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductsPage(),
                  )),
                ),
                _buildFeatureCard(
                  context,
                  'Servicios',
                  Icons.engineering,
                  const Color(0xFF45B7D1),
                  'Ofrece tus servicios',
                  () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ServicesPage(),
                  )),
                ),
                _buildFeatureCard(
                  context,
                  'Comunidad',
                  Icons.people,
                  const Color(0xFFFF6B6B),
                  'Conecta con otros',
                  () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommunityPage(),
                  )),
                ),
                _buildFeatureCard(
                  context,
                  'Grupos',
                  Icons.group_work,
                  const Color(0xFF4ECDC4),
                  'Únete a grupos',
                  () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupsPage(),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dashboard para trabajadores (empleados de empresa)
  Widget _buildWorkerDashboard(BuildContext context) {
    final user = widget.currentUser;
    final userName = user?['name'] ?? 'Usuario';
    final accountType = user?['accountType'] ?? 'worker';
    final userTypeInfo = _getUserTypeInfo(accountType);
    final orgInfo = user?['organizationInfo'] as Map<String, dynamic>?;
    final companyName = orgInfo?['companyName'] ?? 'Tu Empresa';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('¡Hola, $userName!'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showUserProfile(context);
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    const Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    const Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de empleado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          userTypeInfo['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userTypeInfo['title'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chip del tipo de usuario
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userTypeInfo['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (companyName != 'Tu Empresa') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Empresa: $companyName',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    userTypeInfo['description'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Panel de Empleado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Funcionalidades de trabajador
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  'Tareas',
                  Icons.assignment,
                  const Color(0xFF4ECDC4),
                  'Gestiona tus tareas',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Reportes',
                  Icons.bar_chart,
                  const Color(0xFF45B7D1),
                  'Reportes de trabajo',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Equipo',
                  Icons.people,
                  const Color(0xFFFF6B6B),
                  'Tu equipo de trabajo',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Capacitación',
                  Icons.school,
                  const Color(0xFF96CEB4),
                  'Cursos y entrenamientos',
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dashboard para empresas (organizaciones)
  Widget _buildCompanyDashboard(BuildContext context) {
    final user = widget.currentUser;
    final userName = user?['name'] ?? 'Usuario';
    final accountType = user?['accountType'] ?? 'company';
    final userTypeInfo = _getUserTypeInfo(accountType);
    final orgInfo = user?['organizationInfo'] as Map<String, dynamic>?;
    final companyName = orgInfo?['companyName'] ?? userName;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(companyName),
        backgroundColor: const Color(0xFF45B7D1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.business),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showUserProfile(context);
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    const Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    const Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de empresa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF45B7D1), Color(0xFF2980B9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45B7D1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          userTypeInfo['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userTypeInfo['title'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chip del tipo de usuario
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userTypeInfo['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userTypeInfo['description'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Gestión Empresarial',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Funcionalidades de empresa
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  'Empleados',
                  Icons.people_alt,
                  const Color(0xFF45B7D1),
                  'Gestiona tu equipo',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Proyectos',
                  Icons.folder_open,
                  const Color(0xFF4ECDC4),
                  'Administra proyectos',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Métricas',
                  Icons.analytics,
                  const Color(0xFFFF6B6B),
                  'Análisis y reportes',
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Recursos',
                  Icons.inventory,
                  const Color(0xFF96CEB4),
                  'Gestión de recursos',
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene la información de tipo de usuario según el accountType
  Map<String, dynamic> _getUserTypeInfo(String accountType) {
    switch (accountType) {
      case 'individual':
        return {
          'icon': Icons.person,
          'title': 'Minero Individual',
          'label': 'Individual',
          'description': 'Profesional minero independiente especializado en exploración y proyectos personales',
        };
      case 'worker':
        return {
          'icon': Icons.engineering,
          'title': 'Trabajador Minero',
          'label': 'Empleado',
          'description': 'Trabajador especializado vinculado a empresa minera',
        };
      case 'company':
        return {
          'icon': Icons.business,
          'title': 'Empresa Minera',
          'label': 'Empresa',
          'description': 'Organización dedicada a operaciones y proyectos mineros',
        };
      default:
        return {
          'icon': Icons.person,
          'title': 'Usuario Minero',
          'label': 'General',
          'description': 'Miembro de la comunidad minera',
        };
    }
  }

  /// Navega al perfil del usuario actual
  void _showUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(currentUser: widget.currentUser),
      ),
    );
  }

  /// Navega a la página de mensajes
  void _openMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(currentUser: widget.currentUser),
      ),
    );
  }

  /// Cerrar sesión del usuario actual
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Cerrar sesión
              await AuthenticationService.instance.logout();
              
              if (mounted) {
                Navigator.of(context).pop(); // Cerrar dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}