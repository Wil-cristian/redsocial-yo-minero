# YoMinero - Red Social Minera

Aplicación Flutter modularizada con capas simples (features/domain/data) y paleta semántica. Sistema completo de roles y permisos para empleados.

## 🔑 Credenciales de Prueba

Las siguientes cuentas de prueba están precargadas en la aplicación para testing:

### 🏢 Cuenta de Empresa (Admin)
- **Email:** `empresa@test.com`
- **Password:** `test123`
- **Tipo:** Company
- **Funcionalidad:** Puede crear empleados con roles específicos

### 👔 Empleado CEO (Primer Login)
- **Email:** `maria.gerente@test.com`
- **Password:** `test123`
- **Rol:** CEO / Director General
- **Departamento:** Gerencia General
- **⚠️ Importante:** Debe cambiar contraseña en el primer inicio de sesión
- **Dashboard:** Acceso completo (Métricas, Empleados, Proyectos, Finanzas, Recursos, Mensajes)

### 👷 Empleado Técnico
- **Email:** `carlos.tecnico@test.com`
- **Password:** `test123`
- **Rol:** Técnico
- **Departamento:** Operaciones - Zona Norte
- **Dashboard:** Acceso limitado (Mis Tareas, Reportar, Capacitación, Perfil)

### 🧑 Usuario Individual
- **Email:** `juan@test.com`
- **Password:** `test123`
- **Tipo:** Individual
- **Dashboard:** Vista de minero independiente

---

## Arquitectura
- core/: tema, routing, auth y localizador sencillo.
- features/: cada dominio (posts, products, services) con data + domain.
- shared/models: modelos compartidos exportados vía barrel.

## Repositorios
Se usan implementaciones en memoria para desarrollo rápido. Sustituir por fuentes remotas o SQLite conforme crezca.

## Colores
`AppColors` define tokens semánticos (primary, surface, success, info, etc.). Usa esos valores en lugar de hex directos.

## Tests
Ejemplo: `test/post_repository_test.dart` valida la lógica de likes únicos.

## Próximos pasos sugeridos
1. Migrar SDK a >=3.3 y habilitar records/patterns.
2. Integrar gestor de estado (Provider, Riverpod) en lugar de locator manual.
3. Persistencia real para likes y datos.
4. Tests widget para navegación.
# yominero

A new Flutter project.
