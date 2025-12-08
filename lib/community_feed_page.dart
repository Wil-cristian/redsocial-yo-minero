import 'package:flutter/material.dart';

import 'shared/models/post.dart';
import 'features/posts/domain/post_repository.dart';
import 'core/theme/app_colors_unified.dart';
import 'features/posts/ui/post_creation_sheet.dart';
import 'shared/widgets/optimized_post_content.dart';
import 'core/theme/rich_decorations.dart';
import 'core/di/locator.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/supabase/supabase_service.dart';
import 'features/responses/ui/response_modal.dart';
import 'features/responses/ui/responses_list.dart';

class CommunityFeedPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const CommunityFeedPage({super.key, this.currentUser});
  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final _repo = sl<PostRepository>();
  final _supabase = SupabaseService.instance.client;
  List<Post> _posts = [];
  bool _isLoading = true;
  int _selectedFilter = 0; // 0: Todos, 1: Productos, 2: Servicios, 3: Preguntas, 4: Noticias, 5: Encuestas, 6: Ofertas

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('🔄 CommunityFeedPage: Cargando posts...');
      final posts = await _repo.getAll();
      debugPrint('✅ CommunityFeedPage: ${posts.length} posts recibidos');
      debugPrint('📊 Tipos de posts: ${posts.map((p) => p.type).toSet()}');
      
      // 🗳️ Log específico para encuestas
      final polls = posts.where((p) => p.type == PostType.poll).toList();
      debugPrint('🗳️ Encuestas encontradas: ${polls.length}');
      for (var poll in polls) {
        debugPrint('   - ${poll.title}');
        debugPrint('     Opciones: ${poll.pollOptions}');
        debugPrint('     Termina: ${poll.pollEndsAt}');
      }
      
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      debugPrint('✅ Estado actualizado con ${_posts.length} posts');
    } catch (e) {
      debugPrint('❌ Error cargando posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _isPostSaved(String postId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return false;

      final response = await _supabase
          .from('saved_posts')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('post_id', postId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error verificando si post está guardado: $e');
      return false;
    }
  }

  Future<void> _toggleSavePost(String postId) async {
    debugPrint('🔄 Iniciando _toggleSavePost para postId: $postId');
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Usuario no autenticado');
        return;
      }

      debugPrint('👤 Usuario actual: ${currentUser.id}');

      // Verificar si está guardado primero
      bool isSaved = false;
      const tableName = 'saved_posts';

      try {
        debugPrint('🔍 Verificando en tabla: $tableName');
        final checkResponse = await _supabase
            .from(tableName)
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('post_id', postId)
            .maybeSingle();

        isSaved = checkResponse != null;
        debugPrint('📊 Estado actual: $isSaved (response: $checkResponse)');
      } catch (e) {
        debugPrint('⚠️ Error verificando estado: $e');
        return;
      }

      // Ejecutar acción opuesta
      if (isSaved) {
        debugPrint('🗑️ Eliminando de guardados');
        await _supabase
            .from(tableName)
            .delete()
            .eq('user_id', currentUser.id)
            .eq('post_id', postId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eliminado de guardados'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColorsUnified.orange,
            ),
          );
        }
      } else {
        debugPrint('💾 Guardando post');
        await _supabase.from(tableName).insert({
          'user_id': currentUser.id,
          'post_id': postId,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post guardado'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColorsUnified.success,
            ),
          );
        }
      }
      
      debugPrint('✅ Operación completada exitosamente');
      // Forzar rebuild del widget después del cambio
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error guardando post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  void _showNewsDetailModal(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                    AppColorsUnified.companyBlue,
                    AppColorsUnified.companyBlue.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.article, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Noticia',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.title,
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
                    // Fuente y Autor
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.companyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColorsUnified.companyBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.source, color: AppColorsUnified.companyBlue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.newsSource ?? 'Fuente desconocida',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsUnified.companyBlue,
                                  ),
                                ),
                                if (post.newsAuthor != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Por ${post.newsAuthor}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColorsUnified.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contenido completo
                    const Text(
                      'Contenido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColorsUnified.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColorsUnified.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Post> get _filteredPosts {
    debugPrint('🔍 Filtrando posts: filtro=$_selectedFilter, total=${_posts.length}');
    List<Post> filtered;
    switch (_selectedFilter) {
      case 1: // Productos
        filtered = _posts.where((p) => p.type == PostType.product).toList();
        break;
      case 2: // Servicios
        filtered = _posts.where((p) => p.type == PostType.service).toList();
        break;
      case 3: // Preguntas
        filtered = _posts.where((p) => p.type == PostType.request).toList();
        break;
      case 4: // Noticias
        filtered = _posts.where((p) => p.type == PostType.news).toList();
        break;
      case 5: // Encuestas
        filtered = _posts.where((p) => p.type == PostType.poll).toList();
        break;
      case 6: // Ofertas
        filtered = _posts.where((p) => p.type == PostType.offer).toList();
        break;
      default: // Todos
        filtered = _posts;
    }
    debugPrint('✅ Posts filtrados: ${filtered.length}');
    return filtered;
  }

  String _getPostTypeLabel(Post post) {
    switch (post.type) {
      case PostType.request:
        return 'Pregunta';
      case PostType.offer:
        return post.serviceName != null ? 'Servicio' : 'Oferta';
      case PostType.product:
        return 'Producto';
      case PostType.service:
        return 'Servicio';
      case PostType.news:
        return 'Noticia';
      case PostType.poll:
        return 'Encuesta';
      default:
        return 'Publicación';
    }
  }

  IconData _getPostTypeIcon(Post post) {
    switch (post.type) {
      case PostType.request:
        return Icons.help_outline;
      case PostType.offer:
        return Icons.local_offer;
      case PostType.product:
        return Icons.shopping_bag_outlined;
      case PostType.service:
        return Icons.work_outline;
      case PostType.news:
        return Icons.newspaper;
      case PostType.poll:
        return Icons.poll;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColorsUnified.orange, AppColorsUnified.fade(AppColorsUnified.orange, 0.8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.people, color: AppColorsUnified.pureWhite, size: 28),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: AppColorsUnified.pureWhite, size: 28),
                            onPressed: () async {
                              final currentUser = SupabaseAuthService.instance.currentUser;
                              if (currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debes iniciar sesión para publicar')),
                                );
                                return;
                              }

                              final profile = SupabaseAuthService.instance.currentUserProfile;
                              final authorName = profile?['name'] ?? profile?['username'] ?? 'Usuario';

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColorsUnified.pureWhite,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => PostCreationSheet(
                                  create: _repo.create,
                                  authorName: authorName,
                                  onCreated: (post) {
                                    _loadPosts(); // Recargar posts
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('✅ Publicación creada')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Comunidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColorsUnified.pureWhite)),
                      const SizedBox(height: 8),
                      Text('Conecta, comparte y descubre oportunidades', style: TextStyle(fontSize: 14, color: AppColorsUnified.pureWhite)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip('${_posts.length} Publicaciones'),
                          const SizedBox(width: 12),
                          _buildStatChip('0 Sugerencias'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorsUnified.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en la comunidad...',
                    prefixIcon: Icon(Icons.search, color: AppColorsUnified.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('Todos', 0, Icons.grid_view),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Productos', 1, Icons.shopping_bag),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Servicios', 2, Icons.work),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Preguntas', 3, Icons.help),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Noticias', 4, Icons.article),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Encuestas', 5, Icons.poll),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Ofertas', 6, Icons.local_offer),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: AppColorsUnified.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredPosts.length} resultados',
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_filteredPosts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)),
                    const SizedBox(height: 16),
                    const Text('No hay publicaciones', style: TextStyle(fontSize: 16, color: AppColorsUnified.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Sé el primero en publicar', style: TextStyle(fontSize: 14, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2))),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(_filteredPosts[index]),
                childCount: _filteredPosts.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
      ),
      child: Text(text, style: TextStyle(color: AppColorsUnified.pureWhite, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCategoryChip(String label, int index, IconData icon) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColorsUnified.orange : AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? AppColorsUnified.orange : AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)),
          boxShadow: isSelected ? [BoxShadow(color: AppColorsUnified.fade(AppColorsUnified.orange, 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColorsUnified.pureWhite : AppColorsUnified.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? AppColorsUnified.pureWhite : AppColorsUnified.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    // 🎨 POSTS DE PRODUCTO: Sin contenedor, solo carousel flotante
    if (post.type == PostType.product) {
      return _buildProductPost(post);
    }

    // Posts normales con contenedor
    final bool isUrgent = post.categories.any((cat) =>
      cat.toLowerCase().contains('urgente') ||
      cat.toLowerCase().contains('importante') ||
      cat.toLowerCase().contains('oportunidad')
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isUrgent
          ? RichDecorations.rubyGemCard(isElevated: true)
          : BoxDecoration(
              color: AppColorsUnified.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 BADGE URGENTE - Si aplica
            if (isUrgent) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: RichDecorations.rubyGemBadge(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.priority_high, color: AppColorsUnified.pureWhite, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'URGENTE',
                      style: TextStyle(
                        color: AppColorsUnified.pureWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 📝 SECCIÓN PRINCIPAL: Header + Contenido como bloque único
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del autor con botón de guardar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isUrgent
                          ? AppColorsUnified.fade(AppColorsUnified.orangeDark, 0.3)
                          : AppColorsUnified.fade(AppColorsUnified.orange, 0.2),
                      backgroundImage: post.authorProfileImage != null 
                          ? NetworkImage(post.authorProfileImage!) 
                          : null,
                      child: post.authorProfileImage == null
                          ? Text(
                              (post.authorName ?? post.authorId).substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: isUrgent ? AppColorsUnified.orangeDark : AppColorsUnified.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName ?? post.authorUsername ?? 'Usuario ${post.authorId.substring(0, 8)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isUrgent ? AppColorsUnified.orangeDark : AppColorsUnified.charcoal,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(_getPostTypeIcon(post), size: 14, color: AppColorsUnified.textSecondary),
                              const SizedBox(width: 4),
                              Text(_getPostTypeLabel(post), style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12)),
                              const SizedBox(width: 8),
                              Text('· ${_getTimeAgo(post.createdAt)}', style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Botón de guardar
                    FutureBuilder<bool>(
                      future: _isPostSaved(post.id),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
                            size: 24,
                          ),
                          onPressed: () => _toggleSavePost(post.id),
                        );
                      },
                    ),
                  ],
                ),
                
                // Para preguntas, el título y contenido se muestran en el bloque dorado
                // Para otros tipos de posts, mostrar título y contenido aquí
                if (post.type != PostType.request) ...[
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: isUrgent ? AppColorsUnified.orangeDark : AppColorsUnified.charcoal,
                    ),
                  ),
                  if (post.type != PostType.poll) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.content, 
                      style: const TextStyle(
                        fontSize: 14, 
                        color: AppColorsUnified.textPrimary, 
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
                
                // Tags integrados
                if (post.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.categories.take(3).map((cat) {
                      final bool isUrgentTag = cat.toLowerCase().contains('urgente') ||
                                               cat.toLowerCase().contains('importante');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: isUrgentTag
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColorsUnified.fade(AppColorsUnified.orangeDark, 0.3),
                                    AppColorsUnified.fade(AppColorsUnified.orange, 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColorsUnified.fade(AppColorsUnified.orangeDark, 0.6),
                                  width: 1.5,
                                ),
                              )
                            : BoxDecoration(
                                color: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isUrgentTag ? AppColorsUnified.orangeDark : AppColorsUnified.orange,
                            fontSize: 12,
                            fontWeight: isUrgentTag ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),

            // 🎨 CONTENIDO MULTIMEDIA Y CTA - Integrado en el flujo
            const SizedBox(height: 20),
            
            OptimizedPostContent(post: post),

            if (post.imageUrl != null && post.type == PostType.community) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppColorsUnified.background,
                    child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColorsUnified.textSecondary)),
                  ),
                ),
              ),
            ],

            // CTA ÉPICO para NOTICIAS
            if (post.type == PostType.news) ...[
              const SizedBox(height: 20),
              _NewsInteractiveCTA(
                post: post,
                newsSource: post.newsSource ?? 'Fuente desconocida',
                onReadMore: () {
                  _showNewsDetailModal(context, post);
                },
                onSave: () async {
                  await _toggleSavePost(post.id);
                },
              ),
            ],

            // CTA ÉPICO para ENCUESTAS
            if (post.type == PostType.poll) ...[
              const SizedBox(height: 20),
              _PollInteractiveCTA(
                post: post,
                onVote: (option) {
                  debugPrint('Voto: $option en poll ${post.id}');
                },
                onSave: () async {
                  await _toggleSavePost(post.id);
                },
              ),
            ],

            // CTA ÉPICO para OFERTAS
            if (post.type == PostType.offer) ...[
              const SizedBox(height: 20),
              _OfferInteractiveCTA(
                post: post,
                onContact: () {
                  debugPrint('💬 Contactar por oferta: ${post.id}');
                },
                onSave: () {
                  debugPrint('⭐ Guardar oferta: ${post.id}');
                  _toggleSavePost(post.id);
                },
              ),
            ],

            // CTA para GUARDAR eliminado - ahora está en el header

            // Botones de interacción movidos al final para mejor flujo visual
            
            // 🎯 SECCIÓN DE RESPUESTAS UNIFICADA VISUALMENTE - Para preguntas
            if (post.type == PostType.request) ...[
              const SizedBox(height: 28),
              
              // BLOQUE UNIFICADO: Pregunta + Responder + Respuestas
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsUnified.fade(AppColorsUnified.gold, 0.03),
                      AppColorsUnified.fade(AppColorsUnified.goldDeep, 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.15),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header unificado con pregunta
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColorsUnified.gold.withOpacity(0.15),
                                  AppColorsUnified.goldDeep.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.help_rounded,
                              color: AppColorsUnified.gold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColorsUnified.gold,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Comparte tu conocimiento y ayuda',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColorsUnified.fade(AppColorsUnified.textSecondary, 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 18),
                      
                      // Botón de responder unificado con el diseño
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ResponseModal(
                                post: post,
                                onResponseAdded: () {
                                  setState(() {});
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColorsUnified.gold,
                                  AppColorsUnified.goldDeep,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.gold.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Escribir Respuesta',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Respuestas integradas con el mismo diseño unificado
                      ResponsesList(post: post),
                    ],
                  ),
                ),
              ),
              
              // Botones de interacción al final (like, guardar, compartir)
              const SizedBox(height: 24),
              
              // Separador sutil antes de interacciones
              Container(
                height: 1,
                color: AppColorsUnified.fade(AppColorsUnified.grey300, 0.4),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildActionButton(Icons.favorite_border, '${post.likes}', () async {
                    try {
                      await _repo.like(post.id);
                      _loadPosts();
                    } catch (e) {
                      debugPrint('❌ Error al dar like: $e');
                    }
                  }),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _toggleSavePost(post.id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return FutureBuilder<bool>(
                            future: _isPostSaved(post.id),
                            builder: (context, snapshot) {
                              final isSaved = snapshot.data ?? false;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSaved
                                      ? LinearGradient(
                                          colors: [
                                            AppColorsUnified.success,
                                            AppColorsUnified.success.withOpacity(0.8),
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            AppColorsUnified.grey200,
                                            AppColorsUnified.grey300,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isSaved ? Colors.white : AppColorsUnified.textSecondary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isSaved ? 'Guardado' : 'Guardar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSaved ? Colors.white : AppColorsUnified.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(Icons.share_outlined, 'Compartir', () {}),
                ],
              ),
            ] else ...[
              // Para otros tipos de posts, mantener botones de interacción normales
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: AppColorsUnified.fade(AppColorsUnified.grey300, 0.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton(Icons.favorite_border, '${post.likes}', () async {
                    try {
                      await _repo.like(post.id);
                      _loadPosts();
                    } catch (e) {
                      debugPrint('❌ Error al dar like: $e');
                    }
                  }),
                  const SizedBox(width: 20),
                  _buildActionButton(Icons.chat_bubble_outline, '${post.comments}', () async {
                    try {
                      final currentUser = SupabaseAuthService.instance.currentUser;
                      if (currentUser == null) return;

                      final conversation = {
                        'id': '${currentUser.id}_${post.authorId}',
                        'otherUserId': post.authorId,
                        'otherUserName': post.authorName ?? 'Usuario',
                        'otherUserAvatar': null,
                        'lastMessage': 'Interesado en tu post',
                        'timestamp': DateTime.now().toIso8601String(),
                        'unreadCount': 0,
                      };

                      Navigator.pushNamed(
                        context,
                        '/chat-detail',
                        arguments: conversation,
                      );
                    } catch (e) {
                      debugPrint('❌ Error abriendo chat: $e');
                    }
                  }),
                  const SizedBox(width: 20),
                  _buildActionButton(Icons.share_outlined, 'Compartir', () {}),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColorsUnified.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColorsUnified.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  /// 🎨 POST DE PRODUCTO - Sin contenedor blanco, solo carousel flotante
  Widget _buildProductPost(Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 💎 CAROUSEL 3D PREMIUM - Con TODA la info integrada (autor, título, precio, acciones)
        OptimizedPostContent(
          post: post,
          onLike: () async {
            try {
              await _repo.like(post.id);
              _loadPosts();
            } catch (e) {
              debugPrint('❌ Error al dar like: $e');
            }
          },
          onComment: () {
            // Navegar a comentarios
          },
          onShare: () {
            // Compartir post
          },
          onSave: () async {
            await _toggleSavePost(post.id);
          },
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  String _getTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} años';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} meses';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Ahora';
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Image.network(
                    widget.images[index],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColorsUnified.background,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColorsUnified.orange,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColorsUnified.background,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)),
                      const SizedBox(height: 8),
                      const Text('Error al cargar', style: TextStyle(color: AppColorsUnified.textSecondary)),
                    ],
                  ),
                ),
              );
            },
          ),

          if (widget.images.length > 1) ...[
            if (_currentPage > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _previousPage,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: AppColorsUnified.pureWhite,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentPage < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _nextPage,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColorsUnified.pureWhite,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],

          if (widget.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? AppColorsUnified.orange
                          : AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          if (widget.images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.images.length}',
                  style: TextStyle(
                    color: AppColorsUnified.pureWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎯 CTA ÉPICO PARA NOTICIAS - Ultra interactivo y estético
// ═══════════════════════════════════════════════════════════════
class _NewsInteractiveCTA extends StatefulWidget {
  final Post post;
  final String newsSource;
  final VoidCallback onReadMore;
  final VoidCallback onSave;

  const _NewsInteractiveCTA({
    required this.post,
    required this.newsSource,
    required this.onReadMore,
    required this.onSave,
  });

  @override
  State<_NewsInteractiveCTA> createState() => _NewsInteractiveCTAState();
}

class _NewsInteractiveCTAState extends State<_NewsInteractiveCTA>
    with SingleTickerProviderStateMixin {
  final _supabase = SupabaseService.instance.client;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHoveringRead = false;
  bool _isHoveringSave = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  Future<void> _checkIfSaved() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Verificar en saved_posts
      try {
        final response = await _supabase
            .from('saved_posts')
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        if (mounted) {
          setState(() => _isSaved = response != null);
        }
      } catch (e) {
        debugPrint('⚠️ Error verificando guardado: $e');
      }
    } catch (e) {
      debugPrint('❌ Error verificando guardado: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsUnified.companyBlue.withOpacity(0.04),
              AppColorsUnified.grey50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColorsUnified.companyBlue.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.companyBlue.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header con fuente de la noticia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsUnified.companyBlue.withOpacity(0.03),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.companyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: AppColorsUnified.companyBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fuente verificada',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.newsSource,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColorsUnified.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColorsUnified.companyBlue,
                    size: 22,
                  ),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Botón "Leer Completa" con pulse
                  Expanded(
                    flex: 3,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringRead = true),
                      onExit: (_) => setState(() => _isHoveringRead = false),
                      child: AnimatedScale(
                        scale: _isHoveringRead ? 1.02 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isHoveringRead ? 1.0 : _pulseAnimation.value,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onReadMore,
                                  borderRadius: BorderRadius.circular(14),
                                  splashColor: AppColorsUnified.companyBlue.withOpacity(0.3),
                                  highlightColor: AppColorsUnified.companyBlue.withOpacity(0.2),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColorsUnified.companyBlue,
                                          AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColorsUnified.companyBlue.withOpacity(0.4),
                                          blurRadius: _isHoveringRead ? 16 : 12,
                                          spreadRadius: _isHoveringRead ? 2 : 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.article_rounded,
                                          color: Color(0xFFFAFAFA),
                                          size: 24,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Leer Completa',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFAFAFA),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Color(0xFFFAFAFA),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botón Guardar con animación
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringSave = true),
                    onExit: (_) => setState(() => _isHoveringSave = false),
                    child: AnimatedScale(
                      scale: _isHoveringSave ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _isSaved = !_isSaved);
                            widget.onSave();
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isSaved 
                                  ? AppColorsUnified.gold.withOpacity(0.15)
                                  : AppColorsUnified.grey200,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isSaved
                                    ? AppColorsUnified.gold
                                    : AppColorsUnified.grey300,
                                width: _isSaved ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                              color: _isSaved
                                  ? AppColorsUnified.gold
                                  : AppColorsUnified.textSecondary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🗳️ CTA ÉPICO PARA ENCUESTAS - Ultra interactivo con votación real
// ═══════════════════════════════════════════════════════════════
class _PollInteractiveCTA extends StatefulWidget {
  final Post post;
  final Function(String) onVote;
  final VoidCallback onSave;

  const _PollInteractiveCTA({
    required this.post,
    required this.onVote,
    required this.onSave,
  });

  @override
  State<_PollInteractiveCTA> createState() => _PollInteractiveCTAState();
}

class _PollInteractiveCTAState extends State<_PollInteractiveCTA> {
  final _repo = sl<PostRepository>();
  final _supabase = SupabaseService.instance.client;
  String? _selectedOption;
  String? _hoveredOption;
  Map<String, int> _realVotes = {};
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadPollData();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Intentar con saved_posts primero
      try {
        final response = await _supabase
            .from('saved_posts')
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        if (mounted) {
          setState(() => _isSaved = response != null);
        }
      } catch (e) {
        // Si saved_posts no existe, intentar con saved_offers
        final response = await _supabase
            .from('saved_offers')
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        if (mounted) {
          setState(() => _isSaved = response != null);
        }
      }
    } catch (e) {
      debugPrint('❌ Error verificando guardado: $e');
    }
  }

  Future<void> _loadPollData() async {
    try {
      debugPrint('🔄 Cargando datos de encuesta ${widget.post.id}...');
      
      // Cargar votos reales desde la base de datos
      final votes = await _repo.getPollResults(widget.post.id);
      final userVote = await _repo.getUserVote(widget.post.id);
      
      debugPrint('📊 Votos obtenidos: $votes');
      debugPrint('✅ Voto del usuario: $userVote');
      
      if (mounted) {
        setState(() {
          _realVotes = votes;
          _selectedOption = userVote;
        });
        debugPrint('✅ Estado actualizado - selectedOption: $_selectedOption, realVotes: $_realVotes');
      }
    } catch (e) {
      debugPrint('❌ Error cargando datos del poll: $e');
    }
  }

  int get _totalVotes {
    return _realVotes.values.fold(0, (sum, votes) => sum + votes);
  }

  int _getVotes(String option) {
    return _realVotes[option] ?? 0;
  }

  double _getPercentage(String option) {
    if (_totalVotes == 0) return 0;
    return (_getVotes(option) / _totalVotes) * 100;
  }

  bool get _isPollEnded {
    if (widget.post.pollEndsAt == null) return false;
    return DateTime.now().isAfter(widget.post.pollEndsAt!);
  }

  String _formatDate(DateTime date) {
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleVote(String option) async {
    if (_isPollEnded) {
      debugPrint('⏰ Encuesta finalizada, no se puede votar');
      return;
    }

    try {
      debugPrint('🗳️ Votando por: $option en encuesta ${widget.post.id}');
      
      // Votar en la base de datos
      await _repo.votePoll(widget.post.id, option);
      debugPrint('✅ Voto enviado a base de datos');
      
      // Recargar resultados
      await _loadPollData();
      debugPrint('✅ Datos recargados después del voto');
      
      // Notificar al padre
      widget.onVote(option);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Voto registrado: $option'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColorsUnified.companyBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al votar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al registrar voto'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.post.pollOptions ?? [];
    
    debugPrint('═══════════════════════════════════════');
    debugPrint('🗳️ ANALIZANDO WIDGET _PollInteractiveCTA');
    debugPrint('═══════════════════════════════════════');
    debugPrint('📊 Post ID: ${widget.post.id}');
    debugPrint('📝 Post title: ${widget.post.title}');
    debugPrint('🔍 post.pollOptions (tipo): ${widget.post.pollOptions.runtimeType}');
    debugPrint('🔍 post.pollOptions (valor): ${widget.post.pollOptions}');
    debugPrint('📋 Opciones después del ?? []: $options');
    debugPrint('📌 Opciones count: ${options.length}');
    debugPrint('⏰ Poll ends at: ${widget.post.pollEndsAt}');
    debugPrint('🔐 _isPollEnded: $_isPollEnded');
    debugPrint('🗳️ _selectedOption: $_selectedOption');
    debugPrint('📊 _realVotes: $_realVotes');
    debugPrint('═══════════════════════════════════════');
    
    if (options.isEmpty) {
      debugPrint('⚠️ ENCUESTA SIN OPCIONES - widget.post.pollOptions es null o vacío');
      debugPrint('   Mostrando SizedBox.shrink()');
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsUnified.grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColorsUnified.grey300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con el título de la encuesta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.companyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.poll_rounded,
                          color: AppColorsUnified.companyBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Encuesta',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColorsUnified.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.post.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColorsUnified.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.how_to_vote_rounded, size: 14, color: AppColorsUnified.companyBlue),
                      const SizedBox(width: 6),
                      Text(
                        '${_totalVotes} ${_totalVotes == 1 ? "voto" : "votos"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Divisor
            Container(
              height: 1,
              color: AppColorsUnified.grey300,
            ),
            // Opciones interactivas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final votes = _getVotes(option);
                  final percentage = _getPercentage(option);
                  final isSelected = _selectedOption == option;
                  final isHovered = _hoveredOption == option;
                  final hasVoted = _selectedOption != null;
                  final isWinning = hasVoted && votes > 0 && percentage == options.map(_getPercentage).reduce((a, b) => a > b ? a : b);

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredOption = option),
                    onExit: (_) => setState(() => _hoveredOption = null),
                    child: Container(
                      margin: EdgeInsets.only(bottom: index < options.length - 1 ? 10 : 0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isPollEnded
                              ? null
                              : () => _handleVote(option),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: hasVoted && percentage > 0
                                  ? LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        isWinning
                                            ? AppColorsUnified.companyBlue.withOpacity(0.15)
                                            : AppColorsUnified.companyBlue.withOpacity(0.08),
                                        Colors.transparent,
                                      ],
                                      stops: [percentage / 100, percentage / 100],
                                    )
                                  : null,
                              color: hasVoted && percentage > 0
                                  ? null
                                  : isHovered
                                      ? AppColorsUnified.grey200
                                      : AppColorsUnified.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected && hasVoted
                                    ? AppColorsUnified.companyBlue
                                    : AppColorsUnified.grey300,
                                width: isSelected && hasVoted ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (hasVoted) ...[
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: isSelected
                                        ? AppColorsUnified.companyBlue
                                        : AppColorsUnified.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isWinning
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: AppColorsUnified.textPrimary,
                                        ),
                                      ),
                                      if (hasVoted) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${percentage.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isWinning
                                                    ? AppColorsUnified.companyBlue
                                                    : AppColorsUnified.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '($votes)',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColorsUnified.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (!hasVoted)
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColorsUnified.textSecondary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer - Mensaje según estado
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _isPollEnded
                  ? Row(
                      children: [
                        const Icon(
                          Icons.timer_off_rounded,
                          color: AppColorsUnified.error,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Encuesta finalizada el ${_formatDate(widget.post.pollEndsAt!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColorsUnified.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : _selectedOption == null
                      ? const Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: AppColorsUnified.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Toca una opción para votar',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColorsUnified.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColorsUnified.companyBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Total de votos: $_totalVotes',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColorsUnified.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
            ),

            // Botón de guardado
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColorsUnified.grey300,
                    width: 1,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _isSaved = !_isSaved);
                    widget.onSave();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _isSaved
                          ? AppColorsUnified.gold.withOpacity(0.1)
                          : AppColorsUnified.grey200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSaved
                            ? AppColorsUnified.gold
                            : AppColorsUnified.grey300,
                        width: _isSaved ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: _isSaved
                              ? AppColorsUnified.gold
                              : AppColorsUnified.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSaved ? '✓ Guardado' : 'Guardar Encuesta',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _isSaved
                                ? AppColorsUnified.gold
                                : AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 💼 CTA ÉPICO PARA OFERTAS - Precio y contacto instantáneo
// ═══════════════════════════════════════════════════════════════
class _OfferInteractiveCTA extends StatefulWidget {
  final Post post;
  final VoidCallback onContact;
  final VoidCallback onSave;

  const _OfferInteractiveCTA({
    required this.post,
    required this.onContact,
    required this.onSave,
  });

  @override
  State<_OfferInteractiveCTA> createState() => _OfferInteractiveCTAState();
}

class _OfferInteractiveCTAState extends State<_OfferInteractiveCTA> {
  final _supabase = SupabaseService.instance.client;
  bool _isSaved = false;
  bool _isContactHovered = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Intentar con saved_posts primero
      try {
        final result = await _supabase
            .from('saved_posts')
            .select()
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        setState(() {
          _isSaved = result != null;
        });
        return;
      } catch (e) {
        // Si saved_posts no existe, intentar con saved_offers
        final result = await _supabase
            .from('saved_offers')
            .select()
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        setState(() {
          _isSaved = result != null;
        });
      }
    } catch (e) {
      debugPrint('❌ Error verificando post guardado: $e');
    }
  }

  Future<void> _toggleSaveOffer() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Determinar qué tabla usar
      String tableName = 'saved_posts';
      try {
        if (_isSaved) {
          await _supabase
              .from(tableName)
              .delete()
              .eq('user_id', currentUser.id)
              .eq('post_id', widget.post.id);
        } else {
          await _supabase.from(tableName).insert({
            'user_id': currentUser.id,
            'post_id': widget.post.id,
          });
        }
      } catch (e) {
        // Si saved_posts no existe, usar saved_offers
        tableName = 'saved_offers';
        if (_isSaved) {
          await _supabase
              .from(tableName)
              .delete()
              .eq('user_id', currentUser.id)
              .eq('post_id', widget.post.id);
        } else {
          await _supabase.from(tableName).insert({
            'user_id': currentUser.id,
            'post_id': widget.post.id,
          });
        }
      }

      setState(() => _isSaved = !_isSaved);
      widget.onSave();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? '✅ Guardado' : 'Eliminado de guardados'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColorsUnified.companyBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando post: $e');
    }
  }

  Future<void> _openChat() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Crear objeto de conversación compatible con ChatDetailPage
      final conversation = {
        'id': '${currentUser.id}_${widget.post.authorId}',
        'otherUserId': widget.post.authorId,
        'otherUserName': widget.post.authorName ?? 'Usuario',
        'otherUserAvatar': null, // TODO: Agregar avatar si está disponible
        'lastMessage': 'Interesado en tu oferta',
        'timestamp': DateTime.now().toIso8601String(),
        'unreadCount': 0,
      };

      // Navegar a chat
      Navigator.pushNamed(
        context,
        '/chat-detail',
        arguments: conversation,
      );

      widget.onContact();
    } catch (e) {
      debugPrint('❌ Error abriendo chat: $e');
    }
  }

  String _formatPrice() {
    final from = widget.post.pricingFrom;
    final to = widget.post.pricingTo;
    final unit = widget.post.pricingUnit ?? 'USD';

    if (from != null && to != null) {
      return '\$$from - \$$to $unit';
    } else if (from != null) {
      return 'Desde \$$from $unit';
    } else {
      return 'Precio a consultar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsUnified.companyBlue.withOpacity(0.05),
              AppColorsUnified.grey50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColorsUnified.companyBlue.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre del servicio y disponibilidad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsUnified.companyBlue.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorsUnified.companyBlue,
                          AppColorsUnified.companyBlue.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.companyBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.serviceName ?? 'Oferta especial',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColorsUnified.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.post.availability == 'Disponible'
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.post.availability ?? 'Consultar disponibilidad',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: widget.post.availability == 'Disponible'
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botón guardar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSaveOffer,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedScale(
                          scale: _isSaved ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: _isSaved 
                                ? AppColorsUnified.companyBlue
                                : AppColorsUnified.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cuerpo con precio y etiquetas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio destacado
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        color: AppColorsUnified.companyBlue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColorsUnified.companyBlue,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  // Tags del servicio
                  if (widget.post.serviceTags != null && widget.post.serviceTags!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.post.serviceTags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColorsUnified.grey200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColorsUnified.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Botón de contacto principal
                  MouseRegion(
                    onEnter: (_) => setState(() => _isContactHovered = true),
                    onExit: (_) => setState(() => _isContactHovered = false),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openChat,
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColorsUnified.companyBlue,
                                AppColorsUnified.companyBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isContactHovered
                                ? [
                                    BoxShadow(
                                      color: AppColorsUnified.companyBlue.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: AppColorsUnified.companyBlue.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Contactar Ahora',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: _isContactHovered ? 0.1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CTA PARA GUARDAR - Interactivo con estado
// ═══════════════════════════════════════════════════════════════

class _SaveCTA extends StatefulWidget {
  final Post post;
  final Future<void> Function(String) onSave;

  const _SaveCTA({
    required this.post,
    required this.onSave,
  });

  @override
  State<_SaveCTA> createState() => _SaveCTAState();
}

class _SaveCTAState extends State<_SaveCTA> {
  final _supabase = SupabaseService.instance.client;
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    debugPrint('🔍 _SaveCTA: Verificando si post ${widget.post.id} (${widget.post.type}) está guardado');
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ _SaveCTA: Usuario no autenticado');
        return;
      }

      // Para productos, verificar si hay imágenes guardadas
      if (widget.post.type == PostType.product) {
        debugPrint('📦 _SaveCTA: Producto detectado - Imágenes: ${widget.post.productImages}');
      }

      // Verificar en saved_posts
      try {
        final response = await _supabase
            .from('saved_posts')
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post.id)
            .maybeSingle();

        if (mounted) {
          setState(() => _isSaved = response != null);
        }
        debugPrint('📊 _SaveCTA: Post ${widget.post.id} guardado: $_isSaved (response: $response)');
      } catch (e) {
        debugPrint('⚠️ _SaveCTA: Error verificando guardado: $e');
      }
    } catch (e) {
      debugPrint('❌ _SaveCTA: Error general: $e');
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    debugPrint('💾 _SaveCTA: Iniciando guardado para post ${widget.post.id} (${widget.post.type})');
    
    // Estado optimista: cambiar UI inmediatamente
    final wasState = _isSaved;
    setState(() {
      _isLoading = true;
      _isSaved = !_isSaved; // Cambio optimista
    });
    
    try {
      await widget.onSave(widget.post.id);
      debugPrint('✅ _SaveCTA: Guardado completado - Estado: $_isSaved');
    } catch (e) {
      debugPrint('❌ _SaveCTA: Error guardando: $e');
      // Revertir estado optimista en caso de error
      if (mounted) {
        setState(() => _isSaved = wasState);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para productos, mostrar información especial sobre imágenes
    final bool isProduct = widget.post.type == PostType.product;
    final int imageCount = widget.post.productImages?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isSaved
              ? AppColorsUnified.gold.withOpacity(0.1)
              : AppColorsUnified.grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSaved
                ? AppColorsUnified.gold.withOpacity(0.3)
                : AppColorsUnified.grey300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isSaved
                        ? AppColorsUnified.gold.withOpacity(0.2)
                        : AppColorsUnified.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: AppColorsUnified.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSaved ? 'Guardado en favoritos' : 'Guardar para después',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isSaved
                            ? 'Accede desde tus guardados'
                            : 'Accede fácilmente desde tus guardados',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                      // Información especial para productos
                      if (isProduct && imageCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '📸 $imageCount ${imageCount == 1 ? 'imagen' : 'imágenes'} incluida${imageCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColorsUnified.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _handleSave,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isSaved
                            ? AppColorsUnified.success
                            : AppColorsUnified.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLoading
                                ? Icons.hourglass_empty
                                : (_isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_rounded),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isLoading
                                ? 'Guardando...'
                                : (_isSaved ? '✓ Guardado' : 'Guardar'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Información adicional para productos guardados
            if (_isSaved && isProduct) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColorsUnified.gold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorsUnified.gold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColorsUnified.gold,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Producto guardado con todas sus imágenes y detalles',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

