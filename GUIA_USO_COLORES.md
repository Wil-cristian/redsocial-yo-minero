# 🎨 GUÍA DE USO: app_colors_unified.dart

## 📍 ARCHIVO ÚNICO DE COLORES

**TODO está aquí**: `lib/core/theme/app_colors_unified.dart` (575 líneas)

---

## 📋 ESTRUCTURA DEL ARCHIVO

```
app_colors_unified.dart (575 líneas)
│
├─ 🥇 ORO - Color Base (30% - Identidad)
│  ├─ gold, goldLight, goldDark, goldPure, goldWarm
│  ├─ goldGradient (5 capas)
│  ├─ goldVertical (5 capas)
│  └─ goldRadial (4 capas)
│
├─ 🧡 NARANJA - Color Acento (10% - Acción)
│  ├─ orange, orangeLight, orangeDark, orangeMedium, orangeApple
│  ├─ orangeGradient (5 capas) ← TU FAVORITO
│  ├─ orangeVertical (5 capas)
│  ├─ orangeFire (7 capas - dramático)
│  ├─ orangeRadial (4 capas)
│  └─ orangeShadow, orangeGlow
│
├─ ⚪ NEUTRAL CÁLIDO - Dominante (60% - Fondos)
│  ├─ background, backgroundAlt
│  ├─ surface, surfaceAlt, surfaceWarm
│  └─ cardBackground, divider, outline
│
├─ 🥈 PLATA - Secundario Alternativo
│  ├─ silver, silverLight, silverDark
│  ├─ silverGradient (5 capas)
│  ├─ goldSilverEpic (premium máximo)
│  └─ goldOrangeGradient (transición identidad→acción)
│
├─ ✍️ TEXTO
│  └─ textPrimary, textSecondary, textDisabled, textOnOrange, textOnGold
│
├─ ✅ ESTADOS
│  ├─ success (verde esmeralda)
│  ├─ error (rojo rubí)
│  ├─ warning (amarillo ámbar)
│  └─ info (azul zafiro)
│
├─ 💎 GEMAS PREMIUM
│  ├─ emerald + emeraldGradient (5 capas)
│  ├─ ruby + rubyGradient (5 capas)
│  ├─ sapphire + sapphireGradient (5 capas)
│  ├─ amethyst + amethystGradient (5 capas)
│  └─ diamond, bronze
│
├─ 🏠 MÓDULOS (organizados por funcionalidad)
│  ├─ Home: homeWelcomeStart, homeHeroGradient
│  ├─ Productos: productPrimary, productGradient, productBackground
│  ├─ Servicios: servicePrimary, serviceGradient, serviceBackground
│  ├─ Grupos: groupPrimary, groupGradient, groupBackground
│  ├─ Posts: postPrimary, postProductGradient, postServiceGradient
│  ├─ Mensajería: messagePrimary, messageBubbleUser, messageBubbleOther
│  ├─ Perfil: profileHeaderGradient, profileBadgeGold/Silver/Bronze
│  ├─ Empresa: companyPrimary (azul), companySecondary (#45B7D1)
│  ├─ Empleados: employeePrimary, employeeBadgeGreen/Purple/Pink
│  ├─ Métricas: metricsIncome, metricsExpense, metricsIncomeGradient
│  ├─ Notificaciones: notificationUnread, notificationBadge
│  ├─ Favoritos: favoriteActive (oro), favoriteInactive
│  └─ Menú Radial: radialButtonGradient (naranja 3 capas)
│
├─ 🎨 TIPOS DE USUARIO
│  ├─ Individual: userIndividualPrimary (naranja), userIndividualAccent (oro)
│  ├─ Worker: userWorkerPrimary (verde), userWorkerAccent (esmeralda)
│  └─ Company: userCompanyPrimary (azul), userCompanyAccent (oro)
│
├─ 🌓 DARK MODE (preparación futura)
│  └─ darkBackground, darkSurface, darkTextPrimary, darkTextSecondary
│
└─ 🎨 EXTENSIÓN DE CONTEXT
   ├─ context.colorGold, context.colorOrange
   ├─ context.gradientGold, context.gradientOrange
   ├─ context.colorSuccess, context.colorError
   └─ context.colorProduct, context.colorService, etc.
```

---

## 🎯 CÓMO MODIFICAR COLORES

### 1️⃣ Cambiar el ORO en TODA la app

**Ubicación**: Líneas 34-38

```dart
// ============================================
// 🥇 ORO - COLOR BASE (30% - SECUNDARIO)
// ============================================

// CAMBIAR AQUÍ ↓
static const Color gold = Color(0xFFD4AF37);  // ← Oro base
static const Color goldLight = Color(0xFFF4E4C1);
static const Color goldDark = Color(0xFFB8941E);
static const Color goldPure = Color(0xFFFFD700);
```

**Efecto**: Cambia automáticamente en:
- ✅ Badges premium
- ✅ Headers dorados
- ✅ Productos destacados
- ✅ Perfil (badges oro)
- ✅ Gradientes oro (5 capas)
- ✅ 30% de toda la app

---

### 2️⃣ Cambiar el NARANJA en TODA la app

**Ubicación**: Líneas 91-96

```dart
// ============================================
// 🧡 NARANJA - COLOR ACENTO (10% - ACCIÓN)
// ============================================

// CAMBIAR AQUÍ ↓
static const Color orange = Color(0xFFFF6B35);  // ← TU FAVORITO
static const Color orangeLight = Color(0xFFFFB84D);
static const Color orangeDark = Color(0xFFE06800);
static const Color orangeMedium = Color(0xFFF7931E);
```

**Efecto**: Cambia automáticamente en:
- ✅ Menú radial flotante (tu favorito)
- ✅ Todos los botones CTA
- ✅ Notificaciones
- ✅ Acciones principales
- ✅ Gradientes naranja (5-7 capas)
- ✅ 10% de toda la app

---

### 3️⃣ Cambiar FONDOS en TODA la app

**Ubicación**: Líneas 168-175

```dart
// ============================================
// 🎨 NEUTRAL CÁLIDO - COLOR DOMINANTE (60%)
// ============================================

// CAMBIAR AQUÍ ↓
static const Color background = Color(0xFFF8F5EF);  // ← Cream principal
static const Color backgroundAlt = Color(0xFFF2EEE7);
static const Color surface = Color(0xFFFFFFFF);  // Blanco cards
```

**Efecto**: Cambia automáticamente en:
- ✅ Todos los fondos de página
- ✅ Backgrounds de cards
- ✅ Superficies
- ✅ 60% de toda la app

---

### 4️⃣ Cambiar AZUL EMPRESA

**Ubicación**: Líneas 365-371

```dart
// ============================================
// 🏢 MÓDULO: EMPRESA (Complementario AZUL)
// ============================================

// CAMBIAR AQUÍ ↓
static const Color companyPrimary = Color(0xFF3B82F6);  // Azul corporativo
static const Color companySecondary = Color(0xFF45B7D1);  // ← El que usas
```

**Efecto**: Cambia automáticamente en:
- ✅ company_employees_page (6 usos)
- ✅ company_projects_page (5 usos)
- ✅ company_metrics_page (4 usos)
- ✅ Todas las páginas de empresa (37 usos totales)

---

### 5️⃣ Modificar GRADIENTES

**Ubicación**: Líneas 42-53 (oro), 100-111 (naranja)

```dart
// Gradiente ORO (5 capas)
static const LinearGradient goldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFFAF0),  // ← Cambiar highlight
    Color(0xFFF4E4C1),  // ← Cambiar brillante
    Color(0xFFD4AF37),  // ← Cambiar base
    Color(0xFFB8941E),  // ← Cambiar medio
    Color(0xFFAA8C3A),  // ← Cambiar oscuro
  ],
  stops: [0.0, 0.25, 0.5, 0.75, 1.0],  // ← Ajustar distribución
);
```

**Efecto**: Los gradientes se actualizan donde se usan:
- ✅ Badges premium
- ✅ Headers especiales
- ✅ Botones con efecto 3D

---

## 💡 EJEMPLOS PRÁCTICOS

### Probar un oro más brillante:
```dart
// Línea 34 - Cambiar:
static const Color gold = Color(0xFFFFD700);  // Oro puro (más brillante)

// Resultado: Toda la app tendrá oro más brillante
```

### Probar un naranja más intenso:
```dart
// Línea 91 - Cambiar:
static const Color orange = Color(0xFFFF5000);  // Naranja más rojo

// Resultado: Menú radial y CTAs más intensos
```

### Hacer fondos más claros:
```dart
// Línea 168 - Cambiar:
static const Color background = Color(0xFFFFFFFE);  // Casi blanco

// Resultado: Toda la app más clara y minimalista
```

### Cambiar azul empresa a verde:
```dart
// Línea 367 - Cambiar:
static const Color companySecondary = Color(0xFF10B981);  // Verde

// Resultado: 37 usos de azul → verde en páginas de empresa
```

---

## 🎨 PALETA ACTUAL (Teoría Aplicada)

### 🥇 ORO (30% - Identidad)
```
#D4AF37  ████ Oro metalizado (base)
#F4E4C1  ████ Oro brillante
#B8941E  ████ Oro oscuro
#FFD700  ████ Oro puro 24K

Gradiente 5 capas: #FFFAF0 → #F4E4C1 → #D4AF37 → #B8941E → #AA8C3A
```

### 🧡 NARANJA (10% - Acción)
```
#FF6B35  ████ Naranja vibrante (TU FAVORITO)
#FFB84D  ████ Naranja brillante
#F7931E  ████ Naranja medio
#E06800  ████ Naranja oscuro

Gradiente 5 capas: #FFB84D → #FF9500 → #FF6B35 → #F7931E → #E06800
Gradiente 7 capas FUEGO: #FFFAF0 → #FFB84D → #FFAA33 → #FF9500 → #FF6B35 → #F7931E → #E06800
```

### ⚪ NEUTRAL (60% - Dominante)
```
#F8F5EF  ████ Cream cálido (principal)
#F2EEE7  ████ Beige suave
#FFFFFF  ████ Blanco puro
```

### 🔵 AZUL EMPRESA (Complementario)
```
#45B7D1  ████ Azul turquesa (el que usas - 37 veces)
#3B82F6  ████ Azul corporativo
```

---

## ✅ VENTAJAS DE ESTE SISTEMA

1. **UN SOLO ARCHIVO** = 575 líneas con TODO
2. **Cambiar 1 línea** = actualiza TODA la app
3. **Organizado por módulos** = fácil encontrar
4. **Gradientes multicapa** = efecto 3D premium
5. **Teoría aplicada** = regla 60-30-10
6. **Context extension** = acceso rápido con `context.colorGold`

---

## 📝 RESUMEN

| Quiero cambiar... | Línea | Resultado |
|-------------------|-------|-----------|
| **Todo el oro** | 34 | Actualiza 30% de la app |
| **Todo el naranja** | 91 | Actualiza 10% (menú radial, CTAs) |
| **Fondos** | 168 | Actualiza 60% (backgrounds) |
| **Azul empresa** | 367 | Actualiza 37 usos en empresa |
| **Gradiente oro** | 42 | Actualiza badges/headers premium |
| **Gradiente naranja** | 100 | Actualiza botones/FAB |

---

## 🚀 PRÓXIMOS PASOS

1. **Probar colores** - Cambiar líneas y ver resultado
2. **Ajustar gradientes** - Modificar capas para efecto deseado
3. **Expandir paleta** - Agregar nuevos colores módulos si necesario
4. **Dark mode** - Activar cuando esté listo (ya preparado)

**TODO está en un solo lugar. Cambias aquí, actualiza toda la app.** ✨
