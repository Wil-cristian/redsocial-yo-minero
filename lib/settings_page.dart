import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/auth/authentication_service.dart';
import 'login_page.dart';

/// Página de configuración del usuario
class SettingsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const SettingsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool notificationsEnabled;
  late bool emailNotifications;
  late bool darkMode;

  @override
  void initState() {
    super.initState();
    notificationsEnabled = true;
    emailNotifications = true;
    darkMode = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Sección de perfil
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: DashboardColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        (widget.currentUser?['name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentUser?['name'] ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.currentUser?['email'] ?? 'correo@ejemplo.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit, color: Colors.grey[400]),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sección de notificaciones
            _buildSectionHeader('Notificaciones'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildToggleSetting(
                    'Notificaciones',
                    'Recibe notificaciones en la aplicación',
                    notificationsEnabled,
                    (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildToggleSetting(
                    'Notificaciones por correo',
                    'Recibe actualizaciones por email',
                    emailNotifications,
                    (value) {
                      setState(() {
                        emailNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sección de apariencia
            _buildSectionHeader('Apariencia'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildToggleSetting(
                    'Modo oscuro',
                    'Activar tema oscuro (próximamente)',
                    darkMode,
                    (value) {
                      setState(() {
                        darkMode = value;
                      });
                    },
                    enabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sección de privacidad
            _buildSectionHeader('Privacidad y seguridad'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildSettingTile(
                    'Privacidad del perfil',
                    'Controla quién puede ver tu perfil',
                    Icons.privacy_tip_outlined,
                    () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Bloqueados',
                    'Gestiona usuarios bloqueados',
                    Icons.block_outlined,
                    () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Cambiar contraseña',
                    'Actualiza tu contraseña',
                    Icons.lock_outline,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sección de ayuda
            _buildSectionHeader('Ayuda y soporte'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildSettingTile(
                    'Centro de ayuda',
                    'Preguntas frecuentes y tutoriales',
                    Icons.help_outline,
                    () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Reportar problema',
                    'Envíanos tus comentarios',
                    Icons.bug_report_outlined,
                    () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Acerca de',
                    'Versión 1.0.0',
                    Icons.info_outline,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: DashboardColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: DashboardColors.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthenticationService.instance.logout();
              if (mounted) {
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
