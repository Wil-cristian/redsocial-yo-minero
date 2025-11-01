import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'dart:math' as math;

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

  const Premium3DProductCarousel({
    super.key,
    required this.products,
    this.onProductTap,
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
    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });

    // Animación de flotación sutil
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
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
      return const SizedBox(height: 400);
    }

    return Container(
      height: 450,
      color: Colors.white,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return _buildCard(index);
        },
      ),
    );
  }

  Widget _buildCard(int index) {
    final product = widget.products[index];
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0;
        if (_pageController.position.haveDimensions) {
          value = (_currentPage - index).abs();
        }

        // Escala: tarjeta central más grande
        final scale = 1.0 - (value * 0.3).clamp(0.0, 0.3);
        
        // Rotación 3D en eje Y
        final rotationY = (value * 0.3).clamp(-0.3, 0.3);
        
        // Opacidad
        final opacity = (1.0 - (value * 0.4)).clamp(0.6, 1.0);

        // Elevación vertical (flotación)
        final verticalOffset = (value * 30).clamp(0.0, 30.0);

        return Center(
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspectiva
              ..rotateY(rotationY)
              ..scale(scale),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, verticalOffset),
                child: _buildProductCard(product, index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    // Alternar entre oro y plata
    final isGold = index % 2 == 0;

    return GestureDetector(
      onTap: () => widget.onProductTap?.call(product),
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          // Flotación sutil
          final float = math.sin(_floatController.value * 2 * math.pi) * 5;
          
          return Transform.translate(
            offset: Offset(0, float),
            child: Container(
              width: 280,
              height: 400,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  // Sombra cercana
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  // Sombra lejana
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Imagen del producto (placeholder)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFAFAFA),
                              const Color(0xFFF5F5F5),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getProductIcon(product.name),
                            size: 120,
                            color: isGold
                                ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
                                : const Color(0xFFC0C0C0).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),

                    // Gradiente sutil en la parte inferior
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 200,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.95),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Información del producto
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nombre del producto
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Descripción breve
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF666666),
                                height: 1.4,
                                letterSpacing: 0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Precio con acento oro/plata
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: isGold
                                          ? [
                                              const Color(0xFFD4AF37),
                                              const Color(0xFFF4E4C1),
                                            ]
                                          : [
                                              const Color(0xFFC0C0C0),
                                              const Color(0xFFE8E8E8),
                                            ],
                                    ),
                                  ),
                                  child: Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                
                                // Botón minimalista
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isGold
                                        ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                                        : const Color(0xFFC0C0C0).withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: isGold
                                          ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
                                          : const Color(0xFFC0C0C0).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: isGold
                                        ? const Color(0xFFD4AF37)
                                        : const Color(0xFFC0C0C0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Indicador de stock (sutil)
                    if (product.inStock)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isGold
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFFC0C0C0),
                            boxShadow: [
                              BoxShadow(
                                color: (isGold
                                        ? const Color(0xFFD4AF37)
                                        : const Color(0xFFC0C0C0))
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
