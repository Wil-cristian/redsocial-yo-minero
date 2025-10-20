import 'package:flutter/material.dart';
import '../models/user.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glass_card.dart';

/// Tarjeta de perfil de usuario compacta para mostrar en posts, sugerencias, etc.
class UserProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onPhoneTap;
  final bool showDistance;
  final double? distanceKm;
  final bool showRating;
  final bool showSpecializations;
  final bool compact;

  const UserProfileCard({
    super.key,
    required this.user,
    this.onTap,
    this.onPhoneTap,
    this.showDistance = false,
    this.distanceKm,
    this.showRating = true,
    this.showSpecializations = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: compact ? _buildCompactLayout() : _buildFullLayout(),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: user.avatarUrl != null 
                ? NetworkImage(user.avatarUrl!) 
                : null,
              child: user.avatarUrl == null 
                ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                : null,
            ),
            
            const SizedBox(width: 12),
            
            // Basic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  
                  if (user.profession != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.profession!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  
                  if (user.company != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.company!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Verification badge
            if (user.verificationStatus == VerificationStatus.verified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Verificado',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        // Location and distance
        if (user.location != null || showDistance) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getLocationText(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        
        // Phone number
        if (user.phone != null && user.phone!.isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPhoneTap,
            child: Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.phone!,
                    style: TextStyle(
                      color: onPhoneTap != null ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 12,
                      decoration: onPhoneTap != null ? TextDecoration.underline : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Experience level
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              _getExperienceLevelText(user.experienceLevel),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user.yearsOfExperience > 0) ...[
              const SizedBox(width: 8),
              Text(
                '${user.yearsOfExperience} años',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        
        // Rating
        if (showRating && user.ratingCount > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                user.ratingAvg.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${user.ratingCount} reviews)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '${user.completedJobsCount} trabajos',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
        
        // Specializations
        if (showSpecializations && user.specializations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: user.specializations.take(3).map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSpecializationText(spec),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        
        // Bio (if not compact)
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            user.bio!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryContainer,
          backgroundImage: user.avatarUrl != null 
            ? NetworkImage(user.avatarUrl!) 
            : null,
          child: user.avatarUrl == null 
            ? const Icon(Icons.person, size: 20, color: AppColors.primary)
            : null,
        ),
        
        const SizedBox(width: 12),
        
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.verificationStatus == VerificationStatus.verified)
                    const Icon(Icons.verified, size: 16, color: AppColors.success),
                  if (user.isOnline) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              
              if (user.profession != null)
                Text(
                  user.profession!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
              if (showRating && user.ratingCount > 0)
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      user.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (showDistance && distanceKm != null)
                      Text(
                        '• ${distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocationText() {
    if (showDistance && distanceKm != null) {
      return '${user.location?.displayName ?? 'Ubicación'} • ${distanceKm!.toStringAsFixed(1)} km';
    }
    return user.location?.displayName ?? 'Ubicación no especificada';
  }

  String _getExperienceLevelText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Principiante';
      case ExperienceLevel.intermediate:
        return 'Intermedio';
      case ExperienceLevel.advanced:
        return 'Avanzado';
      case ExperienceLevel.expert:
        return 'Experto';
      case ExperienceLevel.master:
        return 'Maestro';
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
}

/// Widget para mostrar sugerencias de usuarios
class UserSuggestionsList extends StatelessWidget {
  final List<User> users;
  final String title;
  final User? currentUser;
  final Function(User)? onUserTap;

  const UserSuggestionsList({
    super.key,
    required this.users,
    required this.title,
    this.currentUser,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final distance = currentUser?.location != null && user.location != null 
                  ? currentUser!.location!.distanceTo(user.location!)
                  : null;
              
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: UserProfileCard(
                  user: user,
                  showDistance: distance != null,
                  distanceKm: distance,
                  onTap: () => onUserTap?.call(user),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}