import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/auth/authentication_service.dart';
import 'requests_page.dart';
import 'messages_page.dart';
import 'products_page.dart';
import 'services_page.dart';
import 'edit_profile_page.dart';
import 'shared/models/user.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const ProfilePage({super.key, this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? get _userData => widget.currentUser;
  String get _userType => _userData?['accountType'] ?? 'individual';
  
  Map<String, dynamic> _getUserTypeInfo() {
    switch (_userType) {
      case 'individual':
        return {
          'title': 'Minero Individual',
          'subtitle': 'Profesional minero independiente',
          'color': AppColors.primary,
          'icon': Icons.person,
        };
      case 'worker':
        return {
          'title': 'Trabajador Minero',
          'subtitle': 'Especialista técnico en operaciones',
          'color': AppColors.secondary,
          'icon': Icons.engineering,
        };
      case 'company':
        return {
          'title': 'Empresa Minera',
          'subtitle': 'Organización líder en proyectos',
          'color': AppColors.warning,
          'icon': Icons.business,
        };
      default:
        return {
          'title': 'Usuario',
          'subtitle': 'Miembro de la comunidad',
          'color': AppColors.primary,
          'icon': Icons.person,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final typeInfo = _getUserTypeInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: typeInfo['color'],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              typeInfo['color'],
              typeInfo['color'].withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(typeInfo),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildStatsCard(typeInfo),
                const SizedBox(height: 20),
                _buildActionsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> typeInfo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: typeInfo['color'].withOpacity(0.1),
            child: Icon(
              typeInfo['icon'],
              size: 40,
              color: typeInfo['color'],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData!['name'] ?? 'Usuario',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeInfo['title'],
                    style: TextStyle(
                      color: typeInfo['color'],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '@',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', _userData!['email'] ?? 'No especificado'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Fecha de Registro', 
            _userData!['createdAt'] != null 
              ? DateTime.parse(_userData!['createdAt']).toLocal().toString().split(' ')[0]
              : 'No disponible'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> typeInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(Icons.handshake, 'Proyectos', '12', typeInfo['color']),
              const SizedBox(width: 20),
              _buildStatItem(Icons.star, 'Calificación', '4.8', AppColors.warning),
              const SizedBox(width: 20),
              _buildStatItem(Icons.groups, 'Conexiones', '45', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    final userColor = _getUserColor();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.request_page,
                  'Solicitudes',
                  userColor,
                  _openRequests,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.message,
                  'Mensajes',
                  userColor,
                  _openMessages,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.shopping_cart,
                  'Productos',
                  userColor,
                  _openProducts,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.build,
                  'Servicios',
                  userColor,
                  _openServices,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    // Crear un objeto User a partir de los datos actuales del usuario
    final currentUserData = widget.currentUser;
    if (currentUserData == null) return;
    
    // Convertir el tipo de cuenta
    AccountType accountType;
    switch (currentUserData['accountType']) {
      case 'worker':
        accountType = AccountType.worker;
        break;
      case 'company':
        accountType = AccountType.company;
        break;
      default:
        accountType = AccountType.individual;
    }
    
    final user = User(
      id: currentUserData['id'] ?? 'temp_id',
      username: currentUserData['username'] ?? currentUserData['email'] ?? 'user',
      email: currentUserData['email'] ?? '',
      name: currentUserData['name'] ?? 'Usuario',
      accountType: accountType,
      createdAt: DateTime.now(),
      // Valores por defecto para campos requeridos
      languages: const [],
      servicesOffered: const [],
      interests: const [],
      watchKeywords: const [],
      experienceLevel: ExperienceLevel.beginner,
      specializations: const [],
      certifications: const [],
      workExperience: const [],
      socialLinks: const [],
      preferences: UserPreferences(),
      preferredPostTypes: const {},
      followedTags: const [],
      followedCategories: const [],
      verificationStatus: VerificationStatus.none,
      ratingAvg: 0.0,
      ratingCount: 0,
      completedJobsCount: 0,
      isOnline: true,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );
  }

  Color _getUserColor() {
    switch (_userType) {
      case 'individual':
        return AppColors.primary;
      case 'worker':
        return AppColors.secondary;
      case 'company':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  void _openMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(currentUser: widget.currentUser),
      ),
    );
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductsPage(),
      ),
    );
  }

  void _openServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServicesPage(),
      ),
    );
  }

  void _openRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestsPage(currentUser: widget.currentUser),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidad'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacidad próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayuda próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    Navigator.pop(context);
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
              Navigator.of(context).pop();
              await AuthenticationService.instance.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
