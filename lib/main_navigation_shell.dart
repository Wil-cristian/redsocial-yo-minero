import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'home_page.dart';
import 'community_feed_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

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

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(currentUser: widget.currentUser),
      CommunityFeedPage(currentUser: widget.currentUser),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenido de la página actual
        _pages[_selectedIndex],
        
        // Barra de navegación fija en la parte inferior
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomNavigation(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: DashboardColors.primary,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Muro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
