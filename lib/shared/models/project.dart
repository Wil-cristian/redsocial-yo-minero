enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planeación';
      case ProjectStatus.inProgress:
        return 'En Progreso';
      case ProjectStatus.onHold:
        return 'En Pausa';
      case ProjectStatus.completed:
        return 'Completado';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }

  static ProjectStatus fromString(String status) {
    switch (status) {
      case 'planning':
        return ProjectStatus.planning;
      case 'in_progress':
        return ProjectStatus.inProgress;
      case 'on_hold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planning;
    }
  }

  String toJson() {
    switch (this) {
      case ProjectStatus.planning:
        return 'planning';
      case ProjectStatus.inProgress:
        return 'in_progress';
      case ProjectStatus.onHold:
        return 'on_hold';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.cancelled:
        return 'cancelled';
    }
  }
}

class Project {
  final String id;
  final String companyId;
  final String name;
  final String description;
  final ProjectStatus status;
  final double progress;
  final double? budgetAmount;
  final String budgetCurrency;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final String? managerId;
  final List<String> teamMembers;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    this.status = ProjectStatus.planning,
    this.progress = 0.0,
    this.budgetAmount,
    this.budgetCurrency = 'USD',
    this.startDate,
    this.endDate,
    this.deadline,
    this.managerId,
    this.teamMembers = const [],
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProjectStatus.fromString(json['status'] as String? ?? 'planning'),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble(),
      budgetCurrency: json['budget_currency'] as String? ?? 'USD',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      managerId: json['manager_id'] as String?,
      teamMembers: (json['team_members'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'description': description,
      'status': status.toJson(),
      'progress': progress,
      'budget_amount': budgetAmount,
      'budget_currency': budgetCurrency,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'manager_id': managerId,
      'team_members': teamMembers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'company_id': companyId,
      'name': name,
      'description': description,
      'status': status.toJson(),
      'progress': progress,
      'budget_amount': budgetAmount,
      'budget_currency': budgetCurrency,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'deadline': deadline?.toIso8601String().split('T')[0],
      'manager_id': managerId,
      'team_members': teamMembers,
    };
  }
}
