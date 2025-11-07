# Instrucciones para Configurar las Tablas en Supabase

## 📋 Tablas Necesarias

Este proyecto requiere las siguientes tablas adicionales en Supabase:

### ✅ Ya creadas (del archivo `supabase_schema.sql`):
- `users` - Usuarios del sistema
- `employee_roles` - Roles de empleados
- `posts` - Publicaciones de comunidad
- `post_likes` - Likes en posts
- `products` - Productos del marketplace
- `services` - Servicios ofrecidos
- `groups` - Grupos de usuarios
- `group_members` - Miembros de grupos

### 🆕 **NUEVAS TABLAS A CREAR** (del archivo `additional_tables.sql`):

#### 1. **favorites** - Sistema de Favoritos
- Permite marcar productos y servicios como favoritos
- Campos principales: `user_id`, `product_id`, `service_id`
- Incluye triggers automáticos para actualizar contadores

#### 2. **conversations** - Conversaciones de Chat
- Conversaciones directas entre dos usuarios
- Campos principales: `user1_id`, `user2_id`, `last_message_at`, contadores de no leídos
- Sistema de unicidad para evitar conversaciones duplicadas

#### 3. **messages** - Mensajes de Chat
- Mensajes dentro de conversaciones
- Campos principales: `conversation_id`, `sender_id`, `content`, `is_read`
- Soporte para mensajes de texto, imágenes y archivos
- **Incluye Realtime** para chat en tiempo real

#### 4. **projects** - Proyectos de Empresas
- Proyectos con progreso, presupuesto y equipo
- Campos principales: `company_id`, `name`, `status`, `progress`, `budget_amount`
- Para métricas del dashboard de empresas

#### 5. **transactions** - Transacciones Financieras
- Ingresos y gastos de empresas
- Campos principales: `company_id`, `type`, `amount`, `category`, `transaction_date`
- Para métricas financieras del dashboard

## 🚀 Pasos para Crear las Tablas

### Opción 1: Ejecutar el script completo (RECOMENDADO)
```sql
-- 1. Primero ejecuta: database/supabase_schema.sql (si no está creado)
-- 2. Luego ejecuta: database/additional_tables.sql
```

### Opción 2: Usar la UI de Supabase
1. Ir a tu proyecto en Supabase
2. Ir a **SQL Editor**
3. Copiar y pegar el contenido de `database/additional_tables.sql`
4. Ejecutar el script

## ⚙️ Configuraciones Importantes

### Row Level Security (RLS)
Todas las tablas tienen **RLS habilitado** con políticas de seguridad:
- ✅ `favorites`: Los usuarios solo pueden gestionar sus propios favoritos
- ✅ `conversations`: Solo participantes pueden ver la conversación
- ✅ `messages`: Solo participantes pueden ver/enviar mensajes
- ✅ `projects`: Solo la empresa y sus empleados pueden ver proyectos
- ✅ `transactions`: Solo empresa y roles financieros pueden ver transacciones

### Triggers Automáticos
- ✅ `updated_at` se actualiza automáticamente en todas las tablas
- ✅ Contadores de favoritos se actualizan automáticamente
- ✅ Conversaciones se actualizan cuando llegan mensajes nuevos
- ✅ Contadores de mensajes no leídos se gestionan automáticamente

### Índices Optimizados
Todas las tablas tienen índices para búsquedas rápidas:
- Búsquedas por usuario
- Búsquedas por fecha
- Búsquedas por relaciones (conversaciones, proyectos, etc.)

## 📊 Datos de Prueba (Opcional)

Después de crear las tablas, puedes insertar datos de prueba para desarrollo:

```sql
-- Ejemplo: Crear un proyecto de prueba
INSERT INTO projects (company_id, name, description, status, progress, budget_amount)
VALUES (
  '00000000-0000-0000-0000-000000000001', -- ID de la empresa de prueba
  'Exploración Mina Sur',
  'Proyecto de exploración y análisis geológico',
  'in_progress',
  65.0,
  500000.00
);

-- Ejemplo: Crear transacciones de prueba
INSERT INTO transactions (company_id, type, category, amount, description, transaction_date)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'income', 'Ventas', 485200.00, 'Ingresos del mes', '2025-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'expense', 'Operaciones', 245800.00, 'Gastos operativos', '2025-01-01');
```

## 🔄 Realtime para Mensajería

Para habilitar Realtime en la tabla `messages`:
1. Ve a **Database** → **Replication**
2. Busca la tabla `messages`
3. Habilita **Realtime**
4. También habilita Realtime en `conversations` para notificaciones

## ✅ Verificación

Después de ejecutar el script, verifica que tienes:
- [x] 5 nuevas tablas creadas
- [x] RLS habilitado en todas
- [x] Políticas de seguridad configuradas
- [x] Triggers funcionando
- [x] Índices creados
- [x] Realtime habilitado (messages y conversations)

## 🆘 Problemas Comunes

### Error: "function update_updated_at_column does not exist"
**Solución**: Primero ejecuta `supabase_schema.sql` que contiene esta función

### Error: "relation products does not exist"
**Solución**: Asegúrate de ejecutar primero `supabase_schema.sql`

### Los mensajes no llegan en tiempo real
**Solución**: Habilita Realtime en las tablas `messages` y `conversations` desde la UI

---

¿Necesitas ayuda? Pregúntame cualquier duda sobre las tablas.
