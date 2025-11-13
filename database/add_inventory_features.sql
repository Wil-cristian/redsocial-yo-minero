-- ============================================
-- 📦 AGREGAR CARACTERÍSTICAS DE FAVORITOS Y PEDIDOS
-- Actualización de tabla inventory_items
-- ============================================

-- Agregar columnas para favoritos y contador de pedidos
ALTER TABLE public.inventory_items
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS request_count INTEGER DEFAULT 0;

-- Índice para búsquedas de favoritos
CREATE INDEX IF NOT EXISTS idx_inventory_items_is_favorite 
ON public.inventory_items(is_favorite) WHERE is_favorite = TRUE;

-- Índice para items más pedidos
CREATE INDEX IF NOT EXISTS idx_inventory_items_request_count 
ON public.inventory_items(request_count DESC);

-- Comentarios para documentación
COMMENT ON COLUMN public.inventory_items.is_favorite IS 'Indica si el item está marcado como favorito';
COMMENT ON COLUMN public.inventory_items.request_count IS 'Contador de veces que se ha solicitado el item';

-- ============================================
-- ✅ ACTUALIZACIÓN COMPLETADA
-- ============================================

-- Verificar que las columnas se agregaron correctamente
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'inventory_items'
AND column_name IN ('is_favorite', 'request_count')
ORDER BY column_name;
