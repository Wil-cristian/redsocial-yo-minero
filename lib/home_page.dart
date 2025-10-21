import 'package:flutter/material.dart';
import 'core/auth/authentication_service.dart';
import 'core/theme/dashboard_colors.dart';
import 'products_page.dart';
import 'services_page.dart';
import 'community_page.dart';
import 'groups_page.dart';
import 'profile_page.dart';
import 'messages_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'cart_favorites_page.dart';
import 'shared/widgets/dashboard_grid_item.dart';

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
    
    return SafeArea(
      child: Column(
          children: [
            // Header con saludo y opciones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espacio para mantener el balance visual
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, size: 20),
                        onPressed: () {},
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartFavoritesPage(),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: DashboardColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 20),
                        onPressed: () => _showDashboardMenu(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hola, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid de opciones
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Primera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Proyectos',
                            icon: Icons.work,
                            backgroundColor: DashboardColors.cardOrangeBg,
                            iconColor: DashboardColors.cardOrange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProductsPage()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Servicios',
                            icon: Icons.engineering,
                            isHighlighted: true,
                            backgroundColor: DashboardColors.cardPurple,
                            iconColor: DashboardColors.cardPurple,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ServicesPage()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Segunda fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Comunidad',
                            icon: Icons.group,
                            backgroundColor: DashboardColors.cardGreenBg,
                            iconColor: DashboardColors.cardGreen,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CommunityPage()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Grupos',
                            icon: Icons.group_work,
                            backgroundColor: DashboardColors.cardBlueBg,
                            iconColor: DashboardColors.cardBlue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GroupsPage()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tercera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Mensajes',
                            icon: Icons.mail_outline,
                            backgroundColor: DashboardColors.cardPinkBg,
                            iconColor: DashboardColors.cardPink,
                            onTap: () => _openMessages(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Perfil',
                            icon: Icons.person,
                            backgroundColor: DashboardColors.cardYellowBg,
                            iconColor: DashboardColors.cardYellow,
                            onTap: () => _showUserProfile(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  /// Dashboard para trabajadores (empleados de empresa)
  Widget _buildWorkerDashboard(BuildContext context) {
    final user = widget.currentUser;
    final userName = user?['name'] ?? 'Usuario';
    final orgInfo = user?['organizationInfo'] as Map<String, dynamic>?;
    final companyName = orgInfo?['companyName'] ?? 'Tu Empresa';
    
    return SafeArea(
      child: Column(
          children: [
            // Header con saludo y opciones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espacio para mantener el balance visual
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, size: 20),
                        onPressed: () {},
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartFavoritesPage(),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: DashboardColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 20),
                        onPressed: () => _showDashboardMenu(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Empleado de: $companyName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid de opciones
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Primera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Tareas',
                            icon: Icons.assignment,
                            backgroundColor: DashboardColors.cardTealBg,
                            iconColor: DashboardColors.cardTeal,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Reportes',
                            icon: Icons.bar_chart,
                            isHighlighted: true,
                            backgroundColor: DashboardColors.cardWorkerGreen,
                            iconColor: DashboardColors.cardWorkerGreen,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Segunda fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Equipo',
                            icon: Icons.people,
                            backgroundColor: DashboardColors.cardIndigoBg,
                            iconColor: DashboardColors.cardIndigo,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Capacitación',
                            icon: Icons.school,
                            backgroundColor: DashboardColors.cardWorkerPinkBg,
                            iconColor: DashboardColors.cardWorkerPink,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tercera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Mensajes',
                            icon: Icons.mail_outline,
                            backgroundColor: DashboardColors.cardOrange2Bg,
                            iconColor: DashboardColors.cardOrange2,
                            onTap: () => _openMessages(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Perfil',
                            icon: Icons.person,
                            backgroundColor: DashboardColors.cardWorkerPurpleBg,
                            iconColor: DashboardColors.cardWorkerPurple,
                            onTap: () => _showUserProfile(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  /// Dashboard para empresas (organizaciones)
  Widget _buildCompanyDashboard(BuildContext context) {
    final user = widget.currentUser;
    final orgInfo = user?['organizationInfo'] as Map<String, dynamic>?;
    final companyName = orgInfo?['companyName'] ?? 'Tu Empresa';
    
    return SafeArea(
      child: Column(
          children: [
            // Header con saludo y opciones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espacio para mantener el balance visual
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, size: 20),
                        onPressed: () {},
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartFavoritesPage(),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: DashboardColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 20),
                        onPressed: () => _showDashboardMenu(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid de opciones
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Primera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Empleados',
                            icon: Icons.people_alt,
                            backgroundColor: DashboardColors.cardDarkBlueBg,
                            iconColor: DashboardColors.cardDarkBlue,
                            onTap: () => Navigator.pushNamed(context, '/company-employees'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Proyectos',
                            icon: Icons.folder_open,
                            isHighlighted: true,
                            backgroundColor: DashboardColors.cardBluePurple,
                            iconColor: DashboardColors.cardBluePurple,
                            onTap: () => Navigator.pushNamed(context, '/company-projects'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Segunda fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Métricas',
                            icon: Icons.analytics,
                            backgroundColor: DashboardColors.cardCompanyPinkBg,
                            iconColor: DashboardColors.cardCompanyPink,
                            onTap: () => Navigator.pushNamed(context, '/company-metrics'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Recursos',
                            icon: Icons.inventory,
                            backgroundColor: DashboardColors.cardDarkGreenBg,
                            iconColor: DashboardColors.cardDarkGreen,
                            onTap: () => Navigator.pushNamed(context, '/company-resources'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tercera fila
                    Row(
                      children: [
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Servicios',
                            icon: Icons.engineering,
                            backgroundColor: DashboardColors.cardCompanyOrangeBg,
                            iconColor: DashboardColors.cardCompanyOrange,
                            onTap: () => Navigator.pushNamed(context, '/company-requested-services'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardGridItem(
                            label: 'Productos',
                            icon: Icons.inventory_2,
                            backgroundColor: DashboardColors.cardCompanyPurpleBg,
                            iconColor: DashboardColors.cardCompanyPurple,
                            onTap: () => Navigator.pushNamed(context, '/company-requested-products'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }


  /// Muestra el menú del dashboard
  void _showDashboardMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header del menú
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Mi Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showUserProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Notificaciones'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(currentUser: widget.currentUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(currentUser: widget.currentUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.purple),
              title: const Text('Ayuda y soporte'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
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