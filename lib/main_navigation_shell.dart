import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'home_page.dart';
import 'community_feed_page.dart';  // MURO conectado a Supabase
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
            selectedItemColor: DashboardColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Comunidad',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_outlined),
                activeIcon: Icon(Icons.bolt),
                label: 'Notif',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Config',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
