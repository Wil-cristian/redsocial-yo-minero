import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/features/responses/domain/response_repository.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/shared/models/post.dart';

class ResponseModal extends StatefulWidget {
  final Post post;
  final VoidCallback onResponseAdded;

  const ResponseModal({
    super.key,
    required this.post,
    required this.onResponseAdded,
  });

  @override
  State<ResponseModal> createState() => _ResponseModalState();
}

class _ResponseModalState extends State<ResponseModal> with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _responseRepo = sl<ResponseRepository>();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const int maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor escribe tu respuesta'),
          backgroundColor: AppColorsUnified.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _responseRepo.createResponse(
        postId: widget.post.id,
        content: _contentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onResponseAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Respuesta publicada!'),
              ],
            ),
            backgroundColor: AppColorsUnified.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _contentController.text.length;
    final remainingChars = maxLength - currentLength;
    final isNearLimit = remainingChars < 100;
    final isOverLimit = currentLength > maxLength;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColorsUnified.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorsUnified.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.gold,
                    AppColorsUnified.goldDeep,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Responder',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Comparte tu conocimiento',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Pregunta:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu respuesta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColorsUnified.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOverLimit
                                ? AppColorsUnified.error
                                : AppColorsUnified.grey300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _contentController,
                          maxLines: 10,
                          maxLength: maxLength,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Escribe una respuesta útil y detallada...\n\n• Comparte tu experiencia\n• Sé claro y específico\n• Ayuda a resolver el problema',
                            hintStyle: TextStyle(
                              color: AppColorsUnified.textSecondary,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            counterText: '',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColorsUnified.textPrimary,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            isOverLimit
                                ? Icons.error_outline
                                : (isNearLimit ? Icons.warning_amber_rounded : Icons.info_outline),
                            color: isOverLimit
                                ? AppColorsUnified.error
                                : (isNearLimit ? AppColorsUnified.orange : AppColorsUnified.textSecondary),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOverLimit
                                ? '¡Has excedido el límite!'
                                : '$remainingChars caracteres restantes',
                            style: TextStyle(
                              fontSize: 13,
                              color: isOverLimit
                                  ? AppColorsUnified.error
                                  : (isNearLimit ? AppColorsUnified.orange : AppColorsUnified.textSecondary),
                              fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColorsUnified.gold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColorsUnified.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Las mejores respuestas son claras, detalladas y basadas en experiencia real',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColorsUnified.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer con botón
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColorsUnified.pureWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || isOverLimit || currentLength == 0
                        ? null
                        : _submitResponse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.gold,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColorsUnified.grey300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Publicar Respuesta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
