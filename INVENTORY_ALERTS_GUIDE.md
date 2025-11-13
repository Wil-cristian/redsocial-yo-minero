# 📦 Sistema de Avisos e Items Destacados - Inventario YoMinero

## ✨ Nuevas Funcionalidades Implementadas

### 🎯 Sección de Avisos Importantes

Se ha agregado una sección horizontal con 3 categorías de avisos clave justo debajo de las tarjetas de estadísticas:

#### 1️⃣ **Próximos a Agotarse** ⚠️
- **Color**: Rojo (error)
- **Icono**: `warning_amber_rounded`
- **Contenido**: 
  - Muestra items con stock crítico (≤30% del mínimo) o bajo
  - Preview de los 3 items más críticos
  - Muestra cantidad actual vs mínimo
  - Al hacer clic, filtra la lista por status crítico

#### 2️⃣ **Favoritos** ⭐
- **Color**: Dorado (gold)
- **Icono**: `favorite`
- **Contenido**:
  - Items marcados como favoritos por el usuario
  - Preview de los 3 favoritos principales
  - Ordenados por cantidad de pedidos
  - Al hacer clic, abre modal con lista completa

#### 3️⃣ **Más Pedidos** 📈
- **Color**: Cobre oscuro (copperDark)
- **Icono**: `trending_up`
- **Contenido**:
  - Top 5 items más solicitados
  - Muestra contador de pedidos junto a cada item
  - Ordenados por `request_count` descendente
  - Al hacer clic, abre modal con top 10

---

## 🔧 Características Técnicas Implementadas

### Modelo de Datos Actualizado

**Archivo**: `lib/shared/models/inventory_item.dart`

```dart
// Nuevos campos agregados:
final bool isFavorite;          // Indica si está marcado como favorito
final int requestCount;          // Contador de veces solicitado

// Constructor actualizado con valores por defecto
isFavorite = false,
requestCount = 0,
```

### Base de Datos - Nuevas Columnas

**Archivo**: `database/add_inventory_features.sql`

```sql
-- Agregar columnas a inventory_items
ALTER TABLE public.inventory_items
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS request_count INTEGER DEFAULT 0;

-- Índices para optimización
CREATE INDEX idx_inventory_items_is_favorite 
  ON public.inventory_items(is_favorite) WHERE is_favorite = TRUE;

CREATE INDEX idx_inventory_items_request_count 
  ON public.inventory_items(request_count DESC);
```

### Servicio de Inventario Actualizado

**Archivo**: `lib/core/services/inventory_service.dart`

```dart
/// Alternar estado de favorito
Future<void> toggleFavorite(String itemId, bool isFavorite) async {
  await _client
    .from('inventory_items')
    .update({'is_favorite': !isFavorite})
    .eq('id', itemId);
}

/// Incrementar contador de pedidos
Future<void> incrementRequestCount(String itemId, int currentCount) async {
  await _client
    .from('inventory_items')
    .update({'request_count': currentCount + 1})
    .eq('id', itemId);
}
```

---

## 🎨 Componentes UI Agregados

### 1. Widget de Tarjeta de Alerta

```dart
Widget _buildAlertCard({
  required String title,
  required int count,
  required IconData icon,
  required Color color,
  required List<InventoryItem> items,
  required VoidCallback onTap,
})
```

**Características**:
- Tarjeta horizontal scrollable (280px width)
- Borde de 2px con color temático
- Header con icono, título y contador
- Preview de hasta 3 items
- Indicador de flecha para ver más
- Sombra con color temático

### 2. Modal de Items Completo

```dart
Widget _buildItemsModal({
  required String title,
  required IconData icon,
  required Color color,
  required List<InventoryItem> items,
})
```

**Características**:
- Ocupa 70% de la altura de pantalla
- Header con icono, título y botón cerrar
- Lista scrollable con tarjetas numeradas
- Muestra contador de pedidos con badge dorado
- Icono de favorito para items marcados

### 3. Botón de Favorito en Tarjetas

Cada tarjeta de inventario ahora incluye:
- Botón de corazón (favorite/favorite_border)
- Cambia de color cuando está marcado (dorado)
- Toggle instantáneo con feedback visual
- Actualización en tiempo real vía Supabase

### 4. Badge de Pedidos

En la sección de costos de cada tarjeta:
- Badge dorado con gradiente
- Icono de carrito de compras
- Contador de pedidos
- Solo visible si `requestCount > 0`

---

## 📊 Getters Agregados

```dart
// Items con stock crítico
List<InventoryItem> get _criticalItems {
  return _inventoryItems.where((item) => item.needsRestock).toList()
    ..sort((a, b) => a.quantity.compareTo(b.quantity));
}

// Items favoritos ordenados por pedidos
List<InventoryItem> get _favoriteItems {
  return _inventoryItems.where((item) => item.isFavorite).toList()
    ..sort((a, b) => b.requestCount.compareTo(a.requestCount));
}

// Items más pedidos (top 5)
List<InventoryItem> get _mostRequestedItems {
  return _inventoryItems.where((item) => item.requestCount > 0).toList()
    ..sort((a, b) => b.requestCount.compareTo(a.requestCount));
}
```

---

## 🔄 Flujo de Interacción

### Marcar como Favorito
1. Usuario hace clic en corazón en tarjeta
2. Se llama `_toggleFavorite(item)`
3. `InventoryService.toggleFavorite()` actualiza Supabase
4. SnackBar confirma la acción
5. Suscripción en tiempo real actualiza UI automáticamente
6. Tarjeta de "Favoritos" se actualiza en tiempo real

### Ver Más Items
1. Usuario hace clic en tarjeta de alerta
2. Se abre modal con lista completa
3. Modal muestra hasta 10 items ordenados
4. Para favoritos: muestra icono de corazón
5. Para más pedidos: muestra badge con contador
6. Usuario puede cerrar con X o deslizar hacia abajo

---

## 🎯 Pasos para Usar

### 1. Ejecutar SQL en Supabase
```bash
# Abrir archivo database/add_inventory_features.sql
# Copiar y ejecutar en SQL Editor de Supabase
```

### 2. Verificar Columnas
```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'inventory_items'
AND column_name IN ('is_favorite', 'request_count');
```

### 3. Ejecutar la Aplicación
```powershell
cd C:\Users\wilo\OneDrive\Desktop\redsocial-yo-minero\redsocial-yo-minero
flutter run -d chrome
```

---

## 📱 Ejemplo de Uso

### Escenario 1: Marcar Items Favoritos
```
1. Abrir Inventario
2. Ver tarjetas de items
3. Clic en corazón de "Taladro Bosch"
4. Item se marca como favorito (corazón dorado)
5. Aparece en tarjeta "Favoritos" arriba
```

### Escenario 2: Ver Próximos a Agotarse
```
1. Ver sección de avisos
2. Tarjeta roja muestra "5 items"
3. Preview muestra 3 items más críticos
4. Clic en la tarjeta
5. Lista filtra solo items con stock bajo
```

### Escenario 3: Revisar Más Pedidos
```
1. Ver tarjeta cobre "Más Pedidos"
2. Muestra top 5 con contadores
3. Clic en tarjeta
4. Modal abre con top 10 completo
5. Cada item muestra badge dorado con cantidad
```

---

## 🎨 Colores Utilizados

| Categoría | Color | Variable |
|-----------|-------|----------|
| Próximos a Agotarse | 🔴 Rojo | `AppColorsUnified.error` |
| Favoritos | 🟡 Dorado | `AppColorsUnified.gold` |
| Más Pedidos | 🟤 Cobre | `AppColorsUnified.copperDark` |
| Badge Pedidos | 🌟 Gradiente Oro | `AppColorsUnified.goldGradient` |

---

## ✅ Checklist de Implementación

- [x] Agregar campos `isFavorite` y `requestCount` al modelo
- [x] Actualizar `fromJson` y `toJson` en modelo
- [x] Crear SQL para agregar columnas e índices
- [x] Implementar `toggleFavorite()` en servicio
- [x] Implementar `incrementRequestCount()` en servicio
- [x] Crear getters para filtrar items (_criticalItems, _favoriteItems, _mostRequestedItems)
- [x] Diseñar widget `_buildAlertsSection()`
- [x] Crear tarjetas de alerta con `_buildAlertCard()`
- [x] Implementar modal completo con `_buildItemsModal()`
- [x] Agregar botón de favorito en tarjetas
- [x] Agregar badge de pedidos en tarjetas
- [x] Conectar eventos de clic con métodos
- [x] Probar sincronización en tiempo real

---

## 🚀 Próximas Mejoras Sugeridas

1. **Sincronización de Pedidos**: Incrementar automáticamente `request_count` cuando se creen movimientos tipo "salida"
2. **Notificaciones**: Alertas push cuando items favoritos lleguen a stock bajo
3. **Análisis Avanzado**: Gráficos de tendencias de pedidos en la página de reportes
4. **Filtros Rápidos**: Agregar tabs para filtrar rápidamente favoritos y más pedidos
5. **Exportación**: Botón para exportar lista de favoritos o más pedidos a Excel/PDF

---

## 📞 Soporte

Si tienes preguntas sobre la implementación:
- Revisa los archivos modificados listados arriba
- Verifica que el SQL se haya ejecutado correctamente
- Confirma que las columnas existan en Supabase
- Prueba la sincronización en tiempo real

**¡Disfruta de la nueva funcionalidad de avisos e items destacados!** 🎉
