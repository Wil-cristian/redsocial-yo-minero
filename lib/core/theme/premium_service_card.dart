import 'package:flutter/material.dart';
import 'package:yominero/shared/models/service.dart';

/// 💎 PREMIUM SERVICE CARD - Diseño ultra sofisticado tema AMATISTA/VIOLETA
/// 
/// Características:
/// - Base blanca premium con tono violeta
/// - Bordes violetas multicapa
/// - Sombras profundas amatista
/// - Animaciones suaves
/// - Glassmorphism
/// - Efectos 3D
class PremiumServiceCard extends StatefulWidget {
  final Service service;
  final VoidCallback onTap;
  final int index;

  const PremiumServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.index,
  });

  @override
  State<PremiumServiceCard> createState() => _PremiumServiceCardState();
}

class _PremiumServiceCardState extends State<PremiumServiceCard>
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

  // Colores premium de gemas (tema violeta/púrpura)
  static const List<List<Color>> _gemGradients = [
    // Amatista
    [Color(0xFF9966CC), Color(0xFF6A0DAD), Color(0xFFDA70D6)],
    // Zafiro
    [Color(0xFF0F52BA), Color(0xFF082567), Color(0xFF6495ED)],
    // Esmeralda
    [Color(0xFF50C878), Color(0xFF00A86B), Color(0xFF7FFFD4)],
    // Rubí
    [Color(0xFFE0115F), Color(0xFF9B111E), Color(0xFFFF6B9D)],
    // Oro
    [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFE55C)],
    // Turquesa
    [Color(0xFF40E0D0), Color(0xFF00CED1), Color(0xFF48D1CC)],
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
              ..rotateX(-0.03)
              ..scale(1.01))
            : Matrix4.identity(),
        margin: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: widget.onTap,
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
                  color: _cardGradient[0].withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: _cardGradient[1].withValues(alpha: 0.3),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ]
            : [
                BoxShadow(
                  color: _cardGradient[0].withValues(alpha: 0.25),
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
        border: Border.all(
          width: 3,
          color: Colors.transparent,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardGradient[0].withValues(alpha: 0.2),
            Colors.white,
            _cardGradient[2].withValues(alpha: 0.15),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _cardGradient[0].withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            width: 2,
            color: _cardGradient[0].withValues(alpha: 0.4),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1,
              color: const Color(0xFFE8E8E8),
            ),
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
                  _cardGradient[2].withValues(alpha: 0.08),
                  Colors.white,
                  _cardGradient[0].withValues(alpha: 0.05),
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
              
              // Descripción
              _buildDescription(),
              
              const SizedBox(height: 16),
              
              // Tags/Características
              if (widget.service.category != null)
                _buildCategoryTag(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      children: [
        // Icono premium con gradiente
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
              _getServiceIcon(),
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
        
        const SizedBox(width: 16),
        
        // Título y categoría
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    _cardGradient[0],
                    _cardGradient[1],
                  ],
                ).createShader(bounds),
                child: Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.service.category != null)
                Text(
                  widget.service.category!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _cardGradient[0],
                  ),
                ),
            ],
          ),
        ),
        
        // Precio premium
        _buildPremiumRate(),
      ],
    );
  }

  Widget _buildPremiumRate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _cardGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardGradient[0].withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.service.priceDisplay,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.3,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.service.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Icons.workspace_premium,
            color: _cardGradient[0],
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Servicio Verificado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
                    Colors.white.withValues(alpha: 0.15),
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

  IconData _getServiceIcon() {
    final name = widget.service.name.toLowerCase();
    if (name.contains('transporte')) return Icons.local_shipping;
    if (name.contains('mapeo') || name.contains('topograf')) return Icons.map;
    if (name.contains('perforación') || name.contains('excavación')) return Icons.construction;
    if (name.contains('análisis') || name.contains('laboratorio')) return Icons.science;
    if (name.contains('consultoría') || name.contains('asesoría')) return Icons.business_center;
    if (name.contains('mantenimiento') || name.contains('reparación')) return Icons.build;
    if (name.contains('seguridad')) return Icons.security;
    if (name.contains('ambiental')) return Icons.eco;
    return Icons.handyman;
  }
}
