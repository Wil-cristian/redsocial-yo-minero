import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../features/posts/domain/post_repository.dart';
import '../models/post.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CreatePostModal extends StatefulWidget {
  final String userId;

  const CreatePostModal({super.key, required this.userId});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _repo = sl<PostRepository>();
  
  PostType _selectedType = PostType.community;
  final List<String> _categories = [];
  final List<String> _tags = [];
  bool _isSubmitting = false;

  final List<String> _availableCategories = [
    'Minería',
    'Oro',
    'Carbón',
    'Esmeraldas',
    'Seguridad',
    'Equipos',
    'Servicios',
    'Ofertas',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa título y contenido')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repo.create(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        categories: _categories,
        tags: _tags,
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar que se creó
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Publicación creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al crear: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsUnified.pureWhite,
              border: const Border(bottom: BorderSide(color: AppColorsUnified.background)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Crear publicación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _isSubmitting ? null : _createPost,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tipo
                  const Text('Tipo de publicación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTypeChip('Publicación', PostType.community, Icons.article),
                      _buildTypeChip('Pregunta', PostType.request, Icons.help),
                      _buildTypeChip('Oferta', PostType.offer, Icons.local_offer),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Título
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      hintText: 'Escribe un título llamativo...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    maxLength: 100,
                  ),

                  const SizedBox(height: 16),

                  // Contenido
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Contenido',
                      hintText: '¿Qué quieres compartir?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                    maxLength: 500,
                  ),

                  const SizedBox(height: 24),

                  // Categorías
                  const Text('Categorías (opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((cat) {
                      final isSelected = _categories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _categories.add(cat);
                            } else {
                              _categories.remove(cat);
                            }
                          });
                        },
                        selectedColor: AppColorsUnified.orange.withValues(alpha: 0.3),
                        checkmarkColor: AppColorsUnified.orange,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, PostType type, IconData icon) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColorsUnified.pureWhite : AppColorsUnified.textSecondary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = type);
      },
      selectedColor: AppColorsUnified.orange,
      labelStyle: TextStyle(
        color: isSelected ? AppColorsUnified.pureWhite : AppColorsUnified.charcoal,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
