import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/theme/premium_widgets.dart';
import 'core/di/locator.dart';
import 'core/auth/supabase_auth_service.dart';
import 'features/posts/domain/post_repository.dart';
import 'features/posts/ui/post_creation_sheet.dart';
import 'shared/models/post.dart';

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
      print('❌ Error cargando posts: $e');
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
          // Header con gradiente
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DashboardColors.cardOrange, DashboardColors.cardOrange.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people, color: Colors.white, size: 28),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                            onPressed: () async {
                              // Verificar si hay usuario autenticado
                              final currentUser = SupabaseAuthService.instance.currentUser;
                              if (currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debes iniciar sesión para publicar')),
                                );
                                return;
                              }

                              // Obtener perfil del usuario
                              final profile = await SupabaseAuthService.instance.currentUserProfile;
                              final authorName = profile?['name'] ?? profile?['username'] ?? 'Usuario';

                              // Mostrar el canvas de creación de posts
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
                      const SizedBox(height: 20),
                      const Text('Comunidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('Conecta, comparte y descubre oportunidades', style: TextStyle(fontSize: 14, color: Colors.white)),
                      const SizedBox(height: 20),
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

          // Barra de búsqueda
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
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

          // Filtros de categoría
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

          // Contador de posts filtrados
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

          // Lista de posts
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
          boxShadow: isSelected ? [BoxShadow(color: DashboardColors.cardOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: DashboardColors.cardOrange.withOpacity(0.2),
                  child: Text(
                    post.authorId.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: DashboardColors.cardOrange, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

          // Contenido del post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 8),
                Text(post.content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                if (post.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.categories.take(3).map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DashboardColors.cardOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(cat, style: TextStyle(color: DashboardColors.cardOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Producto (Product)
          if (post.type == PostType.product)
            _buildProductCard(post),

          // Noticia (News)
          if (post.type == PostType.news)
            _buildNewsCard(post),

          // Servicio (Service)
          if (post.type == PostType.service)
            _buildServiceCard(post),

          // Pregunta/Solicitud (Request) - Tipo Stack Overflow
          if (post.type == PostType.request)
            _buildQuestionCard(post),

          // Oferta laboral/comercial (Offer)
          if (post.type == PostType.offer)
            _buildOfferCard(post),

          // Imagen si existe (excepto para tipos con widget personalizado)
          if (post.imageUrl != null && 
              post.type != PostType.poll && 
              post.type != PostType.product && 
              post.type != PostType.news &&
              post.type != PostType.service &&
              post.type != PostType.offer &&
              post.type != PostType.request)
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

          // Encuesta (Poll)
          if (post.type == PostType.poll)
            _buildPollCard(post),

          const SizedBox(height: 16),

          // Acciones (like, comentar, compartir)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildActionButton(Icons.favorite_border, '${post.likes}', () async {
                  try {
                    await _repo.like(post.id);
                    _loadPosts();
                  } catch (e) {
                    print('❌ Error al dar like: $e');
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

  Widget _buildPollCard(Post post) {
    if (post.pollOptions == null || post.pollOptions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final pollVotes = post.pollVotes ?? {};
    final totalVotes = pollVotes.values.fold<int>(0, (sum, votes) => sum + votes);
    final pollEnded = post.pollEndsAt != null && DateTime.now().isAfter(post.pollEndsAt!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              DashboardColors.cardOrange.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DashboardColors.cardOrange.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: DashboardColors.cardOrange.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la encuesta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.cardOrange.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DashboardColors.cardOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.poll, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Encuesta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (post.pollAllowMultiple == true)
                          Text(
                            'Opción múltiple permitida',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (post.pollEndsAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pollEnded ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            pollEnded ? Icons.lock_clock : Icons.timer_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pollEnded ? 'Cerrada' : _getTimeRemaining(post.pollEndsAt!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Opciones de la encuesta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...post.pollOptions!.asMap().entries.map((entry) {
                    final optionIndex = entry.key;
                    final optionText = entry.value;
                    final votes = pollVotes[optionIndex.toString()] ?? 0;
                    final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;
                    final isWinning = totalVotes > 0 && votes > 0 && votes == pollVotes.values.reduce((a, b) => a > b ? a : b);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: pollEnded ? null : () => _voteOnPoll(post, optionIndex),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isWinning 
                                    ? DashboardColors.cardOrange 
                                    : Colors.grey.shade300,
                                width: isWinning ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isWinning)
                                  BoxShadow(
                                    color: DashboardColors.cardOrange.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Barra de progreso con gradiente
                                if (totalVotes > 0)
                                  Positioned.fill(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isWinning
                                                ? [
                                                    DashboardColors.cardOrange.withOpacity(0.3),
                                                    DashboardColors.cardOrange.withOpacity(0.1),
                                                  ]
                                                : [
                                                    Colors.grey.shade200,
                                                    Colors.grey.shade100,
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Contenido de la opción
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Letra o número de opción
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isWinning 
                                              ? DashboardColors.cardOrange 
                                              : Colors.grey.shade400,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + optionIndex), // A, B, C, D...
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isWinning ? FontWeight.bold : FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      if (totalVotes > 0) ...[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${percentage.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isWinning 
                                                    ? DashboardColors.cardOrange 
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                            Text(
                                              '$votes ${votes == 1 ? 'voto' : 'votos'}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isWinning) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.emoji_events,
                                            color: DashboardColors.cardOrange,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Total de votos y mensaje
                  if (totalVotes > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DashboardColors.cardOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_vote, size: 16, color: DashboardColors.cardOrange),
                          const SizedBox(width: 8),
                          Text(
                            '$totalVotes ${totalVotes == 1 ? 'persona ha votado' : 'personas han votado'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '¡Sé el primero en votar!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
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

  String _getTimeRemaining(DateTime endTime) {
    final diff = endTime.difference(DateTime.now());
    if (diff.isNegative) return 'Finalizada';
    if (diff.inDays > 0) return '${diff.inDays}d restantes';
    if (diff.inHours > 0) return '${diff.inHours}h restantes';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m restantes';
    return 'Finalizando';
  }

  void _voteOnPoll(Post post, int optionIndex) async {
    try {
      // TODO: Implementar votación en el repositorio
      print('📊 Votando opción $optionIndex en encuesta ${post.id}');
      // await _repo.voteOnPoll(post.id, optionIndex);
      // _loadPosts();
    } catch (e) {
      print('❌ Error al votar: $e');
    }
  }

  Widget _buildProductCard(Post post) {
    final hasImages = post.productImages != null && post.productImages!.isNotEmpty;
    final price = post.productPrice ?? 0.0;
    final currency = post.productCurrency ?? 'USD';
    final stock = post.productStock ?? 0;
    final condition = post.productCondition ?? 'Nuevo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PremiumWidgets.productCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes con badge flotante
            Stack(
              children: [
                hasImages
                    ? _buildImageCarousel(post.productImages!)
                    : _buildImagePlaceholder(),
                // Badge "PRODUCTO" premium
                Positioned(
                  top: 12,
                  right: 12,
                  child: PremiumWidgets.premiumBadge(
                    label: 'PRODUCTO',
                    icon: Icons.star,
                    gradientColors: [
                      DashboardColors.gold,
                      DashboardColors.goldLight,
                      DashboardColors.goldDark,
                    ],
                  ),
                ),
              ],
            ),

                  // Información del producto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          const Color(0xFFFFFAF0).withOpacity(0.3),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Precio premium con badges y efectos brillantes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Precio con efectos brillantes (shimmer + pulse)
                            PremiumWidgets.shimmerEffect(
                              child: PremiumWidgets.pulsingBorder(
                                color: DashboardColors.gold,
                                child: PremiumWidgets.priceContainer(
                                  price: price.toString(),
                                  currency: currency,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                PremiumWidgets.conditionBadge(
                                  condition: condition,
                                ),
                                const SizedBox(width: 8),
                                PremiumWidgets.stockBadge(stock: stock),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Botones de acción premium
                        Row(
                          children: [
                            Expanded(
                              // Botón dorado con efectos brillantes
                              child: PremiumWidgets.shimmerEffect(
                                duration: const Duration(seconds: 3),
                                child: PremiumWidgets.goldButton(
                                  label: 'Agregar al carrito',
                                  icon: Icons.shopping_cart,
                                  onPressed: stock > 0 ? () => _addToCart(post) : () {},
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PremiumWidgets.iconButton(
                              icon: Icons.visibility,
                              onPressed: () => _viewProductDetails(post),
                              color: DashboardColors.gold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
    );
  }

  void _addToCart(Post post) {
    // TODO: Implementar agregar al carrito
    print('🛒 Agregando producto ${post.id} al carrito');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${post.title} agregado al carrito'),
        backgroundColor: DashboardColors.cardOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewProductDetails(Post post) {
    // TODO: Navegar a ProductDetailPage
    print('👁️ Viendo detalles del producto ${post.id}');
    Navigator.pushNamed(context, '/product-detail', arguments: post);
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

  // Carrusel de imágenes con indicadores
  Widget _buildImageCarousel(List<String> images) {
    return _ImageCarousel(images: images);
  }

  // Widget de noticia tipo artículo
  Widget _buildNewsCard(Post post) {
    final hasCoverImage = post.newsCoverImage != null && post.newsCoverImage!.isNotEmpty;
    final source = post.newsSource ?? 'Fuente desconocida';
    final author = post.newsAuthor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            if (hasCoverImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  children: [
                    Image.network(
                      post.newsCoverImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Error al cargar imagen', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                    // Badge de "NOTICIA"
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.blue.shade500],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.article, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'NOTICIA',
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
                    ),
                  ],
                ),
              ),

            // Contenido de la noticia
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de fuente/autor
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.newspaper, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              source,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (author != null && author.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey.shade700),
                              const SizedBox(width: 4),
                              Text(
                                author,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Título con estilo de artículo
                  if (post.title.isNotEmpty)
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        height: 1.3,
                      ),
                    ),

                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Botón "Leer más"
                  InkWell(
                    onTap: () {
                      // TODO: Navegar a página de detalle de noticia
                      print('📰 Leer noticia completa: ${post.id}');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade700],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Leer más',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
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

  // Widget de servicio profesional
  Widget _buildServiceCard(Post post) {
    final serviceName = post.serviceName ?? post.title;
    final tags = post.serviceTags ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purple.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del servicio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade700],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.room_service,
                      size: 24,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SERVICIO PROFESIONAL',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          serviceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber.shade300),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido del servicio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción del servicio
                  if (post.content.isNotEmpty)
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Tags/Categorías
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.label,
                                size: 14,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Características del servicio
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildServiceFeature(
                          Icons.verified_user,
                          'Profesional verificado',
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildServiceFeature(
                          Icons.schedule,
                          'Disponibilidad inmediata',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildServiceFeature(
                          Icons.workspace_premium,
                          'Garantía de calidad',
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('📞 Contactar servicio: ${post.id}');
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Contactar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            print('ℹ️ Ver detalles servicio: ${post.id}');
                          },
                          icon: Icon(Icons.info_outline, size: 18, color: Colors.purple.shade700),
                          label: Text(
                            'Detalles',
                            style: TextStyle(color: Colors.purple.shade700),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.purple.shade600, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para características del servicio
  Widget _buildServiceFeature(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Icon(Icons.check_circle, size: 18, color: color),
      ],
    );
  }

  // Widget de pregunta tipo Stack Overflow
  Widget _buildQuestionCard(Post post) {
    final requiredTags = post.requiredTags ?? [];
    final answersCount = post.comments; // Usamos comments como respuestas
    final hasAcceptedAnswer = answersCount > 0; // Simulamos si tiene respuesta aceptada
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con badge de pregunta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.white],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PREGUNTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasAcceptedAnswer ? Colors.green : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasAcceptedAnswer ? Icons.check_circle : Icons.help_outline,
                          size: 14,
                          color: hasAcceptedAnswer ? Colors.white : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasAcceptedAnswer ? 'Resuelta' : 'Sin resolver',
                          style: TextStyle(
                            fontSize: 11,
                            color: hasAcceptedAnswer ? Colors.white : Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido de la pregunta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la pregunta
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contenido/descripción
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Tags/categorías
                  if (requiredTags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: requiredTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.label, size: 12, color: Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Estadísticas de la pregunta
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuestionStat(
                          Icons.visibility_outlined,
                          '${post.likes * 5}',
                          'Vistas',
                          Colors.blue,
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildQuestionStat(
                          Icons.chat_bubble_outline,
                          '$answersCount',
                          'Respuestas',
                          Colors.green,
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildQuestionStat(
                          Icons.favorite_border,
                          '${post.likes}',
                          'Útil',
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de responder
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('💬 Responder pregunta: ${post.id}');
                      },
                      icon: const Icon(Icons.reply, size: 18),
                      label: const Text('Responder pregunta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  // Helper para estadísticas de pregunta
  Widget _buildQuestionStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Widget de oferta laboral/comercial
  Widget _buildOfferCard(Post post) {
    final serviceName = post.serviceName ?? post.title;
    final tags = post.serviceTags ?? [];
    final pricingFrom = post.pricingFrom;
    final pricingTo = post.pricingTo;
    final availability = post.availability ?? 'Disponible';
    
    // Simulación de deadline y plazas (en producción vendría de metadata)
    final deadline = post.deadline ?? DateTime.now().add(const Duration(days: 15));
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    final hoursLeft = deadline.difference(DateTime.now()).inHours;
    final interested = post.likes * 3; // Simulación de interesados
    final maxSlots = 10; // Plazas máximas
    final availableSlots = maxSlots - (interested % maxSlots);
    
    // Determinar urgencia
    final isUrgent = daysLeft <= 3;
    final isNew = post.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 2)));
    final isHot = interested > 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isUrgent ? Colors.orange.shade50 : Colors.green.shade50,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? Colors.orange.shade300 : Colors.green.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isUrgent ? Colors.orange : Colors.green).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la oferta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUrgent 
                      ? [Colors.orange.shade600, Colors.orange.shade700]
                      : [Colors.green.shade600, Colors.green.shade700],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.local_offer,
                          size: 24,
                          color: isUrgent ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'OFERTA',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (isNew) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'NUEVO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isHot) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                                        SizedBox(width: 2),
                                        Text(
                                          'POPULAR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              serviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón anclar/guardar
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            print('📌 Anclar oferta: ${post.id}');
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Estadísticas en el header
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Tiempo restante
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUrgent ? Icons.warning_amber : Icons.access_time,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  daysLeft > 0 
                                      ? '$daysLeft ${daysLeft == 1 ? 'día' : 'días'} restantes'
                                      : '$hoursLeft horas restantes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Interesados
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              '$interested interesados',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido de la oferta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta de plazas limitadas
                  if (availableSlots <= 3)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '¡Solo quedan $availableSlots ${availableSlots == 1 ? 'plaza' : 'plazas'} disponibles!',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Descripción
                  if (post.content.isNotEmpty)
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Rango de precio si existe
                  if (pricingFrom != null || pricingTo != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_money, size: 24, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compensación',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pricingFrom != null && pricingTo != null
                                    ? '\$${pricingFrom.toStringAsFixed(0)} - \$${pricingTo.toStringAsFixed(0)}'
                                    : pricingFrom != null
                                        ? 'Desde \$${pricingFrom.toStringAsFixed(0)}'
                                        : 'Hasta \$${pricingTo!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Tags/Categorías
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.label,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('✅ Aplicar a oferta: ${post.id}');
                          },
                          icon: const Icon(Icons.send, size: 18),
                          label: Text(isUrgent ? '¡Aplicar Ya!' : 'Aplicar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrgent ? Colors.orange.shade600 : Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          print('ℹ️ Ver detalles oferta: ${post.id}');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          side: BorderSide(color: Colors.green.shade600, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.info_outline, size: 20, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder cuando no hay imágenes
  Widget _buildImagePlaceholder() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 250,
        child: Container(
          color: Colors.grey.shade100,
          child: Stack(
          children: [
            // Patrón de cuadros
          Positioned.fill(
            child: CustomPaint(
              painter: _CheckerboardPainter(),
            ),
          ),
          // Icono central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sin imágenes',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

// Widget de carrusel de imágenes con estado
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
          
          // Botones de navegación (flechas)
          if (widget.images.length > 1) ...[
            // Flecha izquierda
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
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
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
            // Flecha derecha
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
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
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
          
          // Indicadores de página (puntos)
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
                          : Colors.white.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          // Contador en la esquina superior derecha
          if (widget.images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
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

// Painter para el patrón de cuadros
class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade200;
    const squareSize = 20.0;

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        if (((x / squareSize) + (y / squareSize)) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
