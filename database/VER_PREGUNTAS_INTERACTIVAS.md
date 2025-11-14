# 🎯 Guía para Ver las Preguntas Interactivas

## 📋 Pasos para Ver los Cambios

### 1. Ejecutar Script SQL en Supabase

1. Ve a tu proyecto en [Supabase](https://supabase.com)
2. Abre el **SQL Editor** (menú lateral izquierdo)
3. Crea una nueva query
4. Copia y pega el contenido de `database/insert_test_questions.sql`
5. Ejecuta el script (botón "Run")
6. Deberías ver el mensaje: "Se insertaron 5 preguntas de prueba correctamente"

### 2. Ver las Preguntas en la App

#### Opción A: En `community_page.dart` (CON interactividad ultra-premium)
1. Ejecuta la app: `flutter run`
2. Ve a la página **"Comunidad"** (ícono de personas)
3. En los filtros superiores, selecciona **"Preguntas"**
4. Verás las 5 preguntas de prueba

#### Opción B: En `community_feed_page.dart` (sin interactividad)
1. Ve al feed de la comunidad
2. Filtra por "Preguntas"
3. Verás las preguntas pero sin los botones CTA especiales

## ✨ Características Interactivas Implementadas

### En las tarjetas de PREGUNTAS (`PostType.request`):

#### 🎨 Interactividad General:
- ✅ Hover effect con elevación -6px
- ✅ Escala animada (0.95→1.0)
- ✅ Shimmer dorado en hover
- ✅ Bordes dorados que se intensifican
- ✅ Sombras multicapa con glow

#### 💫 Componentes Animados:
- ✅ Avatar con borde dorado pulsante
- ✅ Badge de score con breathing effect
- ✅ Chips interactivos individuales (presupuesto, tags)
- ✅ Botón de like con bounce animation

#### 🎯 CTA ESPECIAL PARA PREGUNTAS:
Un contenedor destacado que aparece solo en posts de tipo "request":

**Sección Informativa:**
- 🔷 Ícono de pregunta con gradiente dorado
- 🔷 Título: "¿Tienes la respuesta?"
- 🔷 Subtítulo: "Ayuda a esta persona con tu conocimiento"

**Botón CTA Ultra-Prominente:**
- 🟡 **Gradiente dorado completo** (Amber 600 → Amber 800)
- 🟡 **Pulso continuo** (breathing 6% cada 1.8s)
- 🟡 **Hover effect**: Escala 1.03, glow intenso, sombra 24px blur
- 🟡 **Ícono animado**: Escala 1.15 en hover
- 🟡 **Texto**: "Responder Pregunta" con flecha que se desplaza
- 🟡 **Splash effect**: InkWell con color dorado

## 📊 Preguntas de Prueba Insertadas

1. **"¿Cuál es el mejor equipo para minería a pequeña escala?"**
   - Categorías: Equipos, Técnico, **Urgente**
   - Presupuesto: $5,000 USD
   - Deadline: 7 días

2. **"Documentación para permisos ambientales en minería"**
   - Categorías: Legal, Medio Ambiente, **Importante**
   - Presupuesto: $800 USD
   - Deadline: 14 días

3. **"¿Qué protocolos de seguridad son esenciales en minas subterráneas?"**
   - Categorías: Seguridad, Técnico, **Urgente**
   - Presupuesto: $1,200 USD
   - Deadline: 5 días

4. **"Interpretación de muestras de exploración - ¿Ven potencial aquí?"**
   - Categorías: Geología, Exploración, Consulta
   - Presupuesto: $2,500 USD
   - Deadline: 10 días

5. **"¿Flotación o cianuración para mineral polimetálico?"**
   - Categorías: Procesamiento, Metalurgia, Técnico
   - Presupuesto: $3,500 USD
   - Deadline: 12 días

## 🔧 Hot Reload

Si la app ya está corriendo:
1. Guarda cualquier archivo (Ctrl+S)
2. El hot reload debería aplicarse automáticamente
3. Si no funciona: presiona `r` en la terminal donde corre Flutter

## 🎬 Comportamiento Esperado

Cuando pases el mouse sobre una pregunta:
1. La tarjeta se eleva con animación suave
2. Aparece shimmer dorado moviéndose
3. El borde dorado se intensifica
4. El badge de score pulsa más rápido
5. Los chips individuales reaccionan al hover
6. El botón "Responder Pregunta" brilla intensamente

Cuando NO estés en hover:
1. El botón CTA pulsa constantemente (breathing effect)
2. Invita a hacer clic con su animación de respiración
3. El glow dorado es más sutil pero visible

## 🐛 Solución de Problemas

### No veo las preguntas:
- ✓ Verifica que ejecutaste el script SQL correctamente
- ✓ Asegúrate de estar en `community_page.dart`, NO en `community_feed_page.dart`
- ✓ Filtra por "Preguntas" en los chips superiores

### No veo los CTA interactivos:
- ✓ Verifica que estés viendo posts de `type = 'request'`
- ✓ Revisa que el hot reload se aplicó correctamente
- ✓ Intenta reiniciar la app completamente

### Errores de conexión:
- ✓ Verifica tu archivo `.env` o configuración de Supabase
- ✓ Revisa las credenciales en `lib/core/config/env_config.dart`

## 📝 Archivos Modificados

1. ✅ `lib/community_page.dart` - CTA para preguntas
2. ✅ `lib/requests_page.dart` - Interactividad para tarjetas de solicitudes
3. ✅ `database/insert_test_questions.sql` - Script de datos de prueba
4. ✅ `database/VER_PREGUNTAS_INTERACTIVAS.md` - Esta guía

## 🎨 Sistema de Colores

Los CTA usan el sistema de colores profesional:
- Base: `AppColorsUnified.gold` (#CA8A04 - Amber 600)
- Shadow: `AppColorsUnified.goldShadow` (#92400E - Amber 800)
- Bright: `AppColorsUnified.goldBright` (#FDE047 - Yellow 300)
- Highlight: `AppColorsUnified.goldHighlight` (#FEF3C7 - Amber 100)

---

**¡Disfruta de la experiencia ultra-interactiva! 🚀**
