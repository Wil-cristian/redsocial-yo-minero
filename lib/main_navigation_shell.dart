import 'package:flutter/material.dart';
import 'core/services/preferences_service.dart';
import 'home_page.dart';
import 'community_feed_page.dart';  // MURO conectado a Supabase
import 'notifications_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'shared/widgets/custom_side_drawer.dart';
import 'shared/widgets/floating_radial_button.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// Widget contenedor con navegación fija
/// Mantiene la barra de navegación visible en todas las pantallas
class MainNavigationShell extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const MainNavigationShell({
    super.key,
    this.currentUser,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final _prefsService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(currentUser: widget.currentUser),  // Dashboard
      CommunityFeedPage(currentUser: widget.currentUser),  // MURO conectado a Supabase
      ProfilePage(currentUser: widget.currentUser),
      NotificationsPage(currentUser: widget.currentUser),
      SettingsPage(currentUser: widget.currentUser),
    ];
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 🌟 Crea un icono con efecto metálico REAL usando gradiente de 5 capas
  /// Aplica el goldGradient directamente con ShaderMask para visible profundidad 3D
  /// Soluciona el problema de "amarillo plano" usando shader real, no sombras
  Widget _buildMetallicIcon(IconData iconData) {
    return ShaderMask(
      // 🎨 Usa el gradiente de oro metálico de 5 capas definido en AppColorsUnified
      shaderCallback: (Rect bounds) {
        return AppColorsUnified.goldGradient.createShader(bounds);
      },
      // BlendMode.srcIn = el gradiente REEMPLAZA el color del icono
      // Esto hace que el gradiente sea visible en el icono
      blendMode: BlendMode.srcIn,
      child: Icon(
        iconData,
        size: 24,
        color: Colors.white,  // Color base (será reemplazado por el shader)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ IMPORTANTE: La base de datos usa snake_case (account_type) no camelCase
    final accountType = widget.currentUser?['account_type'] as String?;
    
    // Debug: ver qué datos tenemos del usuario
    debugPrint('🔍 MainNavigationShell - currentUser: ${widget.currentUser}');
    debugPrint('🔍 MainNavigationShell - accountType: $accountType');
    
    return Scaffold(
      backgroundColor: AppColorsUnified.pureWhite,
      body: Stack(
        children: [
          _pages[_selectedIndex],
          // Drawer lateral deslizable
          CustomSideDrawer(
            accountType: accountType,
            currentUser: widget.currentUser,
            onNavigateToIndex: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
      // ✨ Botón flotante de acceso rápido (controlado por switch en configuración)
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _prefsService.floatingMenuEnabled,
        builder: (context, enabled, child) {
          return enabled
              ? FloatingRadialButton(
                  accountType: accountType,
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColorsUnified.goldBright,  // ⭐ ORO BRILLANTE para el texto
            unselectedItemColor: AppColorsUnified.textSecondary,  // Gris para iconos inactivos
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              shadows: [
                // ⭐ BRILLO ESPECULAR SUPERIOR - Reflejo de luz directo
                Shadow(
                  color: const Color(0x66FFF9E6),  // goldHighlight con 40% alpha
                  offset: const Offset(-0.8, -0.8),
                  blurRadius: 2,
                ),
                // 💎 REFLEJO DORADO BRILLANTE - Resplandor metálico
                Shadow(
                  color: const Color(0x99FFE55C),  // goldBright con 60% alpha
                  offset: const Offset(-0.3, -0.3),
                  blurRadius: 1.5,
                ),
                // 🍊 TEXTURA NARANJA CÁLIDO - Calidez vibrante
                Shadow(
                  color: const Color(0x80FF8C42),  // Naranja brillante con 50% alpha
                  offset: const Offset(0.3, 0.3),
                  blurRadius: 2,
                ),
                // 🧡 NARANJA DORADO - Transición rica
                Shadow(
                  color: const Color(0x66E67E22),  // Naranja dorado con 40% alpha
                  offset: const Offset(0.6, 0.6),
                  blurRadius: 2.5,
                ),
                // ☕ CAFÉ CARAMELO - Profundidad cálida
                Shadow(
                  color: const Color(0x998B4513),  // Café con 60% alpha
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
                // 🟤 CAFÉ OSCURO - Contraste estructural
                Shadow(
                  color: const Color(0x80654321),  // Café oscuro con 50% alpha
                  offset: const Offset(1.3, 1.3),
                  blurRadius: 3.5,
                ),
                // � CHOCOLATE AMARGO - Definición final
                Shadow(
                  color: const Color(0x66502D16),  // Chocolate con 40% alpha
                  offset: const Offset(1.6, 1.6),
                  blurRadius: 4,
                ),
              ],
            ),
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: _buildMetallicIcon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline),
                activeIcon: _buildMetallicIcon(Icons.people),
                label: 'Comunidad',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: _buildMetallicIcon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bolt_outlined),
                activeIcon: _buildMetallicIcon(Icons.bolt),
                label: 'Notif',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: _buildMetallicIcon(Icons.settings),
                label: 'Config',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
