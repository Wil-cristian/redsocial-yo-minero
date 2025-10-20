import 'package:flutter/material.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/shared/models/service.dart';
import 'core/theme/colors.dart';
import 'core/di/locator.dart';
import 'core/auth/auth_service.dart';
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
    final user = AuthService.instance.currentUser;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Servicios', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mis Servicios'),
            Tab(text: 'Solicitudes para mí'),
            Tab(text: 'Oportunidades'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() => _computeMatches());
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyServices(),
          _buildMatchList(_suggestedRequests, emptyLabel: 'Sin sugerencias'),
          _buildMatchList(_opportunities, emptyLabel: 'Sin oportunidades'),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateServiceDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Publicar Servicio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(p.type.name,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text('${mr.score} pts',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(p.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(p.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700])),
              if (p.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -4,
                  children: p.tags
                      .take(5)
                      .map((t) => Chip(
                            label:
                                Text(t, style: const TextStyle(fontSize: 11)),
                            backgroundColor: AppColors.secondaryContainer,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primary.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                          gradient: LinearGradient(
                            colors: [
                              _getServiceColor(service.name),
                              _getServiceColor(service.name).withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getServiceColor(service.name).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getServiceIcon(service.name),
                          color: Colors.white,
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
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.category ?? 'Servicio General',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.rateDisplay,
                          style: const TextStyle(
                            color: Colors.white,
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
                      color: Colors.grey[700],
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withValues(alpha: 0.8),
                              AppColors.secondary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: service.authorAvatarUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                service.authorAvatarUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                service.authorIcon,
                                style: const TextStyle(fontSize: 18),
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
                                Text(
                                  service.authorIcon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    service.authorDisplayName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (service.isAuthorVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                ],
                              ],
                            ),
                            if (service.authorRating > 0) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${service.authorRating.toStringAsFixed(1)} (${service.authorReviewCount})',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 8,
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
                                  const Icon(Icons.chat, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Contactar',
                                    style: TextStyle(
                                      color: Colors.white,
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
                  if (service.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          service.location!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          service.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
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
            Text(service.authorIcon),
            const SizedBox(width: 8),
            Expanded(child: Text('Contactar a ${service.authorDisplayName}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio: ${service.name}'),
            Text('Tarifa: ${service.rateDisplay}'),
            if (service.authorRating > 0)
              Text('Rating: ${service.authorRating.toStringAsFixed(1)} ⭐'),
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
                SnackBar(content: Text('Mensaje enviado a ${service.authorDisplayName}')),
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_business, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Publicar Nuevo Servicio'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio',
                  hintText: 'ej: Topografía y mapeo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu servicio en detalle...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por hora (USD)',
                  hintText: '120',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'ej: Estudios Técnicos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'ej: Medellín, Colombia',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
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
              child: const Text(
                'Publicar Servicio',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewService(String name, String description, double rate, String category, String location) {
    // En una app real, esto se enviaría al servidor
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    final newService = Service(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      rate: rate,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDisplayName: currentUser.accountDisplayName,
      authorAccountType: currentUser.accountType.name,
      authorAvatarUrl: currentUser.avatarUrl,
      authorRating: currentUser.ratingAvg,
      authorReviewCount: currentUser.ratingCount,
      category: category.isNotEmpty ? category : null,
      location: location.isNotEmpty ? location : null,
      tags: _extractTagsFromDescription(description),
    );

    setState(() {
      _services.add(newService);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Servicio "${name}" publicado exitosamente!'),
          ],
        ),
        backgroundColor: AppColors.success,
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

  Color _getServiceColor(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('topografía') || lower.contains('mapeo')) {
      return AppColors.info;
    } else if (lower.contains('mantenimiento')) {
      return AppColors.success;
    } else if (lower.contains('legal')) {
      return AppColors.textSecondary;
    }
    return AppColors.primary;
  }
}
