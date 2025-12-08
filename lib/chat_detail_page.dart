import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/supabase/supabase_service.dart';
import 'core/auth/supabase_auth_service.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final Map<String, dynamic>? currentUser;

  const ChatDetailPage({
    super.key,
    required this.conversation,
    this.currentUser,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late TextEditingController _messageController;
  late List<Map<String, dynamic>> _messages;
  final ScrollController _scrollController = ScrollController();
  final _supabase = SupabaseService.instance.client;
  
  String? _conversationId;
  String? _otherUserId;
  String? _otherUserName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messages = [];
    
    // Obtener info del otro usuario desde conversation
    _otherUserId = widget.conversation['otherUserId'];
    _otherUserName = widget.conversation['otherUserName'];
    
    _loadOrCreateConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreateConversation() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null || _otherUserId == null) return;

      // Ordenar IDs para buscar conversación (user1_id < user2_id)
      final userId1 = currentUser.id.compareTo(_otherUserId!) < 0 
          ? currentUser.id 
          : _otherUserId!;
      final userId2 = currentUser.id.compareTo(_otherUserId!) < 0 
          ? _otherUserId! 
          : currentUser.id;

      // Buscar conversación existente
      final existingConversation = await _supabase
          .from('conversations')
          .select()
          .eq('user1_id', userId1)
          .eq('user2_id', userId2)
          .maybeSingle();

      if (existingConversation != null) {
        _conversationId = existingConversation['id'];
      } else {
        // Crear nueva conversación
        final newConversation = await _supabase
            .from('conversations')
            .insert({
              'user1_id': userId1,
              'user2_id': userId2,
            })
            .select()
            .single();
        _conversationId = newConversation['id'];
      }

      // Cargar mensajes
      await _loadMessages();

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error al cargar conversación: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (_conversationId == null) return;

      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      final messagesData = await _supabase
          .from('messages')
          .select('''
            id,
            content,
            sender_id,
            created_at,
            users:sender_id (
              name,
              username
            )
          ''')
          .eq('conversation_id', _conversationId!)
          .order('created_at', ascending: true);

      setState(() {
        _messages = messagesData.map((msg) {
          final senderName = msg['users']?['name'] ?? 'Usuario';
          final isMe = msg['sender_id'] == currentUser.id;
          
          return {
            'id': msg['id'],
            'sender': isMe ? 'Tú' : senderName,
            'senderType': isMe ? 'me' : 'other',
            'content': msg['content'],
            'timestamp': _formatTime(msg['created_at']),
            'date': _formatDate(msg['created_at']),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('❌ Error al cargar mensajes: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    if (_conversationId == null) return;

    final currentUser = SupabaseAuthService.instance.currentUser;
    if (currentUser == null) return;

    final messageContent = _messageController.text;
    _messageController.clear();

    try {
      // Guardar mensaje en base de datos
      final newMessage = await _supabase
          .from('messages')
          .insert({
            'conversation_id': _conversationId,
            'sender_id': currentUser.id,
            'content': messageContent,
          })
          .select('''
            id,
            content,
            sender_id,
            created_at
          ''')
          .single();

      // Actualizar last_message_at en conversation
      await _supabase
          .from('conversations')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', _conversationId!);

      // Agregar mensaje a la lista local
      setState(() {
        _messages.add({
          'id': newMessage['id'],
          'sender': 'Tú',
          'senderType': 'me',
          'content': messageContent,
          'timestamp': _formatTime(newMessage['created_at']),
          'date': _formatDate(newMessage['created_at']),
        });
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error al enviar mensaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar mensaje')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Hoy';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);
      
      if (messageDate == today) {
        return 'Hoy';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Ayer';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Hoy';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'individual':
        return AppColorsUnified.orange;
      case 'worker':
        return DashboardColors.cardTeal;
      case 'company':
        return DashboardColors.cardDarkBlue;
      default:
        return AppColorsUnified.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationType = widget.conversation['type'] ?? 'individual';
    final typeColor = _getTypeColor(conversationType);
    final displayName = _otherUserName ?? widget.conversation['otherUserName'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName),
            if (widget.conversation['isOnline'] == true)
              const Text(
                'En línea',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )
            else
              Text(
                'Desconectado',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)),
              ),
          ],
        ),
        backgroundColor: typeColor,
        foregroundColor: AppColorsUnified.pureWhite,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColorsUnified.pureWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _showComingSoon(context, 'Llamadas'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _showComingSoon(context, 'Videollamadas'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'info') {
                _showConversationInfo(context);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Información'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColorsUnified.error),
                    SizedBox(width: 12),
                    Text('Eliminar chat', style: TextStyle(color: AppColorsUnified.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColorsUnified.orange,
                    ),
                  )
                : _messages.isEmpty
                    ? _buildEmptyMessages()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMine = message['senderType'] == 'me';
                      
                      return _buildMessageBubble(message, isMine, typeColor);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsUnified.pureWhite,
              border: const Border(
                top: BorderSide(color: AppColorsUnified.background, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: typeColor,
                    onPressed: () => _showAttachmentMenu(context),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorsUnified.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          hintStyle: TextStyle(color: AppColorsUnified.textSecondary),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: AppColorsUnified.pureWhite,
                      onPressed: _sendMessage,
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

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMine, Color typeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: typeColor.withOpacity(0.2),
              child: Text(
                widget.conversation['avatar'] ?? 'U',
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMine) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isMine ? typeColor : AppColorsUnified.background,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    message['content'],
                    style: TextStyle(
                      color: isMine ? AppColorsUnified.pureWhite : AppColorsUnified.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['timestamp'],
                  style: const TextStyle(
                    color: AppColorsUnified.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isMine) const SizedBox(width: 12),
          if (isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: typeColor.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColorsUnified.pureWhite, size: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin mensajes aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicia la conversación',
            style: TextStyle(
              fontSize: 14,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adjuntar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                _buildAttachmentOption(Icons.image, 'Foto', AppColorsUnified.companyBlue),
                _buildAttachmentOption(Icons.videocam, 'Video', AppColorsUnified.companyBlueDark),
                _buildAttachmentOption(Icons.description, 'Archivo', AppColorsUnified.orange),
                _buildAttachmentOption(Icons.location_on, 'Ubicación', AppColorsUnified.error),
                _buildAttachmentOption(Icons.contact_mail, 'Contacto', AppColorsUnified.success),
                _buildAttachmentOption(Icons.description, 'Documento', AppColorsUnified.companyBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showComingSoon(context, label);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showConversationInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Información de la conversación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile(Icons.person, 'Nombre', widget.conversation['name'] ?? 'Usuario'),
            _buildInfoTile(Icons.mail, 'Correo', 'usuario@ejemplo.com'),
            _buildInfoTile(Icons.phone, 'Teléfono', '+57 300 123 4567'),
            _buildInfoTile(Icons.location_on, 'Ubicación', 'Medellín, Colombia'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColorsUnified.orange, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColorsUnified.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conversación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta conversación? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversación eliminada')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColorsUnified.error)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Próximamente')),
    );
  }
}
