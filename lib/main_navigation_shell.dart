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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
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
    );
  }
}
