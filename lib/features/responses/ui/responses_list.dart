import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/shared/models/response.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/features/responses/domain/response_repository.dart';
import 'package:yominero/features/responses/ui/response_item.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/core/supabase/supabase_service.dart';

class ResponsesList extends StatefulWidget {
  final Post post;

  const ResponsesList({super.key, required this.post});

  @override
  State<ResponsesList> createState() => _ResponsesListState();
}

class _ResponsesListState extends State<ResponsesList> {
  final _responseRepo = sl<ResponseRepository>();
  final _supabase = SupabaseService.instance.client;
  List<Response> _responses = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  // Función para organizar respuestas jerárquicamente
  List<Widget> _buildHierarchicalResponses(List<Response> responses, String currentUserId) {
    final List<Widget> widgets = [];
    final isPostAuthor = currentUserId == widget.post.authorId;
    
    // 🔍 DEBUG: Logs para diagnosticar
    print('=== DIAGNÓSTICO JERARQUÍA ===');
    print('Total respuestas: ${responses.length}');
    for (final response in responses) {
      print('ID: ${response.id}');
      print('Parent ID: ${response.parentResponseId}');
      print('Contenido: ${response.content.substring(0, response.content.length.clamp(0, 50))}...');
      print('---');
    }
    
    // Separar respuestas padre e hijos basado en parent_response_id
    final Map<String, List<Response>> childrenMap = {};
    final List<Response> parentResponses = [];
    
    for (final response in responses) {
      if (response.parentResponseId == null) {
        // Es una respuesta principal (padre)
        parentResponses.add(response);
        print('✅ PADRE: ${response.content.substring(0, response.content.length.clamp(0, 30))}...');
      } else {
        // Es una respuesta anidada (hija)
        final parentId = response.parentResponseId!;
        if (!childrenMap.containsKey(parentId)) {
          childrenMap[parentId] = [];
        }
        childrenMap[parentId]!.add(response);
        print('🔸 HIJO: ${response.content.substring(0, response.content.length.clamp(0, 30))}... (Parent: $parentId)');
      }
    }
    
    print('Respuestas padre: ${parentResponses.length}');
    print('Mapa de hijos: ${childrenMap.keys.length} padres con hijos');
    print('==============================');
    
    // Ordenar respuestas padre por fecha de creación (más recientes primero)
    parentResponses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Construir widgets jerárquicos
    for (final parentResponse in parentResponses) {
      // Añadir respuesta padre
      widgets.add(
        ResponseItem(
          response: parentResponse,
          onLike: () => _toggleLike(parentResponse),
          onMarkBestAnswer: isPostAuthor
              ? () => _markAsBestAnswer(parentResponse)
              : null,
          onReply: () => _showReplyModal(parentResponse),
          canMarkBestAnswer: isPostAuthor,
          isNested: false,
          nestingLevel: 0,
          showConnectionLine: false,
        ),
      );
      
      // Añadir respuestas hijas ordenadas por fecha (más recientes primero para hijos también)
      final children = childrenMap[parentResponse.id] ?? [];
      children.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      for (final childResponse in children) {
        widgets.add(
          ResponseItem(
            response: childResponse,
            onLike: () => _toggleLike(childResponse),
            onMarkBestAnswer: isPostAuthor
                ? () => _markAsBestAnswer(childResponse)
                : null,
            onReply: () => _showReplyModal(childResponse),
            canMarkBestAnswer: isPostAuthor,
            isNested: true,
            nestingLevel: 1,
            showConnectionLine: true,
          ),
        );
      }
    }
    
    return widgets;
  }

  // Método para obtener respuestas colapsadas respetando jerarquía
  List<Response> _getCollapsedHierarchicalResponses(List<Response> allResponses) {
    // Separar respuestas padre e hijos
    final Map<String, List<Response>> childrenMap = {};
    final List<Response> parentResponses = [];
    
    for (final response in allResponses) {
      if (response.parentResponseId == null) {
        parentResponses.add(response);
      } else {
        final parentId = response.parentResponseId!;
        if (!childrenMap.containsKey(parentId)) {
          childrenMap[parentId] = [];
        }
        childrenMap[parentId]!.add(response);
      }
    }
    
    // Ordenar padres por fecha (más recientes primero)
    parentResponses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Verificar si hay mejor respuesta
    final bestResponse = allResponses.where((r) => r.isBestAnswer).toList();
    if (bestResponse.isNotEmpty) {
      final bestParent = bestResponse.first;
      final result = [bestParent];
      
      // Agregar hijos de la mejor respuesta
      final bestChildren = childrenMap[bestParent.id] ?? [];
      bestChildren.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      result.addAll(bestChildren);
      
      return result;
    }
    
    // Si no hay mejor respuesta, mostrar solo la primera respuesta padre con sus hijos
    if (parentResponses.isNotEmpty) {
      final firstParent = parentResponses.first;
      final result = [firstParent];
      
      // Agregar hijos del primer padre
      final firstChildren = childrenMap[firstParent.id] ?? [];
      firstChildren.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      result.addAll(firstChildren);
      
      return result;
    }
    
    return allResponses;
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);
    try {
      final responses = await _responseRepo.getResponsesForPost(widget.post.id);
      if (mounted) {
        setState(() {
          _responses = responses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando respuestas: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleLike(Response response) async {
    try {
      if (response.userHasLiked) {
        await _responseRepo.unlikeResponse(response.id);
      } else {
        await _responseRepo.likeResponse(response.id);
      }
      await _loadResponses(); // Recargar para actualizar UI
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
  }

  Future<void> _markAsBestAnswer(Response response) async {
    try {
      await _responseRepo.markAsBestAnswer(
        responseId: response.id,
        postId: widget.post.id,
      );
      await _loadResponses(); // Recargar para actualizar UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text('¡Marcada como mejor respuesta!'),
              ],
            ),
            backgroundColor: AppColorsUnified.success,
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
  }

  // Método para mostrar modal de respuesta anidada
  void _showReplyModal(Response parentResponse) {
    final TextEditingController replyController = TextEditingController();
    bool isSubmitting = false;
    bool hasText = false;
    bool listenerAdded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Agregar listener solo una vez
            if (!listenerAdded) {
              replyController.addListener(() {
                final newHasText = replyController.text.trim().isNotEmpty;
                if (newHasText != hasText) {
                  setModalState(() {
                    hasText = newHasText;
                  });
                }
              });
              listenerAdded = true;
            }
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
                      color: AppColorsUnified.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColorsUnified.gold.withValues(alpha: 0.3),
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
                              backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.2),
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
                                  print('🔵 Botón "Enviar Respuesta" presionado');
                                  print('🔵 isSubmitting: $isSubmitting, hasText: $hasText');
                                  print('🔵 Texto a enviar: "${replyController.text.trim()}"');
                                  
                                  setModalState(() => isSubmitting = true);
                                  
                                  try {
                                    await _submitNestedResponse(
                                      widget.post.id, 
                                      parentResponse.id, 
                                      replyController.text.trim()
                                    );
                                    
                                    print('✅ Respuesta enviada, cerrando modal');
                                    Navigator.pop(context);
                                    await _loadResponses();
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Respuesta enviada exitosamente'),
                                        backgroundColor: AppColorsUnified.success,
                                      ),
                                    );
                                  } catch (e) {
                                    print('❌ Error en botón: $e');
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
    print('🚀 Iniciando _submitNestedResponse');
    print('📝 postId: $postId');
    print('👥 parentResponseId: $parentResponseId');
    print('💬 content: $content');
    
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabase.auth.currentUser?.id;
    final isPostAuthor = currentUserId == widget.post.authorId;

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_responses.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsUnified.fade(AppColorsUnified.gold, 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 36,
              color: AppColorsUnified.fade(AppColorsUnified.gold, 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Sin respuestas aún',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¡Sé el primero en ayudar!',
              style: TextStyle(
                fontSize: 13,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // 🔧 NUEVA LÓGICA: Respetamos jerarquía completa
    final responsesToShow = _isExpanded 
        ? _responses 
        : _getCollapsedHierarchicalResponses(_responses);
    final hasMore = _responses.length > responsesToShow.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de respuestas integrado sin padding adicional
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.comment_rounded,
                        size: 14,
                        color: AppColorsUnified.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isExpanded 
                            ? 'Mostrar menos'
                            : '${_responses.length} ${_responses.length == 1 ? 'respuesta' : 'respuestas'}',
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
        const SizedBox(height: 16),
        ..._buildHierarchicalResponses(responsesToShow, currentUserId ?? ''),
        if (hasMore)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorsUnified.grey300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColorsUnified.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isExpanded
                          ? 'Mostrar menos'
                          : 'Ver ${_responses.length - 3} respuestas más',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
