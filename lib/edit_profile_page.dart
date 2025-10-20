import 'package:flutter/material.dart';
import '../shared/models/user.dart';
import '../core/theme/colors.dart';
import '../core/theme/glass_card.dart';

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
  List<String> _languages = [];
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
    _languages = List.from(user.languages);
    _interests = List.from(user.interests);
    _birthDate = user.birthDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Básico', icon: Icon(Icons.person)),
            Tab(text: 'Profesional', icon: Icon(Icons.work)),
            Tab(text: 'Ubicación', icon: Icon(Icons.location_on)),
            Tab(text: 'Preferencias', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildProfessionalTab(),
          _buildLocationTab(),
          _buildPreferencesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProfile,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('Guardar'),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar section
          GlassCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: widget.user.avatarUrl != null 
                    ? NetworkImage(widget.user.avatarUrl!) 
                    : null,
                  child: widget.user.avatarUrl == null 
                    ? Icon(Icons.person, size: 50, color: AppColors.primary)
                    : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selectAvatar,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cambiar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Basic info form
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información Personal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre completo',
                  icon: Icons.person_outline,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _bioController,
                  label: 'Biografía',
                  icon: Icons.edit_note,
                  maxLines: 3,
                  hint: 'Cuéntanos sobre ti...',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                // Birth date picker
                ListTile(
                  leading: Icon(Icons.cake_outlined, color: AppColors.primary),
                  title: Text(_birthDate != null 
                    ? 'Fecha de nacimiento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                    : 'Seleccionar fecha de nacimiento'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectBirthDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Languages selector
                Text(
                  'Idiomas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Español', 'Inglés', 'Portugués', 'Francés'].map((lang) {
                    final isSelected = _languages.contains(lang.toLowerCase());
                    return FilterChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _languages.add(lang.toLowerCase());
                          } else {
                            _languages.remove(lang.toLowerCase());
                          }
                        });
                      },
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

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información Profesional',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _professionController,
                  label: 'Profesión',
                  icon: Icons.work_outline,
                  hint: 'ej. Ingeniero de Minas',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _companyController,
                  label: 'Empresa',
                  icon: Icons.business_outlined,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _jobTitleController,
                  label: 'Cargo',
                  icon: Icons.badge_outlined,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _websiteController,
                  label: 'Sitio web',
                  icon: Icons.language_outlined,
                  hint: 'https://...',
                ),
                
                const SizedBox(height: 16),
                
                // Experience level dropdown
                DropdownButtonFormField<ExperienceLevel>(
                  value: _experienceLevel,
                  decoration: InputDecoration(
                    labelText: 'Nivel de experiencia',
                    prefixIcon: Icon(Icons.trending_up_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ExperienceLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(_getExperienceLevelText(level)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _experienceLevel = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mining specializations
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Especializaciones Mineras',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
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

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _addressController,
                  label: 'Dirección',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'Ciudad',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'Estado/Región',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _countryController,
                  label: 'País',
                  icon: Icons.public_outlined,
                ),
                
                const SizedBox(height: 20),
                
                // Get current location button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar ubicación actual'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.primary,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Intereses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Selecciona tus áreas de interés para recibir sugerencias personalizadas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'seguridad', 'maquinaria', 'geología', 'topografía', 
                    'procesamiento', 'medio ambiente', 'logística', 'tecnología',
                    'mantenimiento', 'capacitación', 'innovación', 'sustentabilidad'
                  ].map((interest) {
                    final isSelected = _interests.contains(interest);
                    return FilterChip(
                      label: Text(interest.substring(0, 1).toUpperCase() + interest.substring(1)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _interests.add(interest);
                          } else {
                            _interests.remove(interest);
                          }
                        });
                      },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
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
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de selección de avatar en desarrollo')),
    );
  }

  void _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _getCurrentLocation() {
    // TODO: Implement geolocation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de geolocalización en desarrollo')),
    );
  }

  void _saveProfile() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil guardado exitosamente'),
        backgroundColor: AppColors.success,
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