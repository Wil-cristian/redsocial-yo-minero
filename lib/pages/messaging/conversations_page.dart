import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/features/connections/data/supabase_connection_repository.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';
import 'package:yominero/shared/models/conversation.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'chat_page.dart';
import 'search_users_page.dart';
import 'connection_requests_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final _messagingRepo = sl<MessagingRepository>();
  final _connectionRepo = sl<ConnectionRepository>();
  final _authService = SupabaseAuthService.instance;
  final _scrollController = ScrollController();
  
  List<Conversation> _conversations = [];
  int _pendingRequestsCount = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;
  Timer? _autoRefreshTimer;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadPendingRequestsCount();
    _startAutoRefresh();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreConversations();
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadConversations(silent: true),
    );
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentOffset = 0;
        _hasMoreData = true;
      });
    }

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        if (!silent && mounted) {
          setState(() {
            _error = 'Usuario no autenticado';
            _isLoading = false;
          });
        }
        return;
      }

      final conversations = await _messagingRepo.getUserConversations(
        currentUser.id,
        limit: _pageSize,
        offset: 0,
      );
      
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _currentOffset = conversations.length;
          _hasMoreData = conversations.length >= _pageSize;
          if (!silent) {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _error = 'Error al cargar conversaciones: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreConversations() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final newConversations = await _messagingRepo.getUserConversations(
        currentUser.id,
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (mounted) {
        setState(() {
          _conversations.addAll(newConversations);
          _currentOffset += newConversations.length;
          _hasMoreData = newConversations.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final requests = await _connectionRepo.getPendingRequestsReceived();
      if (mounted) {
        setState(() {
          _pendingRequestsCount = requests.length;
        });
      }
    } catch (e) {
      // Error silencioso, no afecta la funcionalidad principal
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.pureWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsUnified.textPrimary,
                AppColorsUnified.textPrimary.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.gold.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorsUnified.gold,
                          AppColorsUnified.gold.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.gold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      color: AppColorsUnified.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Mensajes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColorsUnified.whiteTransparent10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person_add_rounded),
                          color: AppColorsUnified.gold,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConnectionRequestsPage(),
                              ),
                            ).then((_) {
                              _loadConversations(silent: true);
                              _loadPendingRequestsCount();
                            });
                          },
                          tooltip: 'Solicitudes',
                        ),
                      ),
                      if (_pendingRequestsCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColorsUnified.gold,
                                  AppColorsUnified.gold.withValues(alpha: 0.9),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColorsUnified.textPrimary,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                _pendingRequestsCount > 9 ? '9+' : '$_pendingRequestsCount',
                                style: const TextStyle(
                                  color: AppColorsUnified.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColorsUnified.whiteTransparent10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search_rounded),
                      color: AppColorsUnified.gold,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchUsersPage(),
                          ),
                        ).then((_) {
                          _loadConversations(silent: true);
                          _loadPendingRequestsCount();
                        });
                      },
                      tooltip: 'Buscar usuarios',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColorsUnified.whiteTransparent10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppColorsUnified.gold,
                      onPressed: () {
                        _loadConversations();
                        _loadPendingRequestsCount();
                      },
                      tooltip: 'Actualizar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColorsUnified.orange,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColorsUnified.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: AppColorsUnified.grey600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConversations,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsUnified.orange,
                foregroundColor: AppColorsUnified.pureWhite,
              ),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.gold.withValues(alpha: 0.2),
                    AppColorsUnified.gold.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: AppColorsUnified.gold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes conversaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inicia una conversación desde el perfil\nde otro usuario',
              style: TextStyle(
                fontSize: 15,
                color: AppColorsUnified.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.gold,
                    AppColorsUnified.gold.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.gold.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColorsUnified.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buscar usuarios',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: AppColorsUnified.orange,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _conversations.length + (_isLoadingMore ? 1 : 0),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index == _conversations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColorsUnified.orange),
              ),
            );
          }
          final conversation = _conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final currentUserId = _authService.currentUser?.id ?? '';
    final otherUserId = conversation.getOtherUserId(currentUserId);
    final otherUserName = conversation.getOtherUserName(currentUserId);
    final otherUserProfileImage = conversation.getOtherUserProfileImage(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unreadCount > 0 
              ? AppColorsUnified.gold.withValues(alpha: 0.6)
              : AppColorsUnified.grey300,
          width: unreadCount > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: unreadCount > 0
                ? AppColorsUnified.gold.withValues(alpha: 0.2)
                : AppColorsUnified.blackTransparent05,
            blurRadius: unreadCount > 0 ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(otherUserId),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColorsUnified.gold.withValues(alpha: 0.1),
          highlightColor: AppColorsUnified.gold.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: unreadCount > 0 ? AppColorsUnified.gold : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.gold.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.15),
                        backgroundImage: otherUserProfileImage != null 
                            ? NetworkImage(otherUserProfileImage) 
                            : null,
                        child: otherUserProfileImage == null
                            ? Text(
                                otherUserName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppColorsUnified.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColorsUnified.gold,
                                AppColorsUnified.gold.withValues(alpha: 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColorsUnified.gold.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: AppColorsUnified.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          fontSize: 17,
                          color: unreadCount > 0 ? AppColorsUnified.gold : AppColorsUnified.textPrimary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColorsUnified.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(conversation.lastMessageAt),
                            style: TextStyle(
                              color: AppColorsUnified.grey500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColorsUnified.gold,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _openChat(String otherUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(otherUserId: otherUserId),
      ),
    ).then((_) => _loadConversations());
  }
}
