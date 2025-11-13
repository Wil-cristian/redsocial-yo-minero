-- ============================================
-- 📦 SISTEMA DE SUBCATEGORÍAS Y ESPECIFICACIONES
-- Agregar campos para tubos, tierras y peso
-- ============================================

-- Agregar nuevas columnas a inventory_items
ALTER TABLE public.inventory_items
ADD COLUMN IF NOT EXISTS subcategory TEXT,
ADD COLUMN IF NOT EXISTS specifications JSONB,
ADD COLUMN IF NOT EXISTS dimensions TEXT,
ADD COLUMN IF NOT EXISTS weight_per_unit NUMERIC(10, 2);

-- Índices para búsquedas optimizadas
CREATE INDEX IF NOT EXISTS idx_inventory_items_subcategory 
ON public.inventory_items(subcategory);

CREATE INDEX IF NOT EXISTS idx_inventory_items_specifications 
ON public.inventory_items USING GIN (specifications);

-- Comentarios para documentación
COMMENT ON COLUMN public.inventory_items.subcategory IS 'Subcategoría específica (tubo_pvc, arena, etc.)';
COMMENT ON COLUMN public.inventory_items.specifications IS 'Especificaciones técnicas en formato JSON';
COMMENT ON COLUMN public.inventory_items.dimensions IS 'Dimensiones del item (ej: "2\" x 6m" o "10m³")';
COMMENT ON COLUMN public.inventory_items.weight_per_unit IS 'Peso por unidad en kilogramos';

-- Ejemplos de especificaciones JSON por tipo:

-- TUBOS:
-- {
--   "tipo": "PVC",
--   "diametro": "2",
--   "diametro_unidad": "pulgadas",
--   "longitud": "6",
--   "longitud_unidad": "metros",
--   "espesor": "Schedule 40",
--   "presion": "150 PSI"
-- }

-- TIERRAS/AGREGADOS:
-- {
--   "tipo": "Arena gruesa",
--   "granulometria": "2-5mm",
--   "humedad": "5%",
--   "origen": "Cantera San Pedro",
--   "densidad": "1.6 ton/m³"
-- }

-- CEMENTO:
-- {
--   "tipo": "Portland Tipo I",
--   "resistencia": "42.5 MPa",
--   "presentacion": "Bolsa 42.5kg"
-- }

-- ============================================
-- ✅ ACTUALIZACIÓN COMPLETADA
-- ============================================

-- Verificar columnas agregadas
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable,
    col_description((table_schema||'.'||table_name)::regclass::oid, ordinal_position) as description
FROM information_schema.columns
WHERE table_name = 'inventory_items'
AND column_name IN ('subcategory', 'specifications', 'dimensions', 'weight_per_unit')
ORDER BY column_name;

-- Verificar índices
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'inventory_items'
AND indexname LIKE '%subcategory%' OR indexname LIKE '%specifications%'
ORDER BY indexname;
