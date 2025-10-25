import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
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
  int _selectedFilter = 0; // 0: Todos, 1: Ventas, 2: Preguntas, 3: Servicios

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
      case 1: // Ventas
        return _posts.where((p) => p.type == PostType.offer).toList();
      case 2: // Preguntas
        return _posts.where((p) => p.type == PostType.request).toList();
      case 3: // Servicios
        return _posts.where((p) => p.type == PostType.offer && p.serviceName != null).toList();
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

          // Filtros de categoría (Todos, Ventas, Preguntas, Servicios)
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('Todos', 0, Icons.grid_view),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Ventas', 1, Icons.shopping_bag),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Preguntas', 2, Icons.help),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Servicios', 3, Icons.work),
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

          // Imagen si existe
          if (post.imageUrl != null && post.type != PostType.poll)
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.poll, size: 20, color: DashboardColors.cardOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Encuesta${post.pollAllowMultiple == true ? ' (Opción múltiple)' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                if (post.pollEndsAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pollEnded ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pollEnded ? 'Finalizada' : _getTimeRemaining(post.pollEndsAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: pollEnded ? Colors.red.shade700 : Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Opciones de la encuesta
            ...post.pollOptions!.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final optionText = entry.value;
              final votes = pollVotes[optionIndex.toString()] ?? 0;
              final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: pollEnded ? null : () => _voteOnPoll(post, optionIndex),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: votes > 0 ? DashboardColors.cardOrange.withOpacity(0.3) : Colors.grey.shade300,
                        width: votes > 0 ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Barra de progreso
                        if (totalVotes > 0)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: DashboardColors.cardOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        
                        // Contenido de la opción
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: votes > 0 ? FontWeight.w600 : FontWeight.normal,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            if (totalVotes > 0) ...[
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DashboardColors.cardOrange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$votes ${votes == 1 ? 'voto' : 'votos'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            // Total de votos
            if (totalVotes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$totalVotes ${totalVotes == 1 ? 'voto total' : 'votos totales'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
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
