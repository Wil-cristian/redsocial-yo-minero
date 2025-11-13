# 🚀 INSTRUCCIONES: Ejecutar Script de Solicitudes de Conexión

## 📋 Paso 1: Acceder a Supabase

1. Ve a https://supabase.com
2. Inicia sesión en tu proyecto
3. Ve a la sección **SQL Editor** (icono de base de datos en el menú lateral)

## 📝 Paso 2: Ejecutar el Script

1. Abre el archivo: `database/connection_requests.sql`
2. Copia **TODO** el contenido del archivo
3. Pégalo en el SQL Editor de Supabase
4. Haz clic en el botón **"RUN"** o presiona `Ctrl+Enter`

## ✅ Paso 3: Verificar la Creación

Deberías ver un mensaje de éxito indicando que se crearon:
- ✅ Tabla `connection_requests`
- ✅ Tabla `connections`
- ✅ Índices para búsquedas rápidas
- ✅ Triggers automáticos
- ✅ Políticas RLS (seguridad)
- ✅ Vistas útiles

## 🔍 Paso 4: Confirmar (Opcional)

Para verificar que todo se creó correctamente, ejecuta esta consulta:

```sql
-- Ver las tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('connection_requests', 'connections');

-- Ver los índices
SELECT indexname 
FROM pg_indexes 
WHERE tablename IN ('connection_requests', 'connections');
```

## 🎯 Paso 5: Reiniciar la App

Una vez ejecutado el script:
1. Detén la aplicación Flutter (si está corriendo)
2. Ejecuta: `flutter run -d chrome`
3. ¡Listo! El sistema de solicitudes ya debería funcionar

## 🐛 Si hay errores:

**Error: "relation already exists"**
- ✅ Normal, significa que la tabla ya existe (está usando IF NOT EXISTS)

**Error: "users table not found"**
- ❌ Necesitas asegurarte de que la tabla `users` existe primero
- Ejecuta primero: `database/supabase_schema.sql`

**Error: "permission denied"**
- ❌ Verifica que tienes permisos de administrador en Supabase
- O ejecuta desde el SQL Editor como administrador

## 📱 Funcionalidades Disponibles:

Una vez ejecutado el script, tendrás:

1. **Buscar Usuarios** → Ver botón "Conectar"
2. **Enviar Solicitudes** → Estado "Pendiente"
3. **Ver Solicitudes Recibidas** → Tab "Recibidas" con botones Aceptar/Rechazar
4. **Ver Solicitudes Enviadas** → Tab "Enviadas" con botón Cancelar
5. **Chatear** → Solo disponible después de aceptar solicitud

## 🎨 Características del Sistema:

- 🔒 **Seguridad RLS**: Cada usuario solo ve sus propias solicitudes
- ⚡ **Triggers Automáticos**: Al aceptar solicitud, se crea la conexión automáticamente
- 🚫 **Validaciones**: No se permiten solicitudes duplicadas o auto-solicitudes
- 📊 **Vistas**: Queries optimizadas para consultas comunes
- 🔍 **Índices**: Búsquedas rápidas por remitente, receptor, y estado

---

## ⚠️ Importante:

**NO** modifiques el script SQL a menos que sepas lo que haces. El sistema de triggers y políticas RLS está diseñado para funcionar en conjunto.
