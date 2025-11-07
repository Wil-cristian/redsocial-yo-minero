// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'core/theme/colors.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/theme/rich_decorations.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/achievements/achievement_models.dart';
import 'core/achievements/achievements_repository.dart';
import 'core/achievements/gem_color_helper.dart';
import 'core/favorites/favorites_repository.dart';
import 'requests_page.dart';
import 'messages_page.dart';
import 'products_page.dart';
import 'services_page.dart';
import 'edit_profile_page.dart';
import 'suggestions_page.dart';
import 'achievements_page.dart';
import 'shared/models/user.dart';
import 'shared/widgets/favorite_gem_card.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const ProfilePage({super.key, this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    // Primero intentar usar el usuario pasado por parámetro
    if (widget.currentUser != null) {
      setState(() {
        _userData = widget.currentUser;
        _isLoading = false;
      });
      return;
    }
    
    // Si no hay usuario, obtenerlo del servicio de auth
    final profile = SupabaseAuthService.instance.currentUserProfile;
    setState(() {
      _userData = profile;
      _isLoading = false;
    });
  }
  
  String get _userType => _userData?['account_type'] ?? _userData?['accountType'] ?? 'individual';
  
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
    if (_isLoading || _userData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Cargando perfil...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final typeInfo = _getUserTypeInfo();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editProfile(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => _showSettings(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      typeInfo['color'],
                      typeInfo['color'].withValues(alpha: 0.8),
                      typeInfo['color'].withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: 50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Profile content
                    Positioned(
                      bottom: 50,
                      left: 24,
                      right: 24,
                      child: _buildProfileHeaderContent(typeInfo),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildLevelCard(),
              const SizedBox(height: 20),
              _buildFavoritesSection(),
              const SizedBox(height: 20),
              _buildStatsCard(typeInfo),
              const SizedBox(height: 20),
              _buildActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderContent(Map<String, dynamic> typeInfo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Icon(
            typeInfo['icon'],
            size: 40,
            color: Colors.white,
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  typeInfo['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '@${_userData!['username'] ?? _userData!['email']?.split('@')[0] ?? 'usuario'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.emerald.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: RichDecorations.emeraldFacetsOverlay(
        opacity: 0.12,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header esmeralda
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DashboardColors.emeraldDeep,
                      DashboardColors.emerald,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', _userData!['email'] ?? 'No especificado'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'Fecha de Registro', 
                      _userData!['createdAt'] != null 
                        ? DateTime.parse(_userData!['createdAt']).toLocal().toString().split(' ')[0]
                        : 'No disponible'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DashboardColors.emerald),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DashboardColors.emeraldDeep,
                  fontWeight: FontWeight.w600,
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

  Widget _buildLevelCard() {
    // Datos de ejemplo - en producción vendrían de la base de datos
    final userLevel = UserLevel(
      level: 42,
      currentXP: 3200,
      xpToNextLevel: 5000,
      tier: GemTier.gold,
      tierName: 'Oro',
      perks: AchievementsRepository.getPerksForTier(GemTier.gold),
    );
    
    final gradient = GemColorHelper.getGradientForTier(userLevel.tier);
    final color = GemColorHelper.getColorForTier(userLevel.tier);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AchievementsPage(currentUser: _userData)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícono de nivel
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      GemColorHelper.getIconForTier(userLevel.tier),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Información de nivel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Nivel ${userLevel.level}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                userLevel.tierName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${userLevel.currentXP} / ${userLevel.xpToNextLevel} XP',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón para ver logros
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: userLevel.progress,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '${(userLevel.progress * 100).toStringAsFixed(1)}% para el siguiente nivel',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    // Ejemplo: obtener favoritos del usuario
    final favorites = FavoritesRepository.getUserFavorites(_userData?['id'] ?? 'demo');
    if (favorites.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...favorites.map((fav) => FavoriteGemCard(favorite: fav)),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> typeInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dorado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: DashboardColors.primaryGradient,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Estadísticas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  _buildStatItem(Icons.handshake, 'Proyectos', '12', DashboardColors.primary),
                  const SizedBox(width: 20),
                  _buildStatItem(Icons.star, 'Calificación', '4.8', DashboardColors.accent),
                  const SizedBox(width: 20),
                  _buildStatItem(Icons.groups, 'Conexiones', '45', DashboardColors.emerald),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.04),
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
                  Icons.auto_awesome,
                  'IA Sugerencias',
                  userColor,
                  _openSuggestions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.shopping_cart,
                  'Productos',
                  userColor,
                  _openProducts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.build,
                  'Servicios',
                  userColor,
                  _openServices,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // Placeholder para mantener simetría
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
          color: color.withValues(alpha: 0.1),
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
    // Usar los datos cargados en _userData
    if (_userData == null) return;
    
    final userData = _userData!; // Safe to use ! after null check
    
    // Convertir el tipo de cuenta
    AccountType accountType;
    final accountTypeStr = userData['account_type'] ?? userData['accountType'] ?? 'individual';
    switch (accountTypeStr) {
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
      id: userData['id'] ?? 'temp_id',
      username: userData['username'] ?? userData['email'] ?? 'user',
      email: userData['email'] ?? '',
      name: userData['name'] ?? 'Usuario',
      accountType: accountType,
      createdAt: DateTime.now(),
      bio: userData['bio'],
      location: userData['location'],
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
    ).then((_) {
      // Recargar datos después de editar
      _loadUserData();
    });
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

  void _openSuggestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionsPage(currentUser: widget.currentUser),
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
              leading: const Icon(Icons.logout, color: AppColorsUnified.error),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppColorsUnified.error)),
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
              await SupabaseAuthService.instance.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColorsUnified.error),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
