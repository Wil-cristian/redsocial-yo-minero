import 'package:flutter/material.dart';

class CustomSideDrawer extends StatefulWidget {
  final String? accountType;
  final Map<String, dynamic>? currentUser;
  final Function(int)? onNavigateToIndex; // Callback para navegar en el shell

  const CustomSideDrawer({
    super.key,
    this.accountType,
    this.currentUser,
    this.onNavigateToIndex,
  });

  @override
  State<CustomSideDrawer> createState() => _CustomSideDrawerState();
}

class _CustomSideDrawerState extends State<CustomSideDrawer>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  List<Map<String, dynamic>> _getMenuItems() {
    debugPrint('🔍 CustomSideDrawer - accountType: ${widget.accountType}');
    debugPrint('🔍 CustomSideDrawer - currentUser: ${widget.currentUser}');

    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.home_rounded,
        'label': 'Inicio',
        'index': 0, // Índice en MainNavigationShell
        'color': const Color(0xFF808080), // Gris medio
      },
      {
        'icon': Icons.description_rounded,
        'label': 'Solicitudes',
        'route': '/requests', // Ruta externa
        'color': const Color(0xFF858585), // Gris medio
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'label': 'Mensajes',
        'route': '/messages', // Ruta externa
        'color': const Color(0xFF757575), // Gris medio
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'IA Sugerencias',
        'route': '/suggestions', // Ruta externa
        'color': const Color(0xFF959595), // Gris medio-claro
      },
      {
        'icon': Icons.store_rounded,
        'label': 'Productos',
        'route': '/products', // Ruta externa
        'color': const Color(0xFF909090), // Gris medio-claro
      },
      {
        'icon': Icons.handyman_rounded,
        'label': 'Servicios',
        'route': '/services', // Ruta externa
        'color': const Color(0xFF707070), // Gris medio
      },
      {
        'icon': Icons.person_rounded,
        'label': 'Perfil',
        'index': 2, // Índice en MainNavigationShell
        'color': const Color(0xFF606060), // Gris medio-oscuro
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'Configuración',
        'index': 4, // Índice en MainNavigationShell
        'color': const Color(0xFF656565), // Gris medio-oscuro
      },
    ];

    // Opciones específicas para empresas
    if (widget.accountType == 'company') {
      debugPrint('✅ Agregando opciones de empresa');
      items.addAll([
        {
          'icon': Icons.people_rounded,
          'label': 'Empleados',
          'route': '/company-employees',
          'color': const Color(0xFFA0A0A0), // Gris claro (destacado)
          'isCompany': true,
        },
        {
          'icon': Icons.bar_chart_rounded,
          'label': 'Métricas',
          'route': '/company-metrics',
          'color': const Color(0xFFB0B0B0), // Gris claro (destacado)
          'isCompany': true,
        },
        {
          'icon': Icons.diamond_rounded,
          'label': 'Producción',
          'route': '/company/production',
          'color': const Color(0xFFC0C0C0), // Gris más claro (destacado)
          'isCompany': true,
        },
      ]);
    } else {
      debugPrint('❌ NO es empresa - accountType: ${widget.accountType}');
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Stack(
      children: [
        // Overlay oscuro cuando el drawer está abierto
        if (_isOpen)
          GestureDetector(
            onTap: _toggleDrawer,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

        // Drawer deslizable
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 280,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A2A2A), // Gris oscuro 1
                    Color(0xFF1F1F1F), // Gris oscuro 2
                    Color(0xFF151515), // Gris oscuro 3
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header con información del usuario
                    _buildDrawerHeader(),

                    const SizedBox(height: 20),

                    // Lista de opciones
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // Opciones básicas
                          ...menuItems
                              .where((item) => item['isCompany'] != true)
                              .map((item) => _buildMenuItem(
                                    icon: item['icon'],
                                    label: item['label'],
                                    color: item['color'],
                                    route: item['route'],
                                    index: item['index'],
                                    isCompanyOption: false,
                                  )),

                          // Separador y opciones de empresa (solo si es company)
                          if (widget.accountType == 'company') ...[
                            const SizedBox(height: 20),
                            
                            // Línea divisoria
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF808080).withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Título de sección
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF404040),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.business_rounded,
                                      color: Color(0xFFE0E0E0),
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'OPCIONES EMPRESA',
                                    style: TextStyle(
                                      color: Color(0xFFB0B0B0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Opciones PRO
                            ...menuItems
                                .where((item) => item['isCompany'] == true)
                                .map((item) => _buildMenuItem(
                                      icon: item['icon'],
                                      label: item['label'],
                                      color: item['color'],
                                      route: item['route'],
                                      index: item['index'],
                                      isCompanyOption: true,
                                    )),
                          ],
                        ],
                      ),
                    ),

                    // Footer con versión
                    _buildDrawerFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Botón de flecha para abrir/cerrar
        Positioned(
          left: _isOpen ? 280 : 0,
          top: MediaQuery.of(context).size.height / 2 - 40,
          child: GestureDetector(
            onTap: _toggleDrawer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF606060), // Gris medio
                    Color(0xFF404040), // Gris medio-oscuro
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isOpen ? 0.5 : 0,
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader() {
    final userName = widget.currentUser?['username'] ?? 'Usuario';
    final accountType = widget.accountType;
    
    debugPrint('📋 DrawerHeader - accountType recibido: $accountType');
    
    final userType = accountType == 'company'
        ? 'Empresa Minera'
        : accountType == 'worker'
            ? 'Trabajador'
            : 'Minero Individual';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF404040), // Gris medio oscuro
            Color(0xFF2A2A2A), // Gris oscuro
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF606060), // Gris medio
                  Color(0xFF404040), // Gris medio-oscuro
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nombre de usuario
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Tipo de cuenta con badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF404040), // Gris medio-oscuro
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF808080), // Gris medio
                width: 1,
              ),
            ),
            child: Text(
              userType,
              style: const TextStyle(
                color: Color(0xFFE0E0E0), // Gris claro para texto
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    String? route,
    int? index,
    bool isCompanyOption = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Borde más visible para opciones PRO
        border: isCompanyOption
            ? Border.all(
                color: const Color(0xFFA0A0A0),
                width: 1.5,
              )
            : null,
        // Fondo sutil para opciones PRO
        color: isCompanyOption
            ? const Color(0xFF353535)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _toggleDrawer();
            // Esperar a que la animación termine antes de navegar
            Future.delayed(const Duration(milliseconds: 300), () {
              if (index != null && widget.onNavigateToIndex != null) {
                // Navegar usando el índice del shell
                widget.onNavigateToIndex!(index);
              } else if (route != null && mounted) {
                // Navegar usando ruta (verificar que el widget siga montado)
                Navigator.pushNamed(context, route);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Icono (más grande para opciones PRO)
                Container(
                  width: isCompanyOption ? 44 : 40,
                  height: isCompanyOption ? 44 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompanyOption
                        ? color.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.2),
                    // Borde para opciones PRO
                    border: isCompanyOption
                        ? Border.all(
                            color: color.withValues(alpha: 0.5),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isCompanyOption ? 24 : 22,
                  ),
                ),

                const SizedBox(width: 16),

                // Label (bold para opciones PRO)
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isCompanyOption
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),

                // Badge especial para opciones de empresa
                if (isCompanyOption)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0), // Gris muy claro
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Color(0xFF202020), // Gris muy oscuro
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.diamond_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'YoMinero v1.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
