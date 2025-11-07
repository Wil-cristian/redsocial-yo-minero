import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/theme/rich_decorations.dart';
import 'core/di/locator.dart';
import 'core/auth/supabase_auth_service.dart';
import 'features/posts/domain/post_repository.dart';
import 'features/posts/ui/post_creation_sheet.dart';
import 'shared/models/post.dart';
import 'shared/widgets/optimized_post_content.dart';

class CommunityFeedPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const CommunityFeedPage({super.key, this.currentUser});
  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final _repo = sl<PostRepository>();
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
      final posts = await _repo.getAll();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando posts: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Post> get _filteredPosts {
    switch (_selectedFilter) {
      case 1: // Productos
        return _posts.where((p) => p.type == PostType.product).toList();
      case 2: // Servicios
        return _posts.where((p) => p.type == PostType.service).toList();
      case 3: // Preguntas
        return _posts.where((p) => p.type == PostType.request).toList();
      case 4: // Noticias
        return _posts.where((p) => p.type == PostType.news).toList();
      case 5: // Encuestas
        return _posts.where((p) => p.type == PostType.poll).toList();
      case 6: // Ofertas
        return _posts.where((p) => p.type == PostType.offer).toList();
      default: // Todos
        return _posts;
    }
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
      backgroundColor: DashboardColors.lightGray,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DashboardColors.cardOrange, DashboardColors.cardOrange.withValues(alpha: 0.8)],
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people, color: Colors.white, size: 28),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
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
                                backgroundColor: Colors.white,
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
                      const Text('Comunidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('Conecta, comparte y descubre oportunidades', style: TextStyle(fontSize: 14, color: Colors.white)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en la comunidad...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icon(Icons.filter_list, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredPosts.length} resultados',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
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
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No hay publicaciones', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('Sé el primero en publicar', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCategoryChip(String label, int index, IconData icon) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? DashboardColors.cardOrange : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? DashboardColors.cardOrange : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: DashboardColors.cardOrange.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w600)),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUrgent)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: RichDecorations.rubyGemBadge(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.priority_high, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'URGENTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isUrgent
                      ? DashboardColors.rubyLight.withValues(alpha: 0.3)
                      : DashboardColors.cardOrange.withValues(alpha: 0.2),
                  child: Text(
                    post.authorId.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: isUrgent ? DashboardColors.rubyDeep : DashboardColors.cardOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isUrgent ? DashboardColors.rubyDeep : Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(_getPostTypeIcon(post), size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(_getPostTypeLabel(post), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('· ${_getTimeAgo(post.createdAt)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade400), onPressed: () {}),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: isUrgent ? DashboardColors.rubyDeep : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(post.content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
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
                                    DashboardColors.rubyLight.withValues(alpha: 0.3),
                                    DashboardColors.ruby.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: DashboardColors.rubyGlow.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              )
                            : BoxDecoration(
                                color: DashboardColors.cardOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isUrgentTag ? DashboardColors.rubyDeep : DashboardColors.cardOrange,
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
          ),

          const SizedBox(height: 16),

          OptimizedPostContent(post: post),

          if (post.imageUrl != null && post.type == PostType.community)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
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
                _buildActionButton(Icons.chat_bubble_outline, '${post.comments}', () {}),
                const SizedBox(width: 20),
                _buildActionButton(Icons.share_outlined, 'Compartir', () {}),
              ],
            ),
          ),
        ],
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
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
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
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: DashboardColors.cardOrange,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Error al cargar', style: TextStyle(color: Colors.grey.shade600)),
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
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
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
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
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
                          ? DashboardColors.cardOrange
                          : Colors.white.withValues(alpha: 0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
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
