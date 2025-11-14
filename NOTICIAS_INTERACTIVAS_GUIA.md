# 📰 Guía: Noticias Interactivas en YoMinero

## ✅ Implementación Completada

### 🎨 Mejoras Visuales
- **Reducción de dorado**: El CTA de preguntas ahora usa un diseño más sutil con fondo gris claro y botón dorado simple
- **Nuevo CTA para noticias**: Diseño con azul corporativo que invita a compartir y guardar noticias
- **Consistencia**: Ambos CTAs mantienen el mismo estilo visual pero con colores apropiados a su contexto

### 🔌 Conexión con Supabase

La página ya está conectada a Supabase mediante el `PostRepository`. Las noticias se filtran automáticamente cuando el usuario selecciona la pestaña "Noticias" (filtro #4).

**Flujo de datos:**
```
CommunityFeedPage → PostRepository → Supabase posts table
                  ↓
          Filtro: type = 'news'
                  ↓
          Renderiza con CTA interactivo
```

### 📊 Datos de Prueba

Se creó el script `database/insert_test_news.sql` con **6 noticias realistas** del sector minero:

1. **Precio del cobre**: Alcanza máximos históricos ($4.50/lb)
2. **Tecnología sustentable**: Startup reduce 60% consumo de agua
3. **Regulaciones ambientales**: Nuevas normas entran en vigor 2026
4. **Descubrimiento de litio**: Yacimiento en Atacama con 2M toneladas
5. **Capacitación**: Programa de minería 4.0 con 5,000 cupos
6. **Acuerdo comercial**: Reducción 35% aranceles en Asia

**Características de las noticias:**
- Títulos atractivos y profesionales
- Contenido extenso con detalles técnicos
- Tags relevantes del sector minero
- Fuentes y autores ficticios pero realistas
- Imágenes de Unsplash relacionadas
- Métricas de engagement (likes/comentarios)
- Fechas escalonadas (2h a 3 días atrás)

## 🚀 Cómo Ejecutar

### Paso 1: Agregar Columnas a la Tabla Posts

**IMPORTANTE**: Ejecutar PRIMERO este script para agregar las columnas necesarias.

1. Ve a tu **Dashboard de Supabase** → [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto `yominero`
3. Click en **SQL Editor** en el menú lateral
4. Click en **New query**
5. Copia y pega el contenido de `database/add_news_columns.sql`
6. Click en **Run** (Ctrl+Enter)
7. Verás la confirmación de que se agregaron las columnas

### Paso 2: Insertar Noticias de Prueba

1. En el mismo **SQL Editor**
2. Click en **New query**
3. Copia y pega el contenido de `database/insert_test_news.sql`
4. Click en **Run** (Ctrl+Enter)
5. Verás el mensaje de confirmación con el conteo de noticias

### Paso 2: Hot Reload en la App

Desde el terminal de VS Code:

```powershell
# Si la app ya está corriendo:
r  # Presiona 'r' para hot reload

# Si no está corriendo:
cd c:\Users\wilo\OneDrive\Desktop\redsocial-yo-minero\redsocial-yo-minero
flutter run
```

1. En la app, ve a la pestaña **Comunidad**
2. Selecciona el filtro **"Noticias"** (4º filtro)
3. Verás las 6 noticias con su CTA interactivo
4. Cada noticia muestra:
   - Badge azul "Noticia"
   - Fuente y autor
   - Contenido completo
   - Botones de like, comentar, compartir
   - **CTA especial** con opciones "Compartir" y "Guardar"

## 🎯 Funcionalidades del CTA de Noticias

### Diseño Visual
- Fondo gris claro con borde sutil
- Ícono de megáfono con fondo azul claro
- Texto motivacional: "¿Te pareció útil esta noticia?"
- Dos botones lado a lado:
  - **Compartir** (azul corporativo)
  - **Guardar** (gris claro)

### Comportamiento
```dart
// Al presionar "Compartir"
onTap: () {
  debugPrint('Compartir noticia: ${post.id}');
  // TODO: Implementar share sheet nativo
}

// Al presionar "Guardar"
onTap: () {
  debugPrint('Guardar noticia: ${post.id}');
  // TODO: Agregar a favoritos del usuario
}
```

## 📝 Comparación: Preguntas vs Noticias

| Aspecto | Preguntas | Noticias |
|---------|-----------|----------|
| Color principal | Dorado | Azul corporativo |
| Ícono | `question_answer_rounded` | `campaign_rounded` |
| CTA primario | "Responder Pregunta" | "Compartir" |
| CTA secundario | - | "Guardar" |
| Mensaje | "¿Tienes la respuesta?" | "¿Te pareció útil?" |
| Propósito | Incentivar respuestas | Incentivar difusión |

## 🔍 Verificación en la Base de Datos

```sql
-- Contar noticias
SELECT COUNT(*) FROM posts WHERE type = 'news';

-- Ver noticias con detalles
SELECT 
  title,
  news_source,
  news_author,
  likes,
  comments,
  DATE_TRUNC('minute', created_at) as fecha
FROM posts 
WHERE type = 'news'
ORDER BY created_at DESC;

-- Verificar tags más usados
SELECT 
  UNNEST(tags) as tag,
  COUNT(*) as frecuencia
FROM posts 
WHERE type = 'news'
GROUP BY tag
ORDER BY frecuencia DESC;
```

## 🎨 Personalización

Si deseas ajustar el diseño del CTA de noticias, edita en `community_feed_page.dart` (línea ~633):

```dart
// Cambiar color del botón "Compartir"
color: AppColorsUnified.companyBlue  // ← Cambiar aquí

// Cambiar texto del CTA
'¿Te pareció útil esta noticia?'  // ← Personalizar mensaje

// Agregar más botones
Row(
  children: [
    // Botón 1: Compartir
    // Botón 2: Guardar
    // Botón 3: Tu botón personalizado ← Agregar aquí
  ],
)
```

## 🐛 Troubleshooting

### Las noticias no aparecen
1. Verifica que ejecutaste el SQL correctamente
2. Revisa que el filtro esté en "Noticias" (no "Todos")
3. Haz pull-to-refresh en la lista
4. Verifica logs: `debugPrint('❌ Error cargando posts: $e');`

### El CTA no se muestra
1. Confirma que el post tiene `type = 'news'`
2. Verifica que `PostType.news` existe en el enum
3. Revisa que no haya errores de compilación

### Botones no responden
1. Los TODOs en `onTap` solo imprimen en consola por ahora
2. Para implementar funcionalidad real, conecta con:
   - Sistema de favoritos (guardar)
   - Share sheet nativo (compartir)

## 📚 Próximos Pasos

1. **Implementar funcionalidad de guardar**: Tabla `saved_posts` en Supabase
2. **Implementar share sheet**: Plugin `share_plus` de Flutter
3. **Agregar vista detallada**: Página dedicada para leer noticia completa
4. **Notificaciones**: Alertar cuando se publiquen noticias importantes
5. **Filtros avanzados**: Por fuente, fecha, categoría, tags

---

**✨ Resultado Final**: Noticias interactivas con diseño profesional, conexión a Supabase y datos de prueba realistas del sector minero.
