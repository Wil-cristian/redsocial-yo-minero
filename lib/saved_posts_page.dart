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

  void _showPostDetails(Map<String, dynamic> post) async {
    // NOTICIAS: Cargar datos reales desde posts
    if (post['post_type'] == 'news') {
      try {
        final postData = await _supabase
            .from('posts')
            .select('news_source, news_author, metadata')
            .eq('id', post['post_id'])
            .single();
        
        // Agregar datos reales al metadata
        if (post['metadata'] == null) {
          post['metadata'] = <String, dynamic>{};
        }
        post['metadata']['source'] = postData['news_source'] ?? 'Fuente desconocida';
        post['metadata']['author'] = postData['news_author'];
        
        // Si hay metadata en la columna metadata, también incluirlo
        if (postData['metadata'] != null) {
          final metadataFromDb = postData['metadata'] as Map<String, dynamic>;
          post['metadata'].addAll(metadataFromDb);
        }
      } catch (e) {
        debugPrint('❌ Error cargando datos de noticia: $e');
      }
    }
    
    // ENCUESTAS: Cargar datos REALES desde la tabla poll_votes
    if (post['post_type'] == 'poll') {
      try {
        final postData = await _supabase
            .from('posts')
            .select('poll_options, poll_ends_at')
            .eq('id', post['post_id'])
            .single();
        
        // Obtener votos REALES contando desde poll_votes tabla
        final voteResults = await _supabase
            .from('poll_votes')
            .select('selected_option')
            .eq('poll_id', post['post_id']);
        
        // Contar votos por opción REALES
        final Map<String, int> realVotes = {};
        for (final row in voteResults) {
          final option = row['selected_option'] as String;
          realVotes[option] = (realVotes[option] ?? 0) + 1;
        }
        
        // SOBRESCRIBIR metadata completamente con datos REALES
        post['metadata'] = <String, dynamic>{
          'pollOptions': postData['poll_options'],
          'pollVotes': realVotes,
          'endsAt': postData['poll_ends_at'],
        };
        
        // Calcular total de votos REALES
        int totalVotes = 0;
        realVotes.forEach((key, value) {
          totalVotes += value;
        });
        post['metadata']['totalVotes'] = totalVotes;
      } catch (e) {
        debugPrint('❌ Error cargando datos de encuesta: $e');
      }
    }
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailsModal(post),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Justo ahora';
          }
          return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
        }
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'Hace $months mes${months > 1 ? 'es' : ''}';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'Hace $years año${years > 1 ? 's' : ''}';
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

  String _formatFullDate(String? dateString) {
    if (dateString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateString);
      final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Fecha desconocida';
    }
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
                  // Stats Cards - INFORMACIÓN REAL
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite,
                          label: 'Me gusta',
                          value: '${post['likes_count'] ?? 0}',
                          color: AppColorsUnified.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bookmark,
                          label: 'Guardado',
                          value: _formatDate(post['saved_at']),
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Metadata específica según tipo de post - INFORMACIÓN REAL (PRIMERO para encuestas)
                  if (post['metadata'] != null) ...[
                    _buildMetadataSection(post['metadata'], postType, typeColor),
                    const SizedBox(height: 24),
                  ],

                  // Descripción
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Espacio para el botón flotante
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
              label: const Text('Contactar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic> metadata, String? postType, Color typeColor) {
    // Si no hay metadata, no mostrar nada
    if (metadata.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles Adicionales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: typeColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              // OFERTAS: Precio, disponibilidad
              if (postType == 'offer') ...[
                if (metadata['price'] != null)
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Precio',
                    value: '\$${metadata['price']} USD',
                    color: typeColor,
                  ),
                if (metadata['availability'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.inventory_2,
                    label: 'Disponibilidad',
                    value: metadata['availability'],
                    color: typeColor,
                  ),
                ],
                if (metadata['discount'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.local_offer,
                    label: 'Descuento',
                    value: '${metadata['discount']}% OFF',
                    color: AppColorsUnified.orange,
                  ),
                ],
              ],

              // PRODUCTOS: Precio, categoría, stock
              if (postType == 'product') ...[
                if (metadata['price'] != null)
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Precio',
                    value: '\$${metadata['price']}',
                    color: typeColor,
                  ),
                if (metadata['category'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Categoría',
                    value: metadata['category'],
                    color: typeColor,
                  ),
                ],
                if (metadata['stock'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.inventory,
                    label: 'Stock',
                    value: '${metadata['stock']} unidades',
                    color: typeColor,
                  ),
                ],
              ],

              // SERVICIOS: Duración, precio
              if (postType == 'service') ...[
                if (metadata['duration'] != null)
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Duración',
                    value: metadata['duration'],
                    color: typeColor,
                  ),
                if (metadata['price'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Precio',
                    value: '\$${metadata['price']}',
                    color: typeColor,
                  ),
                ],
              ],

              // NOTICIAS: Información completa y detallada
              if (postType == 'news') ...[
                // Header de noticia
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        typeColor.withValues(alpha: 0.1),
                        typeColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de sección
                      Row(
                        children: [
                          Icon(Icons.article, color: typeColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Información de la Noticia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Fuente
                      if (metadata['source'] != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.source, color: typeColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fuente',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColorsUnified.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    metadata['source'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Tiempo de lectura
                      if (metadata['readTime'] != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.schedule, color: typeColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tiempo de Lectura',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColorsUnified.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${metadata['readTime']} minutos',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Autor si existe
                      if (metadata['author'] != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.person, color: typeColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Autor',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColorsUnified.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    metadata['author'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // POSTS DE COMUNIDAD: Información y verificación con IA
              if (postType == 'community') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorsUnified.orange.withValues(alpha: 0.1),
                        AppColorsUnified.orange.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColorsUnified.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        children: [
                          Icon(Icons.groups, color: AppColorsUnified.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Post de Comunidad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Descripción
                      Text(
                        'Este es un post compartido por la comunidad. Puedes verificar su contenido con inteligencia artificial para confirmar la información.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColorsUnified.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botón de Verificación con IA (FUTURO)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implementar verificación con IA en el futuro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text('Función de verificación con IA próximamente'),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColorsUnified.companyBlue,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColorsUnified.companyBlue,
                                  AppColorsUnified.companyBlue.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.companyBlue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Verificar con IA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'PRÓXIMAMENTE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ENCUESTAS: Resultados detallados
              if (postType == 'poll') ...[
                // Título de resultados
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.poll, color: typeColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Resultados de Votación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      const Spacer(),
                      // Total de votos inline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: typeColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.how_to_vote, color: typeColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${metadata['totalVotes'] ?? 0} votos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Opciones con resultados (más compactas)
                if (metadata['pollOptions'] != null && metadata['pollVotes'] != null) ...[
                  ...(() {
                    final options = metadata['pollOptions'] as List<dynamic>;
                    final votes = metadata['pollVotes'] as Map<String, dynamic>;
                    final totalVotes = metadata['totalVotes'] as int? ?? 0;
                    
                    return List.generate(options.length, (index) {
                      final option = options[index] as String;
                      final optionVotes = votes[option] as int? ?? 0;
                      final percentage = totalVotes > 0 
                          ? (optionVotes / totalVotes * 100).round() 
                          : 0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Nombre de opción (ancho fijo)
                            SizedBox(
                              width: 110,
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Barra de progreso
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 10,
                                  backgroundColor: AppColorsUnified.grey200,
                                  valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Porcentaje y votos
                            SizedBox(
                              width: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: typeColor,
                                    ),
                                  ),
                                  Text(
                                    '($optionVotes)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColorsUnified.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  })(),
                ],
                
                // Fecha de finalización
                if (metadata['endsAt'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.event,
                    label: 'Finaliza',
                    value: _formatFullDate(metadata['endsAt']),
                    color: typeColor,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
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
    );
  }
}