import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    
    // Mock de mensajes previos
    _messages = [
      {
        'id': '1',
        'sender': 'María González',
        'senderType': 'other',
        'content': 'Hola, ¿cómo estás? Tenía una pregunta sobre el proyecto',
        'timestamp': '10:30',
        'date': 'Hoy',
      },
      {
        'id': '2',
        'sender': 'Tú',
        'senderType': 'me',
        'content': '¡Hola! Bien, ¿qué necesitas?',
        'timestamp': '10:32',
        'date': 'Hoy',
      },
      {
        'id': '3',
        'sender': 'María González',
        'senderType': 'other',
        'content': 'Quería saber si tienes disponibilidad la próxima semana para una reunión',
        'timestamp': '10:33',
        'date': 'Hoy',
      },
      {
        'id': '4',
        'sender': 'María González',
        'senderType': 'other',
        'content': 'Necesitamos discutir los detalles de la exploración',
        'timestamp': '10:34',
        'date': 'Hoy',
      },
      {
        'id': '5',
        'sender': 'Tú',
        'senderType': 'me',
        'content': 'Perfecto, podemos coordinar para el martes o miércoles',
        'timestamp': '10:35',
        'date': 'Hoy',
      },
      {
        'id': '6',
        'sender': 'Tú',
        'senderType': 'me',
        'content': '¿A qué hora te viene bien?',
        'timestamp': '10:36',
        'date': 'Hoy',
      },
      {
        'id': '7',
        'sender': 'María González',
        'senderType': 'other',
        'content': 'Excelente, el martes a las 2 PM estaría perfecto 👍',
        'timestamp': '10:37',
        'date': 'Hoy',
      },
      {
        'id': '8',
        'sender': 'María González',
        'senderType': 'other',
        'content': 'Perfecto, ¿podemos coordinar una reunión para la próxima semana?',
        'timestamp': '15:30',
        'date': 'Hoy',
      },
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': '${_messages.length + 1}',
        'sender': 'Tú',
        'senderType': 'me',
        'content': _messageController.text,
        'timestamp': _getCurrentTime(),
        'date': 'Hoy',
      });
    });

    _messageController.clear();

    // Simular respuesta después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': '${_messages.length + 1}',
            'sender': widget.conversation['name'],
            'senderType': 'other',
            'content': '👍 Mensaje recibido',
            'timestamp': _getCurrentTime(),
            'date': 'Hoy',
          });
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
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

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'individual':
        return DashboardColors.cardOrange;
      case 'worker':
        return DashboardColors.cardTeal;
      case 'company':
        return DashboardColors.cardDarkBlue;
      default:
        return DashboardColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationType = widget.conversation['type'] ?? 'individual';
    final typeColor = _getTypeColor(conversationType);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation['name'] ?? 'Conversación'),
            if (widget.conversation['isOnline'] == true)
              const Text(
                'En línea',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )
            else
              Text(
                'Desconectado',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[400]),
              ),
          ],
        ),
        backgroundColor: typeColor,
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
            child: _messages.isEmpty
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
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          hintStyle: TextStyle(color: Colors.grey[500]),
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
                      color: Colors.white,
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
              backgroundColor: typeColor.withValues(alpha: 0.2),
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
                    color: isMine ? typeColor : Colors.grey[200],
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
                      color: isMine ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['timestamp'],
                  style: TextStyle(
                    color: Colors.grey[500],
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
              backgroundColor: typeColor.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 12),
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
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Sin mensajes aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia la conversación',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
                _buildAttachmentOption(Icons.videocam, 'Video', AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2)),
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
              color: color.withValues(alpha: 0.1),
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
          Icon(icon, color: DashboardColors.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
