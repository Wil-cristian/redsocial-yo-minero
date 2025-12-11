import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/shared/models/response.dart';
import 'package:yominero/features/responses/domain/response_repository.dart';
import 'package:yominero/features/responses/ui/response_modal.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/features/bookings/ui/book_service_page.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/shared/models/product.dart';
import 'package:yominero/core/theme/premium_3d_carousel.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> with SingleTickerProviderStateMixin {
  final _supabase = SupabaseService.instance.client;
  final _responseRepo = sl<ResponseRepository>();
  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoading = true;
  String? _selectedFilter;
  late TabController _tabController;
  
  // Variables para controlar el refresh del modal
  // ignore: unused_field
  Key _modalKey = UniqueKey();
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Todos', 'value': null, 'icon': Icons.grid_view},
    {'label': 'Preguntas', 'value': 'request', 'icon': Icons.help_rounded},
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
    _refreshNotifier.dispose();
    super.dispose();
  }
  
  // Método para forzar refresh del modal
  void _refreshModal() {
    _refreshNotifier.value++;
    setState(() {
      _modalKey = UniqueKey();
    });
  }

  // Método para mostrar modal de respuesta anidada
  void _showReplyToResponseModal(Response parentResponse, Map<String, dynamic> post) {
    final TextEditingController replyController = TextEditingController();
    bool isSubmitting = false;
    bool hasText = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Listener para actualizar el estado cuando cambie el texto
            replyController.removeListener(() {});
            replyController.addListener(() {
              final newHasText = replyController.text.trim().isNotEmpty;
              if (newHasText != hasText) {
                setModalState(() {
                  hasText = newHasText;
                });
              }
            });
            return Container(
              decoration: BoxDecoration(
                color: AppColorsUnified.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del modal
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        color: AppColorsUnified.gold,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Responder a respuesta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Contexto de la respuesta original
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColorsUnified.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColorsUnified.gold.withOpacity(0.2),
                              child: Text(
                                (parentResponse.authorName ?? parentResponse.authorUsername ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsUnified.gold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              parentResponse.authorName ?? parentResponse.authorUsername ?? 'Usuario',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColorsUnified.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          parentResponse.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColorsUnified.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de texto para la respuesta
                  TextField(
                    controller: replyController,
                    maxLines: 4,
                    style: TextStyle(color: AppColorsUnified.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta a ${parentResponse.authorName ?? parentResponse.authorUsername ?? 'este usuario'}...',
                      hintStyle: TextStyle(color: AppColorsUnified.textSecondary),
                      filled: true,
                      fillColor: AppColorsUnified.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColorsUnified.gold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsUnified.surface,
                            foregroundColor: AppColorsUnified.textSecondary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (isSubmitting || !hasText) 
                              ? null 
                              : () async {
                                  setModalState(() => isSubmitting = true);
                                  
                                  try {
                                    await _submitNestedResponse(
                                      post['id'], 
                                      parentResponse.id, 
                                      replyController.text.trim()
                                    );
                                    
                                    Navigator.pop(context);
                                    _refreshModal();
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Respuesta enviada exitosamente'),
                                        backgroundColor: AppColorsUnified.success,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al enviar respuesta: $e'),
                                        backgroundColor: AppColorsUnified.error,
                                      ),
                                    );
                                  } finally {
                                    setModalState(() => isSubmitting = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsUnified.gold,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : const Text(
                                  'Enviar Respuesta',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Método para enviar respuesta anidada
  Future<void> _submitNestedResponse(String postId, String parentResponseId, String content) async {
    try {
      // Usar el repositorio para crear respuesta anidada
      await _responseRepo.createNestedResponse(
        postId: postId,
        parentResponseId: parentResponseId,
        content: content,
      );
      
      print('✅ Respuesta anidada creada exitosamente');
    } catch (e) {
      print('❌ Error al crear respuesta anidada: $e');
      rethrow;
    }
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

  void _bookService(Map<String, dynamic> post) async {
    String? serviceId = post['service_id'];
    
    if (serviceId == null) {
      try {
        final postData = await _supabase
            .from('posts')
            .select('service_id')
            .eq('id', post['post_id'])
            .single();
        serviceId = postData['service_id'];
      } catch (e) {
        debugPrint('❌ Error obteniendo service_id: $e');
      }
    }

    if (serviceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este servicio no tiene sistema de reservas configurado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final serviceData = await _supabase
          .from('services')
          .select('*')
          .eq('id', serviceId)
          .single();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookServicePage(
              service: Service.fromJson(serviceData),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando servicio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el servicio'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  // 💖 LIKES PARA POSTS
  Future<void> _togglePostLike(String postId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      // Verificar si ya tiene like
      final existingLike = await _supabase
          .from('post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        // Quitar like
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);
      } else {
        // Agregar like
        await _supabase
            .from('post_likes')
            .insert({
          'post_id': postId,
          'user_id': currentUser.id,
        });
      }

      // Refrescar modal si está abierto
      _refreshModal();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  existingLike != null ? Icons.favorite_border : Icons.favorite,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(existingLike != null ? 'Like removido' : '¡Te gusta este post!'),
              ],
            ),
            backgroundColor: AppColorsUnified.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al dar like al post: $e');
    }
  }

  // 💖 LIKES PARA RESPUESTAS
  Future<void> _toggleResponseLike(String responseId) async {
    try {
      final responseRepo = sl<ResponseRepository>();
      await responseRepo.likeResponse(responseId);
      
      // Refrescar modal inmediatamente
      _refreshModal();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Like enviado!'),
              ],
            ),
            backgroundColor: AppColorsUnified.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al dar like a respuesta: $e');
    }
  }

  // 📊 OBTENER CONTADOR DE LIKES DEL POST
  Future<int> _getPostLikesCount(String postId) async {
    try {
      final response = await _supabase
          .from('post_likes')
          .select('id')
          .eq('post_id', postId);
      
      return response.length;
    } catch (e) {
      debugPrint('❌ Error obteniendo likes del post: $e');
      return 0;
    }
  }

  // 📊 OBTENER CONTADOR DE LIKES DE RESPUESTA
  Future<int> _getResponseLikesCount(String responseId) async {
    try {
      final response = await _supabase
          .from('response_likes')
          .select('id')
          .eq('response_id', responseId);
      
      return response.length;
    } catch (e) {
      debugPrint('❌ Error obteniendo likes de respuesta: $e');
      return 0;
    }
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
      case 'request':
        return AppColorsUnified.gold;
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
      case 'request':
        return Icons.help_rounded;
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
      case 'request':
        return 'Pregunta';
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

    // 🛍️ PRODUCTOS: Mostrar con carousel 3D
    if (postType == 'product') {
      return _buildProductCard(post, typeColor);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withOpacity(0.2),
          width: 1.5,
        ),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.08),
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

  // 🛍️ CARD ESPECIAL PARA PRODUCTOS CON CAROUSEL 3D
  Widget _buildProductCard(Map<String, dynamic> post, Color typeColor) {
    final metadata = post['metadata'] as Map<String, dynamic>? ?? {};
    
    // Obtener imágenes
    List<dynamic> images = [];
    if (metadata.containsKey('images')) {
      images = metadata['images'] as List<dynamic>? ?? [];
    }
    
    // Crear productos para el carousel
    List<Product> products = [];
    final price = (metadata['price'] as num?)?.toDouble() ?? 0.0;
    
    if (images.isNotEmpty) {
      products = images.asMap().entries.map((entry) {
        return Product(
          id: '${post['post_id']}_${entry.key}',
          sellerId: post['author_id'] ?? 'unknown',
          name: post['title'] ?? 'Producto',
          description: post['content'] ?? '',
          price: price,
          category: metadata['category'] ?? 'General',
          imageUrls: [entry.value.toString()],
          viewsCount: 0,
          favoritesCount: 0,
          createdAt: DateTime.parse(post['saved_at']),
        );
      }).toList();
    } else {
      // Sin imágenes, crear producto placeholder
      products = [
        Product(
          id: post['post_id'] ?? 'unknown',
          sellerId: post['author_id'] ?? 'unknown',
          name: post['title'] ?? 'Producto',
          description: post['content'] ?? '',
          price: price,
          category: metadata['category'] ?? 'General',
          imageUrls: [],
          viewsCount: 0,
          favoritesCount: 0,
          createdAt: DateTime.parse(post['saved_at']),
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💎 CAROUSEL 3D PREMIUM
          Premium3DProductCarousel(
            products: products,
            authorId: post['author_id'],
            authorName: post['author_name'],
            createdAt: DateTime.parse(post['saved_at']),
            title: post['title'],
            likes: post['likes_count'] ?? 0,
            comments: 0,
            isSaved: true,
            onLike: () => debugPrint('Like producto'),
            onComment: () => debugPrint('Comentar producto'),
            onShare: () => debugPrint('Compartir producto'),
            onSave: () async {
              await _removeSavedPost(post['post_id']);
            },
            onProductTap: (_) => _showPostDetails(post),
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
    
    // Si es una pregunta, usar modal especializado
    if (postType == 'request') {
      return _buildQuestionDetailsModal(post);
    }

    // Si es un servicio, usar modal especializado
    if (postType == 'service') {
      return _buildServiceDetailsModal(post);
    }

    // Si es un producto, usar modal especializado con carousel 3D
    if (postType == 'product') {
      return _buildProductDetailsModal(post);
    }

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
                  typeColor.withOpacity(0.8),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: post['post_type'] == 'service'
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _bookService(post);
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 18),
                          label: const Text(
                            'Agendar Cita',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsUnified.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openChat(post);
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text(
                            'Contactar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColorsUnified.companyBlue,
                            side: const BorderSide(
                              color: AppColorsUnified.companyBlue,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🛠️ MODAL ESPECIALIZADO PARA SERVICIOS
  Widget _buildServiceDetailsModal(Map<String, dynamic> post) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColorsUnified.background,
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
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColorsUnified.grey300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con info del autor
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColorsUnified.orange,
                              child: Text(
                                (post['author_name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['author_name'] ?? 'Usuario',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColorsUnified.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (post['author_username'] != null)
                                        Text(
                                          '@${post['author_username']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColorsUnified.textSecondary,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.star,
                                        color: AppColorsUnified.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post['likes_count'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColorsUnified.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColorsUnified.grey100,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Título del servicio
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColorsUnified.companyBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.build_circle_rounded,
                                color: AppColorsUnified.companyBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                post['title'] ?? 'Sin título',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColorsUnified.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 📅 CARD DE DISPONIBILIDAD CON BOTÓN INTEGRADO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorsUnified.orange.withOpacity(0.12),
                                AppColorsUnified.orange.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColorsUnified.orange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColorsUnified.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Disponibilidad',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColorsUnified.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Agenda tu cita ahora',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColorsUnified.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (post['availability']?.toLowerCase().contains('disponible') == true)
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          post['availability'] ?? 'Consultar',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              // Info de horarios
                              if (post['metadata'] != null && post['metadata']['schedule'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    '🕐 ${post['metadata']['schedule']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColorsUnified.textPrimary,
                                    ),
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    '🕐 Horarios flexibles disponibles',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColorsUnified.textPrimary,
                                    ),
                                  ),
                                ),
                              // BOTÓN DE AGENDAR INTEGRADO
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _bookService(post);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorsUnified.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      'Agendar Cita',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 💰 PRECIO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColorsUnified.companyBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money_rounded,
                                color: AppColorsUnified.companyBlue,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Precio del servicio',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColorsUnified.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatServicePrice(post),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppColorsUnified.companyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 📝 DESCRIPCIÓN
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            post['content'] ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColorsUnified.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de contactar secundario
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openChat(post);
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                          label: const Text(
                            'Contactar por chat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColorsUnified.companyBlue,
                            side: const BorderSide(
                              color: AppColorsUnified.companyBlue,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(double.infinity, 54),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatServicePrice(Map<String, dynamic> post) {
    final from = post['pricing_from'];
    final to = post['pricing_to'];
    final unit = post['pricing_unit'] ?? 'USD';

    if (from != null && to != null) {
      return '\$$from - \$$to $unit';
    } else if (from != null) {
      return 'Desde \$$from $unit';
    } else {
      return 'Precio a consultar';
    }
  }

  // 🛍️ MODAL ESPECIALIZADO PARA PRODUCTOS - Con Carousel 3D Premium
  Widget _buildProductDetailsModal(Map<String, dynamic> post) {
    return _ProductDetailsModalContent(
      post: post,
      onRemoved: () {
        // Recargar lista cuando se elimine de guardados
        _loadSavedPosts();
        Navigator.pop(context);
      },
    );
  }
}

// 🛍️ STATEFUL WIDGET PARA MODAL DE PRODUCTO
class _ProductDetailsModalContent extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onRemoved;

  const _ProductDetailsModalContent({
    required this.post,
    required this.onRemoved,
  });

  @override
  State<_ProductDetailsModalContent> createState() => _ProductDetailsModalContentState();
}

class _ProductDetailsModalContentState extends State<_ProductDetailsModalContent> {
  bool _isSaved = true; // Inicialmente está guardado porque estamos en la página de guardados
  final _supabase = SupabaseService.instance.client;

  Future<void> _toggleSave() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      if (_isSaved) {
        // Eliminar de guardados
        await _supabase
            .from('saved_posts')
            .delete()
            .eq('user_id', currentUser.id)
            .eq('post_id', widget.post['post_id']);

        if (mounted) {
          setState(() => _isSaved = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado de guardados'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColorsUnified.orange,
            ),
          );
          // Llamar callback para recargar lista
          Future.delayed(const Duration(seconds: 1), widget.onRemoved);
        }
      } else {
        // Volver a guardar
        await _supabase.from('saved_posts').insert({
          'user_id': currentUser.id,
          'post_id': widget.post['post_id'],
        });

        if (mounted) {
          setState(() => _isSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto guardado nuevamente'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColorsUnified.success,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al cambiar estado de guardado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Product> _createProductsFromMetadata(Map<String, dynamic> post, List<dynamic> images) {
    final metadata = post['metadata'] as Map<String, dynamic>? ?? {};
    final price = (metadata['price'] as num?)?.toDouble() ?? 0.0;

    if (images.isEmpty) {
      return [
        Product(
          id: post['post_id'] ?? 'unknown',
          sellerId: post['author_id'] ?? 'unknown',
          name: post['title'] ?? 'Producto',
          description: post['content'] ?? '',
          price: price,
          isAvailable: (metadata['stock'] as int? ?? 0) > 0,
          category: metadata['category'] ?? 'General',
          imageUrls: [],
          viewsCount: 0,
          favoritesCount: 0,
          createdAt: DateTime.parse(post['saved_at']),
          updatedAt: DateTime.parse(post['saved_at']),
        ),
      ];
    }

    return images.asMap().entries.map((entry) {
      final imageUrl = entry.value.toString();
      
      return Product(
        id: '${post['post_id']}_${entry.key}',
        sellerId: post['author_id'] ?? 'unknown',
        name: post['title'] ?? 'Producto',
        description: post['content'] ?? '',
        price: price,
        isAvailable: (metadata['stock'] as int? ?? 0) > 0,
        category: metadata['category'] ?? 'General',
        imageUrls: [imageUrl],
        viewsCount: 0,
        favoritesCount: 0,
        createdAt: DateTime.parse(post['saved_at']),
        updatedAt: DateTime.parse(post['saved_at']),
      );
    }).toList();
  }

  Widget _buildProductDetailRow({
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Botón de acción para producto
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColorsUnified.textSecondary),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColorsUnified.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.post['metadata'] as Map<String, dynamic>? ?? {};
    
    // Debug: Ver estructura completa
    debugPrint('📦 PRODUCTO GUARDADO:');
    debugPrint('   Post ID: ${widget.post['post_id']}');
    debugPrint('   Metadata: $metadata');
    debugPrint('   Metadata keys: ${metadata.keys}');
    
    // Intentar obtener imágenes de múltiples ubicaciones posibles
    List<dynamic> images = [];
    
    // 1. Buscar en metadata['images']
    if (metadata.containsKey('images')) {
      images = metadata['images'] as List<dynamic>? ?? [];
      debugPrint('   📸 Imágenes en metadata[images]: ${images.length}');
    }
    
    // 2. Si no hay imágenes en metadata, buscar en el nivel superior del post
    if (images.isEmpty && widget.post.containsKey('images')) {
      images = widget.post['images'] as List<dynamic>? ?? [];
      debugPrint('   📸 Imágenes en post[images]: ${images.length}');
    }
    
    // 3. Si aún no hay imágenes, intentar con imageUrls o imageUrl
    if (images.isEmpty) {
      if (metadata.containsKey('imageUrls')) {
        images = metadata['imageUrls'] as List<dynamic>? ?? [];
        debugPrint('   📸 Imágenes en metadata[imageUrls]: ${images.length}');
      } else if (metadata.containsKey('imageUrl')) {
        final singleImage = metadata['imageUrl'];
        if (singleImage != null && singleImage.toString().isNotEmpty) {
          images = [singleImage];
          debugPrint('   📸 Imagen única en metadata[imageUrl]: $singleImage');
        }
      }
    }
    
    debugPrint('   ✅ Total imágenes encontradas: ${images.length}');
    if (images.isNotEmpty) {
      debugPrint('   🖼️ URLs: $images');
    }
    
    // Convertir metadata a lista de Products para el carousel
    final products = _createProductsFromMetadata(widget.post, images);
    debugPrint('   🎨 Products creados: ${products.length}');
    
    // Determinar si es oro o plata (alternado por índice de precio)
    final price = metadata['price'] as num? ?? 0;
    final isGold = (price.toInt() % 2) == 0;
    final accentColor = isGold ? AppColorsUnified.gold : AppColorsUnified.silverLight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: AppColorsUnified.background,
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
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColorsUnified.grey300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Content con scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 🎨 HEADER CON AUTOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: accentColor.withOpacity(0.15),
                          child: Text(
                            (widget.post['author_name'] ?? 'U').substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post['author_name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColorsUnified.textPrimary,
                                ),
                              ),
                              Text(
                                '@${widget.post['author_username'] ?? 'usuario'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColorsUnified.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Icono de producto
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 💎 CAROUSEL 3D O IMÁGENES
                  if (products.isNotEmpty && images.isNotEmpty)
                    Premium3DProductCarousel(
                      products: products,
                      authorId: widget.post['author_id'],
                      authorName: widget.post['author_name'],
                      createdAt: DateTime.parse(widget.post['saved_at']),
                      title: widget.post['title'],
                      likes: widget.post['likes_count'] ?? 0,
                      comments: 0,
                      isSaved: _isSaved,
                      onLike: () async {
                        debugPrint('Like en producto guardado');
                      },
                      onComment: () {
                        debugPrint('Comentar en producto guardado');
                      },
                      onShare: () {
                        debugPrint('Compartir producto guardado');
                      },
                      onSave: _toggleSave,
                    )
                  else
                    // 📦 TARJETA DE PRODUCTO SIN IMÁGENES
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withOpacity(0.08),
                              accentColor.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título del producto
                            Text(
                              widget.post['title'] ?? 'Producto',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColorsUnified.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Precio destacado
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        Text(
                                          price.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Acciones
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.favorite_border,
                                    label: '${widget.post['likes_count'] ?? 0}',
                                    onTap: () => debugPrint('Like'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    label: '0',
                                    onTap: () => debugPrint('Comentar'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildActionButton(
                                    icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                                    label: '',
                                    onTap: _toggleSave,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildActionButton(
                                    icon: Icons.share_outlined,
                                    label: '',
                                    onTap: () => debugPrint('Compartir'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 📋 INFORMACIÓN ADICIONAL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción del producto
                        if (widget.post['content'] != null && widget.post['content'].toString().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: accentColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Descripción',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColorsUnified.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.post['content'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColorsUnified.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Detalles del producto (stock, condición, categoría)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    color: accentColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Detalles',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColorsUnified.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Stock
                              if (metadata['stock'] != null) ...[
                                _buildProductDetailRow(
                                  icon: Icons.inventory_outlined,
                                  label: 'Stock disponible',
                                  value: '${metadata['stock']} unidades',
                                  color: AppColorsUnified.success,
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Condición
                              if (metadata['condition'] != null) ...[
                                _buildProductDetailRow(
                                  icon: Icons.verified_outlined,
                                  label: 'Condición',
                                  value: metadata['condition'],
                                  color: AppColorsUnified.companyBlue,
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Categoría
                              if (metadata['category'] != null) ...[
                                _buildProductDetailRow(
                                  icon: Icons.category_outlined,
                                  label: 'Categoría',
                                  value: metadata['category'],
                                  color: AppColorsUnified.orange,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de contacto (igual que en servicios)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Implementar navegación al chat o contacto
                              debugPrint('Contactar vendedor: ${widget.post['author_id']}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Contactar vendedor',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MÉTODOS HELPER PARA _SavedPostsPageState
extension _SavedPostsPageStateHelpers on _SavedPostsPageState {
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
            color: typeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: typeColor.withOpacity(0.2)),
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
                        typeColor.withOpacity(0.1),
                        typeColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
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
                                color: typeColor.withOpacity(0.15),
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
                                color: typeColor.withOpacity(0.15),
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
                                color: typeColor.withOpacity(0.15),
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
                        AppColorsUnified.orange.withOpacity(0.1),
                        AppColorsUnified.orange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColorsUnified.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Row(
                        children: [
                          Icon(Icons.groups, color: AppColorsUnified.orange, size: 20),
                          SizedBox(width: 8),
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
                      const Text(
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
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text('Función de verificación con IA próximamente'),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColorsUnified.companyBlue,
                                duration: Duration(seconds: 3),
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
                                  AppColorsUnified.companyBlue.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.companyBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Text(
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
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
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
                          color: typeColor.withOpacity(0.15),
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
            color: color.withOpacity(0.15),
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
                  color: color.withOpacity(0.7),
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

  // 🔥 MODAL ÉPICO PARA PREGUNTAS CON RESPUESTAS
  Widget _buildQuestionDetailsModal(Map<String, dynamic> post) {
    final responseRepo = sl<ResponseRepository>();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar elegante
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsUnified.gold.withOpacity(0.3),
                  AppColorsUnified.goldDeep.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header dorado épico
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsUnified.fade(AppColorsUnified.gold, 0.08),
                  AppColorsUnified.fade(AppColorsUnified.goldDeep, 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Autor de la pregunta
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                      child: Text(
                        (post['author_name'] ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppColorsUnified.gold,
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
                            post['author_name'] ?? 'Usuario',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColorsUnified.gold,
                            ),
                          ),
                          Text(
                            '${_formatDate(post['created_at'])} • Pregunta',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.fade(AppColorsUnified.textSecondary, 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de chat con autor
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openChat(post),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColorsUnified.companyBlue,
                                AppColorsUnified.companyBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorsUnified.companyBlue.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Pregunta principal
                Text(
                  post['title'] ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColorsUnified.gold,
                    height: 1.3,
                  ),
                ),
                
                if (post['content'] != null && post['content'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    post['content'],
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColorsUnified.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Stats de la pregunta
                Row(
                  children: [
                    // Like clickeable del post
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _togglePostLike(post['post_id']),
                        borderRadius: BorderRadius.circular(16),
                        child: ValueListenableBuilder<int>(
                          valueListenable: _refreshNotifier,
                          builder: (context, refreshCount, child) {
                            return FutureBuilder<int>(
                              key: ValueKey('post_likes_$refreshCount'),
                              future: _getPostLikesCount(post['post_id']),
                              builder: (context, snapshot) {
                                final likesCount = snapshot.data ?? (post['likes'] ?? 0);
                                return _buildStatChip(
                                  Icons.favorite_rounded,
                                  '$likesCount',
                                  AppColorsUnified.error,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ValueListenableBuilder<int>(
                      valueListenable: _refreshNotifier,
                      builder: (context, refreshCount, child) {
                        return FutureBuilder<List<Response>>(
                          key: ValueKey('responses_count_$refreshCount'),
                          future: responseRepo.getResponsesForPost(post['post_id']),
                          builder: (context, snapshot) {
                            final responseCount = snapshot.data?.length ?? 0;
                            return _buildStatChip(
                              Icons.chat_bubble_rounded,
                              '$responseCount ${responseCount == 1 ? 'respuesta' : 'respuestas'}',
                              AppColorsUnified.gold,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botón para responder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Crear objeto Post desde el Map
                  final postObj = Post(
                    id: post['post_id'],
                    title: post['title'] ?? '',
                    content: post['content'] ?? '',
                    authorId: post['author_id'] ?? '',
                    authorName: post['author_name'],
                    type: PostType.request,
                    createdAt: DateTime.tryParse(post['created_at'] ?? '') ?? DateTime.now(),
                    likes: post['likes'] ?? 0,
                    comments: post['response_count'] ?? 0,
                    categories: [],
                  );
                  
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ResponseModal(
                      post: postObj,
                      onResponseAdded: () {
                        // Refrescar modal inmediatamente y recargar lista
                        _refreshModal();
                        Navigator.pop(context); // Cerrar modal de respuesta
                        _loadSavedPosts(); // Recargar lista en background
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsUnified.gold,
                        AppColorsUnified.goldDeep,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.gold.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Escribir Respuesta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Separador para respuestas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'RESPUESTAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColorsUnified.gold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de respuestas con refresh automático
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _refreshNotifier,
              builder: (context, refreshCount, child) {
                return FutureBuilder<List<Response>>(
                  key: ValueKey('responses_$refreshCount'),
                  future: responseRepo.getResponsesForPost(post['post_id']),
                  builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColorsUnified.gold),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColorsUnified.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error cargando respuestas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final responses = snapshot.data ?? [];
                
                if (responses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColorsUnified.gold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin respuestas aún',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '¡Sé el primero en ayudar!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _buildHierarchicalResponses(responses, post),
                );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Función para organizar respuestas jerárquicamente
  List<Widget> _buildHierarchicalResponses(List<Response> responses, Map<String, dynamic> post) {
    final List<Widget> widgets = [];
    
    // Separar respuestas padre e hijos basado en parent_response_id
    final Map<String, List<Response>> childrenMap = {};
    final List<Response> parentResponses = [];
    
    for (final response in responses) {
      if (response.parentResponseId == null) {
        // Es una respuesta principal (padre)
        parentResponses.add(response);
      } else {
        // Es una respuesta anidada (hija)
        final parentId = response.parentResponseId!;
        if (!childrenMap.containsKey(parentId)) {
          childrenMap[parentId] = [];
        }
        childrenMap[parentId]!.add(response);
      }
    }
    
    // Ordenar respuestas padre por fecha de creación
    parentResponses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // Construir widgets jerárquicos
    for (final parentResponse in parentResponses) {
      // Añadir respuesta padre
      widgets.add(
        _buildResponseCard(
          parentResponse, 
          post,
          isNested: false,
          nestingLevel: 0,
          showConnectionLine: false,
        ),
      );
      
      // Añadir respuestas hijas ordenadas por fecha
      final children = childrenMap[parentResponse.id] ?? [];
      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      for (final childResponse in children) {
        widgets.add(
          _buildResponseCard(
            childResponse, 
            post,
            isNested: true,
            nestingLevel: 1,
            showConnectionLine: true,
          ),
        );
      }
    }
    
    return widgets;
  }

  // Widget para mostrar cada respuesta
  Widget _buildResponseCard(
    Response response, 
    Map<String, dynamic> post, {
    bool isNested = false,
    int nestingLevel = 0,
    bool showConnectionLine = false,
  }) {
    final currentUserId = _supabase.auth.currentUser?.id;
    final isPostAuthor = currentUserId == post['author_id'];
    
    return Container(
      margin: EdgeInsets.only(
        left: isNested ? (nestingLevel * 24.0) : 0,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea de conexión para respuestas anidadas
          if (showConnectionLine) ..._buildConnectionLine(),
          
          // Contenido principal de la respuesta
          Expanded(
            child: Container(
              decoration: BoxDecoration(
        color: response.isBestAnswer
            ? AppColorsUnified.fade(AppColorsUnified.gold, 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: response.isBestAnswer
              ? AppColorsUnified.fade(AppColorsUnified.gold, 0.3)
              : AppColorsUnified.fade(AppColorsUnified.grey300, 0.5),
          width: response.isBestAnswer ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la respuesta
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColorsUnified.fade(AppColorsUnified.companyBlue, 0.2),
                  child: Text(
                    (response.authorName ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: AppColorsUnified.companyBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                            response.authorName ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                          if (response.isBestAnswer) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColorsUnified.gold,
                                    AppColorsUnified.goldDeep,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'MEJOR RESPUESTA',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(response.createdAt.toIso8601String()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de marcar como mejor respuesta (solo para autor del post)
                if (isPostAuthor) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        try {
                          final responseRepo = sl<ResponseRepository>();
                          
                          // Si ya es la mejor respuesta, la desmarcamos
                          // Si no es la mejor respuesta, la marcamos (automáticamente desmarca las otras)
                          await responseRepo.markAsBestAnswer(
                            responseId: response.id,
                            postId: post['post_id'],
                          );
                          
                          // Refrescar el modal inmediatamente
                          _refreshModal();
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(!response.isBestAnswer ? '¡Nueva mejor respuesta!' : 'Mejor respuesta removida'),
                                  ],
                                ),
                                backgroundColor: AppColorsUnified.gold,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: AppColorsUnified.error,
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          response.isBestAnswer ? Icons.star_rounded : Icons.star_border_rounded,
                          color: response.isBestAnswer ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Contenido de la respuesta
            Text(
              response.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColorsUnified.textPrimary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Acciones de la respuesta
            Row(
              children: [
                // Botón de like
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleResponseLike(response.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _refreshNotifier,
                        builder: (context, refreshCount, child) {
                          return FutureBuilder<int>(
                            key: ValueKey('response_likes_${response.id}_$refreshCount'),
                            future: _getResponseLikesCount(response.id),
                            builder: (context, snapshot) {
                              final likesCount = snapshot.data ?? response.likesCount;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 16,
                                    color: AppColorsUnified.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$likesCount',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColorsUnified.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón de responder
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showReplyToResponseModal(response, post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: 16,
                            color: AppColorsUnified.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Responder',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColorsUnified.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir la línea de conexión visual
  List<Widget> _buildConnectionLine() {
    return [
      SizedBox(
        width: 32,
        child: Column(
          children: [
            // Línea vertical desde arriba
            Container(
              width: 2,
              height: 20,
              color: AppColorsUnified.gold.withOpacity(0.4),
            ),
            // Línea horizontal hacia la respuesta
            Row(
              children: [
                Container(
                  width: 2,
                  height: 2,
                  color: AppColorsUnified.gold.withOpacity(0.4),
                ),
                Container(
                  width: 12,
                  height: 2,
                  color: AppColorsUnified.gold.withOpacity(0.4),
                ),
                // Punto de conexión
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColorsUnified.gold.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
    ];
  }
  
  // Widget para chips de estadísticas
  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}