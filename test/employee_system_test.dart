import 'package:flutter_test/flutter_test.dart';
import '../lib/core/auth/employee_roles.dart';

void main() {
  group('Sistema de Roles de Empleados', () {
    test('Todos los roles deben tener IDs únicos', () {
      final roleIds = EmployeeRoles.allRoles.map((r) => r.id).toList();
      final uniqueIds = roleIds.toSet();
      
      expect(roleIds.length, equals(uniqueIds.length),
          reason: 'No debe haber IDs de roles duplicados');
    });

    test('CEO debe tener permisos de acceso total', () {
      final ceo = EmployeeRoles.ceo;
      
      expect(ceo.permissions.contains('view_all'), isTrue);
      expect(ceo.permissions.contains('edit_all'), isTrue);
      expect(ceo.permissions.contains('manage_employees'), isTrue);
    });

    test('Técnico debe tener permisos limitados', () {
      final technician = EmployeeRoles.technician;
      
      expect(technician.permissions.contains('view_own_tasks'), isTrue);
      expect(technician.permissions.contains('report_progress'), isTrue);
      expect(technician.permissions.contains('manage_employees'), isFalse);
      expect(technician.permissions.contains('view_all'), isFalse);
    });

    test('getById debe retornar rol correcto', () {
      final ceo = EmployeeRoles.getById('ceo');
      final technician = EmployeeRoles.getById('technician');
      final invalid = EmployeeRoles.getById('invalid_role');
      
      expect(ceo, isNotNull);
      expect(ceo?.name, equals('CEO / Director General'));
      expect(technician, isNotNull);
      expect(technician?.name, equals('Técnico / Operario'));
      expect(invalid, isNull);
    });

    test('hasPermission debe funcionar correctamente', () {
      // CEO tiene view_all, debería tener todos los permisos
      expect(EmployeeRoles.hasPermission('ceo', 'view_projects'), isTrue);
      expect(EmployeeRoles.hasPermission('ceo', 'manage_finances'), isTrue);
      
      // Técnico solo tiene permisos específicos
      expect(EmployeeRoles.hasPermission('technician', 'view_own_tasks'), isTrue);
      expect(EmployeeRoles.hasPermission('technician', 'manage_employees'), isFalse);
      
      // Rol inválido
      expect(EmployeeRoles.hasPermission('invalid', 'any_permission'), isFalse);
    });

    test('Todos los roles deben tener nombre y descripción', () {
      for (final role in EmployeeRoles.allRoles) {
        expect(role.name.isNotEmpty, isTrue,
            reason: 'Rol ${role.id} debe tener nombre');
        expect(role.description.isNotEmpty, isTrue,
            reason: 'Rol ${role.id} debe tener descripción');
        expect(role.color.isNotEmpty, isTrue,
            reason: 'Rol ${role.id} debe tener color');
        expect(role.permissions.isNotEmpty, isTrue,
            reason: 'Rol ${role.id} debe tener al menos un permiso');
      }
    });

    test('Los colores deben estar en formato hexadecimal', () {
      for (final role in EmployeeRoles.allRoles) {
        expect(role.color.startsWith('#'), isTrue,
            reason: 'Color de ${role.id} debe empezar con #');
        expect(role.color.length, equals(7),
            reason: 'Color de ${role.id} debe tener formato #RRGGBB');
      }
    });

    test('Debe haber exactamente 8 roles definidos', () {
      expect(EmployeeRoles.allRoles.length, equals(8));
      
      final expectedRoleIds = [
        'ceo', 'operations', 'finance', 'hr', 
        'sales', 'supervisor', 'technician', 'administrative'
      ];
      
      final actualRoleIds = EmployeeRoles.allRoles.map((r) => r.id).toList();
      
      for (final id in expectedRoleIds) {
        expect(actualRoleIds.contains(id), isTrue,
            reason: 'Debe existir el rol: $id');
      }
    });

    test('EmployeeRole serialización/deserialización', () {
      final ceo = EmployeeRoles.ceo;
      final json = ceo.toJson();
      final restored = EmployeeRole.fromJson(json);
      
      expect(restored.id, equals(ceo.id));
      expect(restored.name, equals(ceo.name));
      expect(restored.description, equals(ceo.description));
      expect(restored.color, equals(ceo.color));
      expect(restored.permissions, equals(ceo.permissions));
    });
  });

  group('Sistema de Invitaciones de Empleados', () {
    test('EmployeeInvitation debe validar expiración correctamente', () {
      final now = DateTime.now();
      
      // Invitación válida
      final validInvitation = EmployeeInvitation(
        id: 'inv1',
        companyId: 'comp1',
        companyName: 'Test Company',
        employeeName: 'Test Employee',
        employeeEmail: 'test@test.com',
        roleId: 'technician',
        tempPassword: 'TEMP123',
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        isUsed: false,
      );
      
      expect(validInvitation.isExpired, isFalse);
      expect(validInvitation.isValid, isTrue);
      
      // Invitación expirada
      final expiredInvitation = EmployeeInvitation(
        id: 'inv2',
        companyId: 'comp1',
        companyName: 'Test Company',
        employeeName: 'Test Employee',
        employeeEmail: 'test2@test.com',
        roleId: 'technician',
        tempPassword: 'TEMP123',
        createdAt: now.subtract(const Duration(days: 10)),
        expiresAt: now.subtract(const Duration(days: 3)),
        isUsed: false,
      );
      
      expect(expiredInvitation.isExpired, isTrue);
      expect(expiredInvitation.isValid, isFalse);
      
      // Invitación ya usada
      final usedInvitation = EmployeeInvitation(
        id: 'inv3',
        companyId: 'comp1',
        companyName: 'Test Company',
        employeeName: 'Test Employee',
        employeeEmail: 'test3@test.com',
        roleId: 'technician',
        tempPassword: 'TEMP123',
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        isUsed: true,
      );
      
      expect(usedInvitation.isUsed, isTrue);
      expect(usedInvitation.isValid, isFalse);
    });

    test('EmployeeInvitation serialización/deserialización', () {
      final now = DateTime.now();
      final invitation = EmployeeInvitation(
        id: 'inv1',
        companyId: 'comp1',
        companyName: 'Test Company',
        employeeName: 'Test Employee',
        employeeEmail: 'test@test.com',
        roleId: 'technician',
        department: 'IT',
        tempPassword: 'TEMP123',
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        isUsed: false,
      );
      
      final json = invitation.toJson();
      final restored = EmployeeInvitation.fromJson(json);
      
      expect(restored.id, equals(invitation.id));
      expect(restored.companyId, equals(invitation.companyId));
      expect(restored.companyName, equals(invitation.companyName));
      expect(restored.employeeName, equals(invitation.employeeName));
      expect(restored.employeeEmail, equals(invitation.employeeEmail));
      expect(restored.roleId, equals(invitation.roleId));
      expect(restored.department, equals(invitation.department));
      expect(restored.tempPassword, equals(invitation.tempPassword));
      expect(restored.isUsed, equals(invitation.isUsed));
    });
  });
}
