# 🚀 Configuración de Supabase para YoMinero

## Paso 1: Crear archivo .env

1. Copia el archivo `.env.example` y renómbralo a `.env`
2. Ve a tu proyecto en Supabase: https://app.supabase.com
3. Ve a **Settings** → **API**
4. Copia tus credenciales:

```env
SUPABASE_URL=https://tu-proyecto-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **IMPORTANTE:** El archivo `.env` NO se sube a GitHub (está en .gitignore)

## Paso 2: Crear el esquema de base de datos

1. Ve a tu proyecto en Supabase
2. Abre el **SQL Editor** (icono de base de datos en el menú lateral)
3. Crea una nueva query
4. Copia **TODO** el contenido del archivo `supabase_schema.sql`
5. Pega en el editor y haz click en **Run** (▶️)

Esto creará:
- ✅ 7 tablas principales (users, posts, products, services, groups, etc.)
- ✅ 8 roles de empleados predefinidos
- ✅ Índices para búsquedas rápidas
- ✅ Triggers automáticos (likes, updated_at, etc.)
- ✅ Row Level Security (RLS) configurado

## Paso 3: Verificar que todo funcionó

En el SQL Editor, ejecuta:

```sql
-- Ver las tablas creadas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Ver los roles de empleados
SELECT id, name FROM employee_roles;
```

Deberías ver:
- ✅ 7+ tablas
- ✅ 8 roles de empleados

## Paso 4: Configurar Autenticación

1. Ve a **Authentication** → **Providers** en tu dashboard de Supabase
2. Asegúrate de que **Email** esté habilitado
3. **IMPORTANTE:** Desactiva "Confirm email" para desarrollo:
   - Busca la opción **"Enable email confirmations"**
   - **Desactívala** (toggle a OFF/gris)
   - Esto permite crear usuarios sin verificar email

Esto es necesario para desarrollo y pruebas rápidas. En producción deberás activarlo.

## ¿Problemas?

### Error: "extension uuid-ossp does not exist"
- Ve a **Database** → **Extensions**
- Busca `uuid-ossp` y habilítala

### Error: "permission denied"
- Verifica que estés usando el SQL Editor como administrador
- No uses el rol `anon` para ejecutar el schema

### El esquema se ejecutó pero no veo datos
- Es normal, las tablas están vacías
- Los datos de prueba están comentados en el SQL
- Se crearán cuando uses la app

## Siguiente Paso

Una vez completado todo, ejecuta:

```bash
flutter pub get
flutter run -d chrome
```

La app se conectará automáticamente a Supabase. 🎉
