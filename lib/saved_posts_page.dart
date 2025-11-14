import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/supabase/supabase_service.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> with SingleTickerProviderStateMixin {
  final _supabase = SupabaseService.instance.client;
  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoading = true;
  String? _selectedFilter;
  late TabController _tabController;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Todos', 'value': null, 'icon': Icons.grid_view},
    {'label': 'Ofertas', 'value': 'offer', 'icon': Icons.local_offer},
    {'label': 'Productos', 'value': 'product', 'icon': Icons.shopping_bag},
    {'label': 'Servicios', 'value': 'service', 'icon': Icons.build_circle},
    {'label': 'Noticias', 'value': 'news', 'icon': Icons.article},
    {'label': 'Encuestas', 'value': 'poll', 'icon': Icons.poll},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFilter = _filters[_tabController.index]['value'];
        });
        _loadSavedPosts();
      }
    });
    _loadSavedPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPosts() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      final params = {
        'user_id_param': currentUser.id,
        if (_selectedFilter != null) 'post_type_filter': _selectedFilter,
      };

      final response = await _supabase.rpc('get_saved_posts', params: params);

      setState(() {
        _savedPosts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando posts guardados: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSavedPost(String postId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      await _supabase
          .from('saved_posts')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('post_id', postId);

      _loadSavedPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminado de guardados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error eliminando post: $e');
    }
  }

  void _openChat(Map<String, dynamic> post) async {
    final currentUser = SupabaseAuthService.instance.currentUser;
    if (currentUser == null) return;

    String? authorId = post['author_id'];
    
    if (authorId == null) {
      try {
        final postData = await _supabase
            .from('posts')
            .select('author_id')
            .eq('id', post['post_id'])
            .single();
        authorId = postData['author_id'];
      } catch (e) {
        debugPrint('❌ Error obteniendo author_id: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al abrir chat')),
          );
        }
        return;
      }
    }

    if (authorId == null) return;

    final conversation = {
      'otherUserId': authorId,
      'otherUserName': post['author_name'] ?? 'Usuario',
      'type': 'individual',
    };

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/chat-detail',
        arguments: conversation,
      );
    }
  }

  void _showPostDetails(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailsModal(post),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'offer':
        return AppColorsUnified.companyBlue;
      case 'product':
        return AppColorsUnified.warning;
      case 'service':
        return const Color(0xFF0D9488); // Teal 600
      case 'news':
        return AppColorsUnified.charcoal;
      case 'poll':
        return AppColorsUnified.gold;
      default:
        return AppColorsUnified.grey500;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'offer':
        return Icons.local_offer_rounded;
      case 'product':
        return Icons.shopping_bag_rounded;
      case 'service':
        return Icons.build_circle_rounded;
      case 'news':
        return Icons.article_rounded;
      case 'poll':
        return Icons.poll_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'offer':
        return 'Oferta';
      case 'product':
        return 'Producto';
      case 'service':
        return 'Servicio';
      case 'news':
        return 'Noticia';
      case 'poll':
        return 'Encuesta';
      default:
        return 'Post';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text(
          'Guardados',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        backgroundColor: AppColorsUnified.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColorsUnified.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColorsUnified.orange,
              indicatorWeight: 3,
              labelColor: AppColorsUnified.orange,
              unselectedLabelColor: AppColorsUnified.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: _filters.map((filter) {
                return Tab(
                  icon: Icon(filter['icon'] as IconData, size: 20),
                  text: filter['label'],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColorsUnified.orange))
          : _savedPosts.isEmpty
              ? _buildEmptyState()
              : _buildPostsList(),
    );
  }

  Widget _buildEmptyState() {
    final filterLabel = _filters[_tabController.index]['label'];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: AppColorsUnified.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes $filterLabel guardados',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guarda posts para verlos aquí',
            style: TextStyle(
              fontSize: 14,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPosts.length,
      itemBuilder: (context, index) {
        final post = _savedPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postType = post['post_type'];
    final typeColor = _getTypeColor(postType);
    final typeIcon = _getTypeIcon(postType);
    final typeLabel = _getTypeLabel(postType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Por ${post['author_name'] ?? 'Usuario'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeSavedPost(post['post_id']),
                  icon: Icon(Icons.bookmark, color: typeColor),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColorsUnified.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post['content'] != null && post['content'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColorsUnified.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChat(post),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                        label: const Text('Contactar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: typeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showPostDetails(post),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: typeColor,
                          side: BorderSide(color: typeColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ver más'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetailsModal(Map<String, dynamic> post) {
    final postType = post['post_type'];
    final typeColor = _getTypeColor(postType);
    final typeIcon = _getTypeIcon(postType);
    final typeLabel = _getTypeLabel(postType);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorsUnified.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  typeColor,
                  typeColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post['content'] ?? 'Sin descripción disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColorsUnified.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información del autor
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: typeColor,
                          child: Text(
                            (post['author_name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Publicado por',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColorsUnified.textSecondary,
                                ),
                              ),
                              Text(
                                post['author_name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsUnified.textPrimary,
                                ),
                              ),
                              if (post['author_username'] != null)
                                Text(
                                  '@${post['author_username']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColorsUnified.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.favorite, color: AppColorsUnified.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${post['likes_count'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openChat(post);
              },
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: const Text(
                'Contactar Ahora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
