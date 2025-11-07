import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/core/theme/colors.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';
import 'chat_page.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _messagingRepo = sl<MessagingRepository>();
  final _authService = SupabaseAuthService.instance;
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _error;
  Timer? _debounceTimer;
  String _currentQuery = '';
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
        _currentQuery = query;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
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
      
      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
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

  Future<void> _startConversation(Map<String, dynamic> user) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      // Crear o obtener conversación existente
      final conversation = await _messagingRepo.getOrCreateConversation(
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Buscar Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o profesión...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
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
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600),
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
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Busca usuarios para iniciar una conversación',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: user['avatar_url'] != null 
            ? NetworkImage(user['avatar_url']) 
            : null,
        child: user['avatar_url'] == null
            ? Text(
                (user['name'] ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          if (user['company'] != null)
            Text(
              user['company'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.message, color: AppColors.primary),
        onPressed: () => _startConversation(user),
        tooltip: 'Enviar mensaje',
      ),
      onTap: () => _startConversation(user),
    );
  }
}
