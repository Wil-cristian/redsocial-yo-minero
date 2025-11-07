# YoMinero - Red Social para la Industria Minera

## Descripción del Proyecto
YoMinero es una plataforma social especializada para profesionales, empresas y trabajadores de la industria minera. Permite conectar, compartir conocimientos, buscar y ofrecer servicios, y gestionar grupos de trabajo.

## Arquitectura

### Stack Tecnológico
- **Frontend**: Flutter Web 3.32.0
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Deployment**: Replit

### Estructura del Proyecto
```
lib/
├── core/
│   ├── auth/
│   │   └── supabase_auth_service.dart    # Servicio de autenticación con Supabase
│   ├── groups/
│   │   ├── group_repository.dart         # Interfaz abstracta para grupos
│   │   └── supabase_group_repository.dart # Implementación con Supabase
│   ├── di/
│   │   └── locator.dart                  # Dependency injection (get_it)
│   └── supabase/
│       ├── supabase_service.dart         # Cliente Supabase singleton
│       └── supabase_config.dart          # Configuración de Supabase
├── features/
│   └── services/
│       ├── domain/
│       │   └── service_repository.dart   # Interfaz abstracta para servicios
│       └── data/
│           ├── supabase_service_repository.dart # Implementación con Supabase
│           └── in_memory_service_repository.dart # Implementación legacy (mock data)
├── shared/
│   └── models/
│       ├── user.dart                     # Modelo de usuario (local)
│       ├── service.dart                  # Modelo de servicio con fromJson/toJson
│       ├── group.dart                    # Modelo de grupo con fromJson/toJson
│       ├── product.dart                  # Modelo de producto
│       └── post.dart                     # Modelo de publicación
└── pages/
    ├── login_page.dart
    ├── services_page.dart                # Página de servicios
    ├── products_page.dart                # Página de productos
    ├── groups_page.dart                  # Página de grupos
    ├── group_detail_page.dart            # Detalle de grupo
    └── ... (otras páginas)
```

## Estado Actual del Proyecto (Nov 7, 2025)

### ✅ Completado

#### 1. Migración a Supabase - Backend
- [x] Autenticación con Supabase implementada
- [x] Registro de usuarios con tipos de cuenta (individual, worker, company)
- [x] Inicio de sesión funcional
- [x] Persistencia de sesión entre recargas
- [x] Servicio `SupabaseAuthService` con `currentUserModel` helper

#### 2. Repositorios Conectados a Supabase
- [x] **SupabaseServiceRepository**: CRUD completo para servicios
  - create, update, delete, getById, getAll
  - Búsqueda por categoría y tags
  - Métodos asíncronos correctamente implementados
  - fromJson/toJson en modelo Service
- [x] **SupabaseGroupRepository**: Gestión de grupos
  - create, join, leave, getById, getAll
  - Gestión de miembros con protección contra duplicados
  - Contadores de miembros sincronizados correctamente
  - fromJson/toJson en modelo Group

#### 3. Refactorización Arquitectónica (Opción B)
- [x] Eliminado `auth_service.dart` legacy
- [x] Todas las referencias actualizadas a `SupabaseAuthService`
- [x] Uso correcto de `currentUserProfile` (Map) vs `currentUser` (Supabase User)
- [x] Helper `currentUserModel` para obtener modelo User local
- [x] Corrección de referencias en 15+ archivos
- [x] Compilación exitosa sin errores

#### 4. Integración con UI
- [x] Páginas actualizadas para usar repositorios de Supabase
- [x] MatchEngine funciona con `currentUserModel`
- [x] Creación de productos/servicios usa `currentUserProfile`

### ⚠️ Pendientes / TODOs

#### 1. Funcionalidades No Implementadas
- [ ] **Editar Perfil**: Método para actualizar perfil de usuario en Supabase
- [ ] **Favoritos**: Tabla y lógica para marcar servicios/productos favoritos
- [ ] **Mensajería**: Sistema de mensajes en tiempo real con Supabase Realtime
- [ ] **Métricas Dashboard**: Estadísticas y analytics del usuario

#### 2. Repositorios Pendientes
- [ ] ProductRepository con Supabase (actualmente usa datos mock)
- [ ] PostRepository con Supabase (actualmente usa datos mock)
- [ ] FavoritesRepository (requiere tabla en BD)

#### 3. Mejoras Técnicas
- [ ] Manejo de errores más robusto
- [ ] Loading states en todas las operaciones async
- [ ] Refresh de datos después de crear/actualizar
- [ ] Tests unitarios e integración

## Base de Datos

### Esquema Actual (Supabase)
Ver: `database/supabase_schema.sql`

**Tablas Principales:**
- `users` - Perfiles de usuario
- `services` - Servicios ofrecidos
- `groups` - Grupos de trabajo
- `group_members` - Relación usuarios-grupos

**Funciones RPC:**
- `increment_group_members(group_id)` - Incrementa contador de miembros
- `decrement_group_members(group_id)` - Decrementa contador de miembros

### Tablas Faltantes
- `products` - Productos del marketplace
- `posts` - Publicaciones de la comunidad
- `favorites` - Favoritos de usuarios
- `messages` - Sistema de mensajería
- `conversations` - Conversaciones

## Configuración

### Variables de Entorno
Archivo: `.env`
```
SUPABASE_URL=https://wrshdeghtdcrgeqbqihh.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

### Dependency Injection
El proyecto usa `get_it` para DI. Configuración en `lib/core/di/locator.dart`:
- `SupabaseAuthService` (singleton)
- `ServiceRepository` (usa SupabaseServiceRepository)
- `GroupRepository` (usa SupabaseGroupRepository)
- `PostRepository` (usa InMemoryPostRepository - temporal)

## Patrones de Diseño

### Repository Pattern
Cada dominio tiene una interfaz abstracta y múltiples implementaciones:
- `ServiceRepository` → `SupabaseServiceRepository` | `InMemoryServiceRepository`
- `GroupRepository` → `SupabaseGroupRepository` | `InMemoryGroupRepository`

### Singleton Pattern
- `SupabaseAuthService.instance`
- `supabase` client (desde `supabase_service.dart`)

## Problemas Conocidos

1. **Editar perfil no funcional**: El método `updateUser` no existe en `SupabaseAuthService`. Requiere implementación.
2. **Servicios de usuario**: `ManageServicesPage` no actualiza servicios en Supabase (comentado temporalmente).
3. **Datos mock**: Muchas features aún usan datos en memoria en lugar de Supabase.

## Próximos Pasos Recomendados

1. **Implementar ProductRepository con Supabase**
   - Crear tabla `products` en Supabase
   - Implementar SupabaseProductRepository
   - Actualizar ProductsPage para usar repositorio real

2. **Implementar actualización de perfil**
   - Agregar método `updateProfile` a SupabaseAuthService
   - Implementar en EditProfilePage
   - Permitir actualización de avatar, bio, etc.

3. **Sistema de Favoritos**
   - Crear tabla `favorites` en Supabase
   - Implementar FavoritesRepository
   - Agregar UI para marcar/desmarcar favoritos

4. **Mensajería con Realtime**
   - Crear tablas `conversations` y `messages`
   - Implementar listeners de Supabase Realtime
   - UI para chat en tiempo real

## Notas de Desarrollo

- **Compilación**: `flutter build web --release`
- **Servidor local**: El workflow sirve desde `build/web` en puerto 5000
- **Hot reload**: No disponible en web release, requiere rebuild completo
- **Arquitectura limpia**: Priorizar interfaces sobre implementaciones concretas

## Historial de Cambios Importantes

### 2025-11-07
- ✅ Refactorización completa de autenticación (Opción B)
- ✅ Migración de ServiceRepository y GroupRepository a Supabase
- ✅ Corrección de 15+ archivos para usar SupabaseAuthService correctamente
- ✅ Implementación de métodos fromJson/toJson en modelos
- ✅ Protección de contadores de miembros en grupos
- ✅ Compilación exitosa después de arquitectura refactoring

---

**Última actualización**: 7 de noviembre de 2025
