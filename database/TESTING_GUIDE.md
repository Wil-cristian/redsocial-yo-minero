# Guía de Pruebas - YoMinero

## ✅ Estado del Sistema
- ✅ Servidor Flutter corriendo en puerto 5000
- ✅ Sin errores de compilación LSP
- ✅ Configuración de Supabase correcta
- ✅ Migraciones SQL aplicadas

---

## 🧪 Plan de Pruebas Completo

### 1. **Autenticación y Perfiles** 👤

#### Registro de Usuario
1. Abre la app en tu navegador
2. Crea una cuenta nueva con:
   - Nombre completo
   - Email válido
   - Contraseña segura
   - Tipo de usuario (Individual/Trabajador/Empresa)
3. **Verificar**: Deberías ser redirigido al dashboard

#### Edición de Perfil Profesional
1. Ve a tu perfil
2. Edita los nuevos campos:
   - ✅ Teléfono
   - ✅ Profesión
   - ✅ Empresa
   - ✅ Cargo
   - ✅ Sitio web
   - ✅ Ubicación (país, ciudad)
   - ✅ Fecha de nacimiento
   - ✅ Nivel de experiencia
   - ✅ Especializaciones
   - ✅ Intereses
3. Guarda los cambios
4. **Verificar**: Los datos deben persistir al recargar

---

### 2. **Sistema de Notificaciones** 🔔

#### Prueba con Dos Usuarios
1. **Usuario A**: Inicia sesión en un navegador normal
2. **Usuario B**: Inicia sesión en modo incógnito
3. **Usuario A**: Envía un mensaje a Usuario B
4. **Verificar en Usuario B**:
   - ✅ Debería aparecer una notificación inmediatamente
   - ✅ La notificación debe mostrar: "Nuevo mensaje de [Nombre A]"
   - ✅ Al hacer clic, debe redirigir a la conversación

#### Verificar RLS de Notificaciones (Seguridad)
1. Abre la consola del navegador (F12)
2. Intenta ejecutar:
```javascript
supabase.rpc('create_notification', {
  p_user_id: 'otro-usuario-id',
  p_type: 'test',
  p_title: 'Hack Test',
  p_body: 'Testing security'
})
```
3. **Verificar**: Debe fallar con error de permisos ❌
4. **Resultado esperado**: Los usuarios NO pueden crear notificaciones para otros

#### Gestión de Notificaciones
1. Ve a la sección de notificaciones
2. **Verificar**:
   - ✅ Lista de notificaciones ordenadas por fecha
   - ✅ Contador de no leídas en el icono
   - ✅ Marcar como leída funciona
   - ✅ Marcar todas como leídas funciona
   - ✅ Eliminar notificación funciona

---

### 3. **Mensajería en Tiempo Real** 💬

#### Conversaciones
1. Inicia una nueva conversación
2. **Verificar**:
   - ✅ Búsqueda de usuarios con debouncing (300ms)
   - ✅ Resultados de búsqueda aparecen mientras escribes
   - ✅ Crear conversación funciona

#### Mensajes en Tiempo Real
1. Con dos usuarios (A y B):
   - **Usuario A**: Envía mensaje
   - **Usuario B**: Debe ver el mensaje instantáneamente sin recargar
2. **Verificar**:
   - ✅ Mensajes aparecen en tiempo real
   - ✅ Scroll automático a mensajes nuevos
   - ✅ Hora de envío correcta

#### Paginación Infinita
1. Si tienes >20 conversaciones:
   - Scroll hacia abajo
   - **Verificar**: Se cargan más conversaciones automáticamente

---

### 4. **UX: Skeleton Loaders** ⏳

1. Recarga la app con conexión lenta (F12 → Network → Slow 3G)
2. **Verificar animaciones mientras carga**:
   - ✅ Productos: Tarjetas con shimmer
   - ✅ Servicios: Listado con shimmer
   - ✅ Conversaciones: Items con shimmer
   - ✅ Grupos: Cards con shimmer

---

### 5. **Dark Mode** 🌙

1. Ve a configuración o perfil
2. Activa el modo oscuro
3. **Verificar**:
   - ✅ UI cambia a tema oscuro
   - ✅ Transición suave
   - ✅ Recarga la app → debe mantener el tema oscuro (persistencia)
4. Cambia a modo claro
5. **Verificar**: Vuelve a tema claro correctamente

---

### 6. **Pull-to-Refresh** 🔄

En cada página principal, desliza hacia abajo para refrescar:

1. **Productos**: 
   - Desliza → Ver spinner → Lista se actualiza
2. **Servicios**: 
   - Desliza → Ver spinner → Lista se actualiza
3. **Grupos**: 
   - Desliza → Ver spinner → Lista se actualiza
4. **Posts (Feed)**: 
   - Desliza → Ver spinner → Feed se actualiza

---

### 7. **Manejo de Errores** ⚠️

#### Errores de Red
1. Desconecta el WiFi
2. Intenta cargar productos
3. **Verificar**:
   - ✅ Muestra `ErrorView` con icono y mensaje en español
   - ✅ Mensaje descriptivo: "Error de conexión"
   - ✅ Botón "Reintentar" visible

#### Errores de Base de Datos
1. Intenta una operación inválida (ej: crear producto sin campos requeridos)
2. **Verificar**:
   - ✅ Error capturado como `DatabaseException`
   - ✅ Mensaje en español descriptivo
   - ✅ No se rompe la app

#### Estados Vacíos
1. Ve a favoritos sin haber marcado nada
2. **Verificar**:
   - ✅ Muestra `EmptyView` con mensaje
   - ✅ Icono ilustrativo
   - ✅ Mensaje: "No tienes favoritos aún"

---

### 8. **Carga de Imágenes (CachedImage)** 🖼️

1. Navega a productos o servicios con imágenes
2. **Verificar**:
   - ✅ Placeholder mientras carga
   - ✅ Lazy loading (solo carga al hacer scroll)
   - ✅ Si falla la imagen → Icono de respaldo
   - ✅ Imágenes circulares en perfiles

---

### 9. **Funcionalidades Core** 🛠️

#### Productos
- ✅ Crear producto
- ✅ Buscar productos
- ✅ Editar producto
- ✅ Eliminar producto
- ✅ Marcar como favorito

#### Servicios
- ✅ Crear servicio
- ✅ Buscar por categoría/tags
- ✅ Editar servicio
- ✅ Eliminar servicio

#### Grupos
- ✅ Crear grupo
- ✅ Unirse a grupo
- ✅ Salir de grupo
- ✅ Ver miembros
- ✅ Contador de miembros actualizado

#### Dashboard de Métricas
- ✅ Ver proyectos por estado
- ✅ Ver transacciones
- ✅ Filtrar por período
- ✅ Gráficos actualizados

---

## 🔍 Verificación SQL en Supabase

### Verificar Función SECURITY DEFINER
En el SQL Editor de Supabase, ejecuta:

```sql
-- Ver permisos de la función create_notification
\df+ create_notification

-- Debería mostrar que EXECUTE está revocado para PUBLIC
-- Solo el owner/triggers pueden ejecutarla
```

### Verificar Políticas RLS
```sql
-- Ver políticas de notifications
SELECT * FROM pg_policies WHERE tablename = 'notifications';

-- Verificar que:
-- 1. SELECT: auth.uid() = user_id
-- 2. INSERT: auth.uid() = user_id
-- 3. UPDATE: auth.uid() = user_id
-- 4. DELETE: auth.uid() = user_id
```

### Verificar Trigger
```sql
-- Ver trigger de notificaciones
SELECT tgname, tgenabled FROM pg_trigger 
WHERE tgname = 'trigger_notify_new_message';

-- Debe estar habilitado (tgenabled = 'O')
```

---

## ✅ Checklist Final

- [ ] Autenticación funciona
- [ ] Perfiles profesionales se guardan
- [ ] Notificaciones aparecen automáticamente al recibir mensajes
- [ ] No se pueden crear notificaciones para otros usuarios (seguridad)
- [ ] Mensajes en tiempo real funcionan
- [ ] Skeleton loaders se ven mientras carga
- [ ] Dark mode funciona y persiste
- [ ] Pull-to-refresh actualiza datos
- [ ] Errores se muestran con ErrorView
- [ ] Estados vacíos se muestran con EmptyView
- [ ] Imágenes cargan con lazy loading
- [ ] Todas las funcionalidades core funcionan

---

## 🐛 Si Encuentras Problemas

1. **Error de conexión a Supabase**:
   - Verifica `.env` tiene las credenciales correctas
   - Verifica que las migraciones SQL se aplicaron

2. **Notificaciones no aparecen**:
   - Verifica el trigger `trigger_notify_new_message` está activo
   - Revisa la consola del navegador para errores
   - Verifica RLS policies en Supabase

3. **Errores de permisos**:
   - Verifica que `create_notification` tiene EXECUTE revocado
   - Confirma que las políticas RLS están correctas

4. **App no carga**:
   - Recarga con Ctrl+Shift+R (hard refresh)
   - Limpia caché del navegador
   - Verifica que el workflow está corriendo

---

## 📊 Métricas de Éxito

- ⚡ **Tiempo de carga**: <3 segundos
- 🔔 **Notificaciones**: Instantáneas (<1 segundo)
- 💬 **Mensajes en tiempo real**: <500ms
- 🎨 **UX**: Animaciones suaves, sin pantallas blancas
- 🔒 **Seguridad**: RLS previene acceso no autorizado

¡Buena suerte con las pruebas! 🚀
