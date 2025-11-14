import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/core/theme/colors.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';
import 'package:yominero/shared/models/conversation.dart';
import 'package:yominero/shared/models/message.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({super.key, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messagingRepo = sl<MessagingRepository>();
  final _authService = SupabaseAuthService.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<Message> _messages = [];
  Conversation? _conversation;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  StreamSubscription? _realtimeSubscription;
  
  // Información del otro usuario
  String? _otherUserName;
  String? _otherUserProfileImage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      // Obtener o crear conversación
      final conversation = await _messagingRepo.getOrCreateConversation(
        currentUserId,
        widget.otherUserId,
      );

      // Cargar mensajes
      final messages = await _messagingRepo.getConversationMessages(conversation.id);

      // Marcar mensajes como leídos
      await _messagingRepo.markMessagesAsRead(conversation.id, currentUserId);

      // Obtener nombre del otro usuario
      final otherUserName = conversation.getOtherUserName(currentUserId);
      final otherUserProfileImage = conversation.getOtherUserProfileImage(currentUserId);

      // Suscribirse a nuevos mensajes en tiempo real
      _subscribeToMessages(conversation.id);

      if (mounted) {
        setState(() {
          _conversation = conversation;
          _messages = messages;
          _otherUserName = otherUserName;
          _otherUserProfileImage = otherUserProfileImage;
          _isLoading = false;
        });

        // Scroll al final
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar chat: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToMessages(String conversationId) {
    _realtimeSubscription = _messagingRepo
        .subscribeToMessages(conversationId)
        .listen((newMessage) {
      if (mounted) {
        setState(() {
          _messages.add(newMessage);
        });
        
        // Marcar como leído automáticamente si el mensaje es del otro usuario
        final currentUserId = _authService.currentUser?.id;
        if (currentUserId != null && newMessage.senderId != currentUserId) {
          _messagingRepo.markMessagesAsRead(conversationId, currentUserId);
        }

        // Scroll al final
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });
      }
    });
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _conversation == null || _isSending) return;

    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _messagingRepo.sendMessage(
        conversationId: _conversation!.id,
        senderId: currentUserId,
        content: content,
        type: MessageType.text,
      );

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _messagingRepo.unsubscribeFromMessages(_conversation?.id ?? '');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.grey50,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsUnified.orange,
                AppColorsUnified.orangeDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.orange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorsUnified.whiteTransparent20,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
                color: AppColorsUnified.pureWhite,
              ),
            ),
            title: Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.otherUserId}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColorsUnified.pureWhite,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.blackTransparent20,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColorsUnified.pureWhite,
                      backgroundImage: _otherUserProfileImage != null 
                          ? NetworkImage(_otherUserProfileImage!) 
                          : null,
                      child: _otherUserProfileImage == null
                          ? Text(
                              (_otherUserName ?? widget.otherUserId).substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                color: AppColorsUnified.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _otherUserName ?? 'Usuario ${widget.otherUserId.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.pureWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColorsUnified.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.success.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'En línea',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.whiteTransparent90,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.whiteTransparent20,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, size: 22),
                  onPressed: () {},
                  color: AppColorsUnified.pureWhite,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColorsUnified.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeChat,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColorsUnified.pureWhite,
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
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
                    AppColorsUnified.orange.withValues(alpha: 0.1),
                    AppColorsUnified.orange.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: AppColorsUnified.orange.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Inicia la conversación!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envía tu primer mensaje a ${_otherUserName ?? 'este usuario'}',
              style: TextStyle(
                fontSize: 15,
                color: AppColorsUnified.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.orange.withValues(alpha: 0.1),
                    AppColorsUnified.orange.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 20,
                    color: AppColorsUnified.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Los mensajes aparecerán aquí',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColorsUnified.grey700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _authService.currentUser?.id;
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.orange.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColorsUnified.orange.withValues(alpha: 0.1),
                backgroundImage: _otherUserProfileImage != null 
                    ? NetworkImage(_otherUserProfileImage!) 
                    : null,
                child: _otherUserProfileImage == null
                    ? Text(
                        _otherUserName != null && _otherUserName!.isNotEmpty
                            ? _otherUserName!.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.orange,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          AppColorsUnified.orange,
                          AppColorsUnified.orangeDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : AppColorsUnified.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe 
                        ? AppColorsUnified.orange.withValues(alpha: 0.3)
                        : AppColorsUnified.blackTransparent10,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? AppColorsUnified.pureWhite : AppColorsUnified.charcoal,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMe 
                              ? AppColorsUnified.whiteTransparent70 
                              : AppColorsUnified.grey600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: AppColorsUnified.whiteTransparent70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.blackTransparent10,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Botón de adjuntos
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColorsUnified.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 24),
                  onPressed: () {
                    // TODO: Implementar adjuntar archivos
                  },
                  color: AppColorsUnified.orange,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              // Campo de texto
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.grey50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColorsUnified.grey200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            hintStyle: TextStyle(
                              color: AppColorsUnified.grey500,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          minLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      // Botón emoji
                      Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 6),
                        child: IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, size: 24),
                          onPressed: () {
                            // TODO: Implementar selector de emojis
                          },
                          color: AppColorsUnified.grey600,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón enviar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsUnified.orange,
                      AppColorsUnified.orangeDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsUnified.orange.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isSending
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColorsUnified.pureWhite),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 22),
                  onPressed: _isSending ? null : _sendMessage,
                  color: AppColorsUnified.pureWhite,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
