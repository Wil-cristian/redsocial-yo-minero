import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'chat_detail_page.dart';
import 'group_chat_page.dart';

class MessagesPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const MessagesPage({super.key, this.currentUser});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String get _userType => widget.currentUser?['accountType'] ?? 'individual';

  // Datos de ejemplo para conversaciones
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'María González',
      'lastMessage': 'Perfecto, ¿podemos coordinar una reunión para la próxima semana?',
      'timestamp': '2025-10-20 15:30:00',
      'unreadCount': 2,
      'avatar': 'M',
      'isOnline': true,
      'type': 'individual',
    },
    {
      'id': '2',
      'name': 'Carlos Minería S.A.S',
      'lastMessage': 'Gracias por el presupuesto, lo revisaremos y te contactamos',
      'timestamp': '2025-10-20 14:15:00',
      'unreadCount': 0,
      'avatar': 'C',
      'isOnline': false,
      'type': 'company',
    },
    {
      'id': '3',
      'name': 'Juan Pérez',
      'lastMessage': '¿Tienes experiencia con equipos de perforación de marca X?',
      'timestamp': '2025-10-20 12:45:00',
      'unreadCount': 1,
      'avatar': 'J',
      'isOnline': true,
      'type': 'worker',
    },
    {
      'id': '4',
      'name': 'Extractora del Norte',
      'lastMessage': 'El mantenimiento fue excelente, definitivamente los recomendaremos',
      'timestamp': '2025-10-19 16:20:00',
      'unreadCount': 0,
      'avatar': 'E',
      'isOnline': false,
      'type': 'company',
    },
    {
      'id': '5',
      'name': 'Ana Rodríguez',
      'lastMessage': '¿Podrías enviarme los detalles del proyecto de exploración?',
      'timestamp': '2025-10-19 10:30:00',
      'unreadCount': 3,
      'avatar': 'A',
      'isOnline': true,
      'type': 'individual',
    },
  ];

  final List<Map<String, dynamic>> _groups = [
    {
      'id': '1',
      'name': 'Mineros de Antioquia',
      'lastMessage': 'Luis: Nueva oportunidad de exploración en el norte',
      'timestamp': '2025-10-20 13:20:00',
      'unreadCount': 5,
      'memberCount': 24,
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Técnicos Especializados',
      'lastMessage': 'Roberto: ¿Alguien tiene experiencia con equipos de última generación?',
      'timestamp': '2025-10-20 11:45:00',
      'unreadCount': 2,
      'memberCount': 15,
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Seguridad Minera',
      'lastMessage': 'Carmen: Nuevas normativas de seguridad aprobadas',
      'timestamp': '2025-10-19 15:10:00',
      'unreadCount': 0,
      'memberCount': 31,
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final userColor = _getUserColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: userColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Conversaciones',
            ),
            Tab(
              icon: Icon(Icons.group),
              text: 'Grupos',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              userColor.withValues(alpha: 0.05),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildConversationsTab(),
            _buildGroupsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(),
        backgroundColor: userColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationsTab() {
    if (_conversations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No hay conversaciones',
        subtitle: 'Inicia una conversación para conectar con otros mineros',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildGroupsTab() {
    if (_groups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'No hay grupos',
        subtitle: 'Únete a grupos para colaborar con la comunidad minera',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return _buildGroupTile(group);
      },
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final userColor = _getUserColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getTypeColor(conversation['type']).withValues(alpha: 0.2),
              child: Text(
                conversation['avatar'],
                style: TextStyle(
                  color: _getTypeColor(conversation['type']),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (conversation['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation['name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTimestamp(conversation['timestamp']),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation['lastMessage'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (conversation['unreadCount'] > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: userColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conversation['unreadCount']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(conversation),
      ),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    final userColor = _getUserColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.info.withValues(alpha: 0.2),
          child: Icon(
            Icons.group,
            color: AppColors.info,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                group['name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTimestamp(group['timestamp']),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['lastMessage'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${group['memberCount']} miembros',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (group['unreadCount'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: userColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${group['unreadCount']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _openGroupChat(group),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
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

  String _formatTimestamp(String timestampStr) {
    try {
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inMinutes < 1) {
        return 'Ahora';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${timestamp.day}/${timestamp.month}';
      }
    } catch (e) {
      return '';
    }
  }

  void _openChat(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          conversation: conversation,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _openGroupChat(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatPage(
          group: group,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar'),
        content: const Text('La función de búsqueda estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Mensajes archivados'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Contactos bloqueados'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración de chat'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Mensaje'),
        content: const Text('La función de crear nuevo mensaje estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}