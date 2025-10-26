# 🎨 Guía del Esquema de Colores - YoMinero

## 🔥 Esquema Principal: NARANJA-ORO-MADERA (Cofre Dorado)

### Colores Principales (USA ESTOS)

```dart
// 🔸 PRIMARIO - Naranja Vibrante
DashboardColors.primary         // #FF8C00 - Naranja principal
DashboardColors.primaryLight    // #FFAA33 - Naranja claro/glow
DashboardColors.primaryDark     // #E67E00 - Naranja oscuro

// 🟡 ACENTO - Dorado Cálido  
DashboardColors.accent          // #FFB800 - Dorado
DashboardColors.accentLight     // #FFD54F - Dorado claro
DashboardColors.accentDark      // #D4A017 - Dorado oscuro

// 🎨 GRADIENTES DE USO GENERAL
DashboardColors.primaryGradient  // Naranja → Dorado (4 colores)
DashboardColors.epicGradient     // Gradiente épico vertical (5 colores)
```

### ✅ Cómo Usar

#### Botones y Elementos Interactivos
```dart
// ✅ CORRECTO - Usa primary
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: DashboardColors.primary,
    foregroundColor: Colors.white,
  ),
)

// ❌ EVITA - No uses gold directamente
backgroundColor: DashboardColors.gold  // LEGACY
```

#### Headers y Fondos Épicos
```dart
// ✅ CORRECTO - Usa primaryGradient o epicGradient
Container(
  decoration: BoxDecoration(
    gradient: DashboardColors.primaryGradient,
  ),
)

// O para efectos más dramáticos:
Container(
  decoration: BoxDecoration(
    gradient: DashboardColors.epicGradient,
  ),
)
```

#### Badges y Elementos Premium
```dart
// ✅ CORRECTO - Combina primary y accent
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        DashboardColors.primaryLight,
        DashboardColors.primary,
        DashboardColors.accent,
      ],
    ),
  ),
)
```

### 🎯 Paleta Completa Disponible

```dart
// NARANJA VIBRANTE
DashboardColors.orange           // #FF8C00
DashboardColors.orangeBright     // #FF9500
DashboardColors.orangeDark       // #E67E00
DashboardColors.orangeGlow       // #FFAA33
DashboardColors.orangeShadow     // Con opacidad

// MADERA (Tonos Cálidos)
DashboardColors.wood             // #8B4513 - Madera
DashboardColors.woodLight        // #A0522D - Madera clara
DashboardColors.woodDark         // #654321 - Madera oscura
DashboardColors.woodGolden       // #B8860B - Madera dorada

// GRADIENTES ESPECÍFICOS
DashboardColors.orangeGradient       // Gradiente naranja 3 colores
DashboardColors.orangeFireGradient   // Gradiente fuego 5 colores
DashboardColors.woodGradient         // Gradiente madera
```

### 🚫 Colores LEGACY (Evitar en Código Nuevo)

```dart
// Estos aún funcionan pero están marcados como LEGACY
// Internamente apuntan a los nuevos colores primary/accent

DashboardColors.gold         // → primary (FF9500)
DashboardColors.goldLight    // → primaryLight (FFAA33)
DashboardColors.goldDark     // → primaryDark (E67E00)
DashboardColors.goldGradient // → primaryGradient
DashboardColors.goldShine    // → epicGradient
```

## 📋 Reglas de Uso

### 1. **Nuevo Código**
- ✅ Usa `DashboardColors.primary` y `DashboardColors.accent`
- ✅ Usa `DashboardColors.primaryGradient` para fondos
- ✅ Usa `DashboardColors.epicGradient` para efectos dramáticos
- ❌ NO uses `DashboardColors.gold` directamente

### 2. **Código Existente**
- Los colores `gold*` seguirán funcionando (compatibilidad)
- Gradualmente reemplazar con `primary`/`accent` cuando edites el código

### 3. **Texto sobre Fondos**
- Fondo `primary` o `accent` → Texto blanco (`Colors.white`)
- Fondo claro → Texto oscuro (`DashboardColors.charcoal`)

### 4. **Sombras**
```dart
// ✅ CORRECTO
BoxShadow(
  color: DashboardColors.primaryDark.withOpacity(0.3),
  blurRadius: 15,
)
```

## 🎨 Ejemplos Completos

### Header Premium
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        DashboardColors.primaryLight,
        DashboardColors.accent,
        DashboardColors.primary,
        DashboardColors.primaryDark,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  ),
)
```

### Botón de Acción
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: DashboardColors.primary,
    foregroundColor: Colors.white,
    shadowColor: DashboardColors.primaryDark.withOpacity(0.5),
  ),
)
```

### Badge Premium
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        DashboardColors.orangeBright,
        DashboardColors.orange,
        DashboardColors.orangeDark,
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: DashboardColors.orangeShadow,
        blurRadius: 12,
      ),
    ],
  ),
)
```

### Card con Fondo Sutil
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: DashboardColors.primaryLight.withOpacity(0.3),
    ),
    gradient: LinearGradient(
      colors: [
        Colors.white,
        DashboardColors.primaryLight.withOpacity(0.05),
      ],
    ),
  ),
)
```

## 🔄 Migración Rápida

Si ves esto en código existente:
```dart
backgroundColor: DashboardColors.gold
```

Cámbialo por:
```dart
backgroundColor: DashboardColors.primary
```

Y si el texto era oscuro, actualiza a blanco:
```dart
foregroundColor: Colors.white
```

---

**Resumen:** El nuevo esquema **NARANJA-ORO-MADERA** está inspirado en el cofre dorado. Usa `primary` y `accent` para consistencia en toda la app. Los colores `gold*` son legacy y se mantendrán por compatibilidad pero apuntan internamente a los nuevos valores.
