import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';

/// 💎 PREMIUM PRODUCT CARD - Diseño ultra sofisticado con efectos fetichistas
/// 
/// Características:
/// - Base blanca premium
/// - Bordes dorados multicapa
/// - Sombras profundas y resplandor
/// - Animaciones suaves
/// - Glassmorphism
/// - Efectos 3D
class PremiumProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final int index;

  const PremiumProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.index,
  });

  @override
  State<PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<PremiumProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // Colores premium basados en gemas
  static const List<List<Color>> _gemGradients = [
    // Oro Imperial
    [AppColorsUnified.gold, AppColorsUnified.orange, AppColorsUnified.lighten(AppColorsUnified.gold, 0.2)],
    // Plata Lunar
    [AppColorsUnified.lighten(AppColorsUnified.surface, 0.05), AppColorsUnified.lighten(AppColorsUnified.gold, 0.3), AppColorsUnified.surface],
    // Esmeralda
    [Color(0xFF50C878), Color(0xFF00A86B), Color(0xFF7FFFD4)],
    // Zafiro
    [Color(0xFF0F52BA), Color(0xFF082567), Color(0xFF6495ED)],
    // Rubí
    [AppColorsUnified.error, AppColorsUnified.darken(AppColorsUnified.error, 0.2), AppColorsUnified.lighten(AppColorsUnified.error, 0.2)],
    // Amatista
    [Color(0xFF9966CC), Color(0xFF6A0DAD), AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.3)],
  ];

  List<Color> get _cardGradient => _gemGradients[widget.index % _gemGradients.length];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.05)
              ..scale(1.02))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: [
                // Resplandor exterior animado
                _buildOuterGlow(),
                
                // Tarjeta principal
                _buildMainCard(),
                
                // Efecto de brillo superior (shimmer)
                _buildShimmerEffect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOuterGlow() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: _cardGradient[0].withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: _cardGradient[1].withValues(alpha: 0.4),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ]
            : [
                BoxShadow(
                  color: _cardGradient[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Bordes multicapa efecto oro/plata
        border: Border.all(
          width: 3,
          color: Colors.transparent,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardGradient[0].withValues(alpha: 0.3),
            Colors.white,
            _cardGradient[1].withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // Sombra profunda
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Sombra de color
          BoxShadow(
            color: _cardGradient[0].withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // Borde interior dorado
          border: Border.all(
            width: 2,
            color: _cardGradient[0].withValues(alpha: 0.5),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Borde más interno plateado
            border: Border.all(
              width: 1,
              color: const AppColorsUnified.lighten(AppColorsUnified.surface, 0.05),
            ),
            // Fondo blanco premium
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Stack(
      children: [
        // Gradiente sutil de fondo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _cardGradient[2].withValues(alpha: 0.05),
                  Colors.white,
                  _cardGradient[0].withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
        ),
        
        // Contenido
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header premium
              _buildPremiumHeader(),
              
              const SizedBox(height: 16),
              
              // Título con gradiente
              _buildGradientTitle(),
              
              const SizedBox(height: 8),
              
              // Descripción
              _buildDescription(),
              
              const Spacer(),
              
              const SizedBox(height: 12),
              
              // Footer con autor y rating
              _buildPremiumFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icono premium con múltiples capas
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _cardGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: _cardGradient[0].withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 2,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              _getProductIcon(),
              color: Colors.white,
              size: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        
        // Precio premium
        _buildPremiumPrice(),
      ],
    );
  }

  Widget _buildPremiumPrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppColorsUnified.gold, // Oro
            AppColorsUnified.orange, // Naranja dorado
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const AppColorsUnified.gold.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.diamond,
            color: Colors.white,
            size: 16,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text(
            '\$${widget.product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          _cardGradient[0],
          _cardGradient[1],
        ],
      ).createShader(bounds),
      child: Text(
        widget.product.name,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.product.description,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPremiumFooter() {
    return Row(
      children: [
        // Avatar premium
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                _cardGradient[0].withValues(alpha: 0.3),
                _cardGradient[1].withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(
              width: 2,
              color: _cardGradient[0].withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: _cardGradient[0].withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.product.authorAvatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.product.authorAvatarUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Text(
                    widget.product.authorIcon,
                    style: TextStyle(
                      color: _cardGradient[0],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        
        const SizedBox(width: 10),
        
        // Nombre del autor
        Expanded(
          child: Text(
            widget.product.authorName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Rating premium
        _buildPremiumRating(),
      ],
    );
  }

  Widget _buildPremiumRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            _cardGradient[0].withValues(alpha: 0.15),
            _cardGradient[1].withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: _cardGradient[0].withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: _cardGradient[0],
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '4.${5 + (widget.index % 5)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _cardGradient[0],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerController.value * 3, -1.0),
                  end: Alignment(0.0 + _shimmerController.value * 3, 0.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getProductIcon() {
    final name = widget.product.name.toLowerCase();
    if (name.contains('casco')) return Icons.construction;
    if (name.contains('detector')) return Icons.location_searching;
    if (name.contains('linterna')) return Icons.flashlight_on;
    if (name.contains('martillo')) return Icons.hardware;
    if (name.contains('taladro')) return Icons.build;
    if (name.contains('chaleco')) return Icons.security;
    if (name.contains('guantes')) return Icons.back_hand;
    if (name.contains('cuerda')) return Icons.polymer;
    return Icons.shopping_bag;
  }
}
