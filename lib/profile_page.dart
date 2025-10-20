import 'package:flutter/material.dart';
import 'package:yominero/shared/models/user.dart';
import 'core/auth/auth_service.dart';
import 'package:yominero/shared/models/post.dart';
import 'core/routing/app_router.dart';
import 'core/theme/colors.dart';
import 'edit_profile_page.dart';
import 'shared/widgets/user_profile_card.dart';

/// Simple profile page that displays basic user information and a list
/// of the user's posts. Selecting a post navigates to its detail page.
class ProfilePage extends StatefulWidget {
  final User user;
  final List<Post> posts;

  const ProfilePage({super.key, required this.user, required this.posts});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _newTagCtrl = TextEditingController();

  User get _user => AuthService.instance.currentUser ?? widget.user;

  void _toggleType(PostType t) {
    AuthService.instance.togglePreferredPostType(t);
    setState(() {});
  }

  void _addTag() {
    final raw = _newTagCtrl.text.trim().toLowerCase();
    if (raw.isEmpty) return;
    AuthService.instance.followTag(raw);
    _newTagCtrl.clear();
    setState(() {});
  }

  void _removeTag(String tag) {
    AuthService.instance.unfollowTag(tag);
    setState(() {});
  }

  @override
  void dispose() {
    _newTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.username),
        actions: [
          if (_user.role == UserRole.admin)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.shield_moon_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User profile card section
          UserProfileCard(
            user: _user,
            showDistance: false,
            showRating: true,
            showSpecializations: true,
            compact: false,
          ),
          
          const SizedBox(height: 16),
          
          // Edit profile button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: _user),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_user.bio != null) ...[
            const SizedBox(height: 12),
            Text(
              _user.bio!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 24),
          Text('Preferencias de publicaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: -4,
            children: PostType.values.map((t) {
              final enabled = _user.preferredPostTypes.contains(t);
              return FilterChip(
                label: Text(t.name),
                selected: enabled,
                onSelected: (_) => _toggleType(t),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Tags seguidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          if (_user.followedTags.isEmpty)
            Text('No sigues tags aún',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]))
          else
            Wrap(
              spacing: 6,
              runSpacing: -6,
              children: _user.followedTags
                  .map((t) => Chip(
                        label: Text(t),
                        backgroundColor: AppColors.secondaryContainer,
                        onDeleted: () => _removeTag(t),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newTagCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nuevo tag', hintText: 'ej: seguridad'),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTag,
                child: const Text('Agregar'),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Publicaciones:',
            style: TextStyle(fontSize: 18),
          ),
          ...widget.posts.map(
            (post) => ListTile(
              title: Text(post.title),
              subtitle: Text(post.content),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.postDetail,
                  arguments: post,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              AuthService.instance.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
