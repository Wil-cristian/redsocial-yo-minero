import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'radial_menu.dart';
import '../../core/theme/dashboard_colors.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class FloatingRadialButton extends StatefulWidget {
  final String? accountType;

  const FloatingRadialButton({
    super.key,
    this.accountType,
  });

  @override
  State<FloatingRadialButton> createState() => _FloatingRadialButtonState();
}

class _FloatingRadialButtonState extends State<FloatingRadialButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _breatheController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  List<RadialMenuItem> _getMenuItems(BuildContext context) {
    final baseItems = [
      RadialMenuItem(
        icon: Icons.shopping_bag_rounded,
        label: 'Productos',
        color: DashboardColors.orange,
        route: '/products',
        onTap: () => Navigator.pushNamed(context, '/products'),
      ),
      RadialMenuItem(
        icon: Icons.handyman_rounded,
        label: 'Servicios',
        color: DashboardColors.wood,
        route: '/services',
        onTap: () => Navigator.pushNamed(context, '/services'),
      ),
      RadialMenuItem(
        icon: Icons.groups_rounded,
        label: 'Comunidad',
        color: DashboardColors.orangeBright,
        route: '/community',
        onTap: () => Navigator.pushNamed(context, '/community'),
      ),
      RadialMenuItem(
        icon: Icons.group_work_rounded,
        label: 'Grupos',
        color: DashboardColors.woodLight,
        route: '/groups',
        onTap: () => Navigator.pushNamed(context, '/groups'),
      ),
      RadialMenuItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Mensajes',
        color: DashboardColors.cardPink,
        route: '/messages',
        onTap: () => Navigator.pushNamed(context, '/messages'),
      ),
      RadialMenuItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        color: DashboardColors.accent,
        route: '/profile',
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
    ];

    if (widget.accountType == 'company') {
      baseItems.addAll([
        RadialMenuItem(
          icon: Icons.people_rounded,
          label: 'Empleados',
          color: DashboardColors.cardBlue,
          route: '/company/employees',
          onTap: () => Navigator.pushNamed(context, '/company/employees'),
        ),
        RadialMenuItem(
          icon: Icons.analytics_rounded,
          label: 'Métricas',
          color: DashboardColors.cardGreen,
          route: '/company/metrics',
          onTap: () => Navigator.pushNamed(context, '/company/metrics'),
        ),
      ]);
    }

    return baseItems;
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Calcular posición óptima del botón basándose en el tamaño de pantalla
    final navbarHeight = 90.0;
    final minRadiusNeeded = 100.0; // Radio ideal para menú circular
    final itemHalfSize = 35.0;
    final safeMargin = 10.0;
    
    // HORIZONTAL: En pantallas grandes, centrar más el botón para permitir radio mayor
    // En pantallas pequeñas, mantener en esquina derecha
    final buttonRight = size.width > 600
        ? math.max(120.0, size.width * 0.2)  // Desktop: 20% desde derecha, mín 120px
        : 20.0; // Mobile: esquina derecha
    
    // VERTICAL: En pantallas grandes (círculo completo), SUBIR el botón lo suficiente
    // para que haya espacio tanto arriba como abajo
    final spaceNeededBelow = minRadiusNeeded + itemHalfSize + safeMargin + navbarHeight;
    final spaceNeededAbove = minRadiusNeeded + itemHalfSize + safeMargin;
    
    final buttonBottom = size.width > 600
        // Desktop/Tablet: centrar verticalmente para permitir círculo completo
        ? math.max(spaceNeededBelow, size.height - spaceNeededAbove - 70)
        // Mobile: posición normal o ajustada
        : (size.height < 700 || size.height - 55 < spaceNeededBelow
            ? math.min(size.height - spaceNeededBelow - 70, navbarHeight + 40)
            : 20.0);
    
    // Posición del centro del botón (70x70)
    final buttonCenter = Offset(
      size.width - buttonRight - 35,  // Posición horizontal adaptativa
      size.height - buttonBottom - 35, // Posición vertical adaptativa
    );
    
    return Stack(
      children: [
        // Menú radial overlay
        if (_isMenuOpen)
          RadialMenu(
            items: _getMenuItems(context),
            onClose: () => setState(() => _isMenuOpen = false),
            buttonPosition: buttonCenter,
          ),

        // Botón flotante (oculto cuando el menú está abierto)
        if (!_isMenuOpen)
          Positioned(
            right: buttonRight,
            bottom: buttonBottom,
            child: GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _rotateController,
                _breatheController,
              ]),
              builder: (context, child) {
                final breatheScale = 1.0 + (0.05 * _breatheController.value);

                return Transform.scale(
                  scale: breatheScale,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorsUnified.orange,
                          AppColorsUnified.orangeMedium,
                          AppColorsUnified.orangeLight,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const AppColorsUnified.orange
                              .withOpacity(0.6 * _pulseController.value),
                          blurRadius: 30 * (1 + _pulseController.value),
                          spreadRadius: 5 * _pulseController.value,
                        ),
                        BoxShadow(
                          color: const AppColorsUnified.orangeMedium.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo rotatorio de fondo
                        AnimatedBuilder(
                          animation: _rotateController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateController.value * 2 * math.pi,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.25, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Icono central con rotación
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            _isMenuOpen ? Icons.close : Icons.apps_rounded,
                            key: ValueKey(_isMenuOpen),
                            color: Colors.white,
                            size: 34,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        // Puntos decorativos rotatorios
                        ...List.generate(8, (index) {
                          return AnimatedBuilder(
                            animation: _rotateController,
                            builder: (context, child) {
                              final angle = (2 * math.pi / 8) * index +
                                  (_rotateController.value * 2 * math.pi);
                              final distance = 28.0;
                              final x = distance * math.cos(angle);
                              final y = distance * math.sin(angle);

                              return Transform.translate(
                                offset: Offset(x, y),
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.6 * _pulseController.value),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
