import 'dart:math' as math;
import 'post.dart';

// Legacy enum - mantener para compatibilidad
enum UserRole { admin, vendor, customer }

// Nuevo sistema de tipos de cuenta
enum AccountType {
  individual,  // 👤 Persona independiente - minero, técnico, ingeniero independiente
  worker,      // � Trabajador empleado - depende de una empresa
  company      // 🏢 Empresa minera, corporación - puede tener trabajadores
}

// Roles dentro de empresas
enum CompanyRole {
  owner,            // Dueño de la empresa
  manager,          // Gerente/administrador
  customer_service, // Atención al cliente
  content_manager,  // Encargado de publicaciones
  employee          // Empleado regular
}

// Información de grupo/empresa
class OrganizationInfo {
  final String? organizationName;     // Nombre del grupo/empresa
  final String? organizationId;       // ID de la organización
  final List<String> memberIds;       // IDs de miembros (para grupos)
  final CompanyRole? companyRole;     // Rol en empresa (si aplica)
  final String? department;           // Departamento (si aplica)
  final List<String> permissions;     // Permisos específicos
  
  const OrganizationInfo({
    this.organizationName,
    this.organizationId,
    this.memberIds = const [],
    this.companyRole,
    this.department,
    this.permissions = const [],
  });

  // Getters de conveniencia
  bool get canManageContent => permissions.contains('manage_content') || companyRole == CompanyRole.content_manager || companyRole == CompanyRole.owner;
  bool get canManageMembers => permissions.contains('manage_members') || companyRole == CompanyRole.manager || companyRole == CompanyRole.owner;
  bool get canViewAnalytics => permissions.contains('view_analytics') || companyRole == CompanyRole.manager || companyRole == CompanyRole.owner;
}

enum VerificationStatus { none, pending, verified }

/// Professional mining specializations
enum MiningSpecialization {
  extraction,
  safety,
  geology,
  machinery,
  topography,
  processing,
  environmental,
  management,
  logistics,
  electrical,
  metallurgy,
  drilling
}

/// Experience levels for professional classification
enum ExperienceLevel {
  beginner,    // 0-2 years
  intermediate, // 2-5 years
  advanced,    // 5-10 years
  expert,      // 10+ years
  master       // 15+ years with leadership
}

class GeoLocation {
  final String? city;
  final String? state;
  final String? country;
  final double? lat;
  final double? lng;
  final String? address;
  final String? zipCode;
  
  const GeoLocation({
    this.city, 
    this.state,
    this.country, 
    this.lat, 
    this.lng,
    this.address,
    this.zipCode
  });

  /// Calculate distance in km between two locations
  double? distanceTo(GeoLocation other) {
    if (lat == null || lng == null || other.lat == null || other.lng == null) {
      return null;
    }
    
    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km
    final double lat1Rad = lat! * (math.pi / 180);
    final double lat2Rad = other.lat! * (math.pi / 180);
    final double deltaLat = (other.lat! - lat!) * (math.pi / 180);
    final double deltaLng = (other.lng! - lng!) * (math.pi / 180);

    final double a = 
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  String get displayName {
    if (city != null && state != null) {
      return '$city, $state';
    } else if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    }
    return 'Ubicación no especificada';
  }
}

class PricingRange {
  final double from;
  final double to;
  final String unit; // e.g. "hora", "proyecto", "día"
  const PricingRange(
      {required this.from, required this.to, required this.unit});

  String get displayRange => '\$${from.toStringAsFixed(0)} - \$${to.toStringAsFixed(0)} por $unit';
}

class AvailabilityWindow {
  final List<String> days; // e.g. ["Mon","Sat"]
  final String hours; // HH:MM-HH:MM
  const AvailabilityWindow({required this.days, required this.hours});

  String get displaySchedule => '${days.join(", ")} $hours';
}

class ServiceOffering {
  final String name;
  final String category;
  final List<String> tags;
  final PricingRange? pricing;
  final AvailabilityWindow? availability;
  final int? coverageKm;
  final MiningSpecialization? specialization;
  final String? description;
  
  const ServiceOffering({
    required this.name,
    required this.category,
    required this.tags,
    this.pricing,
    this.availability,
    this.coverageKm,
    this.specialization,
    this.description,
  });
}

/// Professional certifications for miners
class Certification {
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? certificateNumber;
  final bool isActive;

  const Certification({
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expiryDate,
    this.certificateNumber,
    this.isActive = true,
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isValid => isActive && !isExpired;
}

/// Work experience entry
class WorkExperience {
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final MiningSpecialization? specialization;
  final String? location;

  const WorkExperience({
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    this.description,
    this.specialization,
    this.location,
  });

  bool get isCurrent => endDate == null;
  Duration get duration => (endDate ?? DateTime.now()).difference(startDate);
}

/// User preferences for content and matching
class UserPreferences {
  final Set<PostType> preferredPostTypes;
  final List<String> followedTags;
  final List<String> followedCategories;
  final List<MiningSpecialization> interestedSpecializations;
  final double maxDistanceKm;
  final bool receiveNotifications;
  final bool allowLocationBasedSuggestions;
  final bool showOnlineStatus;

  UserPreferences({
    Set<PostType>? preferredPostTypes,
    List<String>? followedTags,
    List<String>? followedCategories,
    List<MiningSpecialization>? interestedSpecializations,
    this.maxDistanceKm = 50.0,
    this.receiveNotifications = true,
    this.allowLocationBasedSuggestions = true,
    this.showOnlineStatus = true,
  }) : 
    preferredPostTypes = preferredPostTypes ?? const {PostType.community, PostType.request, PostType.offer},
    followedTags = followedTags ?? const [],
    followedCategories = followedCategories ?? const [],
    interestedSpecializations = interestedSpecializations ?? const [];
}

class User {
  final String id;
  final String username;
  final String email;
  final String name;
  
  // Sistema de roles híbrido
  final UserRole role;              // Legacy - mantener compatibilidad
  final AccountType accountType;    // Nuevo sistema principal
  final OrganizationInfo? organizationInfo; // Info de grupo/empresa
  
  final String? avatarUrl;
  final String? phone;
  final String? bio;

  // Extended profile
  final GeoLocation? location;
  final List<String> languages;
  final List<ServiceOffering> servicesOffered;
  final List<String> interests; // generic tags of interest
  final List<String> watchKeywords;
  
  // New enhanced fields
  final String? profession; // e.g. "Ingeniero de Minas", "Técnico en Seguridad"
  final ExperienceLevel experienceLevel;
  final List<MiningSpecialization> specializations;
  final List<Certification> certifications;
  final List<WorkExperience> workExperience;
  final DateTime? birthDate;
  final String? company;
  final String? jobTitle;
  final String? website;
  final List<String> socialLinks;
  
  // User preferences
  final UserPreferences preferences;
  
  // Original preference fields (keeping for compatibility)
  final Set<PostType> preferredPostTypes;
  final List<String> followedTags;
  final List<String> followedCategories;
  final VerificationStatus verificationStatus;
  final double ratingAvg;
  final int ratingCount;
  final int completedJobsCount;
  
  // Activity tracking
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isOnline;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    
    // Sistema de roles híbrido
    this.role = UserRole.customer,
    this.accountType = AccountType.individual,
    this.organizationInfo,
    
    this.avatarUrl,
    this.phone,
    this.bio,
    this.location,
    this.languages = const ['es'],
    this.servicesOffered = const [],
    this.interests = const [],
    this.watchKeywords = const [],
    
    // New enhanced fields
    this.profession,
    this.experienceLevel = ExperienceLevel.beginner,
    this.specializations = const [],
    this.certifications = const [],
    this.workExperience = const [],
    this.birthDate,
    this.company,
    this.jobTitle,
    this.website,
    this.socialLinks = const [],
    
    // User preferences
    UserPreferences? preferences,
    
    // Original compatibility fields
    Set<PostType>? preferredPostTypes,
    this.followedTags = const [],
    this.followedCategories = const [],
    this.verificationStatus = VerificationStatus.none,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.completedJobsCount = 0,
    
    // Activity tracking
    DateTime? createdAt,
    this.lastActiveAt,
    this.isOnline = false,
  }) : 
    preferredPostTypes = preferredPostTypes ?? const {PostType.community, PostType.request, PostType.offer},
    preferences = preferences ?? UserPreferences(),
    createdAt = createdAt ?? DateTime.now();

  /// Calculate years of experience based on work history
  int get yearsOfExperience {
    if (workExperience.isEmpty) return 0;
    
    final totalDuration = workExperience.fold<Duration>(
      Duration.zero,
      (total, experience) => total + experience.duration,
    );
    
    return (totalDuration.inDays / 365).round();
  }

  /// Get valid (non-expired) certifications
  List<Certification> get validCertifications {
    return certifications.where((cert) => cert.isValid).toList();
  }

  /// Get display name with professional title if available
  String get displayName {
    if (profession != null) {
      return '$name ($profession)';
    }
    return name;
  }

  /// Get user's age if birthdate is provided
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user is recently active (within last 24 hours)
  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inHours < 24;
  }

  User copyWith({
    String? username,
    String? email,
    String? name,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    String? bio,
    GeoLocation? location,
    List<String>? languages,
    List<ServiceOffering>? servicesOffered,
    List<String>? interests,
    List<String>? watchKeywords,
    
    // New enhanced fields
    String? profession,
    ExperienceLevel? experienceLevel,
    List<MiningSpecialization>? specializations,
    List<Certification>? certifications,
    List<WorkExperience>? workExperience,
    DateTime? birthDate,
    String? company,
    String? jobTitle,
    String? website,
    List<String>? socialLinks,
    
    // User preferences
    UserPreferences? preferences,
    
    // Original compatibility fields
    Set<PostType>? preferredPostTypes,
    List<String>? followedTags,
    List<String>? followedCategories,
    VerificationStatus? verificationStatus,
    double? ratingAvg,
    int? ratingCount,
    int? completedJobsCount,
    
    // Activity tracking
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isOnline,
  }) =>
      User(
        id: id,
        username: username ?? this.username,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        location: location ?? this.location,
        languages: languages ?? this.languages,
        servicesOffered: servicesOffered ?? this.servicesOffered,
        interests: interests ?? this.interests,
        watchKeywords: watchKeywords ?? this.watchKeywords,
        
        // New enhanced fields
        profession: profession ?? this.profession,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        specializations: specializations ?? this.specializations,
        certifications: certifications ?? this.certifications,
        workExperience: workExperience ?? this.workExperience,
        birthDate: birthDate ?? this.birthDate,
        company: company ?? this.company,
        jobTitle: jobTitle ?? this.jobTitle,
        website: website ?? this.website,
        socialLinks: socialLinks ?? this.socialLinks,
        
        // User preferences
        preferences: preferences ?? this.preferences,
        
        // Original compatibility fields
        preferredPostTypes: preferredPostTypes ?? this.preferredPostTypes,
        followedTags: followedTags ?? this.followedTags,
        followedCategories: followedCategories ?? this.followedCategories,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        ratingAvg: ratingAvg ?? this.ratingAvg,
        ratingCount: ratingCount ?? this.ratingCount,
        completedJobsCount: completedJobsCount ?? this.completedJobsCount,
        
        // Activity tracking
        createdAt: createdAt ?? this.createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        isOnline: isOnline ?? this.isOnline,
      );

  // ==================== NUEVO SISTEMA DE ROLES ====================
  
  /// Retorna el nombre de display según el tipo de cuenta
  String get accountDisplayName {
    switch (accountType) {
      case AccountType.individual:
        return name;
      case AccountType.worker:
        return name; // Los trabajadores usan su nombre personal
      case AccountType.company:
        return organizationInfo?.organizationName ?? name;
    }
  }

  /// Retorna el icono apropiado para el tipo de cuenta
  String get accountIcon {
    switch (accountType) {
      case AccountType.individual:
        return '👤';
      case AccountType.worker:
        return '�';
      case AccountType.company:
        return '🏢';
    }
  }

  /// Indica si el usuario puede gestionar contenido
  bool get canManageContent {
    // Admin siempre puede
    if (role == UserRole.admin) return true;
    
    // Individuales siempre pueden gestionar su propio contenido
    if (accountType == AccountType.individual) return true;
    
    // Para grupos y empresas, depende de los permisos
    return organizationInfo?.canManageContent ?? false;
  }

  /// Indica si el usuario puede gestionar miembros
  bool get canManageMembers {
    if (role == UserRole.admin) return true;
    return organizationInfo?.canManageMembers ?? false;
  }

  /// Indica si el usuario puede ver analytics
  bool get canViewAnalytics {
    if (role == UserRole.admin) return true;
    return organizationInfo?.canViewAnalytics ?? false;
  }

  /// Retorna el rol de display para mostrar en la UI
  String get displayRole {
    if (accountType == AccountType.company && organizationInfo?.companyRole != null) {
      switch (organizationInfo!.companyRole!) {
        case CompanyRole.owner:
          return 'Propietario';
        case CompanyRole.manager:
          return 'Gerente';
        case CompanyRole.customer_service:
          return 'Atención al Cliente';
        case CompanyRole.content_manager:
          return 'Gestor de Contenido';
        case CompanyRole.employee:
          return 'Empleado';
      }
    }
    
    switch (accountType) {
      case AccountType.individual:
        return profession ?? 'Minero Independiente';
      case AccountType.worker:
        return 'Trabajador en ${organizationInfo?.organizationName ?? "Empresa"}';
      case AccountType.company:
        return 'Empresa';
    }
  }

  /// Indica si es una cuenta verificada (basado en el tipo y otros factores)
  bool get isVerifiedAccount {
    return verificationStatus == VerificationStatus.verified ||
           (accountType == AccountType.company && ratingCount > 10) ||
           (accountType == AccountType.worker && organizationInfo != null);
  }
}
