/// Sistema de roles y permisos para empleados
class EmployeeRole {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final String color;

  const EmployeeRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'permissions': permissions,
    'color': color,
  };

  factory EmployeeRole.fromJson(Map<String, dynamic> json) => EmployeeRole(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    permissions: List<String>.from(json['permissions'] as List),
    color: json['color'] as String,
  );
}

/// Roles predefinidos para empleados
class EmployeeRoles {
  // CEO - Acceso total
  static const EmployeeRole ceo = EmployeeRole(
    id: 'ceo',
    name: 'CEO / Director General',
    description: 'Acceso completo a todas las funciones',
    permissions: [
      'view_all',
      'edit_all',
      'manage_employees',
      'manage_projects',
      'view_metrics',
      'manage_resources',
      'approve_purchases',
      'manage_finances',
    ],
    color: '#1E3A8A', // Azul oscuro
  );

  // Gerente de Operaciones
  static const EmployeeRole operations = EmployeeRole(
    id: 'operations',
    name: 'Gerente de Operaciones',
    description: 'Gestión de proyectos y recursos',
    permissions: [
      'manage_projects',
      'manage_resources',
      'view_metrics',
      'assign_tasks',
    ],
    color: '#7C3AED', // Púrpura
  );

  // Contador/Finanzas
  static const EmployeeRole finance = EmployeeRole(
    id: 'finance',
    name: 'Contador / Finanzas',
    description: 'Gestión financiera y reportes',
    permissions: [
      'view_metrics',
      'manage_finances',
      'approve_purchases',
      'view_projects',
    ],
    color: '#059669', // Verde
  );

  // Recursos Humanos
  static const EmployeeRole hr = EmployeeRole(
    id: 'hr',
    name: 'Recursos Humanos',
    description: 'Gestión de personal',
    permissions: [
      'manage_employees',
      'view_metrics',
    ],
    color: '#DC2626', // Rojo
  );

  // Gerente de Ventas
  static const EmployeeRole sales = EmployeeRole(
    id: 'sales',
    name: 'Gerente de Ventas',
    description: 'Gestión de ventas y clientes',
    permissions: [
      'manage_products',
      'manage_services',
      'view_metrics',
    ],
    color: '#EA580C', // Naranja
  );

  // Supervisor de Proyecto
  static const EmployeeRole supervisor = EmployeeRole(
    id: 'supervisor',
    name: 'Supervisor de Proyecto',
    description: 'Supervisión de proyectos específicos',
    permissions: [
      'view_projects',
      'assign_tasks',
      'manage_resources',
    ],
    color: '#0891B2', // Cyan
  );

  // Técnico
  static const EmployeeRole technician = EmployeeRole(
    id: 'technician',
    name: 'Técnico / Operario',
    description: 'Ejecución de tareas asignadas',
    permissions: [
      'view_own_tasks',
      'report_progress',
    ],
    color: '#4B5563', // Gris
  );

  // Administrativo
  static const EmployeeRole administrative = EmployeeRole(
    id: 'administrative',
    name: 'Administrativo',
    description: 'Soporte administrativo general',
    permissions: [
      'view_projects',
      'manage_documents',
    ],
    color: '#8B5CF6', // Violeta
  );

  static List<EmployeeRole> get allRoles => [
    ceo,
    operations,
    finance,
    hr,
    sales,
    supervisor,
    technician,
    administrative,
  ];

  static EmployeeRole? getById(String id) {
    try {
      return allRoles.firstWhere((role) => role.id == id);
    } catch (e) {
      return null;
    }
  }

  static bool hasPermission(String roleId, String permission) {
    final role = getById(roleId);
    if (role == null) return false;
    return role.permissions.contains(permission) || 
           role.permissions.contains('view_all') ||
           role.permissions.contains('edit_all');
  }
}

/// Modelo de invitación de empleado
class EmployeeInvitation {
  final String id;
  final String companyId;
  final String companyName;
  final String employeeName;
  final String employeeEmail;
  final String roleId;
  final String? department;
  final String tempPassword;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  EmployeeInvitation({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.employeeName,
    required this.employeeEmail,
    required this.roleId,
    this.department,
    required this.tempPassword,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'companyName': companyName,
    'employeeName': employeeName,
    'employeeEmail': employeeEmail,
    'roleId': roleId,
    'department': department,
    'tempPassword': tempPassword,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'isUsed': isUsed,
  };

  factory EmployeeInvitation.fromJson(Map<String, dynamic> json) => EmployeeInvitation(
    id: json['id'] as String,
    companyId: json['companyId'] as String,
    companyName: json['companyName'] as String,
    employeeName: json['employeeName'] as String,
    employeeEmail: json['employeeEmail'] as String,
    roleId: json['roleId'] as String,
    department: json['department'] as String?,
    tempPassword: json['tempPassword'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    isUsed: json['isUsed'] as bool? ?? false,
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;
}
