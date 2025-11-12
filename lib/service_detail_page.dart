import 'package:flutter/material.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'core/theme/colors.dart';

/// Displays detailed information about a service with beautiful design
/// and enhanced user interactions including quotes, contact, and reviews.
class ServiceDetailPage extends StatefulWidget {
  final Service service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> with TickerProviderStateMixin {
  bool _isBookmarked = false;
  late AnimationController _quoteAnimationController;
  late AnimationController _bookmarkAnimationController;

  @override
  void initState() {
    super.initState();
    _quoteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bookmarkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _quoteAnimationController.dispose();
    _bookmarkAnimationController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      if (_isBookmarked) {
        _bookmarkAnimationController.forward().then((_) {
          _bookmarkAnimationController.reverse();
        });
      }
    });
  }

  void _requestQuote() {
    setState(() {
      _quoteAnimationController.forward().then((_) {
        _quoteAnimationController.reverse();
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cotización solicitada para ${widget.service.name}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildServiceHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColorsUnified.greySoftGradient,
      ),
      child: Stack(
        children: [
          // Decorative elements con oro sutil
          Positioned(
            top: 50,
            right: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.05),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: -30,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.03),
              ),
            ),
          ),
          // Main content
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service icon con gradiente oro
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColorsUnified.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getServiceIcon(),
                    color: AppColorsUnified.textPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Service name
                Text(
                  widget.service.name,
                  style: TextStyle(
                    color: AppColorsUnified.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Rate
                Text(
                  widget.service.priceDisplay,
                  style: TextStyle(
                    color: AppColorsUnified.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _buildServiceStatChip('★★★★★', 'Rating'),
                    const SizedBox(width: 12),
                    _buildServiceStatChip('Profesional', 'Categoría'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.grey200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsUnified.grey300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColorsUnified.gold,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColorsUnified.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon() {
    final name = widget.service.name.toLowerCase();
    if (name.contains('mantenimiento')) return Icons.build_circle;
    if (name.contains('soldadura')) return Icons.whatshot;
    if (name.contains('electricidad') || name.contains('eléctrico')) return Icons.electrical_services;
    if (name.contains('plomería') || name.contains('fontanería')) return Icons.plumbing;
    if (name.contains('mecánica') || name.contains('mecánico')) return Icons.engineering;
    if (name.contains('pintura')) return Icons.format_paint;
    if (name.contains('construcción')) return Icons.construction;
    if (name.contains('consultoría')) return Icons.psychology;
    return Icons.handyman;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorsUnified.grey200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorsUnified.grey300),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorsUnified.grey300),
                ),
                child: AnimatedBuilder(
                  animation: _bookmarkAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_bookmarkAnimationController.value * 0.2),
                      child: IconButton(
                        icon: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          color: _isBookmarked ? AppColorsUnified.gold : AppColorsUnified.textPrimary,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorsUnified.grey300),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: AppColorsUnified.textPrimary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartir servicio próximamente')),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildServiceHeaderContent(),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción del Servicio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.service.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Service details section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles del Servicio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Tarifa', widget.service.priceDisplay),
                    _buildDetailRow('Disponibilidad', 'Lunes a Viernes'),
                    _buildDetailRow('Experiencia', '5+ años'),
                    _buildDetailRow('Ubicación', 'Disponible en toda la ciudad'),
                    _buildDetailRow('Respuesta', 'Dentro de 24 horas'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Provider info section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proveedor del Servicio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColorsUnified.goldGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColorsUnified.textPrimary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profesional Certificado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Especialista en ${widget.service.name}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColorsUnified.warning, size: 16),
                                  const Icon(Icons.star, color: AppColorsUnified.warning, size: 16),
                                  const Icon(Icons.star, color: AppColorsUnified.warning, size: 16),
                                  const Icon(Icons.star, color: AppColorsUnified.warning, size: 16),
                                  const Icon(Icons.star, color: AppColorsUnified.warning, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '4.9 (127 reseñas)',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons con gradiente oro
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Quote button
                    AnimatedBuilder(
                      animation: _quoteAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_quoteAnimationController.value * 0.05),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _requestQuote,
                              icon: Icon(Icons.request_quote, color: AppColorsUnified.gold),
                              label: Text(
                                'Solicitar Cotización',
                                style: TextStyle(
                                  color: AppColorsUnified.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsUnified.pureWhite,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Contact button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contactar próximamente')),
                          );
                        },
                        icon: Icon(Icons.message, color: AppColorsUnified.textPrimary),
                        label: Text(
                          'Contactar Proveedor',
                          style: TextStyle(
                            color: AppColorsUnified.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColorsUnified.textPrimary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
