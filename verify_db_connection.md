# ✅ Verificación de Conexión con Supabase

## Estado Actual

### 1. Dependencias ✅
- ✅ Flutter packages instalados correctamente
- ✅ `supabase_flutter: ^2.5.0` 
- ✅ `flutter_dotenv: ^5.1.0`
- ✅ `get_it: ^7.6.0`

### 2. Archivo .env ✅
```
SUPABASE_URL=https://ssyhtymdfkcvindyhyxy.supabase.co
SUPABASE_ANON_KEY=eyJhbG... (configurado)
```

### 3. Próximo Paso: Verificar Tablas en Supabase

Para verificar que la conexión funciona correctamente, vamos a:

## Opción 1: Ejecutar la App (RECOMENDADO)

```bash
# En Windows/Android
flutter run

# En Web
flutter run -d chrome
```

Esto iniciará la app y verás:
- ✅ Si carga la pantalla de login = Conexión OK
- ❌ Si muestra error de conexión = Revisar credenciales

## Opción 2: Verificar desde Supabase Dashboard

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto `ssyhtymdfkcvindyhyxy`
3. Ve a **Table Editor** (izquierda)
4. Verifica que existan estas tablas:
   - ✅ `users`
   - ✅ `posts`
   - ✅ `products`
   - ✅ `services`
   - ✅ `groups`
   - ✅ `group_members`
   - ⚠️ `messages` (si no existe, ejecutar `additional_tables.sql`)
   - ⚠️ `notifications` (si no existe, ejecutar `notifications_table.sql`)

## Checklist de Tablas Necesarias

### Tablas Base (supabase_schema.sql)
- [ ] users
- [ ] employee_roles  
- [ ] posts
- [ ] post_likes
- [ ] products
- [ ] services
- [ ] groups
- [ ] group_members

### Tablas Adicionales (additional_tables.sql)
- [ ] favorites
- [ ] conversations
- [ ] messages
- [ ] projects
- [ ] transactions

### Tabla de Notificaciones (notifications_table.sql)
- [ ] notifications

## Scripts SQL a Ejecutar

Si faltan tablas, ejecuta en orden:

1. **supabase_schema.sql** - Tablas base
2. **additional_tables.sql** - Funcionalidades extendidas  
3. **notifications_table.sql** - Sistema de notificaciones
4. **profile_expansion.sql** - Campos adicionales en perfil

## Cómo Ejecutar Scripts SQL en Supabase

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto
3. Click en **SQL Editor** (menú izquierdo)
4. Click en **+ New Query**
5. Copia y pega el contenido del archivo .sql
6. Click en **Run** (o F5)
7. Verifica que diga "Success"

## Cuentas de Prueba

Una vez verificada la conexión, puedes probar con estas cuentas:

### 🏢 Empresa
- Email: `empresa@test.com`
- Password: `test123`

### 👔 Empleado CEO
- Email: `maria.gerente@test.com`  
- Password: `test123`
- ⚠️ Requiere cambiar contraseña en primer login

### 🧑 Usuario Individual
- Email: `juan@test.com`
- Password: `test123`

## Siguiente Paso

¿Qué prefieres hacer ahora?

**A) Ejecutar la app** para verificar visualmente
```bash
flutter run
```

**B) Revisar las tablas** en Supabase Dashboard primero

**C) Ejecutar las migraciones SQL** si faltan tablas

Dime cuál opción prefieres y continuamos 🚀
