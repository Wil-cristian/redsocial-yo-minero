import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';

class CommunityFeedPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CommunityFeedPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  late List<Map<String, dynamic>> _posts;
  final TextEditingController _postController = TextEditingController();
  int _selectedFilter = 0; // 0: Todos, 1: Ventas, 2: Preguntas, 3: Servicios

  @override
  void initState() {
    super.initState();
    _initializePosts();
  }

  void _initializePosts() {
    _posts = [
      {
        'id': '1',
        'author': 'Luis García',
        'avatar': 'L',
        'type': 'service', // service, product, question, info, post
        'title': 'Servicio de Perforación Especializada',
        'content': 'Ofrezco servicio de perforación con equipos de última generación. 25 años de experiencia en el sector minero. Presupuestos sin costo.',
        'image': null,
        'likes': 45,
        'comments': 12,
        'shares': 8,
        'timestamp': '2 horas',
        'liked': false,
      },
      {
        'id': '2',
        'author': 'María González',
        'avatar': 'M',
        'type': 'product',
        'title': '💰 Se venden herramientas de minería premium',
        'content': 'Martillos neumáticos, picos de tungsteno y equipos de seguridad. Precios competitivos. Envíos a todo el país.',
        'image': null,
        'likes': 78,
        'comments': 23,
        'shares': 15,
        'timestamp': '4 horas',
        'liked': false,
        'price': '\$250.000 - \$890.000',
      },
      {
        'id': '3',
        'author': 'Carlos Minería S.A.S',
        'avatar': 'C',
        'type': 'info',
        'title': '📢 Nuevas normativas de seguridad minera 2025',
        'content': 'El gobierno ha expedido nuevas regulaciones sobre protección ambiental y seguridad laboral. Les compartimos el resumen ejecutivo con los cambios más importantes.',
        'image': null,
        'likes': 156,
        'comments': 45,
        'shares': 89,
        'timestamp': '1 día',
        'liked': false,
      },
      {
        'id': '4',
        'author': 'Juan Pérez',
        'avatar': 'J',
        'type': 'question',
        'title': '❓ ¿Cuál es la mejor técnica de excavación para terrenos arcillosos?',
        'content': 'Tengo un proyecto en una zona con suelo muy arcilloso y necesito saber cuál es la mejor técnica y equipo para este tipo de terreno. ¿Alguien tiene experiencia?',
        'image': null,
        'likes': 23,
        'comments': 18,
        'shares': 5,
        'timestamp': '6 horas',
        'liked': false,
      },
      {
        'id': '5',
        'author': 'Ana Rodríguez',
        'avatar': 'A',
        'type': 'post',
        'title': 'Experiencia en el proyecto de exploración del norte',
        'content': 'Hoy terminamos la primera fase del proyecto de exploración. El equipo trabajó excelentemente y pudimos superar las metas planteadas. ¡Gracias a todos los involucrados!',
        'image': null,
        'likes': 67,
        'comments': 14,
        'shares': 9,
        'timestamp': '3 horas',
        'liked': false,
      },
      {
        'id': '6',
        'author': 'Roberto Silva',
        'avatar': 'R',
        'type': 'product',
        'title': '🔧 Se vende compresor industrial usado (buenas condiciones)',
        'content': 'Compresor 500L con poco uso, totalmente funcional. Precio: \$450.000. Interesados contactar al privado.',
        'image': null,
        'likes': 34,
        'comments': 8,
        'shares': 3,
        'timestamp': '8 horas',
        'liked': false,
        'price': '\$450.000',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedFilter == 0) return _posts;
    
    final typeMap = {1: 'product', 2: 'question', 3: 'service'};
    final filterType = typeMap[_selectedFilter];
    
    return _posts.where((post) => post['type'] == filterType).toList();
  }

  String _getPostTypeIcon(String type) {
    switch (type) {
      case 'product':
        return '🛍️';
      case 'service':
        return '🔧';
      case 'question':
        return '❓';
      case 'info':
        return '📢';
      case 'post':
        return '📝';
      default:
        return '📌';
    }
  }

  Color _getPostTypeColor(String type) {
    switch (type) {
      case 'product':
        return DashboardColors.cardPurple;
      case 'service':
        return DashboardColors.cardTeal;
      case 'question':
        return DashboardColors.cardBlue;
      case 'info':
        return DashboardColors.cardOrange;
      case 'post':
        return DashboardColors.cardGreen;
      default:
        return DashboardColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muro Comunitario'),
        backgroundColor: DashboardColors.primary,
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
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showComingSoon('Notificaciones del muro'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Crear nuevo post
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: DashboardColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCreatePostDialog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '¿Qué quieres compartir?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Todos', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Ventas 🛍️', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Preguntas ❓', 2),
                const SizedBox(width: 8),
                _buildFilterChip('Servicios 🔧', 3),
              ],
            ),
          ),

          // Lista de posts
          Expanded(
            child: _filteredPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8)
                        .copyWith(bottom: 100),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(_filteredPosts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = index);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: DashboardColors.primary.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? DashboardColors.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postType = post['type'] as String;
    
    // Mostrar diseño diferente según el tipo de post
    switch (postType) {
      case 'product':
        return _buildProductCarousel(post);
      case 'service':
        return _buildServiceCard(post);
      case 'question':
        return _buildQuestionCard(post);
      case 'info':
        return _buildInfoCard(post);
      default:
        return _buildDefaultPostCard(post);
    }
  }

  // Carrusel de productos (foto central grande, laterales pequeñas)
  Widget _buildProductCarousel(Map<String, dynamic> post) {
    final typeColor = _getPostTypeColor(post['type']);
    final isLiked = post['liked'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildPostHeader(post, typeColor),

          // Carrusel de fotos
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: PageView.builder(
              itemCount: 3,
              onPageChanged: (index) {},
              itemBuilder: (context, index) {
                final scale = index == 1 ? 1.0 : 0.85;
                final opacity = index == 1 ? 1.0 : 0.7;
                
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: typeColor),
                            const SizedBox(height: 12),
                            Text(
                              'Producto ${index + 1}',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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

          // Precio y contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Precio: ${post['price']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Me gusta',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      post['liked'] = !isLiked;
                      post['likes'] += isLiked ? -1 : 1;
                    });
                  },
                ),
                _buildActionButton(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Comprar',
                  color: typeColor,
                  onTap: () => _showComingSoon('Carrito de compras'),
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartir',
                  color: Colors.grey[600]!,
                  onTap: () => _showComingSoon('Compartir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de servicios interactiva con opciones
  Widget _buildServiceCard(Map<String, dynamic> post) {
    final typeColor = _getPostTypeColor(post['type']);
    final isLiked = post['liked'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildPostHeader(post, typeColor),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),

                // Grid de acciones interactivas
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildServiceActionTile(
                      icon: Icons.chat,
                      label: 'Preguntar',
                      color: Colors.blue,
                      onTap: () => _showCommentsDialog(post),
                    ),
                    _buildServiceActionTile(
                      icon: Icons.phone,
                      label: 'Llamar',
                      color: Colors.green,
                      onTap: () => _showComingSoon('Llamadas'),
                    ),
                    _buildServiceActionTile(
                      icon: Icons.location_on,
                      label: 'Ubicación',
                      color: Colors.red,
                      onTap: () => _showComingSoon('Mapa'),
                    ),
                    _buildServiceActionTile(
                      icon: Icons.bookmark_border,
                      label: 'Guardar',
                      color: Colors.orange,
                      onTap: () => _showComingSoon('Guardado'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey[200], height: 1),

          // Stats compactas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${post['likes']} Me gusta',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Me gusta',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      post['liked'] = !isLiked;
                      post['likes'] += isLiked ? -1 : 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de preguntas
  Widget _buildQuestionCard(Map<String, dynamic> post) {
    final typeColor = _getPostTypeColor(post['type']);
    final isLiked = post['liked'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildPostHeader(post, typeColor),

          // Contenido de pregunta
          Container(
            padding: const EdgeInsets.all(16),
            color: typeColor.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, color: typeColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post['title'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),

          // Respuestas y acciones
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.comment,
                  label: '${post['comments']} Respuestas',
                  color: typeColor,
                  onTap: () => _showCommentsDialog(post),
                ),
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Útil',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      post['liked'] = !isLiked;
                      post['likes'] += isLiked ? -1 : 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de información
  Widget _buildInfoCard(Map<String, dynamic> post) {
    final typeColor = _getPostTypeColor(post['type']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: typeColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header simplificado
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        post['timestamp'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${post['likes']} Me gusta',
                  color: Colors.grey[600]!,
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Compartir',
                  color: typeColor,
                  onTap: () => _showComingSoon('Compartir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta por defecto para posts normales
  Widget _buildDefaultPostCard(Map<String, dynamic> post) {
    final typeColor = _getPostTypeColor(post['type']);
    final isLiked = post['liked'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post, typeColor),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post['title'] != null)
                  Text(
                    post['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                if (post['title'] != null) const SizedBox(height: 8),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post['likes']} Me gusta • ${post['comments']} Comentarios',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Me gusta',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      post['liked'] = !isLiked;
                      post['likes'] += isLiked ? -1 : 1;
                    });
                  },
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comentar',
                  color: Colors.grey[600]!,
                  onTap: () => _showCommentsDialog(post),
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartir',
                  color: Colors.grey[600]!,
                  onTap: () => _showComingSoon('Compartir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post, Color typeColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: typeColor.withValues(alpha: 0.2),
            child: Text(
              post['avatar'],
              style: TextStyle(
                color: typeColor,
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
                Row(
                  children: [
                    Text(
                      post['author'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPostTypeIcon(post['type']),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post['timestamp'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                _showComingSoon('Reportar post');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Reportar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceActionTile(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay posts aquí',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en compartir algo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear nuevo post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _postController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '¿Qué quieres compartir?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPostTypeButton('Publicación', '📝', 'post'),
                  _buildPostTypeButton('Vender', '🛍️', 'product'),
                  _buildPostTypeButton('Pregunta', '❓', 'question'),
                  _buildPostTypeButton('Servicio', '🔧', 'service'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_postController.text.isNotEmpty) {
                      setState(() {
                        _posts.insert(0, {
                          'id': '${_posts.length + 1}',
                          'author': 'Tú',
                          'avatar': 'U',
                          'type': 'post',
                          'title': null,
                          'content': _postController.text,
                          'image': null,
                          'likes': 0,
                          'comments': 0,
                          'shares': 0,
                          'timestamp': 'Ahora',
                          'liked': false,
                        });
                      });
                      _postController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Post publicado exitosamente!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeButton(String label, String emoji, String type) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _showCommentsDialog(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: post['comments'],
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: DashboardColors.primary.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Usuario',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Excelente publicación, me fue de mucha ayuda.',
                                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2 horas',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: DashboardColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar posts'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Busca por autor, tipo o contenido...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Próximamente')),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
