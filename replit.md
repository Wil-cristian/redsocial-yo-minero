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
│   ├── services/
│   │   ├── domain/
│   │   │   └── service_repository.dart   # Interfaz abstracta
│   │   └── data/
│   │       └── supabase_service_repository.dart # Implementación Supabase
│   ├── products/
│   │   ├── domain/
│   │   │   └── product_repository.dart   # Interfaz abstracta
│   │   └── data/
│   │       └── supabase_product_repository.dart # Implementación Supabase
│   ├── posts/
│   │   ├── domain/
│   │   │   └── post_repository.dart      # Interfaz abstracta
│   │   └── data/
│   │       └── supabase_post_repository.dart # Implementación Supabase
│   ├── favorites/
│   │   └── data/
│   │       └── supabase_favorite_repository.dart # Favoritos
│   ├── messaging/
│   │   └── data/
│   │       └── supabase_messaging_repository.dart # Chat con Realtime
│   └── metrics/
│       └── data/
│           └── supabase_metrics_repository.dart # Dashboard y analytics
├── shared/
│   └── models/
│       ├── user.dart                     # Modelo de usuario
│       ├── service.dart                  # Modelo de servicio
│       ├── group.dart                    # Modelo de grupo
│       ├── product.dart                  # Modelo de producto
│       ├── post.dart                     # Modelo de publicación
│       ├── favorite.dart                 # Modelo de favorito
│       ├── conversation.dart             # Modelo de conversación
│       ├── message.dart                  # Modelo de mensaje
│       ├── project.dart                  # Modelo de proyecto
│       └── transaction.dart              # Modelo de transacción
└── pages/
    ├── login_page.dart
    ├── services_page.dart                # Página de servicios
    ├── products_page.dart                # Página de productos
    ├── groups_page.dart                  # Página de grupos
    ├── company_metrics_page.dart         # Dashboard con métricas reales
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
- [x] **SupabaseProductRepository**: Marketplace completo
  - CRUD completo (create, update, delete, getById, getAll)
  - Búsqueda por categoría, vendedor, query
  - JOIN con users para info del vendedor
  - Modelo compatible con código legacy
- [x] **SupabasePostRepository**: Feed social
  - getAll() con información del autor
  - fromJson/toJson implementados
- [x] **SupabaseFavoriteRepository**: Sistema de favoritos
  - Marcar/desmarcar productos y servicios como favoritos
  - Obtener favoritos por tipo (producto/servicio)
  - Toggle de favoritos en UI
- [x] **MessagingRepository**: Chat en tiempo real
  - Gestión de conversaciones
  - Envío y recepción de mensajes
  - Supabase Realtime para chat instantáneo
  - Triggers de BD para actualización automática
- [x] **MetricsRepository**: Analytics y dashboard
  - Proyectos con estados (planning, in_progress, completed, etc.)
  - Transacciones (ingresos, gastos)
  - Métricas calculadas por período (week, month, quarter, year)

#### 3. Refactorización Arquitectónica (Opción B)
- [x] Eliminado `auth_service.dart` legacy
- [x] Todas las referencias actualizadas a `SupabaseAuthService`
- [x] Uso correcto de `currentUserProfile` (Map) vs `currentUser` (Supabase User)
- [x] Helper `currentUserModel` para obtener modelo User local
- [x] Corrección de referencias en 20+ archivos
- [x] Compilación exitosa sin errores

#### 4. Integración con UI
- [x] Páginas actualizadas para usar repositorios de Supabase
- [x] MatchEngine funciona con `currentUserModel`
- [x] Creación de productos/servicios usa `currentUserProfile`
- [x] Dashboard de métricas muestra datos reales
- [x] Selector de período funcional (semana, mes, trimestre, año)

### ⚠️ Pendientes / TODOs

#### 1. Funcionalidades Pendientes
- [ ] **Editar Perfil**: Método para actualizar perfil de usuario en Supabase
- [ ] **UI de Chat**: Páginas de mensajería usando MessagingRepository
- [ ] **Notificaciones**: Sistema de notificaciones push

#### 2. Mejoras Técnicas
- [ ] Manejo de errores más robusto con try-catch
- [ ] Loading states en todas las operaciones async
- [ ] Refresh automático de datos después de crear/actualizar
- [ ] Tests unitarios e integración
- [ ] Implementar ManageServicesPage para editar servicios

## Base de Datos

### Esquema Actual (Supabase)
Ver: `database/supabase_schema.sql` y `database/additional_tables.sql`

**Tablas Implementadas:**
- `users` - Perfiles de usuario
- `services` - Servicios ofrecidos
- `groups` - Grupos de trabajo
- `group_members` - Relación usuarios-grupos
- `products` - Productos del marketplace
- `posts` - Publicaciones de la comunidad
- `favorites` - Favoritos de usuarios (productos y servicios)
- `conversations` - Conversaciones entre usuarios
- `messages` - Mensajes de chat (con Realtime habilitado)
- `projects` - Proyectos de usuarios/empresas
- `transactions` - Transacciones financieras (ingresos/gastos)

**Funciones RPC:**
- `increment_group_members(group_id)` - Incrementa contador de miembros
- `decrement_group_members(group_id)` - Decrementa contador de miembros

**Triggers:**
- `update_conversation_on_message` - Actualiza conversaciones cuando se envía un mensaje
- `update_updated_at` - Actualiza timestamp de updated_at automáticamente

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

**Primera Sesión:**
- ✅ Refactorización completa de autenticación (Opción B)
- ✅ Migración de ServiceRepository y GroupRepository a Supabase
- ✅ Corrección de 15+ archivos para usar SupabaseAuthService correctamente
- ✅ Implementación de métodos fromJson/toJson en modelos
- ✅ Protección de contadores de miembros en grupos
- ✅ Compilación exitosa después de arquitectura refactoring

**Segunda Sesión:**
- ✅ Creación de esquema SQL adicional con 5 nuevas tablas (favorites, conversations, messages, projects, transactions)
- ✅ Implementación completa de Sistema de Favoritos
- ✅ Migración de Products a Supabase con modelo actualizado
- ✅ Implementación de Proyectos y Transacciones para métricas
- ✅ Dashboard de Company Metrics conectado a datos reales de Supabase
- ✅ Sistema de Mensajería con Realtime implementado
- ✅ Triggers de base de datos para actualización automática de conversaciones
- ✅ Todos los repositorios registrados en locator.dart
- ✅ Compilación exitosa de toda la aplicación web

---

**Última actualización**: 7 de noviembre de 2025
