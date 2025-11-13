-- ============================================
-- 📦 SISTEMA DE INVENTARIO - YoMinero
-- Tablas para gestión completa de inventario empresarial
-- ============================================

-- 1️⃣ TABLA: inventory_items
-- Almacena todos los items del inventario de las empresas
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('herramienta', 'equipo', 'material', 'repuesto', 'consumible', 'seguridad')),
    quantity NUMERIC(10, 2) NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'unidades',
    min_stock NUMERIC(10, 2) NOT NULL DEFAULT 0,
    location TEXT NOT NULL,
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    supplier TEXT,
    cost NUMERIC(10, 2),
    status TEXT CHECK (status IN ('disponible', 'bajo', 'critico', 'agotado')),
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2️⃣ TABLA: inventory_movements
-- Registra todos los movimientos (entradas, salidas, ajustes, etc.)
CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('entrada', 'salida', 'ajuste', 'transferencia', 'devolucion', 'merma')),
    quantity NUMERIC(10, 2) NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responsible_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 📊 ÍNDICES PARA OPTIMIZAR CONSULTAS
-- ============================================

-- Índice para búsquedas por empresa
CREATE INDEX IF NOT EXISTS idx_inventory_items_company_id 
ON public.inventory_items(company_id);

-- Índice para filtros por categoría
CREATE INDEX IF NOT EXISTS idx_inventory_items_category 
ON public.inventory_items(category);

-- Índice para filtros por estado
CREATE INDEX IF NOT EXISTS idx_inventory_items_status 
ON public.inventory_items(status);

-- Índice para búsquedas por ubicación
CREATE INDEX IF NOT EXISTS idx_inventory_items_location 
ON public.inventory_items(location);

-- Índice para movimientos por item
CREATE INDEX IF NOT EXISTS idx_inventory_movements_item_id 
ON public.inventory_movements(item_id);

-- Índice para movimientos por tipo
CREATE INDEX IF NOT EXISTS idx_inventory_movements_type 
ON public.inventory_movements(type);

-- Índice para consultas por fecha
CREATE INDEX IF NOT EXISTS idx_inventory_movements_date 
ON public.inventory_movements(date DESC);

-- ============================================
-- ⚡ FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_inventory_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS trigger_update_inventory_items_timestamp ON public.inventory_items;
CREATE TRIGGER trigger_update_inventory_items_timestamp
    BEFORE UPDATE ON public.inventory_items
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_items_updated_at();

-- Función para actualizar last_updated cuando hay movimientos
CREATE OR REPLACE FUNCTION update_inventory_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.inventory_items
    SET last_updated = NEW.date
    WHERE id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar last_updated al crear movimiento
DROP TRIGGER IF EXISTS trigger_update_inventory_last_updated ON public.inventory_movements;
CREATE TRIGGER trigger_update_inventory_last_updated
    AFTER INSERT ON public.inventory_movements
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_last_updated();

-- Función para actualizar cantidad automáticamente con movimientos
CREATE OR REPLACE FUNCTION update_inventory_quantity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.inventory_items
    SET quantity = quantity + NEW.quantity
    WHERE id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar cantidad al crear movimiento
DROP TRIGGER IF EXISTS trigger_update_inventory_quantity ON public.inventory_movements;
CREATE TRIGGER trigger_update_inventory_quantity
    AFTER INSERT ON public.inventory_movements
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_quantity();

-- Función para calcular estado automáticamente
CREATE OR REPLACE FUNCTION calculate_inventory_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity <= 0 THEN
        NEW.status := 'agotado';
    ELSIF NEW.quantity <= (NEW.min_stock * 0.3) THEN
        NEW.status := 'critico';
    ELSIF NEW.quantity <= NEW.min_stock THEN
        NEW.status := 'bajo';
    ELSE
        NEW.status := 'disponible';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para calcular estado antes de insertar/actualizar
DROP TRIGGER IF EXISTS trigger_calculate_inventory_status ON public.inventory_items;
CREATE TRIGGER trigger_calculate_inventory_status
    BEFORE INSERT OR UPDATE OF quantity, min_stock ON public.inventory_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_inventory_status();

-- ============================================
-- 🔒 POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS en ambas tablas
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;

-- 🔓 POLÍTICA 1: Las empresas pueden ver su propio inventario
DROP POLICY IF EXISTS "Companies can view own inventory" ON public.inventory_items;
CREATE POLICY "Companies can view own inventory"
    ON public.inventory_items
    FOR SELECT
    USING (
        auth.uid() = company_id
        OR 
        -- Empleados pueden ver el inventario de su empresa
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.account_type = 'worker'
            AND (users.organization_info->>'companyId')::UUID = inventory_items.company_id
        )
    );

-- 🔓 POLÍTICA 2: Las empresas pueden insertar en su propio inventario
DROP POLICY IF EXISTS "Companies can insert own inventory" ON public.inventory_items;
CREATE POLICY "Companies can insert own inventory"
    ON public.inventory_items
    FOR INSERT
    WITH CHECK (auth.uid() = company_id);

-- 🔓 POLÍTICA 3: Las empresas pueden actualizar su propio inventario
DROP POLICY IF EXISTS "Companies can update own inventory" ON public.inventory_items;
CREATE POLICY "Companies can update own inventory"
    ON public.inventory_items
    FOR UPDATE
    USING (
        auth.uid() = company_id
        OR 
        -- Empleados pueden actualizar el inventario de su empresa
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.account_type = 'worker'
            AND (users.organization_info->>'companyId')::UUID = inventory_items.company_id
        )
    );

-- 🔓 POLÍTICA 4: Las empresas pueden eliminar su propio inventario
DROP POLICY IF EXISTS "Companies can delete own inventory" ON public.inventory_items;
CREATE POLICY "Companies can delete own inventory"
    ON public.inventory_items
    FOR DELETE
    USING (auth.uid() = company_id);

-- 🔓 POLÍTICA 5: Ver movimientos del inventario propio
DROP POLICY IF EXISTS "View own inventory movements" ON public.inventory_movements;
CREATE POLICY "View own inventory movements"
    ON public.inventory_movements
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.inventory_items
            WHERE inventory_items.id = inventory_movements.item_id
            AND (
                inventory_items.company_id = auth.uid()
                OR
                EXISTS (
                    SELECT 1 FROM public.users
                    WHERE users.id = auth.uid()
                    AND users.account_type = 'worker'
                    AND (users.organization_info->>'companyId')::UUID = inventory_items.company_id
                )
            )
        )
    );

-- 🔓 POLÍTICA 6: Crear movimientos en inventario propio
DROP POLICY IF EXISTS "Insert own inventory movements" ON public.inventory_movements;
CREATE POLICY "Insert own inventory movements"
    ON public.inventory_movements
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.inventory_items
            WHERE inventory_items.id = inventory_movements.item_id
            AND (
                inventory_items.company_id = auth.uid()
                OR
                EXISTS (
                    SELECT 1 FROM public.users
                    WHERE users.id = auth.uid()
                    AND users.account_type = 'worker'
                    AND (users.organization_info->>'companyId')::UUID = inventory_items.company_id
                )
            )
        )
    );

-- ============================================
-- 📝 DATOS DE PRUEBA (OPCIONAL - Comentado)
-- Descomenta si quieres datos de ejemplo
-- ============================================

/*
-- Insertar items de inventario de ejemplo
INSERT INTO public.inventory_items (company_id, name, category, quantity, unit, min_stock, location, supplier, cost, description)
VALUES 
    -- Asume que tienes un company_id válido
    ('TU_COMPANY_ID_AQUI', 'Taladro Percutor Bosch GSB 20-2', 'herramienta', 8, 'unidades', 5, 'Almacén Central', 'Ferretería Industrial', 250.00, 'Taladro percutor profesional de alta potencia'),
    ('TU_COMPANY_ID_AQUI', 'Casco de Seguridad MSA V-Gard', 'seguridad', 45, 'unidades', 30, 'Almacén Seguridad', 'MSA Safety', 28.50, 'Casco industrial con certificación ANSI Z89.1'),
    ('TU_COMPANY_ID_AQUI', 'Cemento Portland Tipo I', 'material', 850, 'sacos', 500, 'Bodega Materiales', 'Cementos Pacasmayo', 18.20, 'Cemento de alta resistencia 42.5kg por saco'),
    ('TU_COMPANY_ID_AQUI', 'Filtro de Aire Caterpillar 1R-0750', 'repuesto', 12, 'unidades', 15, 'Almacén Repuestos', 'Caterpillar', 45.80, 'Filtro de aire para maquinaria pesada CAT'),
    ('TU_COMPANY_ID_AQUI', 'Excavadora Hidráulica CAT 320D', 'equipo', 3, 'unidades', 2, 'Patio Maquinaria', 'Caterpillar', 120000.00, 'Excavadora de 20 toneladas para minería'),
    ('TU_COMPANY_ID_AQUI', 'Guantes de Cuero Reforzado', 'seguridad', 180, 'pares', 100, 'Almacén Seguridad', 'Ansell', 8.50, 'Guantes de trabajo resistentes al corte'),
    ('TU_COMPANY_ID_AQUI', 'Combustible Diesel', 'consumible', 5000, 'litros', 2000, 'Tanque Principal', 'Petroperú', 1.25, 'Diesel 2 para maquinaria pesada'),
    ('TU_COMPANY_ID_AQUI', 'Aceite Hidráulico Shell Tellus S2 M68', 'consumible', 150, 'litros', 200, 'Almacén Lubricantes', 'Shell', 6.50, 'Aceite hidráulico premium para equipos');

-- Insertar movimientos de ejemplo
INSERT INTO public.inventory_movements (item_id, type, quantity, responsible_user_id, reason)
SELECT 
    id,
    'entrada',
    quantity,
    company_id,
    'Stock inicial'
FROM public.inventory_items
WHERE company_id = 'TU_COMPANY_ID_AQUI';
*/

-- ============================================
-- ✅ SCRIPT COMPLETADO
-- ============================================

-- Verificar que las tablas se crearon correctamente
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN ('inventory_items', 'inventory_movements')
ORDER BY table_name;

-- Verificar triggers
SELECT 
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('inventory_items', 'inventory_movements')
ORDER BY event_object_table, trigger_name;

-- Verificar políticas RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE tablename IN ('inventory_items', 'inventory_movements')
ORDER BY tablename, policyname;
