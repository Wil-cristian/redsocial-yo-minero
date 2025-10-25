import 'package:flutter/material.dart';
import '../shared/models/user.dart';
import '../core/theme/colors.dart';
import '../core/auth/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // Location controllers
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Form data
  ExperienceLevel _experienceLevel = ExperienceLevel.beginner;
  List<MiningSpecialization> _selectedSpecializations = [];
  List<String> _interests = [];
  DateTime? _birthDate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    final user = widget.user;
    _nameController.text = user.name;
    _bioController.text = user.bio ?? '';
    _phoneController.text = user.phone ?? '';
    _professionController.text = user.profession ?? '';
    _companyController.text = user.company ?? '';
    _jobTitleController.text = user.jobTitle ?? '';
    _websiteController.text = user.website ?? '';
    
    // Location
    _cityController.text = user.location?.city ?? '';
    _stateController.text = user.location?.state ?? '';
    _countryController.text = user.location?.country ?? '';
    _addressController.text = user.location?.address ?? '';
    
    _experienceLevel = user.experienceLevel;
    _selectedSpecializations = List.from(user.specializations);
    _interests = List.from(user.interests);
    _birthDate = user.birthDate;
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
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primaryContainer,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _selectAvatar,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.white.withValues(alpha: 0.1),
                                      ],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    backgroundImage: widget.user.avatarUrl != null 
                                      ? NetworkImage(widget.user.avatarUrl!) 
                                      : null,
                                    child: widget.user.avatarUrl == null 
                                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                                      : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Editar Perfil',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Actualiza tu información personal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Básico', icon: Icon(Icons.person_outline, size: 20)),
                    Tab(text: 'Profesional', icon: Icon(Icons.work_outline, size: 20)),
                    Tab(text: 'Ubicación', icon: Icon(Icons.location_on_outlined, size: 20)),
                    Tab(text: 'Extras', icon: Icon(Icons.tune, size: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Container(
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildProfessionalTab(),
              _buildLocationTab(),
              _buildPreferencesTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _saveProfile,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Personal Information Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildElegantTextField(
                  controller: _nameController,
                  label: 'Nombre completo',
                  icon: Icons.badge_outlined,
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _bioController,
                  label: 'Biografía',
                  icon: Icons.edit_note,
                  maxLines: 4,
                  hint: 'Cuéntanos sobre ti, tus experiencias y objetivos...',
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 20),
                
                // Birth date picker with elegant design
                GestureDetector(
                  onTap: _selectBirthDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de nacimiento',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _birthDate != null 
                                  ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                  : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: _birthDate != null ? Colors.black87 : Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Professional Information Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Información Profesional',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildElegantTextField(
                  controller: _professionController,
                  label: 'Profesión',
                  icon: Icons.badge_outlined,
                  hint: 'ej. Ingeniero de Minas',
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _companyController,
                  label: 'Empresa',
                  icon: Icons.business_outlined,
                  hint: 'ej. MinCorp S.A.',
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _jobTitleController,
                  label: 'Cargo',
                  icon: Icons.assignment_ind_outlined,
                  hint: 'ej. Jefe de Operaciones',
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _websiteController,
                  label: 'Sitio Web',
                  icon: Icons.language,
                  hint: 'ej. www.miempresa.com',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 24),
                
                // Experience Level Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Nivel de Experiencia',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...ExperienceLevel.values.map((level) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<ExperienceLevel>(
                          value: level,
                          groupValue: _experienceLevel,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _experienceLevel = value;
                              });
                            }
                          },
                          title: Text(
                            _getExperienceLevelText(level),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Specializations Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.science_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Especializaciones',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MiningSpecialization.values.map((spec) {
                          final isSelected = _selectedSpecializations.contains(spec);
                          return FilterChip(
                            label: Text(_getSpecializationText(spec)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSpecializations.add(spec);
                                } else {
                                  _selectedSpecializations.remove(spec);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Ubicación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildElegantTextField(
                  controller: _addressController,
                  label: 'Dirección',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                  hint: 'Dirección completa de tu residencia',
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _cityController,
                  label: 'Ciudad',
                  icon: Icons.location_city_outlined,
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _stateController,
                  label: 'Estado/Región',
                  icon: Icons.map_outlined,
                ),
                
                const SizedBox(height: 20),
                
                _buildElegantTextField(
                  controller: _countryController,
                  label: 'País',
                  icon: Icons.public_outlined,
                ),
                
                const SizedBox(height: 24),
                
                // Get current location button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryContainer, AppColors.primaryContainer.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                    label: const Text(
                      'Usar ubicación actual',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Intereses y Preferencias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Selecciona tus áreas de interés para recibir sugerencias personalizadas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Seguridad Minera', 'Maquinaria Pesada', 'Geología', 'Topografía', 
                    'Procesamiento', 'Medio Ambiente', 'Logística', 'Tecnología',
                    'Mantenimiento', 'Capacitación', 'Innovación', 'Sustentabilidad',
                    'Perforación', 'Voladura', 'Metalurgia', 'Gestión de Proyectos'
                  ].map((interest) {
                    final isSelected = _interests.contains(interest.toLowerCase());
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _interests.add(interest.toLowerCase());
                          } else {
                            _interests.remove(interest.toLowerCase());
                          }
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getExperienceLevelText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Principiante (0-2 años)';
      case ExperienceLevel.intermediate:
        return 'Intermedio (2-5 años)';
      case ExperienceLevel.advanced:
        return 'Avanzado (5-10 años)';
      case ExperienceLevel.expert:
        return 'Experto (10+ años)';
      case ExperienceLevel.master:
        return 'Maestro (15+ años)';
    }
  }

  String _getSpecializationText(MiningSpecialization spec) {
    switch (spec) {
      case MiningSpecialization.extraction:
        return 'Extracción';
      case MiningSpecialization.safety:
        return 'Seguridad';
      case MiningSpecialization.geology:
        return 'Geología';
      case MiningSpecialization.machinery:
        return 'Maquinaria';
      case MiningSpecialization.topography:
        return 'Topografía';
      case MiningSpecialization.processing:
        return 'Procesamiento';
      case MiningSpecialization.environmental:
        return 'Medio Ambiente';
      case MiningSpecialization.management:
        return 'Gestión';
      case MiningSpecialization.logistics:
        return 'Logística';
      case MiningSpecialization.electrical:
        return 'Eléctrico';
      case MiningSpecialization.metallurgy:
        return 'Metalurgia';
      case MiningSpecialization.drilling:
        return 'Perforación';
    }
  }

  void _selectAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función de selección de avatar en desarrollo'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _getCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función de geolocalización en desarrollo'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveProfile() {
    // Update the current user using AuthService
    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      profession: _professionController.text.trim().isNotEmpty ? _professionController.text.trim() : null,
      company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
      jobTitle: _jobTitleController.text.trim().isNotEmpty ? _jobTitleController.text.trim() : null,
      website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
      experienceLevel: _experienceLevel,
      specializations: _selectedSpecializations,
      interests: _interests,
      birthDate: _birthDate,
    );
    
    AuthService.instance.updateUser((_) => updatedUser);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('¡Perfil actualizado exitosamente!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _websiteController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}