import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:yominero/core/theme/app_colors_unified.dart';

/// 💎 PREMIUM 3D CAROUSEL - Estilo Apple/Dior
/// 
/// Características minimalistas:
/// - Solo ORO y PLATA sobre fondo BLANCO
/// - Perspectiva 3D con tarjeta central prominente
/// - Sombras realistas y profundas
/// - Efecto de flotación
/// - Animaciones suaves y elegantes
class Premium3DProductCarousel extends StatefulWidget {
  final List<Product> products;
  final Function(Product)? onProductTap;
  final String? authorId;
  final String? authorName;
  final DateTime? createdAt;
  final String? title;
  final int? likes;
  final int? comments;
  final bool? isSaved;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const Premium3DProductCarousel({
    super.key,
    required this.products,
    this.onProductTap,
    this.authorId,
    this.authorName,
    this.createdAt,
    this.title,
    this.likes,
    this.comments,
    this.isSaved,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<Premium3DProductCarousel> createState() => _Premium3DProductCarouselState();
}

class _Premium3DProductCarouselState extends State<Premium3DProductCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _floatController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Empezar en el MEDIO de las imágenes para ver laterales a AMBOS lados
    final middleIndex = widget.products.isEmpty ? 0 : (widget.products.length / 2).floor();
    final safeIndex = middleIndex.clamp(0, widget.products.length - 1);
    
    _pageController = PageController(
      viewportFraction: 0.50, // 50% - Proporciones perfectas: 25% | 50% | 25%
      initialPage: safeIndex,
    );
    
    _currentPage = safeIndex.toDouble();
    
    _pageController.addListener(() {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page ?? safeIndex.toDouble();
        });
      }
    });

    // Animación de flotación sutil
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Más lenta para ser más elegante
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(Premium3DProductCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si los productos cambiaron, reiniciar el controlador
    if (oldWidget.products.length != widget.products.length) {
      _pageController.dispose();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox(height: 480);
    }

    return Column(
      children: [
        // 📸 IMÁGENES FLOTANTES - Altura EXTRA para que no se corten los lados
        SizedBox(
          height: 500, // MUY GRANDE para que las rotadas laterales no se corten
          child: PageView.builder(
            clipBehavior: Clip.none, // Sin recorte
            controller: _pageController,
            // SIN padEnds:false para que el carousel esté CENTRADO
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              return _buildFloatingImage(index);
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 📋 INFORMACIÓN COMPLETA EN CONTENEDOR - TODO ABAJO
        SizedBox(
          height: 180, // Más alto para incluir todo
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              if (widget.products.isEmpty) {
                return const SizedBox.shrink();
              }
              final currentIndex = _currentPage.round().clamp(0, widget.products.length - 1);
              return _buildInfoContainer(widget.products[currentIndex], currentIndex);
            },
          ),
        ),
      ],
    );
  }

  /// 📸 Construye solo la imagen flotante con transformaciones 3D
  Widget _buildFloatingImage(int index) {
    final product = widget.products[index];
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        // Offset desde el centro (-1.0 = izquierda, 0.0 = centro, 1.0 = derecha)
        double offset = _currentPage - index;
        
        // Si el PageController aún no tiene dimensiones, usar offset calculado manualmente
        if (!_pageController.position.haveDimensions) {
          final middleIndex = (widget.products.length / 2).floor();
          offset = middleIndex.toDouble() - index;
        }
        
        final absOffset = offset.abs(); // Distancia absoluta del centro

        // ESCALA GRADUAL: central grande (1.3x), va disminuyendo hacia los lados
        final scale = 1.3 - (absOffset * 0.45).clamp(0.0, 0.45); // De 1.3x a 0.85x
        
        // ROTACIÓN GRADUAL Y PROPORCIONAL a la posición
        // offset negativo (izquierda) → rotación positiva (muestra lado derecho)
        // offset positivo (derecha) → rotación negativa (muestra lado izquierdo)
        // Forzar 0° cuando está centrado (eliminar rotación residual por precisión flotante)
        final rotationY = absOffset < 0.01 ? 0.0 : -offset * 0.3;
        
        // OPACIDAD GRADUAL: 100% en centro, disminuye hacia los lados
        final opacity = (1.0 - (absOffset * 0.15)).clamp(0.5, 1.0);

        // ELEVACIÓN GRADUAL: centro arriba, laterales bajan
        final verticalOffset = absOffset * 25;

        // PROFUNDIDAD GRADUAL: centro al frente, laterales atrás
        final zDepth = -absOffset * 100;

        return GestureDetector(
          onTap: () => widget.onProductTap?.call(product),
          child: Center( // Center para alineación vertical
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003) // Perspectiva pronunciada
                ..translateByVector3(Vector3(0.0, verticalOffset, zDepth))
                ..rotateY(rotationY)
                ..scaleByVector3(Vector3.all(scale)),
              alignment: Alignment.center,
              child: Opacity(
                opacity: opacity,
                child: _buildImageOnly(product, index, absOffset),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🖼️ Solo la imagen - contenedor independiente flotante
  Widget _buildImageOnly(Product product, int index, double distanceFromCenter) {
    // Alternar entre oro y plata
    final isGold = index % 2 == 0;
    
    // Sombras más intensas para la tarjeta central
    // Asegurar que shadowIntensity nunca sea negativo pero mantener rango útil
    final shadowIntensity = (1.0 - (distanceFromCenter * 0.7)).clamp(0.05, 1.0);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        // Flotación sutil solo para tarjeta central
        final float = distanceFromCenter < 0.5 
            ? math.sin(_floatController.value * 2 * math.pi) * 10.0
            : 0.0;
        
        return Transform.translate(
          offset: Offset(0, float),
          child: Container(
            // SIN width fijo - usa TODO el espacio disponible del viewportFraction
            height: 240, // Altura REDUCIDA para que las 3 imágenes se vean mejor
            margin: const EdgeInsets.symmetric(horizontal: 4), // Margen MUY pequeño para que estén juntas
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [
                // Sombra cercana - más intensa en el centro
                BoxShadow(
                  color: Colors.black.withOpacity((0.22 * shadowIntensity).clamp(0.0, 1.0)),
                  blurRadius: 32 * shadowIntensity,
                  offset: Offset(0, 16 * shadowIntensity),
                  spreadRadius: 2 * shadowIntensity,
                ),
                // Sombra lejana - más suave
                BoxShadow(
                  color: Colors.black.withOpacity((0.14 * shadowIntensity).clamp(0.0, 1.0)),
                  blurRadius: 64 * shadowIntensity,
                  offset: Offset(0, 28 * shadowIntensity),
                  spreadRadius: 0,
                ),
                // Sombra ambiental dorada/plateada
                BoxShadow(
                  color: (isGold
                          ? AppColorsUnified.gold
                          : AppColorsUnified.silverLight)
                      .withOpacity((0.18 * shadowIntensity).clamp(0.0, 1.0)),
                  blurRadius: 42 * shadowIntensity,
                  offset: const Offset(0, 0),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isGold, product.name),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder(isGold, product.name);
                      },
                    )
                  : _buildPlaceholder(isGold, product.name),
            ),
          ),
        );
      },
    );
  }

  /// 📋 Contenedor de información COMPLETA - Todo abajo (autor, título, precio, acciones)
  Widget _buildInfoContainer(Product product, int index) {
    final isGold = index % 2 == 0;
    final accentColor = isGold ? AppColorsUnified.gold : AppColorsUnified.silverLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AUTOR - si se proporciona
          if (widget.authorId != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: accentColor.withOpacity(0.2),
                  child: Text(
                    (widget.authorName ?? widget.authorId ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.authorName ?? widget.authorId ?? 'Usuario',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      if (widget.createdAt != null)
                        Text(
                          'Producto · ${_getTimeAgo(widget.createdAt!)}',
                          style: TextStyle(color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2), fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // TÍTULO - si se proporciona, si no usa nombre del producto
          Text(
            widget.title ?? product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColorsUnified.textPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // PRECIO Y ACCIONES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accentColor,
                ),
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // ACCIONES - likes, comentarios, guardar, compartir
              Row(
                children: [
                  // Like
                  _buildActionButton(
                    Icons.favorite_border,
                    widget.likes?.toString() ?? '0',
                    widget.onLike,
                  ),
                  const SizedBox(width: 16),
                  // Comentarios
                  _buildActionButton(
                    Icons.chat_bubble_outline,
                    widget.comments?.toString() ?? '0',
                    widget.onComment,
                  ),
                  const SizedBox(width: 16),
                  // Guardar
                  if (widget.onSave != null)
                    _buildActionButton(
                      widget.isSaved == true ? Icons.bookmark : Icons.bookmark_border,
                      '',
                      widget.onSave,
                    ),
                  if (widget.onSave != null)
                    const SizedBox(width: 16),
                  // Compartir
                  _buildActionButton(
                    Icons.share_outlined,
                    '',
                    widget.onShare,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón de acción minimalista (like, comentario, compartir)
  Widget _buildActionButton(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColorsUnified.textSecondary),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColorsUnified.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Calcular tiempo transcurrido
  String _getTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} años';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} meses';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Ahora';
  }

  /// Placeholder premium con gradiente metálico
  Widget _buildPlaceholder(bool isGold, String productName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGold
              ? [
                  AppColorsUnified.gold.withOpacity(0.1),
                  AppColorsUnified.goldLight.withOpacity(0.05),
                  AppColorsUnified.gold.withOpacity(0.08),
                ]
              : [
                  AppColorsUnified.silverLight.withOpacity(0.12),
                  AppColorsUnified.textSecondary.withOpacity(0.06),
                  AppColorsUnified.silverLight.withOpacity(0.1),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGold
                    ? AppColorsUnified.gold.withOpacity(0.15)
                    : AppColorsUnified.silverLight.withOpacity(0.15),
              ),
              child: Icon(
                _getProductIcon(productName),
                size: 48,
                color: isGold
                    ? AppColorsUnified.gold.withOpacity(0.6)
                    : AppColorsUnified.textSecondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              productName,
              style: TextStyle(
                color: isGold
                    ? AppColorsUnified.gold.withOpacity(0.5)
                    : AppColorsUnified.textSecondary.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    final name = productName.toLowerCase();
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
