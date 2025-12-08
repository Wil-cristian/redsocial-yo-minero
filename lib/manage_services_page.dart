import 'package:flutter/material.dart';
import 'package:yominero/shared/models/user.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/theme/colors.dart';

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key});

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  List<ServiceOffering> get userServices => 
      SupabaseAuthService.instance.currentUserModel?.servicesOffered ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColorsUnified.greySoftGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // Beautiful App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey200,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsUnified.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
                  tooltip: 'Volver al perfil',
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.grey200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18, color: AppColorsUnified.textPrimary),
                    label: const Text('Cerrar'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.grey200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColorsUnified.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.build, color: AppColorsUnified.textPrimary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Mis Servicios',
                        style: TextStyle(
                          color: AppColorsUnified.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColorsUnified.greySoftGradient,
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Beautiful header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorsUnified.orange.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.orange.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColorsUnified.orange, AppColors.secondary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.orange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.engineering, color: AppColorsUnified.pureWhite, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gestiona tus servicios profesionales',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea, edita y organiza los servicios que ofreces a la comunidad minera',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColorsUnified.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Add new service button - Enhanced
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorsUnified.pureWhite,
                            AppColorsUnified.orange.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.orange.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showAddServiceDialog(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: AppColorsUnified.goldGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    size: 48,
                                    color: AppColorsUnified.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Crear Nuevo Servicio',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsUnified.gold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega un servicio profesional a tu catálogo',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColorsUnified.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Services list
                    if (userServices.isEmpty)
                      _buildBeautifulEmptyState()
                    else
                      Column(
                        children: userServices.asMap().entries.map((entry) {
                          final index = entry.key;
                          final service = entry.value;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOutBack,
                            child: _buildBeautifulServiceCard(service, index),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorsUnified.grey300, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColorsUnified.grey200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.work_outline,
              size: 64,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu catálogo está vacío',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comienza agregando tu primer servicio profesional para conectar con clientes en la industria minera',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColorsUnified.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColorsUnified.goldGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: AppColorsUnified.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Empieza hoy mismo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsUnified.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulServiceCard(ServiceOffering service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColorsUnified.grey300, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditServiceDialog(service),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and edit button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColorsUnified.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getServiceIcon(service.category),
                          color: AppColorsUnified.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorsUnified.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColorsUnified.grey200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColorsUnified.grey300),
                              ),
                              child: Text(
                                service.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColorsUnified.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.grey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColorsUnified.gold,
                        ),
                      ),
                    ],
                  ),
                  
                  if (service.description != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.grey200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColorsUnified.grey300),
                      ),
                      child: Text(
                        service.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColorsUnified.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  
                  if (service.pricing != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.pureWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.attach_money, color: AppColorsUnified.gold, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service.pricing!.displayRange,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColorsUnified.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (service.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: service.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.grey200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColorsUnified.grey300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColorsUnified.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
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

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'maquinaria':
        return Icons.precision_manufacturing;
      case 'seguridad':
        return Icons.security;
      case 'topografía':
        return Icons.terrain;
      case 'mantenimiento':
        return Icons.build_circle;
      case 'consultoría':
        return Icons.psychology;
      default:
        return Icons.engineering;
    }
  }

  void _showAddServiceDialog() {
    _showServiceDialog();
  }

  void _showEditServiceDialog(ServiceOffering service) {
    _showServiceDialog(existingService: service);
  }

  void _showServiceDialog({ServiceOffering? existingService}) {
    final nameController = TextEditingController(text: existingService?.name ?? '');
    final categoryController = TextEditingController(text: existingService?.category ?? '');
    final descriptionController = TextEditingController(text: existingService?.description ?? '');
    final priceFromController = TextEditingController(
      text: existingService?.pricing?.from.toString() ?? ''
    );
    final priceToController = TextEditingController(
      text: existingService?.pricing?.to.toString() ?? ''
    );
    final priceUnitController = TextEditingController(
      text: existingService?.pricing?.unit ?? 'hora'
    );
    final tagsController = TextEditingController(
      text: existingService?.tags.join(', ') ?? ''
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingService == null ? 'Nuevo Servicio' : 'Editar Servicio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio *',
                  hintText: 'ej: Mantenimiento de equipos',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  hintText: 'ej: Maquinaria',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu servicio...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceFromController,
                      decoration: const InputDecoration(
                        labelText: 'Precio desde',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: priceToController,
                      decoration: const InputDecoration(
                        labelText: 'Precio hasta',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unidad de precio',
                  hintText: 'ej: hora, día, proyecto',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separados por comas)',
                  hintText: 'ej: taladro, mantenimiento, reparación',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _saveService(
              nameController.text,
              categoryController.text,
              descriptionController.text,
              priceFromController.text,
              priceToController.text,
              priceUnitController.text,
              tagsController.text,
              existingService,
            ),
            child: Text(existingService == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveService(
    String name,
    String category,
    String description,
    String priceFrom,
    String priceTo,
    String priceUnit,
    String tagsText,
    ServiceOffering? existingService,
  ) {
    if (name.trim().isEmpty || category.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y categoría son obligatorios'),
          backgroundColor: AppColorsUnified.error,
        ),
      );
      return;
    }

    // Parse pricing
    PricingRange? pricing;
    if (priceFrom.isNotEmpty && priceTo.isNotEmpty) {
      final from = double.tryParse(priceFrom);
      final to = double.tryParse(priceTo);
      if (from != null && to != null) {
        pricing = PricingRange(
          from: from,
          to: to,
          unit: priceUnit.trim().isNotEmpty ? priceUnit.trim() : 'hora',
        );
      }
    }

    // Parse tags
    final tags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // ignore: unused_local_variable
    final newService = ServiceOffering(
      name: name.trim(),
      category: category.trim(),
      description: description.trim().isNotEmpty ? description.trim() : null,
      pricing: pricing,
      tags: tags,
    );

    // TODO: Actualizar servicios del usuario en Supabase
    // SupabaseAuthService.instance.updateUser((user) {
    //   final currentServices = List<ServiceOffering>.from(user.servicesOffered);
    //   
    //   if (existingService != null) {
    //     // Replace existing service
    //     final index = currentServices.indexWhere((s) => s.name == existingService.name);
    //     if (index != -1) {
    //       currentServices[index] = newService;
    //     }
    //   } else {
    //     // Add new service
    //     currentServices.add(newService);
    //   }

    //   return User(
    //     id: user.id,
    //     username: user.username,
    //     email: user.email,
    //     name: user.name,
    //     role: user.role,
    //     avatarUrl: user.avatarUrl,
    //     phone: user.phone,
    //     bio: user.bio,
    //     location: user.location,
    //     languages: user.languages,
    //     servicesOffered: currentServices,
    //     interests: user.interests,
    //     watchKeywords: user.watchKeywords,
    //     profession: user.profession,
    //     experienceLevel: user.experienceLevel,
    //     specializations: user.specializations,
    //     certifications: user.certifications,
    //     workExperience: user.workExperience,
    //     birthDate: user.birthDate,
    //     company: user.company,
    //     jobTitle: user.jobTitle,
    //     website: user.website,
    //     socialLinks: user.socialLinks,
    //     preferences: user.preferences,
    //     preferredPostTypes: user.preferredPostTypes,
    //     followedTags: user.followedTags,
    //     followedCategories: user.followedCategories,
    //     verificationStatus: user.verificationStatus,
    //     ratingAvg: user.ratingAvg,
    //     ratingCount: user.ratingCount,
    //     completedJobsCount: user.completedJobsCount,
    //     createdAt: user.createdAt,
    //     lastActiveAt: user.lastActiveAt,
    //     isOnline: user.isOnline,
    //   );
    // });

    Navigator.of(context).pop();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existingService == null 
          ? 'Servicio creado exitosamente' 
          : 'Servicio actualizado exitosamente'),
        backgroundColor: AppColorsUnified.success,
      ),
    );
  }
}