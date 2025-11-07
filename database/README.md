# YoMinero - Migraciones de Base de Datos

Este directorio contiene los scripts SQL para configurar y actualizar la base de datos de Supabase.

## Scripts Disponibles

### 1. `supabase_schema.sql`
**Descripción**: Esquema inicial con las tablas principales.

**Tablas incluidas**:
- `users` - Perfiles de usuario
- `services` - Servicios ofrecidos
- `groups` - Grupos de trabajo
- `group_members` - Relación usuarios-grupos

**Ejecutar**: Una sola vez durante la configuración inicial del proyecto.

### 2. `additional_tables.sql`
**Descripción**: Tablas adicionales para funcionalidades extendidas.

**Tablas incluidas**:
- `products` - Marketplace de productos
- `posts` - Publicaciones de la comunidad
- `favorites` - Favoritos de usuarios
- `conversations` - Conversaciones entre usuarios
- `messages` - Mensajes de chat
- `projects` - Proyectos de usuarios/empresas
- `transactions` - Transacciones financieras

**Ejecutar**: Después de `supabase_schema.sql`.

### 3. `profile_expansion.sql`
**Descripción**: Ampliación del esquema de perfil de usuario con campos profesionales.

**Campos agregados**:
- `phone` - Número de teléfono de contacto
- `profession` - Profesión o título profesional
- `company` - Nombre de la empresa donde trabaja
- `job_title` - Cargo o puesto actual
- `website` - Sitio web personal o de empresa
- `location` - Ubicación en formato JSON
- `birth_date` - Fecha de nacimiento
- `experience_level` - Nivel de experiencia (beginner, intermediate, advanced, expert)
- `specializations` - Lista de especializaciones en minería
- `interests` - Lista de intereses o áreas de interés

**Ejecutar**: Después de `additional_tables.sql`.

### 4. `notifications_table.sql` ⭐ NUEVO
**Descripción**: Sistema de notificaciones en tiempo real.

**Tabla incluida**:
- `notifications` - Notificaciones de usuarios

**Funcionalidades**:
- Notificaciones en tiempo real con Supabase Realtime
- Tipos: message, group_invite, product_liked, service_request, new_follower, comment, mention
- Trigger automático para nuevos mensajes
- Contador de no leídas
- Políticas RLS para seguridad

**Trigger incluido**:
- `notify_new_message()` - Crea notificación cuando llega un nuevo mensaje

**Ejecutar**: Después de `profile_expansion.sql`.

## Cómo Ejecutar las Migraciones

### Opción 1: Dashboard de Supabase (Recomendado)

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Click en "SQL Editor" en el menú lateral
3. Click en "+ New Query"
4. Copia y pega el contenido del archivo SQL
5. Click en "Run" para ejecutar

### Opción 2: CLI de Supabase

```bash
# Instalar Supabase CLI si no lo tienes
npm install -g supabase

# Opción A: Ejecutar desde archivo directamente
supabase db execute --file database/profile_expansion.sql

# Opción B: Ejecutar el contenido como SQL
supabase db execute --sql "$(cat database/profile_expansion.sql)"

# Opción C: Usar psql directamente con las credenciales de tu proyecto
psql "postgres://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres" \
  -f database/profile_expansion.sql
```

**Nota**: Para migraciones versionadas con control de versiones:
```bash
# Crear una nueva migración
supabase migration new profile_expansion

# Copiar el contenido de profile_expansion.sql al archivo generado en supabase/migrations/
# Luego aplicar todas las migraciones pendientes
supabase db push
```

## Orden de Ejecución Recomendado

Para una configuración completa desde cero:

```
1. supabase_schema.sql          # Esquema base
2. additional_tables.sql        # Tablas adicionales
3. profile_expansion.sql        # Expansión de perfiles
4. notifications_table.sql      # Sistema de notificaciones
```

## Verificar Migraciones

Después de ejecutar cada script, verifica que las tablas se crearon correctamente:

```sql
-- Ver todas las tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Ver columnas de la tabla users
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';
```

## Row Level Security (RLS)

Todos los scripts incluyen políticas de RLS para proteger los datos. Asegúrate de que RLS esté habilitado:

```sql
-- Verificar que RLS esté habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

## Rollback

Si necesitas revertir la migración de `profile_expansion.sql`:

```sql
-- Eliminar campos agregados
ALTER TABLE users
DROP COLUMN IF EXISTS phone,
DROP COLUMN IF EXISTS profession,
DROP COLUMN IF EXISTS company,
DROP COLUMN IF EXISTS job_title,
DROP COLUMN IF EXISTS website,
DROP COLUMN IF EXISTS location,
DROP COLUMN IF EXISTS birth_date,
DROP COLUMN IF EXISTS experience_level,
DROP COLUMN IF EXISTS specializations,
DROP COLUMN IF EXISTS interests;

-- Eliminar índices
DROP INDEX IF EXISTS idx_users_profession;
DROP INDEX IF EXISTS idx_users_company;
DROP INDEX IF EXISTS idx_users_experience_level;
DROP INDEX IF EXISTS idx_users_specializations;
DROP INDEX IF EXISTS idx_users_interests;
```

## Notas Importantes

- ⚠️ Siempre haz un backup antes de ejecutar migraciones en producción
- 🔒 Verifica que las políticas de RLS estén configuradas correctamente
- 🧪 Prueba las migraciones en un ambiente de desarrollo primero
- 📊 Monitorea el rendimiento después de agregar índices

## Soporte

Si encuentras problemas con las migraciones:

1. Verifica los logs en Supabase Dashboard > Database > Logs
2. Revisa que tengas los permisos necesarios
3. Asegúrate de que el proyecto de Supabase esté activo

---

**Última actualización**: 7 de noviembre de 2025
