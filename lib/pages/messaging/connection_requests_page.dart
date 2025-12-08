import 'package:flutter/material.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/features/connections/data/supabase_connection_repository.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/shared/models/connection_request.dart';
import 'package:yominero/pages/messaging/chat_page.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';

class ConnectionRequestsPage extends StatefulWidget {
  const ConnectionRequestsPage({super.key});

  @override
  State<ConnectionRequestsPage> createState() => _ConnectionRequestsPageState();
}

class _ConnectionRequestsPageState extends State<ConnectionRequestsPage> with SingleTickerProviderStateMixin {
  final _connectionRepo = sl<ConnectionRepository>();
  final _messagingRepo = sl<MessagingRepository>();
  final _authService = SupabaseAuthService.instance;
  
  late TabController _tabController;
  List<ConnectionRequest> _receivedRequests = [];
  List<ConnectionRequest> _sentRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final received = await _connectionRepo.getPendingRequestsReceived();
      final sent = await _connectionRepo.getPendingRequestsSent();
      
      if (mounted) {
        setState(() {
          _receivedRequests = received;
          _sentRequests = sent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar solicitudes: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptRequest(ConnectionRequest request) async {
    try {
      await _connectionRepo.acceptConnectionRequest(request.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud aceptada. Ahora puedes chatear con ${request.getOtherUserDisplayName()}'),
            backgroundColor: AppColorsUnified.success,
            action: SnackBarAction(
              label: 'Chatear',
              textColor: AppColorsUnified.pureWhite,
              onPressed: () async {
                // Crear conversación y abrir chat
                final currentUserId = _authService.currentUser?.id;
                if (currentUserId != null) {
                  await _messagingRepo.getOrCreateConversation(
                    currentUserId,
                    request.senderId,
                  );
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(otherUserId: request.senderId),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
        _loadRequests();
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

  Future<void> _rejectRequest(ConnectionRequest request) async {
    try {
      await _connectionRepo.rejectConnectionRequest(request.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadRequests();
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

  Future<void> _cancelRequest(ConnectionRequest request) async {
    try {
      await _connectionRepo.cancelConnectionRequest(request.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadRequests();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.pureWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsUnified.textPrimary,
                AppColorsUnified.textPrimary.withOpacity(0.95),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.gold.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColorsUnified.gold),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Solicitudes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.gold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppColorsUnified.gold),
                        onPressed: _loadRequests,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColorsUnified.gold,
                  unselectedLabelColor: AppColorsUnified.grey500,
                  indicatorColor: AppColorsUnified.gold,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Recibidas'),
                          if (_receivedRequests.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColorsUnified.gold,
                                    AppColorsUnified.gold.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_receivedRequests.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsUnified.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Enviadas'),
                          if (_sentRequests.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColorsUnified.grey500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_sentRequests.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsUnified.pureWhite,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColorsUnified.gold))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColorsUnified.error),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRequests,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReceivedTab(),
                    _buildSentTab(),
                  ],
                ),
    );
  }

  Widget _buildReceivedTab() {
    if (_receivedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.gold.withOpacity(0.2),
                    AppColorsUnified.gold.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 50,
                color: AppColorsUnified.gold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes solicitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las solicitudes de conexión\naparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColorsUnified.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final request = _receivedRequests[index];
        return _buildReceivedRequestCard(request);
      },
    );
  }

  Widget _buildReceivedRequestCard(ConnectionRequest request) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColorsUnified.gold.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColorsUnified.gold.withOpacity(0.15),
                  backgroundImage: request.otherUserProfileImage != null
                      ? NetworkImage(request.otherUserProfileImage!)
                      : null,
                  child: request.otherUserProfileImage == null
                      ? Text(
                          request.getOtherUserDisplayName()[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.gold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.getOtherUserDisplayName(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Quiere conectar contigo',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColorsUnified.grey600,
                        ),
                      ),
                      if (request.message != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColorsUnified.grey100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            request.message!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColorsUnified.grey700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(request),
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.gold,
                      foregroundColor: AppColorsUnified.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColorsUnified.grey700,
                      side: BorderSide(color: AppColorsUnified.grey400),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentTab() {
    if (_sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.grey300.withOpacity(0.3),
                    AppColorsUnified.grey300.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_outlined,
                size: 50,
                color: AppColorsUnified.grey500,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No has enviado solicitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Busca usuarios y envíales\nsolicitudes de conexión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColorsUnified.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final request = _sentRequests[index];
        return _buildSentRequestCard(request);
      },
    );
  }

  Widget _buildSentRequestCard(ConnectionRequest request) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColorsUnified.grey300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColorsUnified.grey200,
          backgroundImage: request.otherUserProfileImage != null
              ? NetworkImage(request.otherUserProfileImage!)
              : null,
          child: request.otherUserProfileImage == null
              ? Text(
                  request.getOtherUserDisplayName()[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.grey700,
                  ),
                )
              : null,
        ),
        title: Text(
          request.getOtherUserDisplayName(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: AppColorsUnified.grey500,
            ),
            const SizedBox(width: 4),
            Text(
              'Pendiente',
              style: TextStyle(
                fontSize: 13,
                color: AppColorsUnified.grey500,
              ),
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () => _cancelRequest(request),
          style: TextButton.styleFrom(
            foregroundColor: AppColorsUnified.error,
          ),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
