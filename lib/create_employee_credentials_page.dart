import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'core/theme/colors.dart';
import 'core/auth/employee_roles.dart';
import 'core/auth/supabase_auth_service.dart';

/// Página para que la empresa cree credenciales para empleados
class CreateEmployeeCredentialsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CreateEmployeeCredentialsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CreateEmployeeCredentialsPage> createState() => _CreateEmployeeCredentialsPageState();
}

class _CreateEmployeeCredentialsPageState extends State<CreateEmployeeCredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  
  EmployeeRole? _selectedRole;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = EmployeeRoles.technician; // Rol por defecto
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateUsername(String name) {
    final nameParts = name.trim().toLowerCase().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts[nameParts.length - 1] : '';
    final random = Random().nextInt(9999);
    return '${firstName}_${lastName}_$random';
  }

  Future<void> _createEmployeeCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      final companyId = widget.currentUser?['id'] as String;

      // Generar credenciales
      final password = _generatePassword();
      final username = _generateUsername(_nameController.text);

      // Crear empleado usando el servicio de autenticación
      final result = await SupabaseAuthService.instance.createEmployeeCredentials(
        companyId: companyId,
        employeeName: _nameController.text,
        employeeEmail: _emailController.text,
        tempPassword: password,
        roleId: _selectedRole!.id,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
      );

      setState(() => _isGenerating = false);

      if (mounted) {
        if (result.isSuccess) {
          _showCredentialsDialog(username, password);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage ?? 'Error al crear empleado')),
          );
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showCredentialsDialog(String username, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Text('Credenciales Creadas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credenciales generadas exitosamente. Comparte esta información con el empleado:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildCredentialItem('Usuario', username),
            const SizedBox(height: 12),
            _buildCredentialItem('Contraseña', password),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El empleado debe cambiar la contraseña en su primer inicio de sesión',
                      style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Usuario: $username\nContraseña: $password'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credenciales copiadas al portapapeles')),
              );
            },
            child: const Text('Copiar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Volver a la página anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copiado')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear Credenciales de Empleado'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Se generarán credenciales temporales que el empleado deberá cambiar en su primer inicio de sesión.',
                        style: TextStyle(color: Colors.blue[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              const Text(
                'Nombre Completo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: Juan Pérez García',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              const Text(
                'Email Corporativo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'empleado@empresa.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Rol
              const Text(
                'Rol / Cargo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<EmployeeRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: EmployeeRoles.allRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            role.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            role.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (role) {
                    setState(() => _selectedRole = role);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Departamento (opcional)
              const Text(
                'Departamento (Opcional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  hintText: 'Ej: Operaciones - Zona Norte',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Permisos del rol seleccionado
              if (_selectedRole != null) ...[
                const Text(
                  'Permisos del Rol',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedRole!.permissions.map((permission) {
                      return Chip(
                        label: Text(
                          _formatPermission(permission),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.green[50],
                        side: BorderSide(color: Colors.green[200]!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Botón crear
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _createEmployeeCredentials,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Generar Credenciales',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPermission(String permission) {
    final map = {
      'view_all': 'Ver Todo',
      'edit_all': 'Editar Todo',
      'manage_employees': 'Gestionar Empleados',
      'manage_projects': 'Gestionar Proyectos',
      'view_metrics': 'Ver Métricas',
      'manage_resources': 'Gestionar Recursos',
      'approve_purchases': 'Aprobar Compras',
      'manage_finances': 'Gestionar Finanzas',
      'assign_tasks': 'Asignar Tareas',
      'manage_products': 'Gestionar Productos',
      'manage_services': 'Gestionar Servicios',
      'view_projects': 'Ver Proyectos',
      'view_own_tasks': 'Ver Tareas Propias',
      'report_progress': 'Reportar Progreso',
      'manage_documents': 'Gestionar Documentos',
    };
    return map[permission] ?? permission;
  }
}
