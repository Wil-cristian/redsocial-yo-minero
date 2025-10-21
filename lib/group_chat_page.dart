import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';

class GroupChatPage extends StatefulWidget {
  final Map<String, dynamic> group;
  final Map<String, dynamic>? currentUser;

  const GroupChatPage({
    super.key,
    required this.group,
    this.currentUser,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late TextEditingController _messageController;
  late List<Map<String, dynamic>> _messages;
  late List<Map<String, dynamic>> _members;
  final ScrollController _scrollController = ScrollController();
  bool _showMembers = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    
    // Mock de mensajes del grupo
    _messages = [
      {
        'id': '1',
        'sender': 'Luis García',
        'avatar': 'L',
        'content': 'Nueva oportunidad de exploración en el norte, ¿alguien interesado?',
        'timestamp': '14:30',
        'date': 'Hoy',
      },
      {
        'id': '2',
        'sender': 'María González',
        'avatar': 'M',
        'content': '¿Dónde exactamente? Necesito más detalles',
        'timestamp': '14:32',
        'date': 'Hoy',
      },
      {
        'id': '3',
        'sender': 'Carlos Pérez',
        'avatar': 'C',
        'content': 'Tengo experiencia en esa zona, puedo colaborar',
        'timestamp': '14:33',
        'date': 'Hoy',
      },
      {
        'id': '4',
        'sender': 'Luis García',
        'avatar': 'L',
        'content': 'Excelente, les comparto el documento con los detalles por correo',
        'timestamp': '14:35',
        'date': 'Hoy',
      },
      {
        'id': '5',
        'sender': 'Tú',
        'avatar': 'U',
        'content': '¿A cuándo es la reunión de coordinación?',
        'timestamp': '14:36',
        'date': 'Hoy',
      },
      {
        'id': '6',
        'sender': 'Luis García',
        'avatar': 'L',
        'content': 'Para mañana a las 10 AM. Manden confirmación.',
        'timestamp': '14:37',
        'date': 'Hoy',
      },
    ];

    // Mock de miembros del grupo
    _members = [
      {'name': 'Luis García', 'role': 'Admin', 'online': true, 'avatar': 'L'},
      {'name': 'María González', 'role': 'Miembro', 'online': true, 'avatar': 'M'},
      {'name': 'Carlos Pérez', 'role': 'Miembro', 'online': true, 'avatar': 'C'},
      {'name': 'Ana Rodríguez', 'role': 'Miembro', 'online': false, 'avatar': 'A'},
      {'name': 'Roberto Silva', 'role': 'Miembro', 'online': true, 'avatar': 'R'},
      {'name': 'Tú', 'role': 'Miembro', 'online': true, 'avatar': 'U'},
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
        'avatar': 'U',
        'content': _messageController.text,
        'timestamp': _getCurrentTime(),
        'date': 'Hoy',
      });
    });

    _messageController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group['name'] ?? 'Grupo'),
            Text(
              '${widget.group['memberCount']} miembros',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
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
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGroupInfo(context),
          ),
          IconButton(
            icon: Icon(_showMembers ? Icons.close : Icons.group),
            onPressed: () => setState(() => _showMembers = !_showMembers),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                          final isMine = message['sender'] == 'Tú';
                          
                          return _buildGroupMessageBubble(message, isMine);
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
                        color: DashboardColors.primary,
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
                          color: DashboardColors.primary,
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
          if (_showMembers)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Miembros (${_members.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return _buildMemberTile(member);
                        },
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

  Widget _buildGroupMessageBubble(Map<String, dynamic> message, bool isMine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: DashboardColors.primary.withValues(alpha: 0.2),
              child: Text(
                message['avatar'],
                style: const TextStyle(
                  color: Colors.white,
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
                if (!isMine)
                  Text(
                    message['sender'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                if (!isMine) const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: isMine ? DashboardColors.primary : Colors.grey[200],
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
              backgroundColor: DashboardColors.primary.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white, size: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: DashboardColors.primary.withValues(alpha: 0.2),
            child: Text(
              member['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (member['online'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
      title: Text(member['name']),
      subtitle: Text(member['role'], style: const TextStyle(fontSize: 12)),
      trailing: member['role'] == 'Admin'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DashboardColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            )
          : null,
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
            'Sé el primero en escribir',
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
                _buildAttachmentOption(Icons.image, 'Foto', Colors.blue),
                _buildAttachmentOption(Icons.videocam, 'Video', Colors.purple),
                _buildAttachmentOption(Icons.description, 'Archivo', Colors.orange),
                _buildAttachmentOption(Icons.location_on, 'Ubicación', Colors.red),
                _buildAttachmentOption(Icons.contact_mail, 'Contacto', Colors.teal),
                _buildAttachmentOption(Icons.description, 'Documento', Colors.indigo),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label - Próximamente')),
        );
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

  void _showGroupInfo(BuildContext context) {
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
                'Información del grupo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile(Icons.group, 'Nombre', widget.group['name'] ?? 'Grupo'),
            _buildInfoTile(Icons.people, 'Miembros', '${widget.group['memberCount']} miembros'),
            _buildInfoTile(Icons.description, 'Descripción', 'Grupo de mineros especializados'),
            _buildInfoTile(Icons.calendar_today, 'Creado', '15 de octubre, 2025'),
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
}
