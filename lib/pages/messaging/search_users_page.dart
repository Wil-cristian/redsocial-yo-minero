import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/features/connections/data/supabase_connection_repository.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'chat_page.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _messagingRepo = sl<MessagingRepository>();
  final _connectionRepo = sl<ConnectionRepository>();
  final _authService = SupabaseAuthService.instance;
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, String> _connectionStatus = {}; // userId -> status
  bool _isSearching = false;
  String? _error;
  Timer? _debounceTimer;
  int _searchVersion = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().length < 2) {
      setState(() {
        _searchVersion++;
        _searchResults = [];
        _error = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final searchVersion = ++_searchVersion;

    try {
      final results = await _messagingRepo.searchUsers(query);
      
      // Solo actualizar si esta es la búsqueda más reciente
      if (searchVersion != _searchVersion || !mounted) return;
      
      // Excluir al usuario actual de los resultados
      final currentUserId = _authService.currentUser?.id;
      final filteredResults = results.where((user) => user['id'] != currentUserId).toList();
      
      // Verificar estado de conexión para cada usuario
      final statusMap = <String, String>{};
      for (final user in filteredResults) {
        final userId = user['id'] as String;
        statusMap[userId] = await _checkConnectionStatus(userId);
      }
      
      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
          _connectionStatus = statusMap;
          _isSearching = false;
          _error = null;
        });
      }
    } catch (e) {
      if (searchVersion != _searchVersion || !mounted) return;
      
      if (mounted) {
        setState(() {
          _error = 'Error al buscar usuarios: $e';
          _isSearching = false;
        });
      }
    }
  }

  Future<String> _checkConnectionStatus(String userId) async {
    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return 'none';

    try {
      // Verificar si están conectados
      final isConnected = await _connectionRepo.areUsersConnected(currentUserId, userId);
      if (isConnected) return 'connected';

      // Verificar si hay solicitud pendiente
      final pendingRequest = await _connectionRepo.getPendingRequestBetweenUsers(currentUserId, userId);
      if (pendingRequest != null) {
        if (pendingRequest.senderId == currentUserId) {
          return 'pending_sent';
        } else {
          return 'pending_received';
        }
      }

      return 'none';
    } catch (e) {
      return 'none';
    }
  }

  Future<void> _sendConnectionRequest(Map<String, dynamic> user) async {
    try {
      await _connectionRepo.sendConnectionRequest(user['id']);
      
      if (mounted) {
        setState(() {
          _connectionStatus[user['id']] = 'pending_sent';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud enviada a ${user['name'] ?? 'usuario'}'),
            backgroundColor: AppColorsUnified.success,
            duration: const Duration(seconds: 2),
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

  Future<void> _startConversation(Map<String, dynamic> user) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      // Crear o obtener conversación existente
      await _messagingRepo.getOrCreateConversation(
        currentUser.id,
        user['id'],
      );

      if (mounted) {
        // Navegar a la página de chat
        Navigator.pop(context); // Cerrar búsqueda
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              otherUserId: user['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar conversación: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text(
          'Buscar Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColorsUnified.orange,
        foregroundColor: AppColorsUnified.pureWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: AppColorsUnified.orange,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o profesión...',
                filled: true,
                fillColor: AppColorsUnified.pureWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColorsUnified.orange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Resultados
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorsUnified.orange),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColorsUnified.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppColorsUnified.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchController.text.trim().length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Busca usuarios para iniciar una conversación',
              style: TextStyle(
                fontSize: 16,
                color: AppColorsUnified.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron usuarios',
              style: TextStyle(
                fontSize: 16,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final status = _connectionStatus[user['id']] ?? 'none';
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColorsUnified.grey300, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.15),
          backgroundImage: user['profile_image_url'] != null 
              ? NetworkImage(user['profile_image_url']) 
              : null,
          child: user['profile_image_url'] == null
              ? Text(
                  (user['name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.gold,
                  ),
                )
              : null,
        ),
        title: Text(
          user['name'] ?? 'Usuario',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['profession'] != null)
              Text(
                user['profession'],
                style: const TextStyle(
                  color: AppColorsUnified.textSecondary,
                  fontSize: 14,
                ),
              ),
            if (user['company'] != null)
              Text(
                user['company'],
                style: TextStyle(
                  color: AppColorsUnified.grey500,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: _buildActionButton(user, status),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> user, String status) {
    switch (status) {
      case 'connected':
        // Ya son contactos, puede chatear directamente
        return ElevatedButton.icon(
          onPressed: () => _startConversation(user),
          icon: const Icon(Icons.chat, size: 18),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsUnified.gold,
            foregroundColor: AppColorsUnified.textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
        
      case 'pending_sent':
        // Solicitud enviada, esperando respuesta
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColorsUnified.grey600,
              ),
              const SizedBox(width: 4),
              Text(
                'Pendiente',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColorsUnified.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
        
      case 'pending_received':
        // Tiene solicitud de este usuario (debe ir a notificaciones)
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsUnified.gold.withValues(alpha: 0.2),
                AppColorsUnified.gold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColorsUnified.gold.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notification_important,
                size: 16,
                color: AppColorsUnified.gold,
              ),
              SizedBox(width: 4),
              Text(
                'Solicitud',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColorsUnified.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        
      case 'none':
      default:
        // No hay conexión, puede enviar solicitud
        return ElevatedButton.icon(
          onPressed: () => _sendConnectionRequest(user),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Conectar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsUnified.pureWhite,
            foregroundColor: AppColorsUnified.gold,
            elevation: 0,
            side: const BorderSide(
              color: AppColorsUnified.gold,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
    }
  }
}
