# 🎨 GUÍA DE COLORES METÁLICOS YOMINERO

## ✨ Colores NO Planos - Brillantes y Realistas

Esta app usa **gradientes metálicos multicapa** inspirados en:
- 🥇 **Oro real 24K** - Color principal
- 💎 **Esmeralda** - Verde piedra preciosa
- 🪙 **Platino/Plata** - Metal brillante
- 🟤 **Bronce** - Metal cálido

---

## 📖 CÓMO USAR

### 1️⃣ **Botón con Oro Brillante**

```dart
Container(
  decoration: MetallicDecoration.gold(
    borderRadius: 12,
    withShadow: true,
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    onPressed: () {},
    child: Text('Botón Dorado'),
  ),
)
```

### 2️⃣ **Card con Esmeralda Brillante**

```dart
Container(
  decoration: MetallicDecoration.emerald(borderRadius: 16),
  padding: EdgeInsets.all(16),
  child: Text('Card Verde Esmeralda'),
)
```

### 3️⃣ **Gradiente Manual Personalizado**

```dart
Container(
  decoration: BoxDecoration(
    gradient: MetallicColors.goldShine,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: DashboardColors.goldShadow,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: YourWidget(),
)
```

### 4️⃣ **AppBar con Oro Brillante**

```dart
AppBar(
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: MetallicColors.goldMetallic,
    ),
  ),
  title: Text('Mi App'),
)
```

### 5️⃣ **FloatingActionButton Circular con Oro**

```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: MetallicColors.goldRadial, // Gradiente circular
    boxShadow: [
      BoxShadow(
        color: DashboardColors.gold.withOpacity(0.4),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: FloatingActionButton(
    backgroundColor: Colors.transparent,
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

---

## 🎨 PALETA COMPLETA DISPONIBLE

### Gradientes Lineales:
- `MetallicColors.goldShine` - Oro brillante (5 capas)
- `MetallicColors.emeraldShine` - Esmeralda cristalino
- `MetallicColors.platinumShine` - Platino pulido
- `MetallicColors.bronzeShine` - Bronce cálido
- `MetallicColors.sapphireShine` - Zafiro azul
- `MetallicColors.amethystShine` - Amatista púrpura
- `MetallicColors.rubyShine` - Rubí rojo
- `MetallicColors.aquamarineShine` - Aguamarina turquesa
- `MetallicColors.amberShine` - Ámbar naranja

### Gradientes Radiales:
- `MetallicColors.goldRadial` - Para botones circulares
- `MetallicColors.emeraldRadial` - Para avatares

### Efectos Especiales:
- `MetallicColors.goldShimmer` - Efecto de carga animado
- `MetallicColors.goldOverlay` - Para hover effects

---

## 🔥 EJEMPLOS AVANZADOS

### Tarjeta con Múltiples Capas de Brillo

```dart
Stack(
  children: [
    // Capa base con gradiente
    Container(
      decoration: BoxDecoration(
        gradient: MetallicColors.goldShine,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(20),
      child: YourContent(),
    ),
    
    // Capa de brillo superior
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    ),
  ],
)
```

### Shimmer Effect Animado

```dart
AnimatedContainer(
  duration: Duration(seconds: 2),
  decoration: BoxDecoration(
    gradient: MetallicColors.goldShimmer,
  ),
  // Animar posición del gradiente para efecto shimmer
)
```

---

## 💡 TIPS PARA COLORES BRILLANTES

1. **Usa múltiples capas** - 4-5 colores en gradiente
2. **Agrega sombras** - Hace el efecto 3D
3. **Highlights en esquinas** - Simula reflejo de luz
4. **Overlays sutiles** - Para efectos hover/pressed
5. **Combina Linear + Radial** - Para efectos complejos

---

## 🎯 COLORES POR TIPO DE POST

- **Productos** → `MetallicColors.goldShine`
- **Servicios** → `MetallicColors.amethystShine`
- **Preguntas** → `MetallicColors.amberShine`
- **Noticias** → `MetallicColors.sapphireShine`
- **Encuestas** → `MetallicColors.aquamarineShine`
- **Ofertas** → `MetallicColors.emeraldShine`
- **Comunidad** → `MetallicColors.rubyShine`
