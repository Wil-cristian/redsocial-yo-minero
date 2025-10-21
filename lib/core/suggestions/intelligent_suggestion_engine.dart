import '../../shared/models/user.dart';
import '../../shared/models/post.dart';

/// Resultado de sugerencia con puntuación
class SuggestionResult<T> {
  final T item;
  final double score;
  final List<String> reasons;

  const SuggestionResult({
    required this.item,
    required this.score,
    this.reasons = const [],
  });
}

/// Motor de sugerencias inteligente para usuarios y contenido
class IntelligentSuggestionEngine {
  
  /// Sugerir usuarios basado en ubicación, especialidades y compatibilidad
  static List<SuggestionResult<User>> suggestUsers({
    required User currentUser,
    required List<User> allUsers,
    int maxResults = 10,
    double minScore = 20.0,
  }) {
    final suggestions = <SuggestionResult<User>>[];
    
    for (final user in allUsers) {
      if (user.id == currentUser.id) continue;
      
      final score = _calculateUserCompatibilityScore(currentUser, user);
      final reasons = _getUserSuggestionReasons(currentUser, user);
      
      if (score >= minScore) {
        suggestions.add(SuggestionResult(
          item: user,
          score: score,
          reasons: reasons,
        ));
      }
    }
    
    // Ordenar por puntuación descendente
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    
    return suggestions.take(maxResults).toList();
  }

  /// Sugerir contenido personalizado basado en perfil del usuario
  static List<SuggestionResult<Post>> suggestContent({
    required User user,
    required List<Post> allPosts,
    int maxResults = 20,
    double minScore = 15.0,
  }) {
    final suggestions = <SuggestionResult<Post>>[];
    
    for (final post in allPosts) {
      if (post.authorId == user.id) continue;
      
      final score = _calculateContentRelevanceScore(user, post);
      final reasons = _getContentSuggestionReasons(user, post);
      
      if (score >= minScore) {
        suggestions.add(SuggestionResult(
          item: post,
          score: score,
          reasons: reasons,
        ));
      }
    }
    
    // Ordenar por puntuación descendente
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    
    return suggestions.take(maxResults).toList();
  }

  /// Buscar colaboradores potenciales para un proyecto
  static List<SuggestionResult<User>> findCollaborators({
    required User projectOwner,
    required List<User> availableUsers,
    required List<MiningSpecialization> requiredSpecializations,
    GeoLocation? projectLocation,
    double? maxDistanceKm,
    int maxResults = 5,
  }) {
    final suggestions = <SuggestionResult<User>>[];
    
    for (final user in availableUsers) {
      if (user.id == projectOwner.id) continue;
      
      final score = _calculateCollaborationScore(
        projectOwner,
        user,
        requiredSpecializations,
        projectLocation,
        maxDistanceKm,
      );
      
      final reasons = _getCollaborationReasons(
        projectOwner,
        user,
        requiredSpecializations,
        projectLocation,
      );
      
      if (score > 0) {
        suggestions.add(SuggestionResult(
          item: user,
          score: score,
          reasons: reasons,
        ));
      }
    }
    
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions.take(maxResults).toList();
  }

  /// Calcular puntuación de compatibilidad entre usuarios
  static double _calculateUserCompatibilityScore(User user1, User user2) {
    double score = 0.0;
    
    // Especializations en común (peso alto)
    final commonSpecializations = user1.specializations
        .where((spec) => user2.specializations.contains(spec))
        .length;
    score += commonSpecializations * 15.0;
    
    // Intereses en común
    final commonInterests = user1.interests
        .where((interest) => user2.interests.contains(interest))
        .length;
    score += commonInterests * 10.0;
    
    // Nivel de experiencia similar (bonus por complementariedad)
    final experienceDiff = (user1.experienceLevel.index - user2.experienceLevel.index).abs();
    if (experienceDiff <= 1) {
      score += 20.0; // Niveles similares
    } else if (experienceDiff == 2) {
      score += 15.0; // Puede ser mentor/aprendiz
    }
    
    // Proximidad geográfica
    if (user1.location != null && user2.location != null) {
      final distance = user1.location!.distanceTo(user2.location!);
      if (distance != null) {
        if (distance <= 10) {
          score += 25.0; // Muy cerca
        } else if (distance <= 50) {
          score += 15.0; // Cerca
        } else if (distance <= 100) {
          score += 5.0; // Moderadamente cerca
        }
      }
    }
    
    // Idiomas en común
    final commonLanguages = user1.languages
        .where((lang) => user2.languages.contains(lang))
        .length;
    score += commonLanguages * 8.0;
    
    // Rating del usuario (credibilidad)
    if (user2.ratingCount > 0) {
      score += user2.ratingAvg * 2.0;
    }
    
    // Actividad reciente
    if (user2.isRecentlyActive) {
      score += 10.0;
    }
    
    // Verificación
    if (user2.verificationStatus == VerificationStatus.verified) {
      score += 15.0;
    }
    
    return score;
  }

  /// Calcular relevancia de contenido para el usuario
  static double _calculateContentRelevanceScore(User user, Post post) {
    double score = 0.0;
    
    // Tipo de post preferido
    if (user.preferredPostTypes.contains(post.type)) {
      score += 20.0;
    }
    
    // Tags seguidos
    final matchedTags = post.tags
        .where((tag) => user.followedTags.contains(tag))
        .length;
    score += matchedTags * 12.0;
    
    // Intereses del usuario
    final matchedInterests = post.tags
        .where((tag) => user.interests.contains(tag))
        .length;
    score += matchedInterests * 10.0;
    
    // Categorías seguidas
    final matchedCategories = post.categories
        .where((cat) => user.followedCategories.contains(cat))
        .length;
    score += matchedCategories * 15.0;
    
    // Especializations relevantes
    final postSpecializations = _extractSpecializationsFromPost(post);
    final matchedSpecs = postSpecializations
        .where((spec) => user.specializations.contains(spec))
        .length;
    score += matchedSpecs * 18.0;
    
    // Keywords observadas
    final matchedKeywords = post.tags
        .where((tag) => user.watchKeywords.contains(tag))
        .length;
    score += matchedKeywords * 8.0;
    
    // Frescura del contenido
    final hoursOld = DateTime.now().difference(post.createdAt).inHours;
    if (hoursOld <= 6) {
      score += 15.0; // Muy reciente
    } else if (hoursOld <= 24) {
      score += 10.0; // Reciente
    } else if (hoursOld <= 72) {
      score += 5.0; // Moderadamente reciente
    }
    
    // Engagement del post
    if (post.likes > 0) {
      score += (post.likes * 0.5).clamp(0, 10);
    }
    if (post.comments > 0) {
      score += (post.comments * 1.0).clamp(0, 15);
    }
    
    return score;
  }

  /// Calcular puntuación para colaboración
  static double _calculateCollaborationScore(
    User projectOwner,
    User candidate,
    List<MiningSpecialization> requiredSpecs,
    GeoLocation? projectLocation,
    double? maxDistanceKm,
  ) {
    double score = 0.0;
    
    // Especializations requeridas
    final hasRequiredSpecs = requiredSpecs
        .where((spec) => candidate.specializations.contains(spec))
        .length;
    
    if (hasRequiredSpecs == 0) return 0.0; // No cumple requisitos básicos
    
    score += hasRequiredSpecs * 25.0;
    
    // Experiencia
    score += candidate.yearsOfExperience * 2.0;
    score += candidate.experienceLevel.index * 10.0;
    
    // Rating y trabajos completados
    if (candidate.ratingCount > 0) {
      score += candidate.ratingAvg * 8.0;
      score += (candidate.completedJobsCount * 0.5).clamp(0, 20);
    }
    
    // Proximidad al proyecto
    if (projectLocation != null && candidate.location != null) {
      final distance = candidate.location!.distanceTo(projectLocation);
      if (distance != null) {
        if (maxDistanceKm != null && distance > maxDistanceKm) {
          return 0.0; // Fuera del rango
        }
        
        // Bonus por proximidad
        if (distance <= 25) {
          score += 30.0;
        } else if (distance <= 50) {
          score += 20.0;
        } else if (distance <= 100) {
          score += 10.0;
        }
      }
    }
    
    // Disponibilidad (activo recientemente)
    if (candidate.isRecentlyActive) {
      score += 15.0;
    }
    
    // Verificación
    if (candidate.verificationStatus == VerificationStatus.verified) {
      score += 20.0;
    }
    
    return score;
  }

  /// Extraer especializations de un post basado en tags y contenido
  static List<MiningSpecialization> _extractSpecializationsFromPost(Post post) {
    final specializations = <MiningSpecialization>[];
    
    final allText = '${post.title} ${post.content} ${post.tags.join(' ')}'.toLowerCase();
    
    // Mapeo de palabras clave a especializations
    final keywordMap = {
      MiningSpecialization.safety: ['seguridad', 'ppe', 'protección', 'riesgo'],
      MiningSpecialization.geology: ['geología', 'geologico', 'mineral', 'roca'],
      MiningSpecialization.machinery: ['maquinaria', 'equipo', 'taladro', 'excavadora'],
      MiningSpecialization.topography: ['topografía', 'mapeo', 'levantamiento', 'drone'],
      MiningSpecialization.extraction: ['extracción', 'minado', 'explotación'],
      MiningSpecialization.processing: ['procesamiento', 'concentración', 'beneficio'],
      MiningSpecialization.environmental: ['ambiental', 'sustentable', 'ecológico'],
      MiningSpecialization.electrical: ['eléctrico', 'electricidad', 'energía'],
      MiningSpecialization.drilling: ['perforación', 'perforar', 'sondaje'],
    };
    
    for (final entry in keywordMap.entries) {
      if (entry.value.any((keyword) => allText.contains(keyword))) {
        specializations.add(entry.key);
      }
    }
    
    return specializations;
  }

  /// Generar razones para sugerencia de usuarios
  static List<String> _getUserSuggestionReasons(User currentUser, User suggestedUser) {
    final reasons = <String>[];
    
    final commonSpecs = currentUser.specializations
        .where((spec) => suggestedUser.specializations.contains(spec))
        .length;
    
    if (commonSpecs > 0) {
      reasons.add('$commonSpecs especialización${commonSpecs > 1 ? 'es' : ''} en común');
    }
    
    if (currentUser.location != null && suggestedUser.location != null) {
      final distance = currentUser.location!.distanceTo(suggestedUser.location!);
      if (distance != null && distance <= 50) {
        reasons.add('Ubicado a ${distance.toStringAsFixed(1)} km');
      }
    }
    
    if (suggestedUser.ratingAvg >= 4.0 && suggestedUser.ratingCount > 5) {
      reasons.add('Excelente rating (${suggestedUser.ratingAvg.toStringAsFixed(1)}/5.0)');
    }
    
    if (suggestedUser.verificationStatus == VerificationStatus.verified) {
      reasons.add('Perfil verificado');
    }
    
    if (suggestedUser.isRecentlyActive) {
      reasons.add('Activo recientemente');
    }
    
    return reasons;
  }

  /// Generar razones para sugerencia de contenido
  static List<String> _getContentSuggestionReasons(User user, Post post) {
    final reasons = <String>[];
    
    if (user.followedTags.any((tag) => post.tags.contains(tag))) {
      reasons.add('Contiene tags que sigues');
    }
    
    if (user.interests.any((interest) => post.tags.contains(interest))) {
      reasons.add('Relacionado con tus intereses');
    }
    
    final hoursOld = DateTime.now().difference(post.createdAt).inHours;
    if (hoursOld <= 6) {
      reasons.add('Contenido muy reciente');
    }
    
    if (post.likes > 10) {
      reasons.add('Popular (${post.likes} likes)');
    }
    
    return reasons;
  }

  /// Generar razones para colaboración
  static List<String> _getCollaborationReasons(
    User projectOwner,
    User candidate,
    List<MiningSpecialization> requiredSpecs,
    GeoLocation? projectLocation,
  ) {
    final reasons = <String>[];
    
    final hasSpecs = requiredSpecs
        .where((spec) => candidate.specializations.contains(spec))
        .length;
    
    if (hasSpecs > 0) {
      reasons.add('Tiene $hasSpecs especialización${hasSpecs > 1 ? 'es' : ''} requerida${hasSpecs > 1 ? 's' : ''}');
    }
    
    if (candidate.yearsOfExperience >= 5) {
      reasons.add('${candidate.yearsOfExperience} años de experiencia');
    }
    
    if (candidate.completedJobsCount > 10) {
      reasons.add('${candidate.completedJobsCount} trabajos completados');
    }
    
    return reasons;
  }
}