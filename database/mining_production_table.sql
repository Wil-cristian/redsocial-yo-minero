-- ==================================================
-- TABLA: mining_production
-- Dashboard de Producción Minera - YoMinero
-- ==================================================
-- Este script crea la tabla para el sistema de
-- producción minera con todas las métricas necesarias
-- ==================================================

CREATE TABLE IF NOT EXISTS mining_production (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Información de la zona
  zone_name TEXT NOT NULL, -- Nombre de la zona minera
  zone_coordinates JSONB, -- Coordenadas GPS de la zona (opcional)
  
  -- Información del mineral
  mineral_type TEXT NOT NULL, -- Oro, Plata, Cobre, Hierro, etc.
  tonnage DECIMAL(10, 2) NOT NULL, -- Toneladas extraídas
  purity DECIMAL(5, 2) NOT NULL CHECK (purity >= 0 AND purity <= 100), -- Pureza del mineral (0-100%)
  grade DECIMAL(10, 4) NOT NULL, -- Ley del mineral (g/t para metales preciosos)
  
  -- Información del turno
  production_date DATE NOT NULL,
  shift TEXT NOT NULL CHECK (shift IN ('morning', 'afternoon', 'night')),
  workers_count INTEGER NOT NULL DEFAULT 0,
  
  -- Estado
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
  
  -- Metadatos adicionales
  metadata JSONB DEFAULT '{}'::jsonb,
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================================================
-- ÍNDICES PARA OPTIMIZAR BÚSQUEDAS
-- ==================================================

-- Índice para búsquedas por empresa
CREATE INDEX idx_mining_production_company_id ON mining_production(company_id);

-- Índice para búsquedas por zona
CREATE INDEX idx_mining_production_zone ON mining_production(zone_name);

-- Índice para búsquedas por tipo de mineral
CREATE INDEX idx_mining_production_mineral ON mining_production(mineral_type);

-- Índice para búsquedas por fecha
CREATE INDEX idx_mining_production_date ON mining_production(production_date DESC);

-- Índice para búsquedas por turno
CREATE INDEX idx_mining_production_shift ON mining_production(shift);

-- Índice para búsquedas por estado
CREATE INDEX idx_mining_production_status ON mining_production(status);

-- Índice compuesto para consultas frecuentes (empresa + fecha)
CREATE INDEX idx_mining_production_company_date ON mining_production(company_id, production_date DESC);

-- ==================================================
-- TRIGGER PARA ACTUALIZAR updated_at
-- ==================================================

CREATE OR REPLACE FUNCTION update_mining_production_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_mining_production_timestamp
BEFORE UPDATE ON mining_production
FOR EACH ROW
EXECUTE FUNCTION update_mining_production_updated_at();

-- ==================================================
-- ROW LEVEL SECURITY (RLS)
-- ==================================================

ALTER TABLE mining_production ENABLE ROW LEVEL SECURITY;

-- Política: Las empresas solo pueden ver sus propias producciones
CREATE POLICY "Las empresas pueden ver sus propias producciones"
ON mining_production FOR SELECT
USING (
  auth.uid()::text IN (
    SELECT id::text FROM users WHERE id = mining_production.company_id
  )
  OR
  -- También permitir a empleados de la empresa ver las producciones
  auth.uid()::text IN (
    SELECT user_id::text FROM user_employees 
    WHERE company_id = mining_production.company_id
  )
);

-- Política: Las empresas pueden insertar sus propias producciones
CREATE POLICY "Las empresas pueden crear producciones"
ON mining_production FOR INSERT
WITH CHECK (
  auth.uid()::text IN (
    SELECT id::text FROM users WHERE id = mining_production.company_id
  )
);

-- Política: Las empresas pueden actualizar sus propias producciones
CREATE POLICY "Las empresas pueden actualizar sus producciones"
ON mining_production FOR UPDATE
USING (
  auth.uid()::text IN (
    SELECT id::text FROM users WHERE id = mining_production.company_id
  )
);

-- Política: Las empresas pueden eliminar sus propias producciones
CREATE POLICY "Las empresas pueden eliminar sus producciones"
ON mining_production FOR DELETE
USING (
  auth.uid()::text IN (
    SELECT id::text FROM users WHERE id = mining_production.company_id
  )
);

-- ==================================================
-- VISTA PARA ESTADÍSTICAS AGREGADAS
-- ==================================================

CREATE OR REPLACE VIEW mining_production_stats AS
SELECT 
  company_id,
  zone_name,
  mineral_type,
  production_date,
  shift,
  COUNT(*) as total_records,
  SUM(tonnage) as total_tonnage,
  AVG(purity) as avg_purity,
  AVG(grade) as avg_grade,
  SUM(workers_count) as total_workers,
  MAX(tonnage) as max_tonnage,
  MIN(tonnage) as min_tonnage
FROM mining_production
WHERE status IN ('active', 'completed')
GROUP BY company_id, zone_name, mineral_type, production_date, shift;

-- ==================================================
-- DATOS DE EJEMPLO (OPCIONAL - PARA TESTING)
-- ==================================================

-- Insertar producciones de ejemplo para la empresa de prueba
-- Nota: Cambia el company_id por el ID real de tu empresa de prueba

DO $$
DECLARE
  test_company_id UUID;
BEGIN
  -- Obtener el ID de la empresa de prueba (empresa@test.com)
  SELECT id INTO test_company_id FROM users WHERE email = 'empresa@test.com' LIMIT 1;
  
  IF test_company_id IS NOT NULL THEN
    -- Producción de Oro - Zona Norte
    INSERT INTO mining_production (
      company_id, zone_name, mineral_type, tonnage, purity, grade,
      production_date, shift, workers_count, status, notes
    ) VALUES
    (test_company_id, 'Zona Norte', 'Oro', 45.50, 85.00, 12.50, CURRENT_DATE, 'morning', 25, 'completed', 'Producción excelente'),
    (test_company_id, 'Zona Norte', 'Oro', 38.20, 82.00, 11.80, CURRENT_DATE - 1, 'afternoon', 22, 'completed', 'Buen rendimiento'),
    (test_company_id, 'Zona Norte', 'Oro', 52.00, 88.00, 13.20, CURRENT_DATE - 2, 'morning', 28, 'completed', 'Mejor día del mes'),
    
    -- Producción de Plata - Zona Sur
    (test_company_id, 'Zona Sur', 'Plata', 120.00, 92.00, 850.00, CURRENT_DATE, 'afternoon', 30, 'active', 'En proceso'),
    (test_company_id, 'Zona Sur', 'Plata', 115.80, 90.00, 820.00, CURRENT_DATE - 1, 'night', 28, 'completed', 'Turno nocturno'),
    (test_company_id, 'Zona Sur', 'Plata', 125.50, 93.00, 870.00, CURRENT_DATE - 2, 'morning', 32, 'completed', 'Alta pureza'),
    
    -- Producción de Cobre - Zona Este
    (test_company_id, 'Zona Este', 'Cobre', 380.00, 78.00, 2.80, CURRENT_DATE - 1, 'night', 40, 'completed', 'Gran volumen'),
    (test_company_id, 'Zona Este', 'Cobre', 365.00, 76.00, 2.65, CURRENT_DATE - 2, 'afternoon', 38, 'completed', 'Producción estándar'),
    (test_company_id, 'Zona Este', 'Cobre', 395.00, 80.00, 2.95, CURRENT_DATE - 3, 'morning', 42, 'completed', 'Máxima capacidad'),
    
    -- Producción de Hierro - Zona Oeste
    (test_company_id, 'Zona Oeste', 'Hierro', 850.00, 65.00, 45.00, CURRENT_DATE - 1, 'morning', 50, 'completed', 'Alto volumen'),
    (test_company_id, 'Zona Oeste', 'Hierro', 820.00, 63.00, 42.00, CURRENT_DATE - 2, 'afternoon', 48, 'completed', 'Producción regular'),
    
    -- Producción de Zinc - Zona Central
    (test_company_id, 'Zona Central', 'Zinc', 215.00, 72.00, 8.50, CURRENT_DATE, 'morning', 35, 'active', 'En progreso'),
    (test_company_id, 'Zona Central', 'Zinc', 198.00, 70.00, 8.20, CURRENT_DATE - 1, 'night', 33, 'completed', 'Turno completo');
    
    RAISE NOTICE 'Datos de ejemplo insertados correctamente para la empresa de prueba';
  ELSE
    RAISE NOTICE 'No se encontró la empresa de prueba (empresa@test.com)';
  END IF;
END $$;

-- ==================================================
-- FUNCIONES ÚTILES
-- ==================================================

-- Función para calcular valor estimado de producción
CREATE OR REPLACE FUNCTION calculate_production_value(
  p_tonnage DECIMAL,
  p_purity DECIMAL,
  p_grade DECIMAL
) RETURNS DECIMAL AS $$
BEGIN
  RETURN p_tonnage * (p_purity / 100) * p_grade;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Función para obtener el top de producciones por zona
CREATE OR REPLACE FUNCTION get_top_production_zones(
  p_company_id UUID,
  p_limit INTEGER DEFAULT 5
) RETURNS TABLE (
  zone_name TEXT,
  total_tonnage DECIMAL,
  avg_purity DECIMAL,
  production_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mp.zone_name,
    SUM(mp.tonnage)::DECIMAL as total_tonnage,
    AVG(mp.purity)::DECIMAL as avg_purity,
    COUNT(*)::BIGINT as production_count
  FROM mining_production mp
  WHERE mp.company_id = p_company_id
    AND mp.status = 'completed'
  GROUP BY mp.zone_name
  ORDER BY total_tonnage DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ==================================================
-- COMENTARIOS EN LA TABLA
-- ==================================================

COMMENT ON TABLE mining_production IS 'Registro de producción minera por zona, turno y tipo de mineral';
COMMENT ON COLUMN mining_production.zone_name IS 'Nombre de la zona minera donde se realizó la extracción';
COMMENT ON COLUMN mining_production.mineral_type IS 'Tipo de mineral extraído (Oro, Plata, Cobre, etc.)';
COMMENT ON COLUMN mining_production.tonnage IS 'Cantidad de toneladas extraídas';
COMMENT ON COLUMN mining_production.purity IS 'Pureza del mineral extraído (porcentaje 0-100)';
COMMENT ON COLUMN mining_production.grade IS 'Ley del mineral (g/t para metales preciosos)';
COMMENT ON COLUMN mining_production.shift IS 'Turno de trabajo: morning, afternoon, night';

-- ==================================================
-- ¡LISTO! TABLA CREADA EXITOSAMENTE
-- ==================================================

-- Verificar que todo se creó correctamente
SELECT 'Tabla mining_production creada exitosamente' as status;
SELECT COUNT(*) as registros_ejemplo FROM mining_production;
