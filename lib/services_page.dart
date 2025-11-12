import 'package:flutter/material.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'core/di/locator.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/matching/match_engine.dart';
import 'features/services/domain/service_repository.dart';
import 'features/posts/domain/post_repository.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with SingleTickerProviderStateMixin {
  late final ServiceRepository _repo;
  late final PostRepository _postRepo;
  late List<Service> _services;
  bool _servicesLoading = true;
  late TabController _tabController;
  List<MatchResult> _suggestedRequests = [];
  List<MatchResult> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _repo = sl<ServiceRepository>();
    _postRepo = sl<PostRepository>();
    _services = [];
    _tabController = TabController(length: 3, vsync: this);
    _computeMatches();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _servicesLoading = true);
    try {
      final res = await _repo
          .getAll()
          .timeout(const Duration(seconds: 8), onTimeout: () => <Service>[]);
      if (!mounted) return;
      setState(() => _services = res);
    } catch (e) {
      if (!mounted) return;
      // keep empty list and stop loading
    } finally {
      if (mounted) {
        setState(() => _servicesLoading = false);
      }
    }
  }

  Future<void> _computeMatches() async {
    final user = SupabaseAuthService.instance.currentUserModel;
    final posts = await _postRepo
        .getAll()
        .timeout(const Duration(seconds: 8), onTimeout: () => <Post>[]);
    if (user != null) {
      setState(() {
        _suggestedRequests = MatchEngine.requestsForUser(user, posts);
        _opportunities = MatchEngine.opportunitiesForUser(user, posts);
      });
    } else {
      setState(() {
        _suggestedRequests = [];
        _opportunities = [];
      });
    }
  }

  Widget _buildServicesHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColorsUnified.greySoftGradient,  // Blanco perla suave
      ),
      child: Stack(
        children: [
          // Decorative elements sutiles
          Positioned(
            top: 50,
            right: -35,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.05),  // Oro muy sutil
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: -20,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.03),  // Oro ultra sutil
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
                // Services icon con goldGradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColorsUnified.goldGradient,  // ⭐ Oro metálico
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.build_circle,
                    color: AppColorsUnified.textPrimary,  // Negro sobre oro
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Servicios',
                  style: TextStyle(
                    color: AppColorsUnified.textPrimary,  // Negro
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Ofrece tus habilidades, encuentra expertos',
                  style: TextStyle(
                    color: AppColorsUnified.textSecondary,  // Gris 60%
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row con estilo minimalista
                Row(
                  children: [
                    _buildServiceStatChip('${_services.length}', 'Servicios'),
                    const SizedBox(width: 12),
                    _buildServiceStatChip('${_suggestedRequests.length}', 'Sugerencias'),
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
        color: AppColorsUnified.grey200,  // Blanco perla medio
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsUnified.grey300),  // Borde gris sutil
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColorsUnified.gold,  // ⭐ Valor en oro
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColorsUnified.textSecondary,  // Gris 60%
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
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
                color: AppColorsUnified.grey200,  // Blanco perla
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
                  gradient: AppColorsUnified.goldGradient,  // ⭐ Botón oro
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColorsUnified.textPrimary, size: 24),
                  tooltip: 'Publicar servicio',
                  onPressed: _showCreateServiceDialog,
                ),
              ),
              Container(
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey200,  // Blanco perla
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorsUnified.grey300),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: AppColorsUnified.textPrimary),
                  onPressed: () {
                    _computeMatches();
                    setState(() {});
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildServicesHeaderContent(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: AppColorsUnified.pureWhite,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColorsUnified.gold,  // ⭐ Tab activo en oro
                  unselectedLabelColor: AppColorsUnified.textSecondary,  // Gris 60%
                  indicatorColor: AppColorsUnified.gold,  // ⭐ Indicador en oro
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Mis Servicios'),
                    Tab(text: 'Solicitudes para mí'),
                    Tab(text: 'Oportunidades'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyServices(),
            _buildMatchList(_suggestedRequests, emptyLabel: 'Sin sugerencias'),
            _buildMatchList(_opportunities, emptyLabel: 'Sin oportunidades'),
          ],
        ),
      ),
    );
  }

  Widget _buildMyServices() {
    if (_servicesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_services.isEmpty) {
      return Center(
        child: Text('Sin servicios todavía',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildBeautifulServiceCard(service, index);
      },
    );
  }

  Widget _buildMatchList(List<MatchResult> list, {required String emptyLabel}) {
    if (list.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColorsUnified.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mr = list[index];
        final p = mr.post;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColorsUnified.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColorsUnified.grey300, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.grey200,  // Blanco perla
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColorsUnified.grey300),
                    ),
                    child: Text(p.type.name,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.gold,  // ⭐ Tipo en oro
                            fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text('${mr.score} pts',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColorsUnified.gold)),  // ⭐ Score en oro
                ],
              ),
              const SizedBox(height: 8),
              Text(p.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.textPrimary,  // Negro
                  )),
              const SizedBox(height: 4),
              Text(p.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColorsUnified.textSecondary)),
              if (p.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -4,
                  children: p.tags
                      .take(5)
                      .map((t) => Chip(
                            label: Text(t, style: TextStyle(fontSize: 11, color: AppColorsUnified.textPrimary)),
                            backgroundColor: AppColorsUnified.grey200,  // Blanco perla
                            side: BorderSide(color: AppColorsUnified.grey300),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildBeautifulServiceCard(Service service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColorsUnified.grey300,  // Borde sutil
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showServiceDetails(service),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del servicio
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,  // ⭐ Oro metálico
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getServiceIcon(service.name),
                        color: AppColorsUnified.textPrimary,  // Negro sobre oro
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,  // Negro
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColorsUnified.gold,  // ⭐ Categoría en oro
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,  // ⭐ Badge oro
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        service.priceDisplay,
                        style: TextStyle(
                          color: AppColorsUnified.textPrimary,  // Negro sobre oro
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Descripción
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsUnified.textSecondary,  // Gris 60%
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Tags si existen
                if (service.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: service.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.grey200,  // Blanco perla
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColorsUnified.grey300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: AppColorsUnified.textPrimary,  // Negro
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Información del autor
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,  // ⭐ Avatar oro
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: service.providerAvatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              service.providerAvatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.engineering,
                              size: 24,
                              color: AppColorsUnified.textPrimary,  // Negro sobre oro
                            ),
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  service.providerName ?? "Proveedor",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsUnified.textPrimary,  // Negro
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: AppColorsUnified.warning),
                              const SizedBox(width: 2),
                              Text(
                                '${0.0.toStringAsFixed(1)} (${0})',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColorsUnified.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,  // ⭐ Botón oro
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _contactAuthor(service),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat, color: AppColorsUnified.textPrimary, size: 16),  // Negro sobre oro
                                const SizedBox(width: 4),
                                Text(
                                  'Contactar',
                                  style: TextStyle(
                                    color: AppColorsUnified.textPrimary,  // Negro sobre oro
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Información adicional
                if (service.availability != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColorsUnified.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        service.availability!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        service.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(service.name),
        content: Text(service.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _contactAuthor(service);
            },
            child: const Text('Contactar'),
          ),
        ],
      ),
    );
  }

  void _contactAuthor(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(child: Text('Contactar a ${service.providerName ?? "Proveedor"}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio: ${service.name}'),
            Text('Tarifa: ${service.priceDisplay}'),
            if (0.0 > 0)
              Text('Rating: ${0.0.toStringAsFixed(1)} ⭐'),
            const SizedBox(height: 16),
            const Text('¿Cómo te gustaría contactar?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para enviar mensaje
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mensaje enviado a ${service.providerName ?? "Proveedor"}')),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Enviar Mensaje'),
          ),
        ],
      ),
    );
  }

  void _showCreateServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final rateController = TextEditingController();
    final categoryController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColorsUnified.pureWhite,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColorsUnified.goldGradient,  // ⭐ Icono oro
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add_business, color: AppColorsUnified.textPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Publicar Nuevo Servicio', style: TextStyle(color: AppColorsUnified.textPrimary)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del servicio',
                  labelStyle: TextStyle(color: AppColorsUnified.textSecondary),
                  hintText: 'ej: Topografía y mapeo',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.gold, width: 2),  // ⭐ Borde oro en foco
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: AppColorsUnified.textSecondary),
                  hintText: 'Describe tu servicio en detalle...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.gold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tarifa por hora (USD)',
                  labelStyle: TextStyle(color: AppColorsUnified.textSecondary),
                  hintText: '120',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.gold, width: 2),
                  ),
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: AppColorsUnified.textSecondary),
                  hintText: 'ej: Estudios Técnicos',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.gold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  labelStyle: TextStyle(color: AppColorsUnified.textSecondary),
                  hintText: 'ej: Medellín, Colombia',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.gold, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: AppColorsUnified.textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColorsUnified.goldGradient,  // ⭐ Botón oro
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    rateController.text.isNotEmpty) {
                  _createNewService(
                    nameController.text,
                    descriptionController.text,
                    double.parse(rateController.text),
                    categoryController.text,
                    locationController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Publicar Servicio',
                style: TextStyle(color: AppColorsUnified.textPrimary, fontWeight: FontWeight.bold),  // Negro sobre oro
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewService(String name, String description, double rate, String category, String location) {
    final profile = SupabaseAuthService.instance.currentUserProfile;
    if (profile == null) return;

    final newService = Service(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      providerId: profile['id'],
      name: name,
      description: description,
      category: category.isNotEmpty ? category : 'General',
      tags: _extractTagsFromDescription(description),
      pricingFrom: rate,
      pricingUnit: 'hora',
      providerName: profile['name'] ?? '',
      providerAccountType: profile['account_type'] ?? 'individual',
      providerAvatarUrl: profile['profile_image_url'],
    );

    setState(() {
      _services.add(newService);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColorsUnified.pureWhite),
            const SizedBox(width: 8),
            Text('Servicio "$name" publicado exitosamente!'),
          ],
        ),
        backgroundColor: AppColorsUnified.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<String> _extractTagsFromDescription(String description) {
    // Lógica simple para extraer tags de palabras clave
    final tags = <String>[];
    final keywords = ['topografia', 'mantenimiento', 'legal', 'consultoria', 'mapeo', 'reparacion', 'licencias'];
    
    for (final keyword in keywords) {
      if (description.toLowerCase().contains(keyword)) {
        tags.add(keyword);
      }
    }
    
    return tags;
  }

  IconData _getServiceIcon(String serviceName) {
    if (serviceName.toLowerCase().contains('topografía')) {
      return Icons.map_outlined;
    } else if (serviceName.toLowerCase().contains('mantenimiento')) {
      return Icons.build_outlined;
    } else if (serviceName.toLowerCase().contains('legal')) {
      return Icons.gavel_outlined;
    }
    return Icons.miscellaneous_services_outlined;
  }
}
